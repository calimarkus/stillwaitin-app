//
//  PasswordViewController.h
//  StillWaitin
//

extern NSString *const SWSilenceTimeIntervalUserDefaultsKey;

@class PasswordViewController;

typedef void(^PasswordViewControllerShouldDismissBlock)(PasswordViewController *passwordViewController);

 @interface PasswordViewController : UIViewController

@property (nonatomic, assign) BOOL shouldEvaluateOnWillAppear;
@property (nonatomic, copy) PasswordViewControllerShouldDismissBlock shouldDismissBlock;

+ (BOOL)shouldEnterPassword;

@end
