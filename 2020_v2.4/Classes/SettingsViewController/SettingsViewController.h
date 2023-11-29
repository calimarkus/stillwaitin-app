//
//  SettingsViewController.h
//  StillWaitin
//

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

@end
