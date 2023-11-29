//
//  RealmEntryGroup.h
//  StillWaitin
//

@class RealmEntry;
@class RealmEntryGroup;

NS_ASSUME_NONNULL_BEGIN

extern NSArray<RealmEntryGroup *> *EntryGroupsForEntries(NSArray<RealmEntry *> *entries,
                                                         NSSet<NSString *> * _Nullable entryIdsToExcludeFromDisplay,
                                                         BOOL excludeArchivedEntriesFromTotalValue,
                                                         BOOL filterToArchivedGroupsOnly);

@interface RealmEntryGroup : NSObject

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSNumber *totalValue;
@property (nonatomic, copy) NSArray<RealmEntry *> *entries;
@property (nonatomic, assign) BOOL allEntriesAreArchived;

@end

NS_ASSUME_NONNULL_END

