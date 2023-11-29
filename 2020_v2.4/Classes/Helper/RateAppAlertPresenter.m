//
//  RateAppAlertPresenter.m
//  StillWaitin
//

#import "RateAppAlertPresenter.h"
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>

NSString *const TotalAppStartCountKey = @"kKEY_TOTAL_APP_START_COUNT";

@implementation RateAppAlertPresenter

+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[self alloc] init];
  });
  return _sharedInstance;
}

- (NSString *)_versionSpecificAppStartCountKey {
  return [NSString stringWithFormat:
          @"kKEY_APP_START_COUNT_V%@",
          [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
}

- (void)bumpAppStartCounts {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setInteger:1 + [self appStartCountForCurrentVersion] forKey:[self _versionSpecificAppStartCountKey]];
  [userDefaults setInteger:1 + [self appStartCountTotal] forKey:TotalAppStartCountKey];
  [userDefaults synchronize];
}
- (NSUInteger)appStartCountForCurrentVersion {
  return [[NSUserDefaults standardUserDefaults] integerForKey:[self _versionSpecificAppStartCountKey]];
}

- (NSUInteger)appStartCountTotal {
  return [[NSUserDefaults standardUserDefaults] integerForKey:TotalAppStartCountKey];
}

- (void)presentAlertWithMessage:(NSString*)message
             fromViewController:(UIViewController*)viewController {
  NSString *formattedMessage = message = [message
                                          stringByReplacingOccurrencesOfString:@"#version#"
                                          withString:[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];

  __weak typeof(self) blockSelf = self;
  [UIAlertController presentAlertFromViewController:viewController
                                          withTitle:NSLocalizedString(@"keyRateApp", nil)
                                            message:formattedMessage
                                            buttons:@[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyRate",nil)],
                                                      [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]
                                      buttonHandler:^(UIAlertAction *action) {
    if (action.style != UIAlertActionStyleCancel) {
      [blockSelf presentStoreProductViewControllerFromViewController:viewController];
    }
  }];
}

- (void)presentStoreProductViewControllerFromViewController:(UIViewController*)viewController {
  // used to present SKStoreProductViewController
}


@end
