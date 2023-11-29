//
//  EmptyListView.m
//  StillWaitin
//

#import "EmptyListView.h"

#import "SWColors.h"
#import <UIView+SimplePositioning.h>

@implementation EmptyListView {
  UIImageView *_arrowImageView;
  UILabel *_infoLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
  }
  return self;
}

- (void)setVisibleAnimated:(BOOL)isVisible {
  // add first info arrow
  if (!_arrowImageView) {
    UIImage *image = [[UIImage imageNamed:@"list_info_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _arrowImageView = [[UIImageView alloc] initWithImage:image];
    _arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _arrowImageView.frameRight = self.frameWidth - 30;
    _arrowImageView.frameY = -100;
    _arrowImageView.tintColor = SWColorEmptyListInfoTextColor();
  }

  // add first info text
  if (!_infoLabel) {
    _infoLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, _arrowImageView.frameY+10, 140, 50)];
    _infoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _infoLabel.frameRight = _arrowImageView.frameX;
    _infoLabel.textColor= SWColorEmptyListInfoTextColor();
    _infoLabel.numberOfLines = 2;
    _infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _infoLabel.backgroundColor = [UIColor clearColor];
    _infoLabel.textAlignment = NSTextAlignmentRight;
    _infoLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:15.0];
    _infoLabel.text = NSLocalizedString(@"keyAddFirstEntry", nil);
  }

  [self addSubview:_arrowImageView];
  [self addSubview:_infoLabel];

  self.alpha = 0.0;
  [UIView animateWithDuration:0.33 delay:0.15 options:0 animations:^{
    self->_arrowImageView.frameY = 20;
    self->_infoLabel.frameY = self->_arrowImageView.frameY+10;
    if (isVisible) {
      self.alpha = 1.0;
    }
  } completion:nil];
}

- (void)updateForScrollContentOffset:(CGPoint)contentOffset {
  const double fadeDistance = 40.0;
  const double clampedOffsetY = ABS(MAX(MIN(0, contentOffset.y), -fadeDistance));
  self.alpha = ((fadeDistance-clampedOffsetY) / fadeDistance);
}

- (CGSize)sizeThatFits:(CGSize)size {
  return CGSizeMake(size.width, _infoLabel.frameBottom + 10);
}

@end
