//
//  LocalNotificationHandler.m
//  StillWaitin
//

#import "LocalNotificationHandler.h"

#import "DetailViewController.h"
#import "RealmEntryStorage.h"

@implementation LocalNotificationHandler {
  UINavigationController *_mainNavigationController;
}

- (instancetype)initWithMainNavigationController:(UINavigationController *)mainNavigationController {
  self = [super init];
  if (self) {
    _mainNavigationController = mainNavigationController;
  }
  return self;
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)notificationResponse
         withCompletionHandler:(nonnull void (^)(void))completionHandler {
  NSString *const entryID = notificationResponse.notification.request.identifier;
  NSLog(@"localNotificationReceived - with entryId: %@", entryID);

  RealmEntry *const notificationEntry = [[RealmEntryStorage sharedStorage] entryForEntryID:entryID];

  if (notificationEntry) {
    NSLog(@"Will show details for notification entry");
    DetailViewController* detailViewController = [[DetailViewController alloc] init];
    [detailViewController setRealmEntry:notificationEntry];

    // hide any modals (e.g. Settings or iPad details)
    if (_mainNavigationController.topViewController.presentedViewController) {
      [_mainNavigationController.topViewController dismissViewControllerAnimated:YES completion:nil];
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      [_mainNavigationController setViewControllers:@[_mainNavigationController.viewControllers.firstObject, detailViewController]
                                           animated:YES];
    } else {
      // dismiss entry VC
      if (_mainNavigationController.viewControllers.count > 1) {
        [_mainNavigationController setViewControllers:@[_mainNavigationController.viewControllers.firstObject]
                                             animated:YES];
      }

      // present details
      UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
      navController.navigationBar.translucent = NO;
      navController.modalPresentationStyle = UIModalPresentationFormSheet;
      [_mainNavigationController.topViewController presentViewController:navController animated:YES completion:nil];
    }
  } else {
    NSLog(@"Could not find entry for entryId: %@", entryID);
  }
}

@end
