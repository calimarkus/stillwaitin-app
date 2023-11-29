//
//  RealmEntryStorage.m
//  StillWaitin
//
//

#import "RealmEntry.h"
#import "RealmEntryStorage.h"
#import "SimpleLocalNotification.h"

#import <Realm/RLMRealm.h>
#import <Realm/RLMRealmConfiguration.h>
#import <Realm/RLMResults.h>

@interface RLMNotificationToken (Cancelable) <RealmEntryStorageListenerCancelable>
@end
@implementation RLMNotificationToken (Cancelable)
@end

@interface RealmEntryStorage ()
@property (nonatomic, strong) RLMRealm *realm;
@end

@implementation RealmEntryStorage

+ (instancetype)sharedStorage {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[self alloc] init];
  });
  return _sharedInstance;
}

- (instancetype)init {
  SetupDefaultRealmWithCustomDatabasePath();
  return [self initWithRealm:[RLMRealm defaultRealm]];
}

- (instancetype)initWithRealm:(RLMRealm *)realm {
  self = [super init];
  if (self) {
    _realm = realm;
  }
  return self;
}

#pragma mark - Fetching

- (RealmEntry *)entryForEntryID:(NSString *)entryID {
  return [RealmEntry objectForPrimaryKey:entryID];
}

- (NSArray<RealmEntry *> *)entriesWithFilter:(RealmEntryStorageFilter)filter {
  switch (filter) {
    case RealmEntryStorageFilterAllEntries:
      return [self _allObjectsInResult:[RealmEntry allObjects]];
    case RealmEntryStorageFilterActiveEntries:
      return [self _allObjectsForPredicate:[NSPredicate predicateWithFormat:@"isArchived = NO"]];
    case RealmEntryStorageFilterArchivedEntries:
      return [self _allObjectsForPredicate:[NSPredicate predicateWithFormat:@"isArchived = YES"]];
  }
}

- (NSArray<RealmEntry *> *)entriesMatchingFullName:(NSString *)fullname
                                        withFilter:(RealmEntryStorageFilter)filter {
  switch (filter) {
    case RealmEntryStorageFilterAllEntries:
      return [self _allObjectsForPredicate:[NSPredicate predicateWithFormat:@"fullName =[c] %@", fullname]];
    case RealmEntryStorageFilterActiveEntries:
      return [self _allObjectsForPredicate:[NSPredicate predicateWithFormat:@"fullName =[c] %@ && isArchived = NO", fullname]];
    case RealmEntryStorageFilterArchivedEntries:
      return [self _allObjectsForPredicate:[NSPredicate predicateWithFormat:@"fullName =[c] %@ && isArchived = YES", fullname]];
  }
}

- (NSArray<RealmEntry *> *)_allObjectsForPredicate:(NSPredicate *)predicate {
  return [self _allObjectsInResult:[RealmEntry objectsWithPredicate:predicate]];
}

- (NSArray<RealmEntry *> *)_allObjectsInResult:(RLMResults *)results {
  NSMutableArray<RealmEntry *> *mutableEntries = [NSMutableArray array];
  for (NSInteger i=0; i<results.count; i++) {
    RealmEntry *entry = results[i];
    [mutableEntries addObject:entry];
  }
  return [mutableEntries copy];
}

#pragma mark - Sanitize Data

- (void)removeOutdatedNotificationDatesFromEntries:(NSArray<RealmEntry *> *)entries {
  NSMutableArray<RealmEntry *> *entriesToUpdate = [NSMutableArray array];
  for (RealmEntry *entry in entries) {
    if (entry.notificationDate != nil && [entry.notificationDate timeIntervalSinceNow] < 0) {
      [entriesToUpdate addObject:entry];
    }
  }

  if (entriesToUpdate.count > 0) {
    [_realm beginWriteTransaction];
    for (RealmEntry *entry in entriesToUpdate) {
      entry.notificationDate = nil;
    }
    [_realm commitWriteTransaction];
  }
}

#pragma mark - Deleting

- (BOOL)archiveEntry:(RealmEntry*)entry {
  return [self _deleteEntry:entry onlyArchive:YES];
}

- (BOOL)unarchiveEntry:(RealmEntry*)entry {
  if (entry.uniqueId) {
    // Fetch entry
    RealmEntry *fetchedEntry = [self entryForEntryID:entry.uniqueId];
    if (fetchedEntry.isArchived) {
      [_realm beginWriteTransaction];
      fetchedEntry.isArchived = NO;
      [_realm commitWriteTransaction];
    }
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)deleteEntry:(RealmEntry*)entry {
  return [self _deleteEntry:entry onlyArchive:NO];
}

- (BOOL)_deleteEntry:(RealmEntry*)entry
         onlyArchive:(BOOL)onlyArchive {
  if (entry.uniqueId) {
    // Fetch entry
    RealmEntry *fetchedEntry = [self entryForEntryID:entry.uniqueId];

    // Cancel notification if needed
    if(fetchedEntry.notificationDate != nil) {
      [SimpleLocalNotification cancelScheduledLocalNotificationsMatchingUniqueIdentifier:fetchedEntry.uniqueId];
    }

    // Delete photo from disk if needed
    if (!onlyArchive &&
        fetchedEntry.photofilename != nil &&
        fetchedEntry.photofilename.length > 0) {
      NSError * error;
      BOOL didDeleteFile = [[NSFileManager defaultManager]
                            removeItemAtPath:PhotoFilePathForRealmEntry(fetchedEntry)
                            error:&error];
      if (!didDeleteFile) {
        NSLog(@"Error deleting file for entry: %@", [error localizedDescription]);
      }
    }

    [_realm beginWriteTransaction];
    if (onlyArchive) {
      fetchedEntry.isArchived = YES;
    } else {
      [_realm deleteObject:fetchedEntry];
    }
    [_realm commitWriteTransaction];

    return YES;
  } else {
    return NO;
  }
}

#pragma mark - Saving

- (void)saveEntry:(RealmEntry*)entry {
  [_realm beginWriteTransaction];
  [_realm addOrUpdateObject:entry];
  [_realm commitWriteTransaction];
}

- (void)saveEntries:(NSArray<RealmEntry *>*)entries {
  [_realm beginWriteTransaction];
  [_realm addOrUpdateObjects:entries];
  [_realm commitWriteTransaction];
}

#pragma mark - Change Listener

- (id<RealmEntryStorageListenerCancelable>)addUpdateListenerBlock:(void(^)(void))updateListenerBlock {
  return [_realm addNotificationBlock:^(RLMNotification notification, RLMRealm *realm) {
    if (updateListenerBlock) {
      updateListenerBlock();
    }
  }];
}

#pragma mark - Default DB Path

static void SetupDefaultRealmWithCustomDatabasePath(void) {
  NSURL *const databaseDirectory = [[[[NSFileManager defaultManager]
                                      URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask]
                                     firstObject]
                                    URLByAppendingPathComponent:@"Database/"];

  if(![[NSFileManager defaultManager] fileExistsAtPath:[databaseDirectory absoluteString]]){
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtURL:databaseDirectory
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
    NSCAssert(error == nil, @"Error creating DB folder: %@", error);
  }

  RLMRealmConfiguration *config = [[RLMRealmConfiguration alloc] init];
  config.fileURL = [databaseDirectory URLByAppendingPathComponent:@"swdb.realm"];
  [RLMRealmConfiguration setDefaultConfiguration:config];
}

@end
