//
//  SWSettingsCell.h
//  StillWaitin
//
//

#import <UIKit/UIKit.h>

extern NSString *const SWSettingsCellReuseIdentifier;

@interface SWSettingsCell : UITableViewCell
- (void)setShowsCheckmark:(BOOL)selected;
@end
