//
//  MigrationController.m
//  StillWaitin
//

#import "MigrationController.h"

#import "Entry.h"
#import "EntryStorage.h"
#import "RealmEntry.h"
#import "RealmEntryStorage.h"

static NSString *const kDidMigrateSuccessfullyKey = @"MigrationViewControllerDidMigrateSuccessfullyKey";

RealmEntry *RealmEntryForEntry(Entry *oldEntry) {
  RealmEntry *newEntry = [[RealmEntry alloc] init];
  newEntry.fullName = [[oldEntry.person capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  newEntry.email = oldEntry.email;
  newEntry.phoneNumber = oldEntry.phoneNumber;
  newEntry.entryDescription = oldEntry.entryDescription;
  newEntry.photofilename = oldEntry.photofilename;
  newEntry.debtDate = oldEntry.date;
  newEntry.value = oldEntry.value;
  newEntry.debtDirection = oldEntry.direction;

  if (oldEntry.isLocationAvailable) {
    RealmLocation *location = [[RealmLocation alloc] init];
    location.latitude = oldEntry.location.latitude;
    location.longitude = oldEntry.location.longitude;
    newEntry.location = location;
  }

  return newEntry;
}

@implementation MigrationController {
  EntryStorage *_entryStorage;
  RealmEntryStorage *_realmEntryStorage;
}

- (instancetype)initWithEntryStorage:(EntryStorage *)entryStorage
                   realmEntryStorage:(RealmEntryStorage *)realmEntryStorage {
  self = [super init];
  if (self) {
    _entryStorage = entryStorage;
    _realmEntryStorage = realmEntryStorage;
  }
  return self;
}

+ (BOOL)needsMigration {
  return ([[NSUserDefaults standardUserDefaults] boolForKey:kDidMigrateSuccessfullyKey] != YES);
}

- (void)markMigrationCompleted {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidMigrateSuccessfullyKey];
}

- (void)executeMigration {
  NSMutableArray<RealmEntry *> *newEntries  = [NSMutableArray array];
  NSArray<Entry *> *oldEntries = [_entryStorage entries];
  for (Entry *oldEntry in oldEntries) {
    [newEntries addObject:RealmEntryForEntry(oldEntry)];
  }
  [_realmEntryStorage saveEntries:newEntries];
}

@end
