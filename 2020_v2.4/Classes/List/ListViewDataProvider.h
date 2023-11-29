//
//  ListViewDataSource.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

#import "ListViewDataSourceContentType.h"

@class RealmEntryGroup;
@class RealmEntryStorage;

@interface ListViewDataProvider : NSObject

// input
@property (nonatomic, strong) NSString *exactFullName;
@property (nonatomic, strong) NSString *currentSearchString;
@property (nonatomic, assign) ListViewDataSourceContentType contentType;
@property (nonatomic, assign) BOOL shouldSearchForPersonMatches;
@property (nonatomic, assign) BOOL shouldSearchForEntryMatches;

// output
@property (nonatomic, readonly) NSArray<RealmEntryGroup *> *entryGroups;
@property (nonatomic, readonly) double totalSumAcrossAllEntries;

- (instancetype)initWithRealmEntryStorage:(RealmEntryStorage *)entryStorage;

- (void)refetchData;

@end
