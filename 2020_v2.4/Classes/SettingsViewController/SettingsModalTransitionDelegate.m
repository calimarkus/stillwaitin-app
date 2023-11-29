//
//  SettingsModalTransitionDelegate.m
//  StillWaitin
//
//

#import "SettingsModalTransitionDelegate.h"

@implementation SettingsModalTransitionDelegate

@synthesize transitionController = _transitionController;
@synthesize percentageDrivenController = _percentageDrivenController;

- (SettingsModalTransitionController *)transitionController {
  if (!_transitionController) {
    _transitionController = [[SettingsModalTransitionController alloc] init];
  }
  return _transitionController;
}

- (SettingsModalTransitionController *)transitionControllerForReverse:(BOOL)reverse {
  self.transitionController.reverse = reverse;
  return self.transitionController;
}

- (UIPercentDrivenInteractiveTransition *)percentageDrivenController {
  if (_percentageDrivenController == nil) {
    _percentageDrivenController = [[UIPercentDrivenInteractiveTransition alloc] init];
  }
  return _percentageDrivenController;
}

#pragma mark UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
  return [self transitionControllerForReverse:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  return [self transitionControllerForReverse:NO];
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
  if (!self.isInteractive) return nil;
  return self.percentageDrivenController;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
  if (!self.isInteractive) return nil;
  return self.percentageDrivenController;
}

#pragma mark UIGestureRecognizer

- (void)handlePanGesture:(UIScreenEdgePanGestureRecognizer*)recognizer {
  if (recognizer.state == UIGestureRecognizerStateChanged) {
    CGFloat viewWidth = CGRectGetWidth(recognizer.view.window.frame);
    CGFloat translationX = ABS([recognizer translationInView:recognizer.view.window].x);
    CGFloat relative = MAX(0.0,MIN(1.0,translationX/viewWidth));

    // jump start on interactive transition, so smth happens right after dragging starts
    if (self.transitionController.reverse) relative = relative*0.97+0.03;
    if (!self.transitionController.reverse) relative = relative*0.85+0.15;

    [self.percentageDrivenController updateInteractiveTransition:ABS(relative)];
  }

  if (recognizer.state == UIGestureRecognizerStateEnded ||
      recognizer.state == UIGestureRecognizerStateFailed) {
    CGFloat velocityX = [recognizer velocityInView:recognizer.view].x;
    if ((velocityX > 0 && self.transitionController.reverse) ||
        (velocityX < 0 && !self.transitionController.reverse)) {
      [self.percentageDrivenController finishInteractiveTransition];
    } else {
      [self.percentageDrivenController cancelInteractiveTransition];
    }
  }
}

@end
