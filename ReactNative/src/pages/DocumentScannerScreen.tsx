import React, {useCallback, useEffect, useRef, useState} from 'react';
import {
  AppState,
  AppStateStatus,
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions,
} from 'react-native';
import {
  ContourModel,
  onContourClosed,
  onEventCaptured,
  onSelfieCaptured,
  startContour,
} from 'contour-ai-sdk';

const CLIENT_ID = '<CLIENT_ID>';
const POWERED_BY_TEXT = 'Powered by React Native';

type PreviewSide = 'front' | 'back' | 'frontFaceOnly';

type PreviewConfig = {
  key: PreviewSide;
  label: string;
  emptyLabel: string;
};

type DocumentScannerScreenProps = {
  title: string;
  description: string;
  documentType: string;
  previews: PreviewConfig[];
  selfie?: boolean;
};

export default function DocumentScannerScreen({
  title,
  description,
  documentType,
  previews,
  selfie = false,
}: DocumentScannerScreenProps) {
  const [frontImageUri, setFrontImageUri] = useState('');
  const [backImageUri, setBackImageUri] = useState('');
  const [statusMessage, setStatusMessage] = useState('Preparing scanner...');
  const scanInProgressRef = useRef(false);
  const appStateRef = useRef(AppState.currentState);
  const {width} = useWindowDimensions();
  const useSingleColumn = width < 420 || selfie;

  const updateStatus = useCallback((message: string) => {
    setStatusMessage(message);
  }, []);

  const handleContourClosed = useCallback(() => {
    scanInProgressRef.current = false;
    updateStatus('Scanner closed. Tap a preview to scan again.');
    console.log('SDK closed');
  }, [updateStatus]);

  const registerScannerCallbacks = useCallback(() => {
    onContourClosed(() => {
      handleContourClosed();
    });

    onEventCaptured((eventCaptured: string) => {
      console.log(eventCaptured);
    });

    onSelfieCaptured((selfieCapture: any) => {
      const selfieUri = selfieCapture.selfieUri;
      if (selfieUri) {
        setFrontImageUri(selfieUri);
        scanInProgressRef.current = false;
        updateStatus('Selfie captured. Tap it to scan again.');
      }
    });
  }, [handleContourClosed, updateStatus]);

  useEffect(() => {
    updateStatus('Tap a preview to start scanning.');
    registerScannerCallbacks();

    const subscription = AppState.addEventListener(
      'change',
      (nextAppState: AppStateStatus) => {
        const previousAppState = appStateRef.current;
        appStateRef.current = nextAppState;

        if (
          scanInProgressRef.current &&
          previousAppState.match(/inactive|background/) &&
          nextAppState === 'active'
        ) {
          handleContourClosed();
        }
      },
    );

    return () => {
      subscription.remove();
    };
  }, [handleContourClosed, registerScannerCallbacks, updateStatus]);

  const onCaptured = (event: any) => {
    const croppedFrontUri = event.croppedFrontUri;
    const croppedRearUri = event.croppedRearUri;

    if (croppedFrontUri) {
      setFrontImageUri(croppedFrontUri);
    }

    if (croppedRearUri) {
      setBackImageUri(croppedRearUri);
    }

    if (croppedFrontUri || croppedRearUri) {
      scanInProgressRef.current = false;
      updateStatus('Preview captured. Tap it to scan again.');
    }
  };

  const startSDK = (capturingSide: PreviewSide) => {
    scanInProgressRef.current = true;
    updateStatus('Opening scanner...');
    registerScannerCallbacks();

    const contoursModel: ContourModel = {
      clientId: CLIENT_ID,
      captureType: 'both',
      enableMultipleCapturing: false,
      type: documentType,
      capturingSide,
    };

    startContour(contoursModel, onCaptured);
  };

  const getImageUri = (side: PreviewSide) =>
    side === 'back' ? backImageUri : frontImageUri;

  return (
    <ScrollView
      bounces={false}
      contentContainerStyle={styles.screen}
      style={styles.scrollView}>
      <View style={styles.heroCard}>
        <Text style={styles.eyebrow}>Identity Verification</Text>
        <Text style={styles.versionMeta}>{POWERED_BY_TEXT}</Text>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.description}>{description}</Text>
        <Text style={styles.statusMessage}>{statusMessage}</Text>

        <View
          style={[
            styles.previewGrid,
            useSingleColumn && styles.previewGridSingle,
          ]}>
          {previews.map(preview => {
            const imageUri = getImageUri(preview.key);

            return (
              <Pressable
                key={preview.key}
                accessibilityRole="button"
                accessibilityLabel={preview.label}
                style={[
                  styles.previewTile,
                  useSingleColumn && styles.previewTileSingle,
                ]}
                onPress={() => startSDK(preview.key)}>
                <Text style={styles.previewLabel}>{preview.label}</Text>
                <View
                  style={[
                    styles.previewImageWrap,
                    selfie && styles.selfieImageWrap,
                    imageUri && styles.previewImageWrapActive,
                  ]}>
                  {imageUri ? (
                    <Image
                      resizeMode="contain"
                      source={{uri: imageUri}}
                      style={styles.imageStyle}
                    />
                  ) : (
                    <Text style={styles.previewEmpty}>
                      {preview.emptyLabel}
                    </Text>
                  )}
                </View>
              </Pressable>
            );
          })}
        </View>
      </View>
    </ScrollView>
  );
}

