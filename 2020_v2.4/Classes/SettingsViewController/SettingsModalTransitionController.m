//
//  SettingsModalTransitionController.m
//  StillWaitin
//
//

#import <QuartzCore/QuartzCore.h>

#import "SettingsModalTransitionController.h"

static const CGFloat SettingsTransitionBottomPartDuration = 0.8f;

@implementation SettingsModalTransitionController

- (CGFloat)duration {
  return 0.38;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *toView = toVC.view;
  UIView *fromView = fromVC.view;

  [self animateTransition:transitionContext
                   fromVC:fromVC toVC:toVC
                 fromView:fromView toView:toView];
}

#pragma mark - Animation code

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
                   fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC
                 fromView:(UIView *)fromView toView:(UIView *)toView {
  [transitionContext.containerView addSubview:toView];

  // name position related views
  UIView *bottomView = self.reverse ? toView : fromView;
  UIView *topView = self.reverse ? fromView : toView;
  CALayer *bottomLayer = bottomView.layer;
  CALayer *topLayer = topView.layer;

  // make sure topLayer is in front
  bottomLayer.zPosition = 0;
  topLayer.zPosition = 100;

  // prepare completion block
  void(^transitionCompleted)(BOOL) = ^(BOOL finished) {
    BOOL transitionCanceled = [transitionContext transitionWasCancelled];
    if (transitionCanceled) {
      [transitionContext.containerView bringSubviewToFront:fromView];
    } else {
      [fromView removeFromSuperview];
    }

    topLayer.transform = CATransform3DIdentity;
    bottomLayer.transform = CATransform3DIdentity;
    bottomLayer.zPosition = 0;
    topLayer.zPosition = 0;

    [transitionContext completeTransition:!transitionCanceled];
  };

  // run reverse animation
  if (self.reverse)
  {
    // Reset to initial transform
    bottomSetupWithPercentage(bottomView, 0.0);
    topSetupWithPercentage(topView, 0.0);

    //Perform animation
    [UIView animateKeyframesWithDuration:self.duration
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{

                                [UIView addKeyframeWithRelativeStartTime:0.0f
                                                        relativeDuration:SettingsTransitionBottomPartDuration
                                                              animations:^{
                                                                bottomSetupWithPercentage(bottomView, 1.0);
                                                              }];

                                [UIView addKeyframeWithRelativeStartTime:0.0f
                                                        relativeDuration:1.0f
                                                              animations:^{
                                                                topSetupWithPercentage(topView, 1.0);
                                                              }];

                              } completion:^(BOOL finished) {
                                transitionCompleted(finished);
                              }];
  }

  // run default animation
  else
  {
    // Reset to initial transform
    bottomSetupWithPercentage(bottomView, 1.0);
    topSetupWithPercentage(topView, 1.0);

    //Perform animation
    [UIView animateKeyframesWithDuration:self.duration
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{

                                [UIView addKeyframeWithRelativeStartTime:0.0f
                                                        relativeDuration:1.0f
                                                              animations:^{
                                                                topSetupWithPercentage(topView, 0.0);
                                                              }];

                                [UIView addKeyframeWithRelativeStartTime:(1.0f - SettingsTransitionBottomPartDuration)
                                                        relativeDuration:SettingsTransitionBottomPartDuration
                                                              animations:^{
                                                                bottomSetupWithPercentage(bottomView, 0.0);
                                                              }];

                              } completion:^(BOOL finished) {
                                transitionCompleted(finished);
                              }];
  }

}

#pragma mark - View setup for animation start/end

static void bottomSetupWithPercentage(UIView *view, CGFloat p) {
  view.alpha = p;

  CGFloat scale = 0.92 + 0.08*p;
  CALayer *layer = view.layer;
  CATransform3D t = CATransform3DIdentity;
  t = CATransform3DScale(t, scale, scale, 1.0);
  layer.transform = t;
}

static void topSetupWithPercentage(UIView *view, CGFloat p) {
  CALayer *layer = view.layer;
  CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;

  CATransform3D t = CATransform3DIdentity;
  t.m34 = 1.0f / -500.0f; // z distance
  t = CATransform3DRotate(t, radianFromDegree(3.0*p), 0.0f, 0.0f, 1.0f);
  t = CATransform3DTranslate(t, screenWidth*p, -22.0f*p, 60.0f*p);
  t = CATransform3DRotate(t, radianFromDegree(-25.0*p), 0.0f, 1.0f, 0.0f);
  t = CATransform3DRotate(t, radianFromDegree(5.0*p), 1.0f, 0.0f, 0.0f);
  layer.transform = t;
}

#pragma mark - Convert Degrees to Radian

static inline double radianFromDegree(float degrees) {
  return (degrees / 180) * M_PI;
}

@end
