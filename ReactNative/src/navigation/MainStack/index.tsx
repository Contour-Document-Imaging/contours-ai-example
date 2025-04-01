import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import Home from '../../pages/Home';

const Stack = createStackNavigator();

const MainAppStack = () => {
  return (
    <Stack.Navigator
      initialRouteName={'Home'}
      screenOptions={{ gestureEnabled: false, headerShown: false }}>
      <Stack.Screen name={'Home'} component={Home} />
    </Stack.Navigator>
  );
};
export default MainAppStack;
