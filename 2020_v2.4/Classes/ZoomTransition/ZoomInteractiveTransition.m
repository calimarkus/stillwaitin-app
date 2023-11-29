//
//  ZoomTransition.m
//  ZoomSegueExample
//
//  Copyright (c) 2014 Denys Telezhkin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "ZoomInteractiveTransition.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

@interface ZoomInteractiveTransition()

@property (nonatomic, assign) CGFloat startScale;
@property (nonatomic, assign) BOOL shouldCompleteTransition;
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation ZoomInteractiveTransition

-(void)commonSetup {
  self.transitionEnabled = YES;
  self.transitionDuration = 0.3;
  self.handleEdgePanBackGesture = YES;
  self.transitionAnimationOption = UIViewKeyframeAnimationOptionCalculationModeCubic;
}

- (instancetype)initWithNavigationController:(UINavigationController *)nc {
  if (self = [super init]) {
    self.navigationController = nc;
    nc.delegate = self;
    [self commonSetup];
  }
  return self;
}

-(instancetype)init {
  if (self = [super init])
  {
    [self commonSetup];
  }
  return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return self.transitionDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController <ZoomTransitionProtocol> * fromVC = (id)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController <ZoomTransitionProtocol> *toVC = (id)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView * containerView = [transitionContext containerView];
  UIView * fromView = [fromVC view];
  UIView * toView = [toVC view];
  UIView * zoomFromView = [fromVC viewForZoomTransition];
  UIView * zoomToView = [toVC viewForZoomTransition];
  [containerView addSubview:toView];

  // use larger view for transition
  UIView * animatingView;
  if (zoomToView.frameWidth > zoomFromView.frameWidth ||
      zoomToView.frameHeight > zoomFromView.frameHeight) {
    animatingView = zoomToView;
    zoomFromView.alpha = 0;
  } else {
    animatingView = zoomFromView;
    zoomToView.alpha = 0;
  }

  // remember original state
  UIView *originalSuperView = animatingView.superview;
  NSInteger originalIndex = [animatingView.superview.subviews indexOfObject:animatingView];
  CGRect originalFrame = animatingView.frame;
  CGRect toFrame = [containerView convertRect:zoomToView.frame
                                     fromView:zoomToView.superview];
  CGRect fromFrame = [containerView convertRect:zoomFromView.frame
                                       fromView:zoomFromView.superview];

  // prepare animation
  toView.alpha = 0;
  fromView.alpha = 1;
  animatingView.frame = fromFrame;
  [containerView addSubview:animatingView];

  // setup pan gesture
  if (self.handleEdgePanBackGesture) {
    UIScreenEdgePanGestureRecognizer *edgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                            action:@selector(handleEdgePan:)];
    edgePanRecognizer.edges = UIRectEdgeLeft;
    [toView addGestureRecognizer:edgePanRecognizer];
  }

  // animate transition
  [UIView animateKeyframesWithDuration:self.transitionDuration
                                 delay:0
                               options:self.transitionAnimationOption
                            animations:^{
                              animatingView.frame = toFrame;
                              fromView.alpha = 0;
                              toView.alpha = 1;
                            } completion:^(BOOL finished) {
                              if ([transitionContext transitionWasCancelled]) {
                                [toView removeFromSuperview];
                                [transitionContext completeTransition:NO];
                              } else {
                                [fromView removeFromSuperview];
                                [transitionContext completeTransition:YES];
                              }

                              toView.alpha = 1.0;
                              fromView.alpha = 1.0;
                              zoomFromView.alpha = 1.0;
                              zoomToView.alpha = 1.0;
                              animatingView.frame = originalFrame;
                              [originalSuperView insertSubview:animatingView atIndex:originalIndex];
                            }];
}

#pragma mark - edge back gesture handling

- (void) handleEdgePan:(UIScreenEdgePanGestureRecognizer *)gr {
  CGPoint point = [gr translationInView:gr.view];

  switch (gr.state) {
    case UIGestureRecognizerStateBegan:
      self.interactive = YES;
      [self.navigationController popViewControllerAnimated:YES];
      break;
    case UIGestureRecognizerStateChanged: {
      CGFloat percent = point.x / gr.view.frame.size.width;
      self.shouldCompleteTransition = (percent > 0.25);

      [self updateInteractiveTransition: (percent <= 0.0) ? 0.0 : percent];
      break;
    }
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
      if (!self.shouldCompleteTransition || gr.state == UIGestureRecognizerStateCancelled)
        [self cancelInteractiveTransition];
      else
        [self finishInteractiveTransition];
      self.interactive = NO;
      break;
    default:
      break;
  }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
  if (!self.transitionEnabled || !navigationController) {
    return nil;
  }

  if (![fromVC conformsToProtocol:@protocol(ZoomTransitionProtocol)] ||
      ![toVC conformsToProtocol:@protocol(ZoomTransitionProtocol)])
  {
    return nil;
  }

  return self;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
  if (self.transitionEnabled && self.isInteractive) {
    return self;
  }

  return nil;
}

@end
