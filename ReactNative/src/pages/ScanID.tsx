import React from 'react';
import { useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity, Image } from 'react-native';
import { startContour, onContourClosed, ContourModel, onEventCaptured } from 'contour-ai-sdk';

export default function ScanID() {
  const [frontImageUri, setFrontImageUri] = useState<string>('');
  const [rearImageUri, setRearImageUri] = useState<string>('');

  const startSDK = (checkSide: string) => {
    const contoursModel: ContourModel = {
      clientId: '<CLIENT_ID>',
      captureType: 'both',
      enableMultipleCapturing: false,
      type: 'id',
      capturingSide: checkSide
    };
    startContour(contoursModel, updateState);
  };

  onContourClosed(() => {
    console.log('SDK closed');
  });

  onEventCaptured((eventCaptured: string) => {
    console.log(eventCaptured);
  });

  const updateState = (e: any) => {
    const frontUri = e.frontUri;
    const rearUri = e.rearUri;
    if (frontUri) {
      setFrontImageUri(frontUri);
    }
    if (rearUri) {
      setRearImageUri(rearUri);
    }
  };

  return (
    <>
      <View style={styles.container}>
        <Text style={styles.checkSideLabel}>Front ID</Text>
        <TouchableOpacity
          style={styles.placeholderContainer}
          onPress={() => {
            startSDK('front');
          }}>
          {frontImageUri && (
            <Image
              style={styles.imageStyle}
              resizeMode="contain"
              source={{uri: frontImageUri}}
            />
          )}
        </TouchableOpacity>
        <Text style={styles.checkSideLabel}>Rear ID</Text>
        <TouchableOpacity
          style={styles.placeholderContainer}
          onPress={() => {
            startSDK('back');
          }}>
          {rearImageUri && (
            <Image
              style={styles.imageStyle}
              resizeMode="contain"
              source={{uri: rearImageUri}}
            />
          )}
        </TouchableOpacity>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f0f0',
  },
  placeholderContainer: {
    height: 200,
    backgroundColor: 'gray',
    margin: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkSideLabel: {
    color: 'black',
    textAlign: 'center',
    padding: 10,
    marginTop: 50,
  },
  imageStyle: {
    width: '100%',
    height: '100%',
  },
});
