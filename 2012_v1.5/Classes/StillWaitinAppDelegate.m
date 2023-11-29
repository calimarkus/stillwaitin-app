//
//  StillWaitinAppDelegate.m
//  StillWaitin
//
//  Created by devmob on 22.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "StillWaitinAppDelegate.h"

#import "RateAppAlert.h"
#import "PasswordViewController.h"


void uncaughtExceptionHandler(NSException *exception);

@implementation StillWaitinAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	LogInfo(@"didFinishLaunchingWithOptions: %@", launchOptions);
	
	// Create window
	mWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	// Add first view controller
	// Show list view	
	SettingsViewController* settingsViewController = [[SettingsViewController alloc] initWithFrame: CGRectMake(0.0, kSTATUS_BAR_HEIGHT, mWindow.bounds.size.width, mWindow.bounds.size.height-kSTATUS_BAR_HEIGHT)];
	ListViewController* listViewController = [[ListViewController alloc] initWithFrame:CGRectMake(0.0, kSTATUS_BAR_HEIGHT, mWindow.bounds.size.width, mWindow.bounds.size.height-kSTATUS_BAR_HEIGHT)];
	settingsViewController.listViewController = listViewController;
	
	mNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	[mNavController pushViewController: listViewController animated: NO];
	mNavController.navigationBarHidden = YES;
	
	[mWindow setRootViewController:mNavController];
    [mWindow makeKeyAndVisible];
	
	[listViewController release];
	[settingsViewController release];
	
	// Show Password View
	[PasswordViewController showOnViewController: mNavController.topViewController animationsEnabled: YES animateIn: NO];
	
	// check for local notification
	if (&UIApplicationLaunchOptionsLocalNotificationKey)
	{
		UILocalNotification* localNotification = (UILocalNotification*)[launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
		if (localNotification != nil)
		{
			[self handleLocalNotification: localNotification];
		}
	}
	
	return YES;
}

- (void)dealloc
{
	[mEnteredForegroundDate release];
	[mNavController release];
    [mWindow release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark application state

- (void)applicationDidBecomeActive:(UIApplication *)application
{	
	// Show Popup, if App is started the 20th time.
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSNumber* num = [defaults objectForKey: kKEY_APP_START_COUNT];
	if (num == nil) {
		num = [NSNumber numberWithInt: 0];
	}
	int count = [num intValue] + 1;
	[defaults setValue: [NSNumber numberWithInt: count] forKey: kKEY_APP_START_COUNT];
	
	if (count == 20)
	{
		[RateAppAlert showWithMessageKey:@"keyRateInfoText"];
	}
}


- (void)applicationWillResignActive:(UIApplication *)application
{	
	// Show password view
	[PasswordViewController showOnViewController: mNavController.topViewController animationsEnabled: NO animateIn: NO];
}


- (void) applicationDidEnterBackground:(UIApplication *)application
{
	// reset animation
	[PasswordViewController showOnViewController: mNavController.topViewController animationsEnabled: NO animateIn: NO];
	PasswordViewController* passwordViewController = (PasswordViewController*)mNavController.topViewController.modalViewController;
	[passwordViewController resetAnimations];
}


- (void) applicationWillEnterForeground:(UIApplication *)application
{	
	// Animate passwordview
	if (mNavController.topViewController.modalViewController != nil)
	{
		PasswordViewController* passwordViewController = (PasswordViewController*)mNavController.topViewController.modalViewController;
		[passwordViewController resetAnimations];
		[passwordViewController viewDidAppear: NO];
	}
	
	[mEnteredForegroundDate release];
	mEnteredForegroundDate = [[NSDate alloc] init];
	
	[mNavController.topViewController viewWillAppear: NO];
}

- (void) applicationWillTerminate:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -
#pragma mark Local Notification

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{	
	mReceivedLocalNotification = [notification retain];
	
	// if currently showing settings, switch back to list
	if ([mNavController.viewControllers count] == 1)
	{
		// show list
		SettingsViewController* settingsViewController = (SettingsViewController*)[mNavController.viewControllers objectAtIndex: 0];
		[settingsViewController showListView];
	}
	
	// don't show alert, handle notification instantly
	// this is needed, because if app is in background and local notification is shown, this method will
	// be called instead of application did finish launching with options, although the popup was already presented
	CGFloat secondsSinceAppStart = [[NSDate date] timeIntervalSinceDate: mEnteredForegroundDate];
	if (mEnteredForegroundDate != nil && secondsSinceAppStart < 0.75)
	{
		[self handleLocalNotification: notification];
		return;
	}
	else
	{
	}
	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"keyNotification", nil)
														message: notification.alertBody
													   delegate: self
											  cancelButtonTitle: NSLocalizedString(@"keyCancel", nil)
											  otherButtonTitles: NSLocalizedString(@"keyOk", nil), nil];
	[alertView show];
	[alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1 && mReceivedLocalNotification != nil)
	{
		[self handleLocalNotification: [[mReceivedLocalNotification copy] autorelease]];
	}
	else
	{
		// if entry should not be shown
		if ([mNavController.topViewController class] == [ListViewController class])
		{
			ListViewController* listViewController = (ListViewController*)mNavController.topViewController;
			[listViewController reloadData];
		}
	}

	[mReceivedLocalNotification release];
	mReceivedLocalNotification = nil;
}

- (void)handleLocalNotification:(UILocalNotification*)localNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SWLocalNotificationReceived" object:nil userInfo:[NSDictionary dictionaryWithObject:localNotification forKey:@"notification"]];
}

@end
