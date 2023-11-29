//
//  LocalNotificationCenter.m
//
//  Created by devmob on 15.11.10.
//
//	This util helps to manage local notifications. The local notification center is a wrapper for the local notification features of iOS since 4.
//
//	Case: Fire body alert in one minute
//	
//		NSDate* fireDate = [[NSDate date] dateByAddingTimeInterval: 60.0];
//		[[LocalNotificationCenter sharedInstance] setApplication: application];
//		BOOL success = [[LocalNotificationCenter sharedInstance] scheduleLocalNotificationWithAlertBody:@"Mi alert" andFireDate:fireDate andTimeZone:nil];
//
//	Case: Fire icon badge number update to number 5
//
//		BOOL success = [[LocalNotificationCenter sharedInstance] scheduleLocalNotificationWithIconBadgeNumber:5 andFireDate:fireDate andTimeZone:nil];
//

#import <Foundation/Foundation.h>


@interface LocalNotificationCenter : NSObject

/*
 *	Singleton creation
 *
 *	@returns the static shared instance
 *
 */
+ (LocalNotificationCenter*) sharedInstance;

/*
 *	Schedule a local notification. Required parameters are 'fireDate'.
 *
 *	@param alertBody the alert body to show
 *	@param iconBadgeNumber the number to show on app icon, which has to be greater than -1
 *	@param soundName the file name of the sound
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *
 *	@returns the newly created local notification or nil, if registration failed
 *
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithAlertBody:(NSString*)alertBody andIconBadgeNumber:(NSInteger)iconBadgeNumber andSoundName:(NSString*)soundName andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone andUserInfo: (NSDictionary*) userInfo __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 *	Schedule a local notification with alert body only. Required parameters are 'alertBody' and 'fireDate'.
 *
 *	@param alertBody the alert body to show
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *
 *	@returns the newly created local notification or nil, if registration failed
 *
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithAlertBody:(NSString*)alertBody andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 *	Schedule a local notification with sound only. Required parameters are 'soundName' and 'fireDate'.
 *
 *	@param soundName the file name of the sound
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *
 *	@returns the newly created local notification or nil, if registration failed
 *
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithSoundName:(NSString*)soundName andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 *	Schedule a local notification with icon badge number only. Required parameters are 'iconBadgeNumber' and 'fireDate'.
 *
 *	@param iconBadgeNumber the number to show on app icon, which has to be greater than -1
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *
 *	@returns the newly created local notification or nil, if registration failed
 *
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithIconBadgeNumber:(NSInteger)iconBadgeNumber andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

/*
 *	Cancel all scheduled local notifications
 *
 */
- (void) cancelAllLocalNotifications __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@end