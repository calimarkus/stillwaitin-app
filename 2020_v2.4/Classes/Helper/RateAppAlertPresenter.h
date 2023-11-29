//
//  RateAppAlertPresenter.h
//  StillWaitin
//

#import <UIKit/UIKit.h>


@interface RateAppAlertPresenter : NSObject

+ (instancetype)sharedInstance;

- (void)bumpAppStartCounts;
- (NSUInteger)appStartCountForCurrentVersion;
- (NSUInteger)appStartCountTotal;

- (void)presentAlertWithMessage:(NSString*)message
             fromViewController:(UIViewController*)viewController;
- (void)presentStoreProductViewControllerFromViewController:(UIViewController*)viewController;

@end