const colors = {
  bgBottom: '#d8e8ef',
  cardBg: '#fffcf8',
  cardBorder: 'rgba(47, 71, 87, 0.12)',
  textStrong: '#183642',
  textMuted: '#5f7782',
  accent: '#0f766e',
  accentSoft: '#b9ebe1',
};

const styles = StyleSheet.create({
  scrollView: {
    flex: 1,
    backgroundColor: colors.bgBottom,
  },
  screen: {
    flexGrow: 1,
    alignItems: 'center',
    justifyContent: 'flex-start',
    paddingHorizontal: 24,
    paddingTop: 32,
    paddingBottom: 104,
    backgroundColor: colors.bgBottom,
  },
  heroCard: {
    width: '100%',
    maxWidth: 420,
    paddingHorizontal: 24,
    paddingTop: 28,
    paddingBottom: 24,
    borderWidth: 1,
    borderColor: colors.cardBorder,
    borderRadius: 28,
    backgroundColor: colors.cardBg,
    shadowColor: colors.textStrong,
    shadowOffset: {width: 0, height: 24},
    shadowOpacity: 0.16,
    shadowRadius: 30,
    elevation: 10,
  },
  eyebrow: {
    color: colors.accent,
    fontSize: 13,
    fontWeight: '700',
    letterSpacing: 1.8,
    textTransform: 'uppercase',
  },
  versionMeta: {
    marginTop: 6,
    marginBottom: 14,
    color: colors.textMuted,
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.5,
  },
  title: {
    color: colors.textStrong,
    fontSize: 34,
    fontWeight: '800',
    lineHeight: 37,
  },
  description: {
    marginTop: 14,
    color: colors.textMuted,
    fontSize: 15,
    lineHeight: 24,
  },
  statusMessage: {
    minHeight: 22,
    marginTop: 20,
    color: colors.textMuted,
    fontSize: 14,
    lineHeight: 21,
  },
  previewGrid: {
    marginTop: 18,
    flexDirection: 'row',
    gap: 12,
  },
  previewGridSingle: {
    flexDirection: 'column',
    alignItems: 'stretch',
  },
  previewTile: {
    flex: 1,
    minWidth: 0,
  },
  previewTileSingle: {
    flex: 0,
    width: '100%',
  },
  previewImageWrap: {
    height: 220,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: 'rgba(24, 54, 66, 0.14)',
    borderRadius: 12,
    backgroundColor: '#edf8f6',
    shadowColor: colors.textStrong,
    shadowOffset: {width: 0, height: 12},
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  selfieImageWrap: {
    alignSelf: 'flex-start',
    width: 220,
    height: 220,
  },
  previewImageWrapActive: {
    borderColor: 'rgba(15, 118, 110, 0.28)',
    backgroundColor: '#ffffff',
  },
  imageStyle: {
    width: '100%',
    height: '100%',
    backgroundColor: '#ffffff',
  },
  previewEmpty: {
    paddingHorizontal: 10,
    color: colors.textMuted,
    fontSize: 13,
    fontWeight: '700',
    textAlign: 'center',
  },
  previewLabel: {
    marginBottom: 8,
    color: colors.textStrong,
    fontSize: 13,
    fontWeight: '700',
  },
});
