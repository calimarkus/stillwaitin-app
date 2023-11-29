//
//  EntryListEntryCell.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

@class RealmEntry;

@interface EntryListEntryCell : UITableViewCell

@property (nonatomic, strong) RealmEntry *entry;

+ (CGFloat)height;

@end
