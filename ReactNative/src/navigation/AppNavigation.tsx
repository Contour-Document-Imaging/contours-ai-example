import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { navigationRef } from './RootNavigation';
import MainAppStack from './MainStack';

const AppNavigation: React.FC = () => {
  
  return (
    <NavigationContainer ref={navigationRef}>
      <MainAppStack />
    </NavigationContainer>
  );
};

export default React.memo(AppNavigation);
