//
//  MigrationController.h
//  StillWaitin
//

#import <UIKit/UIKit.h>

@class Entry;
@class EntryStorage;
@class RealmEntry;
@class RealmEntryStorage;

RealmEntry *RealmEntryForEntry(Entry *entry);

@interface MigrationController : NSObject

- (instancetype)initWithEntryStorage:(EntryStorage *)entryStorage
                   realmEntryStorage:(RealmEntryStorage *)realmEntryStorage;

+ (BOOL)needsMigration;
- (void)executeMigration;
- (void)markMigrationCompleted;

@end
