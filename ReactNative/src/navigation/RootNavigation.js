import { createNavigationContainerRef } from '@react-navigation/native';

export const navigationRef = createNavigationContainerRef();

export function navigate(routeName, routeParams) {
  if (navigationRef.isReady()) {
   
  }
}
