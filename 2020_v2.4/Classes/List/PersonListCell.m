//
//  PersonListCell.m
//  StillWaitin
//


#import "PersonListCell.h"

#import "CurrencyManager.h"
#import "RealmEntryGroup.h"
#import "SWColors.h"
#import <UIView+SimplePositioning.h>

@implementation PersonListCell {
  UILabel *_personLabel;
  UILabel *_debtSumLabel;
  UIView *_directionIndicator;
  UIImageView *_checkmarkIcon;
  UIView *_separatorView;
  UIView *_selectedSeparatorView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.backgroundColor = SWColorContentCellBackground();

    _personLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_personLabel];
    _debtSumLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_debtSumLabel];

    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = SWColorContentCellBackground();
    self.backgroundView = backgroundView;

    const CGFloat separatorHeight = [UIScreen mainScreen].scale >= 2.0 ? 0.5 : 1;
    const CGFloat separatorLeftMargin = 35;
    const CGRect separatorFrame = CGRectMake(separatorLeftMargin,
                                             CGRectGetHeight(self.bounds) - separatorHeight,
                                             CGRectGetWidth(self.bounds) - separatorLeftMargin,
                                             separatorHeight);
    UIView *separatorView = [[UIView alloc] initWithFrame:separatorFrame];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    separatorView.backgroundColor = SWColorContentCellSeparator();
    [backgroundView addSubview:separatorView];
    _separatorView = separatorView;

    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    selectedBackgroundView.backgroundColor = SWColorSelectedContentCellBackground();
    self.selectedBackgroundView = selectedBackgroundView;

    UIView *selectedSeparatorView = [[UIView alloc] initWithFrame:separatorFrame];
    selectedSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    selectedSeparatorView.backgroundColor = SWColorContentCellSeparator();
    [selectedBackgroundView addSubview:selectedSeparatorView];
    _selectedSeparatorView = selectedSeparatorView;

    _directionIndicator = [UIView new];
    _directionIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _directionIndicator.layer.cornerRadius = 5.0;
    _directionIndicator.layer.rasterizationScale = [UIScreen mainScreen].scale;
    _directionIndicator.layer.shouldRasterize = YES;
    [self.contentView addSubview:_directionIndicator];

    _checkmarkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    _checkmarkIcon.frame = CGRectMake(0, 0, 12, 12);
    _checkmarkIcon.hidden = YES;
    _checkmarkIcon.tintColor = SWColorHighContrastTextColor();
    [self.contentView addSubview:_checkmarkIcon];
  }
  return self;
}

+ (CGFloat)height {
  NSString *preferredContentSizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;
  if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryMedium] ||
      [preferredContentSizeCategory isEqualToString:UIContentSizeCategoryLarge] ||
      [preferredContentSizeCategory isEqualToString:UIContentSizeCategoryUnspecified]) {
    // default
    return 54.0;
  } else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraSmall] ||
      [preferredContentSizeCategory isEqualToString:UIContentSizeCategorySmall]) {
    return 50.0;
  } else {
    return 66.0;
  }
}

- (void)setEntryGroup:(RealmEntryGroup *)entryGroup {
  _entryGroup = entryGroup;

  // formatted person
  UIFont *font1   = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  UIColor *color1 = SWColorHighContrastTextColor();
  NSAttributedString *personString = [[NSAttributedString alloc] initWithString:self.entryGroup.fullName
                                                                     attributes:@{NSFontAttributeName:font1,NSForegroundColorAttributeName:color1}];
  _personLabel.attributedText = personString;

  // debt value
  double debtValue = [self.entryGroup.totalValue doubleValue];
  NSString *debtValueString = [[CurrencyManager currencyNumberFormatter] stringFromNumber:@(ABS(debtValue))];
  NSString *debtDescriptionFormat = (self.shouldUsePastTense
                                     ? (debtValue < 0
                                        ? NSLocalizedString(@"keyFooterOutFormatPastTense", nil)
                                        : NSLocalizedString(@"keyFooterInFormatPastTense", nil))
                                     : (debtValue < 0
                                        ? NSLocalizedString(@"keyFooterOutFormat", nil)
                                        : NSLocalizedString(@"keyFooterInFormat", nil)));
  NSString *debtDescription = [NSString stringWithFormat:debtDescriptionFormat, debtValueString];

  // formatted debt description
  UIFont *font2   = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  UIColor *color2 = SWColorLowContrastTextColor();
  NSAttributedString *sumString = [[NSAttributedString alloc] initWithString:debtDescription
                                                                  attributes:@{NSFontAttributeName:font2,
                                                                               NSForegroundColorAttributeName:color2}];

  _debtSumLabel.attributedText = sumString;

  _checkmarkIcon.hidden = !entryGroup.allEntriesAreArchived;
  _directionIndicator.hidden = entryGroup.allEntriesAreArchived;
  _directionIndicator.backgroundColor = SWIndicatorColorForDebtDirection(_entryGroup.totalValue.doubleValue > 0 ? DebtDirectionIn : DebtDirectionOut);
  _separatorView.hidden = !_showsSeparator;
  _selectedSeparatorView.hidden = !_showsSeparator;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  [_personLabel sizeToFit];
  [_debtSumLabel sizeToFit];

  _directionIndicator.frame = CGRectMake(15,
                                         floor((self.contentView.frameHeight-10)/2.0) - 1,
                                         10,
                                         10);
  _checkmarkIcon.center = _directionIndicator.center;

  const CGRect remainingRect = CGRectMake(_directionIndicator.frameRight, 0, self.contentView.frameWidth - _directionIndicator.frameRight, self.contentView.frameHeight);
  const CGRect labelBounds = CGRectInset(remainingRect, 10, 0);

  CGFloat cellCenterY = floor(CGRectGetHeight(labelBounds)/2.0);
  CGFloat personLabelY = floor(cellCenterY - _personLabel.frameHeight);
  _personLabel.frame = CGRectMake(labelBounds.origin.x,
                                  personLabelY,
                                  CGRectGetWidth(labelBounds),
                                  CGRectGetHeight(_personLabel.frame));

  _debtSumLabel.frame = CGRectMake(labelBounds.origin.x,
                                   floor(_personLabel.frameBottom),
                                   CGRectGetWidth(labelBounds),
                                   _debtSumLabel.frameHeight);
}

@end
