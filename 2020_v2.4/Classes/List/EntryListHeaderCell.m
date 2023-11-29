//
//  EntryListHeaderCell.m
//  StillWaitin
//


#import "EntryListHeaderCell.h"

#import "CurrencyManager.h"
#import "RealmEntryGroup.h"
#import "SWColors.h"
#import <UIView+SimplePositioning.h>

@implementation EntryListHeaderCell {
  UILabel *_titleLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
  {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = SWColorGrayWash();

    _titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
  }
  return self;
}

+ (CGFloat)height {
  NSString *preferredContentSizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;
  if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge] ||
      [preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
    return 55.0;
  } else {
    return 45.0;
  }
}

- (void)setEntryGroup:(RealmEntryGroup *)entryGroup {
  _entryGroup = entryGroup;

  [self updateTextAddNewline:NO];

  // check if we need to make it a two liner
  CGFloat viewWidth = self.contentView.frameWidth;
  CGRect textSize = [_titleLabel.attributedText boundingRectWithSize:CGSizeMake(viewWidth, CGFLOAT_MAX) options:0 context:nil];
  if (textSize.size.width >= viewWidth) {
    [self updateTextAddNewline:YES];
  }
}

- (void)updateTextAddNewline:(BOOL)addNewline {
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

  // formatted person
  UIFont *font1   = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  UIColor *color1 = SWColorHighContrastTextColor();
  NSAttributedString *personString = [[NSAttributedString alloc] initWithString:self.entryGroup.fullName
                                                                     attributes:@{NSFontAttributeName:font1,NSForegroundColorAttributeName:color1}];

  // formatted debt description
  UIFont *font2   = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  UIColor *color2 = SWColorLowContrastTextColor();
  NSAttributedString *sumString = [[NSAttributedString alloc] initWithString:debtDescription
                                                                  attributes:@{NSFontAttributeName:font2,
                                                                               NSForegroundColorAttributeName:color2}];

  // formatted header string
  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
  [attributedText appendAttributedString:personString];
  [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
  if (addNewline) [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
  [attributedText appendAttributedString:sumString];

  _titleLabel.attributedText = attributedText;
  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat insetX = 14.0;
  CGFloat width = CGRectInset(self.contentView.bounds, insetX, 0).size.width;

  [_titleLabel sizeToFit];
  _titleLabel.frame = CGRectMake(insetX,
                                 floor(self.contentView.frameHeight - _titleLabel.frameHeight - 2.0),
                                 width,
                                 _titleLabel.frameHeight);
}

@end
