//
//  SettingsModalTransitionDelegate.h
//  StillWaitin
//
//

#import "SettingsModalTransitionController.h"

@interface SettingsModalTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, readonly) SettingsModalTransitionController *transitionController;
@property (nonatomic, readonly) UIPercentDrivenInteractiveTransition *percentageDrivenController;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

- (void)handlePanGesture:(UIScreenEdgePanGestureRecognizer*)recognizer;

@end
