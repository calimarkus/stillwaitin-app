//
//  SettingsModalTransitionController.h
//  StillWaitin
//
//

#import <Foundation/Foundation.h>

@interface SettingsModalTransitionController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL reverse; //  The direction of the animation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
                   fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC
                 fromView:(UIView *)fromView toView:(UIView *)toView;

@end
