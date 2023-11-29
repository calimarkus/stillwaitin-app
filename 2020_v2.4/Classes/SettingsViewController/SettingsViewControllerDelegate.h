//
//  SettingsViewControllerDelegate.h
//  StillWaitin
//

@class SettingsViewController;
@protocol ListViewController;

@protocol SettingsViewControllerDelegate
- (void)settingsViewControllerDidChangeSettings:(SettingsViewController *)settingsViewController;
- (void)settingsViewController:(SettingsViewController *)settingsViewController
 providedNewListViewController:(UIViewController<ListViewController> *)listViewController;
@end

