
import React from 'react';
import { useState } from 'react';
import { StyleSheet, View, Text, TouchableOpacity, Image } from 'react-native';
import { startContourSDK, onContourClosed, onEventCaptured  } from 'contour-ai-sdk';

export default function App() {
  const [frontImageUri, setFrontImageUri] = useState<string>('');
  const [rearImageUri, setRearImageUri] = useState<string>('');

  const startSDK = (checkSide: string) => {
    startContourSDK(checkSide, '<CLIENT_ID>', 'both', false, updateState);
  }

  onContourClosed(() => {
    console.log('SDK closed')
  });

  onEventCaptured((eventCaptured: string) => {
    console.log(eventCaptured)
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
        <Text style={styles.checkSideLabel}>Front Check</Text>
        <TouchableOpacity style={styles.placeholderContainer}
          onPress={() => {
            startSDK('front');
          }}>
          {frontImageUri && <Image
            style={styles.imageStyle}
            resizeMode="contain"
            source={{ uri: frontImageUri }} />}

        </TouchableOpacity>
        <Text style={styles.checkSideLabel}>Rear Check</Text>
        <TouchableOpacity style={styles.placeholderContainer}
          onPress={() => {
            startSDK('back');
          }}>
          {rearImageUri && <Image
            style={styles.imageStyle}
            resizeMode="contain"
            source={{ uri: rearImageUri }} />}
        </TouchableOpacity>
      </View>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  placeholderContainer: {
    height: 200,
    backgroundColor: 'gray',
    margin: 16,
    justifyContent: 'center', // Center content vertically
    alignItems: 'center', // Center content horizontally
  },
  checkSideLabel: {
    color: 'black',
    textAlign: 'center',
    padding: 10,
    marginTop: 50,
  },
  imageStyle: {
    width: '100%', // Optional: Ensure the image fits within the container
    height: '100%', // Optional: Adjust the height based on your needs
  },
});
