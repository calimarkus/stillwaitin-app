//
//  SettingsPresentationHelper.m
//  StillWaitin
//

#import "SettingsPresentationHelper.h"

#import "SettingsModalTransitionDelegate.h"
#import "SettingsViewController.h"
#import "SettingsViewControllerDelegate.h"

@implementation SettingsPresentationHelper {
  SettingsModalTransitionDelegate *_settingsTransitionDelegate;
  __weak UIViewController<SettingsViewControllerDelegate> *_fromViewController;
  UIScreenEdgePanGestureRecognizer *_edgePanGestureRecognizer;
}

- (void)setupForSourceViewController:(UIViewController<SettingsViewControllerDelegate> *)sourceViewController {
  if (_fromViewController != nil) {
    _fromViewController.navigationItem.leftBarButtonItem = nil;
    [_fromViewController.view removeGestureRecognizer:_edgePanGestureRecognizer];
  }

  _fromViewController = sourceViewController;

  _fromViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_settings"]
                                                                                          style:UIBarButtonItemStylePlain
                                                                                         target:self
                                                                                         action:@selector(settingsButtonTouchHandler:)];

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    // setup show settings gesture
    _edgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showSettingsInteractive:)];
    _edgePanGestureRecognizer.edges = UIRectEdgeLeft;
    [_fromViewController.view addGestureRecognizer:_edgePanGestureRecognizer];
  }
}

- (void)pushSettingsControllerInteractive:(BOOL)interactive {
  SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
  settingsViewController.delegate = _fromViewController;
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
  navController.navigationBar.translucent = NO;
  navController.modalPresentationStyle = UIModalPresentationFullScreen;

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    if (!_settingsTransitionDelegate) {
      _settingsTransitionDelegate = [[SettingsModalTransitionDelegate alloc] init];
    }
    _settingsTransitionDelegate.interactive = interactive;
    navController.transitioningDelegate = _settingsTransitionDelegate;

    // setup dismiss settings gesture
    UIScreenEdgePanGestureRecognizer *recognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(hideSettingsInteractive:)];
    recognizer.edges = UIRectEdgeRight;
    [navController.view addGestureRecognizer:recognizer];
  } else {
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
  }

  [_fromViewController presentViewController:navController animated:YES completion:nil];
}

- (void)settingsButtonTouchHandler:(id)sender {
  [self pushSettingsControllerInteractive:NO];
}

- (void)showSettingsInteractive:(UIScreenEdgePanGestureRecognizer*)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    _settingsTransitionDelegate.interactive = YES;
    [self pushSettingsControllerInteractive:YES];
  }

  [_settingsTransitionDelegate handlePanGesture:recognizer];
}

- (void)hideSettingsInteractive:(UIScreenEdgePanGestureRecognizer*)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    _settingsTransitionDelegate.interactive = YES;
    [_fromViewController dismissViewControllerAnimated:YES completion:nil];
  }

  [_settingsTransitionDelegate handlePanGesture:recognizer];
}

@end
