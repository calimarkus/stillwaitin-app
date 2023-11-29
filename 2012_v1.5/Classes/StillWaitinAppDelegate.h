//
//  StillWaitinAppDelegate.h
//  StillWaitin
//
//  Created by devmob on 22.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "ListViewController.h"
#import "SettingsViewController.h"

@interface StillWaitinAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate>
{
	UINavigationController* mNavController;
	
    UIWindow* mWindow;
	
    UILocalNotification* mReceivedLocalNotification;
	
	NSDate* mEnteredForegroundDate;
}

- (void) handleLocalNotification: (UILocalNotification*) localNotification;

//void uncaughtExceptionHandler(NSException *exception);

@end