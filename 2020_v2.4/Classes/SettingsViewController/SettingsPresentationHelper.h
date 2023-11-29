//
//  SettingsPresentationHelper.h
//  StillWaitin
//

#import <Foundation/Foundation.h>

@protocol SettingsViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SettingsPresentationHelper : NSObject

- (void)setupForSourceViewController:(UIViewController<SettingsViewControllerDelegate> *)sourceViewController;

@end

NS_ASSUME_NONNULL_END
