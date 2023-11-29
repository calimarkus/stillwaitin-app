//
//  RootViewController.m
//  StillWaitin
//

#import "RootViewController.h"

#import "ListTotalSumBar.h"
#import "ListViewController.h"
#import "RateAppAlertPresenter.h"
#import "SWSettings.h"
#import "SettingsPresentationHelper.h"
#import "SettingsViewControllerDelegate.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

@interface RootViewController () <
ListViewControllerDelegate,
SettingsViewControllerDelegate
>
@end

@implementation RootViewController {
  SettingsPresentationHelper *_settingsPresentationHelper;
  UIViewController<ListViewController> *_listViewController;
  ListTotalSumBar *_totalSumBar;
}

- (instancetype)initWithListViewController:(UIViewController<ListViewController> *)listViewController {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_sw"]];
    self.navigationItem.rightBarButtonItem = listViewController.navigationItem.rightBarButtonItem;

    _listViewController = listViewController;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // settings button & gesture
  _settingsPresentationHelper = [SettingsPresentationHelper new];
  [_settingsPresentationHelper setupForSourceViewController:self];

  // Add total sum bar
  UINib *nibFile = [UINib nibWithNibName:NSStringFromClass([ListTotalSumBar class]) bundle:nil];
  _totalSumBar = [[nibFile instantiateWithOwner:nil options:nil] firstObject];
  _totalSumBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  _totalSumBar.frameWidth = self.view.frameWidth;
  _totalSumBar.frameBottom = self.view.frameHeight;
  [self.view addSubview:_totalSumBar];

  // childVC
  [self _setupChildViewController];
}

- (void)_setupChildViewController {
  [self addChildViewController:_listViewController];
  [self.view addSubview:_listViewController.view];
  [_listViewController didMoveToParentViewController:self];
  _listViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _listViewController.delegate = self;

  [self.view bringSubviewToFront:_totalSumBar];
  [self _updateTotalSumBarVisibility];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  // Show rate popup, if app is started the 20th time.
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if ([[RateAppAlertPresenter sharedInstance] appStartCountForCurrentVersion] == 20) {
      [[RateAppAlertPresenter sharedInstance]
       presentAlertWithMessage:NSLocalizedString(@"keyRateInfoText", nil)
       fromViewController:self];
    }
  });
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  if (_totalSumBar.hidden) {
    _listViewController.view.frame = self.view.bounds;
  } else {
    CGRect top = CGRectZero;
    CGRect bottom = CGRectZero;
    CGRectDivide(self.view.bounds, &bottom, &top, _totalSumBar.frameHeight, CGRectMaxYEdge);

    _listViewController.view.frame = top;
    _totalSumBar.frame = bottom;
  }
}

#pragma mark - TotalSum bar

- (void)_updateTotalSumBarVisibility {
  _totalSumBar.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsKeyShouldShowTotalSum];
  [self.view setNeedsLayout];

  // update tableView safe area insets
  CGFloat bottomSafeAreaInsets = (_totalSumBar.hidden ? [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom : 0);
  UIEdgeInsets insets = _listViewController.tableView.contentInset;
  insets.bottom = bottomSafeAreaInsets;
  _listViewController.tableView.scrollIndicatorInsets = insets;
  _listViewController.tableView.contentInset = insets;
}

#pragma mark - ListViewControllerDelegate

- (void)listViewControllerDidUpdateToTotalSum:(double)totalSum {
  _totalSumBar.totalSum = totalSum;
}

#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewControllerDidChangeSettings:(SettingsViewController *)settingsViewController {
  [self _updateTotalSumBarVisibility];
}

- (void)settingsViewController:(SettingsViewController *)settingsViewController
 providedNewListViewController:(UIViewController<ListViewController> *)listViewController {
  // remove current childVC
  [_listViewController willMoveToParentViewController:nil];
  [_listViewController.view removeFromSuperview];
  [_listViewController removeFromParentViewController];

  // create & setup new childVC
  _listViewController = listViewController;
  [self _setupChildViewController];
}

@end
