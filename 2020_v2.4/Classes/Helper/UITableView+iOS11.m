//
//  UITableView+iOS11.m
//  StillWaitin
//
//

#import "UITableView+iOS11.h"

@implementation UITableView (iOS11)

- (void)sw_setupBottomInsetAndDisableAutomaticContentInsetAdjustment {
  self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  self.contentInset = UIEdgeInsetsMake(0, 0, [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom, 0);
  self.scrollIndicatorInsets = self.contentInset;

  if (@available(iOS 13.0, *)) {
    self.automaticallyAdjustsScrollIndicatorInsets = NO;
  }
}

@end
