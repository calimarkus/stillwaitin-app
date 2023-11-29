//
//  LocalNotificationCenter.m
//
//  Created by devmob on 15.11.10.
//

#import "LocalNotificationCenter.h"

@interface LocalNotificationCenter (private)
- (void) checkApplicationInstance;
@end


static LocalNotificationCenter* sharedInstance = nil;

@implementation LocalNotificationCenter

/*
 *	Singleton creation
 *
 *	@returns the static shared instance
 *
 */
+ (LocalNotificationCenter*)sharedInstance
{
	if (nil == sharedInstance)
	{
		sharedInstance = [[LocalNotificationCenter alloc] init];
	}
	
	return sharedInstance;
}

#pragma mark -
#pragma mark memory management

- (void) dealloc
{	
	[super dealloc];
}

#pragma mark -
#pragma mark scheduling

/*
 *	Schedule a local notification. Required parameters are 'fireDate'.
 *
 *	@param alertBody the alert body to show
 *	@param iconBadgeNumber the number to show on app icon, which has to be greater than -1
 *	@param soundName the file name of the sound
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *	@returns the newly created local notification or nil, if registration failed
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithAlertBody:(NSString*)alertBody andIconBadgeNumber:(NSInteger)iconBadgeNumber andSoundName:(NSString*)soundName andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone andUserInfo: (NSDictionary*) userInfo
{	
	if (nil == fireDate)
		return NO;
	
	Class UI_LocalNotification = NSClassFromString(@"UILocalNotification");
	
	if (UI_LocalNotification == nil) {
		return nil;
	}
	
	UILocalNotification* localNotification = [[UI_LocalNotification alloc] init];
	localNotification.fireDate = fireDate;
	localNotification.timeZone = timeZone;
	localNotification.alertBody = alertBody;
	localNotification.soundName = soundName;
	localNotification.applicationIconBadgeNumber = iconBadgeNumber;
	localNotification.repeatInterval = 0;
	localNotification.repeatCalendar = nil;
	localNotification.userInfo = userInfo;
	
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	
	return [localNotification autorelease];
}

/*
 *	Schedule a local notification with alert body only. Required parameters are 'alertBody' and 'fireDate'.
 *
 *	@param alertBody the alert body to show
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *	@returns the newly created local notification or nil, if registration failed
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithAlertBody:(NSString*)alertBody andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone
{
	if (nil == alertBody)
		return NO;
	
	UILocalNotification* localNotification = [self scheduleLocalNotificationWithAlertBody: alertBody
																	   andIconBadgeNumber: 0
																			 andSoundName: nil
																			  andFireDate: fireDate
																			  andTimeZone: timeZone
																			  andUserInfo: nil];
	
	return localNotification;
}

/*
 *	Schedule a local notification with sound only. Required parameters are 'soundName' and 'fireDate'.
 *
 *	@param soundName the file name of the sound
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *	@returns the newly created local notification or nil, if registration failed
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithSoundName:(NSString*)soundName andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone;
{
	if (nil == soundName)
		return NO;
	
	UILocalNotification* localNotification = [self scheduleLocalNotificationWithAlertBody: nil
																	   andIconBadgeNumber: 0
																			 andSoundName: soundName
																			  andFireDate: fireDate
																			  andTimeZone: timeZone
																			  andUserInfo: nil];
	
	return localNotification;
}

/*
 *	Schedule a local notification with icon badge number only. Required parameters are 'iconBadgeNumber' and 'fireDate'.
 *
 *	@param iconBadgeNumber the number to show on app icon, which has to be greater than -1
 *	@param fireDate the fire date when the local notification shows up
 *	@param timeZone the time zone defines the behaviour of time zone objects
 *	@returns the newly created local notification or nil, if registration failed
 *	@throws exception if no application instance is set
 *
 */
- (UILocalNotification*) scheduleLocalNotificationWithIconBadgeNumber:(NSInteger)iconBadgeNumber andFireDate:(NSDate*)fireDate andTimeZone:(NSTimeZone*)timeZone
{
	if (0 > iconBadgeNumber)
		return NO;
	
	UILocalNotification* localNotification = [self scheduleLocalNotificationWithAlertBody: nil
																	   andIconBadgeNumber: iconBadgeNumber
																			 andSoundName: nil
																			  andFireDate: fireDate
																			  andTimeZone: timeZone
																			  andUserInfo: nil];
	
	return localNotification;
}

/*
 *	Cancel all scheduled local notifications
 *
 */
- (void) cancelAllLocalNotifications
{	
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
