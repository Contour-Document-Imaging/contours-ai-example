import React from 'react';
import { createMaterialTopTabNavigator } from '@react-navigation/material-top-tabs';
import { SafeAreaView, StyleSheet } from 'react-native';
import { TabsLabel } from '../constants/constants';
import ScanPassport from './ScanPassport';
import ScanCheck from './ScanCheck';
import ScanID from './ScanID';
import SelfieCapture from './SelfieCapture';

const Tab = createMaterialTopTabNavigator();

export default function Home() {
  return (
    <SafeAreaView style={styles.safeArea}>
      <Tab.Navigator
        initialRouteName={TabsLabel.Check}
        screenOptions={{
          tabBarLabelStyle: { fontSize: 14 },
          tabBarIndicatorStyle: {
            height: 0,
          },
        }}>
        <Tab.Screen name={TabsLabel.Check} children={() => <ScanCheck />} />
        <Tab.Screen name={TabsLabel.ID} children={() => <ScanID />} />
        <Tab.Screen name={TabsLabel.Passport} children={() => <ScanPassport />} />
       <Tab.Screen name={TabsLabel.Selfie} children={() => <SelfieCapture />} />
      </Tab.Navigator>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },
});
