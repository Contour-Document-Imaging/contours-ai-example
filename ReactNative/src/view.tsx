import React from 'react';
import {
  Image,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
  useWindowDimensions,
} from 'react-native';
import {
  DocumentConfig,
  DocumentType,
  PreviewSide,
} from './scannerConfig';

const POWERED_BY_TEXT = 'Powered by React Native';

type ViewProps = {
  activeDocumentType: DocumentType;
  config: DocumentConfig;
  getImageUri: (side: PreviewSide) => string;
  onSelectDocumentType: (documentType: DocumentType) => void;
  onStartScan: (side: PreviewSide) => void;
  statusMessage: string;
};

const tabs: Array<{label: string; value: DocumentType}> = [
  {label: 'Check', value: 'check'},
  {label: 'ID', value: 'id'},
  {label: 'Passport', value: 'passport'},
  {label: 'Selfie', value: 'selfie'},
];

export default function ViewScreen({
  activeDocumentType,
  config,
  getImageUri,
  onSelectDocumentType,
  onStartScan,
  statusMessage,
}: ViewProps) {
  const {width} = useWindowDimensions();
  const useSingleColumn = width < 420 || Boolean(config.selfie);

  return (
    <View style={styles.safeArea}>
      <ScrollView
        bounces={false}
        contentContainerStyle={styles.screen}
        style={styles.scrollView}>
        <View style={styles.heroCard}>
          <Text style={styles.title}>{config.title}</Text>
          <Text style={styles.versionMeta}>{POWERED_BY_TEXT}</Text>
          <Text style={styles.description}>{config.description}</Text>
          <Text style={styles.statusMessage}>{statusMessage}</Text>

          <View
            style={[
              styles.previewGrid,
              useSingleColumn && styles.previewGridSingle,
            ]}>
            {config.items.map(preview => {
              const imageUri = getImageUri(preview.documentCaptureSide);

              return (
                <Pressable
                  key={preview.documentCaptureSide}
                  accessibilityRole="button"
                  accessibilityLabel={preview.label}
                  style={[
                    styles.previewTile,
                    useSingleColumn && styles.previewTileSingle,
                  ]}
                  onPress={() => onStartScan(preview.documentCaptureSide)}>
                  <Text style={styles.previewLabel}>{preview.label}</Text>
                  <View
                    style={[
                      styles.previewImageWrap,
                      config.selfie && styles.selfieImageWrap,
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

      <View pointerEvents="box-none" style={styles.tabBarPosition}>
        <View style={styles.tabBar}>
          {tabs.map(tab => {
            const focused = activeDocumentType === tab.value;

            return (
              <Pressable
                key={tab.value}
                accessibilityRole="tab"
                accessibilityState={focused ? {selected: true} : {}}
                style={[styles.tabButton, focused && styles.tabButtonActive]}
                onPress={() => onSelectDocumentType(tab.value)}>
                <Text
                  adjustsFontSizeToFit
                  numberOfLines={1}
                  style={[
                    styles.tabButtonText,
                    focused && styles.tabButtonTextActive,
                  ]}>
                  {tab.label}
                </Text>
              </Pressable>
            );
          })}
        </View>
      </View>
    </View>
  );
}

const colors = {
  bgBottom: '#d8e8ef',
  cardBg: '#fffcf8',
  cardBorder: 'rgba(47, 71, 87, 0.12)',
  textStrong: '#183642',
  textMuted: '#5f7782',
  accent: '#0f766e',
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.bgBottom,
  },
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
  versionMeta: {
    marginTop: 8,
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
  tabBarPosition: {
    position: 'absolute',
    right: 16,
    bottom: 16,
    left: 16,
    zIndex: 20,
    alignSelf: 'center',
    alignItems: 'center',
  },
  tabBar: {
    width: '100%',
    maxWidth: 420,
    minHeight: 64,
    padding: 8,
    flexDirection: 'row',
    gap: 8,
    borderWidth: 1,
    borderColor: 'rgba(24, 54, 66, 0.14)',
    borderRadius: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.96)',
    shadowColor: '#183642',
    shadowOffset: {width: 0, height: 18},
    shadowOpacity: 0.18,
    shadowRadius: 24,
    elevation: 12,
  },
  tabButton: {
    flex: 1,
    minHeight: 46,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 14,
    overflow: 'hidden',
  },
  tabButtonActive: {
    backgroundColor: '#183642',
  },
  tabButtonText: {
    color: '#5f7782',
    fontSize: 14,
    fontWeight: '800',
  },
  tabButtonTextActive: {
    color: '#ffffff',
  },
});
