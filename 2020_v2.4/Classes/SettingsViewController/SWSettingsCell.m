//
//  SettingsCell.m
//  StillWaitin
//
//

#import "SWSettingsCell.h"

#import "SWColors.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

NSString *const SWSettingsCellReuseIdentifier = @"SWSettingsCellReuseIdentifier";

@implementation SWSettingsCell {
  UIImageView *_accessoryCheckmarkView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
  if (self) {
    [self reset];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self reset];
}

- (void)reset {
  self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  self.accessoryView = nil;
  self.tintColor = SWColorGreenContrastTintColor();
  self.textLabel.textColor = SWColorSettingsTextColor();
  self.detailTextLabel.textColor = SWColorHighContrastTextColor();
  self.backgroundColor = SWColorContentCellBackground();

  UIView *bgView = [UIView new];
  bgView.backgroundColor = SWColorSelectedContentCellBackground();
  self.selectedBackgroundView = bgView;
}

- (void)setShowsCheckmark:(BOOL)selected {
  self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
