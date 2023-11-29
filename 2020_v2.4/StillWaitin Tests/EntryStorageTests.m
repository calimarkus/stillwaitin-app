//
//  StillWaitin_Tests.m
//  StillWaitin Tests
//
//

#import "DummyDataWriter.h"
#import "Entry.h"
#import "EntryStorage.h"
#import "MigrationController.h"
#import "RealmEntry.h"
#import "RealmEntryStorage.h"

#import <Realm/RLMRealm.h>
#import <Realm/RLMRealmConfiguration.h>
#import <Realm/RLMResults.h>

#import <XCTest/XCTest.h>

@interface EntryStorageTests : XCTestCase
@end

@implementation EntryStorageTests {
  RLMRealm *_testRealm;
}

- (void)setUp
{
  RLMRealmConfiguration *config = [[RLMRealmConfiguration alloc] init];
  config.inMemoryIdentifier = @"TestRealmForEntryStorageTests";
  [RLMRealmConfiguration setDefaultConfiguration:config];
  _testRealm = [RLMRealm defaultRealm];

  XCTAssert([_testRealm.configuration.inMemoryIdentifier isEqualToString:config.inMemoryIdentifier],
            @"Realm not setup correctly.");
}

- (void)tearDown
{
  _testRealm = nil;
}

- (void)testLegacyEntryStorage
{
  NSInteger entryCount = 233, deleteCount = 213;

  // create some debug entries
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"testLegacyEntryStorage"];
  EntryStorage *entryStorage = [[EntryStorage alloc] initWithStorageKey:@"testLegacyEntryStorage"];
  [entryStorage saveEntries:[DummyDataWriter createDummyDataWithPersonCount:entryCount
                                                     maxEntryCountPerPerson:1
                                                              maxDebtValue:50
                                                      shouldUseLegacyModel:YES]];
  XCTAssert(entryStorage.entries.count == entryCount, @"Dummy Data was not added correctly");

  // group entries
  NSArray *allEntries = [entryStorage entries];
  XCTAssert(allEntries.count == entryCount, @"Wrong count of entries");

  // delete some entries
  for (NSInteger i=0; i<deleteCount; i++) {
    [entryStorage deleteEntry:entryStorage.entries.lastObject];
  }

  // group entries again
  allEntries = [entryStorage entries];
  XCTAssert(allEntries.count == (entryCount-deleteCount), @"Dummy Data was not added correctly");
}

- (void)testInsertEntryToMemoryRealm
{
  // create realm storage
  RealmEntryStorage *realmStorage = [[RealmEntryStorage alloc] initWithRealm:_testRealm];

  RealmEntry *entry = [RealmEntry new];
  entry.fullName = @"One";
  entry.value = @15;
  [realmStorage saveEntry:entry];

  NSArray<RealmEntry *> *entries = [realmStorage entriesWithFilter:RealmEntryStorageFilterAllEntries];

  XCTAssert(entries.count == 1, @"Entry wasn't saved successfully");
  XCTAssert([entries.firstObject.fullName isEqualToString:@"One"], @"Saved Entry has wrong name");
  XCTAssert([entries.firstObject.value isEqualToNumber:@15], @"Saved Entry has wrong value");

  CleanupRealm(_testRealm);
  XCTAssert([RealmEntry allObjects].count == 0, @"Couldn't delete all entries.");
}

- (void)testMigrationToRealm
{
  // create storage & add some debug entries
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"testMigrationToRealm"];
  EntryStorage *entryStorage = [[EntryStorage alloc] initWithStorageKey:@"testMigrationToRealm"];
  [entryStorage saveEntries:[DummyDataWriter createDummyDataWithPersonCount:500
                                                     maxEntryCountPerPerson:1
                                                              maxDebtValue:999
                                                      shouldUseLegacyModel:YES]];
  XCTAssert(entryStorage.entries.count == 500, @"Dummy Data was not added correctly");

  // create realm storage
  RealmEntryStorage *realmStorage = [[RealmEntryStorage alloc] initWithRealm:_testRealm];

  // migrate
  MigrationController *migrationController = [[MigrationController alloc] initWithEntryStorage:entryStorage
                                                                             realmEntryStorage:realmStorage];
  [migrationController executeMigration];

  NSArray<Entry *> *oldEntries = [entryStorage entries];
  NSArray<RealmEntry *> *newEntries = [realmStorage entriesWithFilter:RealmEntryStorageFilterAllEntries];

  XCTAssert(oldEntries.count == newEntries.count, @"New store has different count of entries after Migration");

  BOOL foundExactEntry = NO;
  Entry *oldEntry = oldEntries.firstObject;
  for (RealmEntry *entry in newEntries) {
    if (entry.debtDirection == oldEntry.direction &&
        IsEqualOrBothNil(entry.fullName, oldEntry.person) &&
        IsEqualOrBothNil(entry.value, oldEntry.value) &&
        IsEqualOrBothNil(entry.email, oldEntry.email) &&
        IsEqualOrBothNil(entry.phoneNumber, oldEntry.phoneNumber) &&
        IsEqualOrBothNil(entry.entryDescription, oldEntry.entryDescription) &&
        IsEqualOrBothNil(entry.photofilename, oldEntry.photofilename)) {
      foundExactEntry = YES;
      break;
    }
  }
  XCTAssert(foundExactEntry, @"Couldn't find exact copy of existing entry.");

  CleanupRealm(_testRealm);
  XCTAssert([RealmEntry allObjects].count == 0, @"Couldn't delete all entries.");
}

static BOOL IsEqualOrBothNil(id left, id right) {
  return ((left == nil && right == nil) ||
          [left isEqual:right]);
}

static void CleanupRealm(RLMRealm *_testRealm) {
  [_testRealm beginWriteTransaction];
  [_testRealm deleteAllObjects];
  [_testRealm commitWriteTransaction];
}

@end
