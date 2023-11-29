//
//  RootViewController.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

@protocol ListViewController;

NS_ASSUME_NONNULL_BEGIN

@interface RootViewController : UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithListViewController:(UIViewController<ListViewController> *)listViewController NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
