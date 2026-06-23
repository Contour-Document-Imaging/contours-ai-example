import React from 'react';
import {createMaterialTopTabNavigator} from '@react-navigation/material-top-tabs';
import {Pressable, SafeAreaView, StyleSheet, Text, View} from 'react-native';
import {TabsLabel} from '../constants/constants';
import ScanPassport from './ScanPassport';
import ScanCheck from './ScanCheck';
import ScanID from './ScanID';
import SelfieCapture from './SelfieCapture';

const Tab = createMaterialTopTabNavigator();

function BottomTabs({state, navigation}: any) {
  return (
    <View pointerEvents="box-none" style={styles.tabBarPosition}>
      <View style={styles.tabBar}>
        {state.routes.map((route: any, index: number) => {
          const focused = state.index === index;

          return (
            <Pressable
              key={route.key}
              accessibilityRole="tab"
              accessibilityState={focused ? {selected: true} : {}}
              style={[styles.tabButton, focused && styles.tabButtonActive]}
              onPress={() => navigation.navigate(route.name)}>
              <Text
                numberOfLines={1}
                adjustsFontSizeToFit
                style={[
                  styles.tabButtonText,
                  focused && styles.tabButtonTextActive,
                ]}>
                {route.name}
              </Text>
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

function renderBottomTabs(props: any) {
  return <BottomTabs {...props} />;
}

export default function Home() {
  return (
    <SafeAreaView style={styles.safeArea}>
      <Tab.Navigator
        initialRouteName={TabsLabel.Check}
        tabBar={renderBottomTabs}
        screenOptions={{
          sceneStyle: styles.scene,
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
  safeArea: {
    flex: 1,
    backgroundColor: '#d8e8ef',
  },
  scene: {
    backgroundColor: '#d8e8ef',
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
