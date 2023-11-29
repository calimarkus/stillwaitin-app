//
//  PersonListCell.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

@class RealmEntryGroup;

@interface PersonListCell : UITableViewCell

@property (nonatomic, strong) RealmEntryGroup *entryGroup;
@property (nonatomic, assign) BOOL shouldUsePastTense;
@property (nonatomic, assign) BOOL showsSeparator;

+ (CGFloat)height;

@end
