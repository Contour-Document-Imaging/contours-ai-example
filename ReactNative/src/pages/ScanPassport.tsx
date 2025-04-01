import React from 'react';
import { useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity, Image } from 'react-native';
import { startContourSDK, onContourClosed, onEventCaptured } from 'contour-ai-sdk';

export default function ScanPassport() {
  const [frontImageUri, setFrontImageUri] = useState<string>('');

  const startSDK = (checkSide: string) => {
    startContourSDK(checkSide, '<CLIENT_ID>', 'both', false, updateState);
  };

  onContourClosed(() => {
    console.log('SDK closed');
  });

  onEventCaptured((eventCaptured: string) => {
    console.log(eventCaptured);
  });

  const updateState = (e: any) => {
    const frontUri = e.frontUri;
    if (frontUri) {
      setFrontImageUri(frontUri);
    }
  };

  return (
    <>
      <View style={styles.container}>
        <Text style={styles.checkSideLabel}>Passport</Text>
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
