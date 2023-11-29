//
//  EntryStorage.m
//  StillWaitin
//
//


#import "Entry.h"
#import "EntryStorage.h"
#import "SWSettings.h"

// don't change the keys, they are used in old data
NSString *const SWEntriesUserDefaultsKey = @"entry";
NSString *const SWEntriesNextUniqueEntryID = @"kKEY_USERDEFAULTS_UNIQUE_ENTRY_ID";
NSString *const EntryStorageDidUpdateNotification = @"EntryStorageDidUpdateNotification";

@interface EntryStorage ()
@property (nonatomic, strong) NSMutableArray<Entry *> *mutableEntries;
@property (nonnull, strong) NSString *storageKey;
@end

@implementation EntryStorage

+ (instancetype)sharedStorage {
  static EntryStorage *collection = nil;
  if (!collection) {
    collection = [[EntryStorage alloc] init];
  }
  return collection;
}

- (instancetype)init {
  return [self initWithStorageKey:SWEntriesUserDefaultsKey];
}

- (instancetype)initWithStorageKey:(NSString *)storageKey {
  self = [super init];
  if (self) {
    _storageKey = [storageKey copy];
  }
  return self;
}

- (NSArray<Entry *> *)entries {
  return [NSArray arrayWithArray:self.mutableEntries];
}

- (NSMutableArray<Entry *> *)mutableEntries {
  if(!_mutableEntries) {
    _mutableEntries = [self readFromUserDefaults];
    [self runCompatibilityChecks];
  }

  return _mutableEntries;
}

- (NSArray<NSArray<Entry *> *> *)entriesGroupedByPerson {
  return [self groupEntriesByPerson:self.entries];
}

#pragma mark Data logic

- (void)runCompatibilityChecks {
  BOOL didUpdateData = NO, hasEntry4Instances = NO;
  for (Entry* entry in self.mutableEntries)
  {
    // add entryId, if missing
    if (!entry.entryId) {
      entry.entryId = [EntryStorage nextEntryID];
      didUpdateData = YES;
    }

    // change to money type, if not of money type
    if (entry.type != DebtTypeMoney) {
      entry.type = DebtTypeMoney;
      didUpdateData = YES;
    }

    // update photopath to only contain filename
    if (entry.photofilename != nil && [entry.photofilename rangeOfString:@"/Documents/"].location != NSNotFound) {
      NSRange range = [entry.photofilename rangeOfString:@"/Documents/"];
      entry.photofilename = [entry.photofilename substringFromIndex:range.location+range.length];
      didUpdateData = YES;
    }

    // check for old entry classes
    if ([entry isMemberOfClass:[Entry4 class]]) {
      hasEntry4Instances = YES;
    }
  }

  // update to new unified entry class
  if (hasEntry4Instances) {
    NSMutableArray *newEntries = [NSMutableArray arrayWithCapacity:self.mutableEntries.count];
    for(uint i = 0; i < self.mutableEntries.count; i++)
    {
      Entry4* entry = (Entry4*)[self.mutableEntries objectAtIndex:i];
      Entry* newEntry = [entry copy];
      [newEntries addObject:newEntry];
    }
    self.mutableEntries = newEntries;
    didUpdateData = YES;
  }

  // save, if data was changed
  if (didUpdateData) {
    [self saveToUserDefaults];
  }
}

- (NSArray<NSArray<Entry *> *> *)groupEntriesByPerson:(NSArray<Entry *> *)entries {
  NSMutableArray<NSMutableArray<Entry *> *> *entriesGroupedByPerson = [NSMutableArray array];

  for (Entry* entry in entries)
  {
    // determine whether person already exists in entry array
    NSInteger existingPersonPosition = NSNotFound;
    for(NSInteger i=0; i < entriesGroupedByPerson.count; i++) {
      Entry* savedEntry = entriesGroupedByPerson[i][0];
      if([entry.person caseInsensitiveCompare:savedEntry.person] == NSOrderedSame) {
        existingPersonPosition = i;
        break;
      }
    }

    // check, if person is existing
    if(existingPersonPosition != NSNotFound) {
      NSMutableArray *personArray = entriesGroupedByPerson[existingPersonPosition];
      [personArray addObject:entry];
    }

    // else add a new person
    else {
      NSMutableArray *newPersonArray = [NSMutableArray array];
      [newPersonArray addObject:entry];
      [entriesGroupedByPerson addObject:newPersonArray];
    }
  }

  // calculate balance and save footer strings
  for (NSArray *personEntryArray in entriesGroupedByPerson)
  {
    // sum up entries
    double balance = 0.0;
    for (Entry *entry in personEntryArray) {
      balance += [entry.signedValue doubleValue];
    }

    // save in first entry
    Entry* firstEntryOfPerson = (Entry*)personEntryArray[0];
    firstEntryOfPerson.totalValueForPerson = @(balance);
  }

  // order alphabetically
  [entriesGroupedByPerson sortUsingComparator:^NSComparisonResult(NSMutableArray<Entry *> *personArray, NSMutableArray<Entry *> *otherPersonArray) {
    return [personArray.firstObject.person caseInsensitiveCompare:otherPersonArray.firstObject.person];
  }];

  return entriesGroupedByPerson;
}

#pragma mark date interaction

- (BOOL)deleteEntry:(Entry*)entry {
  if (!entry) return NO;

  // Delete photo if needed
  if (entry.photoPath != nil && entry.photoPath.length > 0) {
    NSError * error;
    if ([[NSFileManager defaultManager] removeItemAtPath:entry.photoPath error:&error] != YES) {
      NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }
  }

  NSInteger count = self.mutableEntries.count;
  [self.mutableEntries removeObject:entry];
  if (self.mutableEntries.count == count) {
    NSLog(@"ENTRY NOT DELETED");
    return NO;
  }
  NSAssert(self.mutableEntries.count == count-1, @"Deleted more than one entry.");

  // save changes
  [self saveToUserDefaults];

  // log deletion

  return YES;
}

- (void)saveEntry:(Entry*)entry {
  if (!entry || ![entry isKindOfClass:[Entry class]]) return;

  if (!entry.entryId) {
    // set ID if not existing
    entry.entryId = [EntryStorage nextEntryID];
  }

  [self.mutableEntries addObject:entry];
  [self saveToUserDefaults];

  // log addition
}

- (void)saveEntries:(NSArray<Entry *>*)entries {
  for (Entry *entry in entries) {
    [self saveEntry:entry];
  }
}

#pragma mark entry id

+ (NSString*)nextEntryID {
  NSInteger entryID = [[NSUserDefaults standardUserDefaults] integerForKey:SWEntriesNextUniqueEntryID];
  [[NSUserDefaults standardUserDefaults] setInteger:entryID+1 forKey:SWEntriesNextUniqueEntryID];
  return [NSString stringWithFormat: @"ID_%07ld", (long)entryID];
}

#pragma mark NSUserDefaults

- (NSMutableArray*)readFromUserDefaults {
  NSMutableArray *result;
  NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:_storageKey];
  if (data != nil) {
    result = [[NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:data error:nil] mutableCopy];
  } else {
    result = [NSMutableArray array];
  }
  return result;
}

- (void)saveToUserDefaults {
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.mutableEntries requiringSecureCoding:NO error:nil];
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:_storageKey];
  [[NSUserDefaults standardUserDefaults] synchronize];

  // send update notification
  [[NSNotificationCenter defaultCenter] postNotificationName:EntryStorageDidUpdateNotification
                                                      object:nil];
}

@end

