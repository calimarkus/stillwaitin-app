//
//  EntryListEntryCell.m
//  StillWaitin
//

#import "EntryListEntryCell.h"

#import "CurrencyManager.h"
#import "RealmEntry.h"
#import "SWColors.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

#import <QuartzCore/QuartzCore.h>

@implementation EntryListEntryCell {
  UIView *_directionIndicator;
  UILabel *_bigDateLabel;
  UILabel *_dateLabel;
  UILabel *_descriptionLabel;
  UILabel *_valueLabel;
  UIImageView *_notificationIcon;
  UIImageView *_checkmarkIcon;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self _setupSubviews];
  }
  return self;
}

+ (CGFloat)height {
  NSString *preferredContentSizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;
  if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge] ||
      [preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
    return 68.0;
  } else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategorySmall] ||
             [preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraSmall]) {
    return 52.0;
  }else {
    return 58.0;
  }
}

- (void)_setupSubviews {
  self.backgroundColor = SWColorGrayWash();
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  const double backgroundInset = 2;
  const CGRect contentViewBounds = self.contentView.bounds;

  UIView *backgroundContentView = [[UIView alloc] initWithFrame:contentViewBounds];
  backgroundContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  UIView *innerBackground = [[UIView alloc] initWithFrame:CGRectInset(contentViewBounds, 0, backgroundInset)];
  innerBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  innerBackground.backgroundColor = SWColorContentCellBackground();
  [backgroundContentView addSubview:innerBackground];
  self.backgroundView = backgroundContentView;

  UIView *selectedBackgroundContentView = [[UIView alloc] initWithFrame:contentViewBounds];
  selectedBackgroundContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  UIView *selectedInnerBackground = [[UIView alloc] initWithFrame:CGRectInset(contentViewBounds, 0, backgroundInset)];
  selectedInnerBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  selectedInnerBackground.backgroundColor = SWColorSelectedContentCellBackground();
  [selectedBackgroundContentView addSubview:selectedInnerBackground];
  self.selectedBackgroundView = selectedBackgroundContentView;

  _directionIndicator = [UIView new];
  _directionIndicator.frame = CGRectMake(15,
                                         floor((CGRectGetHeight(contentViewBounds)-10)/2.0) - 1,
                                         10,
                                         10);
  _directionIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
  _directionIndicator.layer.cornerRadius = _directionIndicator.frameHeight/2.0;
  _directionIndicator.layer.rasterizationScale = [UIScreen mainScreen].scale;
  _directionIndicator.layer.shouldRasterize = YES;
  [self.contentView addSubview:_directionIndicator];

  _bigDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 0, 172, 21)];
  _bigDateLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
  _bigDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  _bigDateLabel.textColor = SWColorLowContrastTextColor();
  [self.contentView addSubview:_bigDateLabel];

  _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 8, 86, 21)];
  _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
  _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
  _dateLabel.textColor = SWColorLowContrastTextColor();
  [self.contentView addSubview:_dateLabel];

  _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 27, 141, 21)];
  _descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
  [self.contentView addSubview:_descriptionLabel];

  _notificationIcon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"notification_icon_list"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
  _notificationIcon.frame = CGRectMake(0, 0, 12, 12);
  _notificationIcon.tintColor = SWColorHighContrastTextColor();
  [self.contentView addSubview:_notificationIcon];

  _checkmarkIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
  _checkmarkIcon.frame = CGRectMake(0, 0, 12, 12);
  _checkmarkIcon.hidden = YES;
  _checkmarkIcon.tintColor = SWColorHighContrastTextColor();
  [self.contentView addSubview:_checkmarkIcon];

  _valueLabel = [UILabel new];
  _valueLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds)-120,
                                 backgroundInset,
                                 120,
                                 CGRectGetHeight(self.contentView.bounds) - backgroundInset * 2);
  _valueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
  _valueLabel.adjustsFontSizeToFitWidth = YES;
  _valueLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
  [self.contentView addSubview:_valueLabel];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self setEntry:nil];
}

