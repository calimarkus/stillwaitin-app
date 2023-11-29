//
//  RealmEntryStorage.h
//  StillWaitin
//
//

@class RealmEntry;
@class RealmEntryStorage;
@class RLMRealm;

typedef NS_ENUM(NSInteger, RealmEntryStorageFilter) {
  RealmEntryStorageFilterActiveEntries,
  RealmEntryStorageFilterArchivedEntries,
  RealmEntryStorageFilterAllEntries,
};

@protocol RealmEntryStorageListenerCancelable <NSObject>
- (void)invalidate;
@end

@interface RealmEntryStorage : NSObject

+ (instancetype)sharedStorage;

- (instancetype)initWithRealm:(RLMRealm *)realm NS_DESIGNATED_INITIALIZER;

- (RealmEntry *)entryForEntryID:(NSString *)entryID;
- (NSArray<RealmEntry *> *)entriesWithFilter:(RealmEntryStorageFilter)filter;
- (NSArray<RealmEntry *> *)entriesMatchingFullName:(NSString *)fullname
                                        withFilter:(RealmEntryStorageFilter)filter;

- (BOOL)archiveEntry:(RealmEntry*)entry;
- (BOOL)unarchiveEntry:(RealmEntry*)entry;
- (BOOL)deleteEntry:(RealmEntry *)entry;
- (void)saveEntry:(RealmEntry *)entry;
- (void)saveEntries:(NSArray<RealmEntry *>*)entries;

- (void)removeOutdatedNotificationDatesFromEntries:(NSArray<RealmEntry *> *)entries;

- (id<RealmEntryStorageListenerCancelable>)addUpdateListenerBlock:(void(^)(void))updateListenerBlock;

@end
