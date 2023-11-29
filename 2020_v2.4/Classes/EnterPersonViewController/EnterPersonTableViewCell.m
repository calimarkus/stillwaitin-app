//
//  EnterPersonTableViewCell.m
//  StillWaitin
//

#import "EnterPersonTableViewCell.h"

#import "AddressBookContact.h"
#import "SWColors.h"

@implementation EnterPersonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = SWColorHighContrastTextColor();
  }
  return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];

  self.backgroundColor = (highlighted
                          ? SWColorSelectedContentCellBackground()
                          : SWColorContentCellBackground());
}

- (void)setContact:(AddressBookContact*)contact {
  self.textLabel.text = contact.fullName;
  self.detailTextLabel.text = (contact.allowDeletion ? NSLocalizedString(@"keyRecentlyUsed", nil) : nil);
}

@end
