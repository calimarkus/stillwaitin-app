//
//  ListTotalSumBar.m
//  StillWaitin
//

#import "ListTotalSumBar.h"

#import "CurrencyManager.h"
#import "SWColors.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

#import <QuartzCore/QuartzCore.h>

@interface ListTotalSumBar ()
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *directionIndicator;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* valueLabel;
@end


@implementation ListTotalSumBar

- (void)awakeFromNib {
  [super awakeFromNib];

  self.backgroundColor = SWColorGreenMain();
  self.containerView.backgroundColor = SWColorGreenMain();

  // localize title
  self.titleLabel.text = NSLocalizedString(@"keyTotalSum", nil);

  // setup indicator corner radius
  self.directionIndicator.layer.cornerRadius = self.directionIndicator.frameHeight/2.0;
  self.directionIndicator.layer.rasterizationScale = [UIScreen mainScreen].scale;
  self.directionIndicator.layer.shouldRasterize = YES;

  // safe area adjustment
  CGFloat safeBottomMargin = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] safeAreaInsets].bottom;
  self.frameHeight += safeBottomMargin;
}

- (void)setTotalSum:(CGFloat)totalSum {
  _totalSum = totalSum;

  // update sum
  NSString* sumString = [[CurrencyManager currencyNumberFormatter] stringFromNumber:@(ABS(totalSum))];
  self.valueLabel.text = [NSString stringWithFormat: @"%@", sumString];

  // update indicator
  if (totalSum >= 0) {
    self.directionIndicator.backgroundColor = SWColorIndicatorGreen();
  } else {
    self.directionIndicator.backgroundColor = SWColorIndicatorRed();
  }
}

@end