- (void)setEntry:(RealmEntry *)entry {
  _entry = entry;

  // update dates
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  _dateLabel.text = [dateFormatter stringFromDate:entry.debtDate];
  _bigDateLabel.text = _dateLabel.text;

  // date style
  BOOL hasDescription = (entry.entryDescription.length > 0);
  _dateLabel.hidden = !hasDescription;
  _bigDateLabel.hidden = hasDescription;

  // value
  _valueLabel.text = [[CurrencyManager currencyNumberFormatter] stringFromNumber:entry.value];
  _valueLabel.textColor = (entry.isArchived ?
                           SWColorLowContrastTextColor() :
                           SWColorHighContrastTextColor());

  // description
  _descriptionLabel.text = [entry.entryDescription stringByReplacingOccurrencesOfString:@"\n"
                                                                             withString:@" "];
  _descriptionLabel.textColor = (entry.isArchived
                                 ? SWColorLowContrastTextColor()
                                 : SWColorHighContrastTextColor());

  // icons
  _notificationIcon.hidden = entry.notificationDate == nil;
  _checkmarkIcon.hidden = !entry.isArchived;

  // debt direction indicator
  _directionIndicator.hidden = _entry.isArchived;
  _directionIndicator.backgroundColor = SWIndicatorColorForDebtDirection(_entry.debtDirection);

  [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)editing animated:(BOOL)animated {
  [super setHighlighted:editing animated:animated];

  // only read entry, if it isn't invalidated
  if (!_entry.isInvalidated) {
    _directionIndicator.backgroundColor = SWIndicatorColorForDebtDirection(_entry.debtDirection); // needed here because view background colors get overwritten
  }
}

#pragma mark layout

- (void)layoutSubviews {
  [super layoutSubviews];

  if (_entry.isInvalidated) {
    return; // don't read entry, if it's not valid anymore
  }

  [_dateLabel sizeToFit];
  [_bigDateLabel sizeToFit];
  [_descriptionLabel sizeToFit];
  [_valueLabel sizeToFit];
  const double fullDescriptionWidth = _descriptionLabel.frameWidth;

  UIView *const visibleDateLabel = _bigDateLabel.hidden ? _dateLabel : _bigDateLabel;
  _directionIndicator.frameY = floor((self.contentView.frameHeight - _directionIndicator.frameHeight)/2.0);
  _checkmarkIcon.center = _directionIndicator.center;
  _bigDateLabel.frameY = floor((self.contentView.frameHeight - _bigDateLabel.frameHeight)/2.0);
  _dateLabel.frameY = floor(self.contentView.frameHeight/2.0 - _dateLabel.frameHeight - 1.5);
  _valueLabel.frameY = floor((self.contentView.frameHeight - _valueLabel.frameHeight)/2.0);
  _valueLabel.frameRight = self.contentView.frameRight - 10;
  _descriptionLabel.frameWidth = _valueLabel.frameX - _descriptionLabel.frameX - 10.0;
  _descriptionLabel.frameY = _dateLabel.frameBottom;
  _notificationIcon.center = CGPointMake(floor(visibleDateLabel.frameRight + _notificationIcon.frameWidth/2.0 + 5.0),
                                         visibleDateLabel.center.y);

  // ensure value doesn't overlap other content
  const double mostRightDateAndIconEdge = (_notificationIcon.hidden ? visibleDateLabel.frameRight : _notificationIcon.frameRight);
  const double minimumValueX = mostRightDateAndIconEdge + 10;
  if (_valueLabel.frameX < minimumValueX) {
    double difference = minimumValueX - _valueLabel.frameX;
    _valueLabel.frameWidth -= difference;
    _valueLabel.frameRight = self.contentView.frameRight - 10;
  }

  // for the description
  // - ensure minimum description width, if needed (shrinking the _valueLabel)
  // - ensure description uses all available space, if available
  const double minimumDescriptionWidthIfNeeded = 0.357;
  if (_entry.description.length > 0) {
    if (_descriptionLabel.frameX + fullDescriptionWidth + 5 > _valueLabel.frameX) {
      _descriptionLabel.frameWidth = MIN(self.frameWidth * minimumDescriptionWidthIfNeeded, fullDescriptionWidth + 5);
      const double minimumValueX = _descriptionLabel.frameRight + 10;
      if (minimumValueX > _valueLabel.frameX) {
        double difference = minimumValueX - _valueLabel.frameX;
        _valueLabel.frameWidth -= difference;
        _valueLabel.frameRight = self.contentView.frameRight - 10;
      }
    }

    if (fullDescriptionWidth > _descriptionLabel.frameWidth &&
        _valueLabel.frameX - _descriptionLabel.frameRight > 10) {
      _descriptionLabel.frameWidth += (_valueLabel.frameX - 10 - _descriptionLabel.frameRight);
    }
  }
}

@end
