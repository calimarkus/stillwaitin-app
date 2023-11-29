//
//  LocalNotificationHandler.h
//  StillWaitin
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalNotificationHandler : NSObject <
UNUserNotificationCenterDelegate
>

- (instancetype)initWithMainNavigationController:(UINavigationController *)mainNavigationController;

@end

NS_ASSUME_NONNULL_END
