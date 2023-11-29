//
//  StillWaitinAppDelegate.m
//  StillWaitin
//

#import "StillWaitinAppDelegate.h"

#import "AppAppearance.h"
#import "DataImportHelper.h"
#import "EntriesImporterExporter.h"
#import "InAppPurchaseManager.h"
#import "ListViewControllerFactory.h"
#import "LocalNotificationHandler.h"
#import "PasswordViewController.h"
#import "RateAppAlertPresenter.h"
#import "RootViewController.h"
#import "SWColors.h"
#import <UserNotifications/UserNotifications.h>

@interface StillWaitinAppDelegate () <
UIApplicationDelegate>
@end

@implementation StillWaitinAppDelegate {
  UIWindow *_mainWindow;
  UIWindow *_passwordWindow;
  UINavigationController *_navigationController;
  id _notificationDelegate;
  NSURL *_rememberedImportFileUrl;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [AppAppearance setupAppearance];
  [[InAppPurchaseManager sharedInstance] prepareManager];

  // setup root controller
  _navigationController = [[UINavigationController alloc] initWithRootViewController:
                           [[RootViewController alloc] initWithListViewController:createListViewController()]];
  _navigationController.navigationBar.translucent = NO;

  // setup window
  _mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _mainWindow.backgroundColor = SWNavbarBackgroundColor();
  [_mainWindow setRootViewController:_navigationController];
  [_mainWindow makeKeyAndVisible];

  // show password view
  [self showPasswordViewIfNeededWithShouldEvaluate:YES];

  // local notification delegate
  _notificationDelegate = [[LocalNotificationHandler alloc] initWithMainNavigationController:_navigationController];
  [[UNUserNotificationCenter currentNotificationCenter] setDelegate:_notificationDelegate];

  return YES;
}

#pragma mark - Application state

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [[RateAppAlertPresenter sharedInstance] bumpAppStartCounts];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [self showPasswordViewIfNeededWithShouldEvaluate:NO];
}

#pragma mark - PasswordController

- (BOOL)showPasswordViewIfNeededWithShouldEvaluate:(BOOL)shouldEvaluate {
  BOOL alreadyPresenting = [_passwordWindow isKeyWindow];
  if (!alreadyPresenting && [PasswordViewController shouldEnterPassword]) {
    __weak __typeof(self) weakSelf = self;
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
    passwordViewController.shouldDismissBlock = ^(PasswordViewController *passwordViewController) {
      [weakSelf _passwordViewControllerShouldDismiss:passwordViewController];
    };
    passwordViewController.shouldEvaluateOnWillAppear = shouldEvaluate;

    // setup window
    _passwordWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_passwordWindow setRootViewController:passwordViewController];
    [_passwordWindow makeKeyAndVisible];
    return YES;
  } else {
    return NO;
  }
}

- (void)_passwordViewControllerShouldDismiss:(PasswordViewController *)passwordViewController {
  [_mainWindow makeKeyAndVisible];
  _passwordWindow = nil;

  if (_rememberedImportFileUrl != nil) {
    NSURL *importFileUrl = _rememberedImportFileUrl;
    _rememberedImportFileUrl = nil;
    [DataImportHelper evaluateImportOfURL:importFileUrl mainNavigationController:_navigationController];
  }
}

#pragma mark - Data import

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  if (_passwordWindow.isKeyWindow) {
    _rememberedImportFileUrl = url;
  } else {
    [DataImportHelper evaluateImportOfURL:url mainNavigationController:_navigationController];
  }
  return YES;
}

@end
