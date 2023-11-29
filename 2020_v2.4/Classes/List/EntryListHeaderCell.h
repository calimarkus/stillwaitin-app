//
//  EntryListHeaderCell.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

@class RealmEntryGroup;

@interface EntryListHeaderCell : UITableViewCell

@property (nonatomic, strong) RealmEntryGroup *entryGroup;
@property (nonatomic, assign) BOOL shouldUsePastTense;

+ (CGFloat)height;

@end
