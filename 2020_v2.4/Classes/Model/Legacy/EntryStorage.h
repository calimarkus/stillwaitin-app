//
//  EntryStorage.h
//  StillWaitin
//
//

@class Entry;

extern NSString *const EntryStorageDidUpdateNotification;

@interface EntryStorage : NSObject

@property (nonatomic, readonly) NSArray<Entry *> *entries;
@property (nonatomic, readonly) NSArray<NSArray<Entry *> *> *entriesGroupedByPerson;

+ (instancetype)sharedStorage;
- (instancetype)initWithStorageKey:(NSString *)storageKey NS_DESIGNATED_INITIALIZER;

// managing entries
- (BOOL)deleteEntry:(Entry *)entry;
- (void)saveEntry:(Entry *)entry;
- (void)saveEntries:(NSArray<Entry *>*)entries;

// entry id
+ (NSString *)nextEntryID;

// persisting
- (void)saveToUserDefaults;

@end

