//
//  RealmEntryGroup.m
//  StillWaitin
//

#import "NSArray+Map.h"
#import "RealmEntry.h"
#import "RealmEntryGroup.h"
#import "SWSettings.h"

NSArray<RealmEntryGroup *> *EntryGroupsForEntries(NSArray<RealmEntry *> *entries,
                                                  NSSet<NSString *> *entryIdsToExcludeFromDisplay,
                                                  BOOL excludeArchivedEntriesFromTotalValue,
                                                  BOOL filterToArchivedGroupsOnly) {
  // group by person
  NSMutableDictionary<NSString *, NSMutableArray<RealmEntry *>*> *const nameToEntryArray = [NSMutableDictionary dictionary];
  for (RealmEntry* entry in entries) {
    NSString *cleanedUpName = [[entry.fullName capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray<RealmEntry *> *existingArray = nameToEntryArray[cleanedUpName];
    if(existingArray) {
      [existingArray addObject:entry];
    } else {
      nameToEntryArray[cleanedUpName] = [NSMutableArray arrayWithObject:entry];
    }
  }

  // create EntryGroups
  NSMutableArray<RealmEntryGroup *> *const entryGroups = [NSMutableArray arrayWithCapacity:nameToEntryArray.count];
  [nameToEntryArray enumerateKeysAndObjectsUsingBlock:^(NSString *fullName, NSMutableArray<RealmEntry *> *entryArray, BOOL *stop) {
    // sort entries by date
    [entryArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"debtDate" ascending:NO]]];

    double totalValue = 0;
    BOOL allEntriesAreArchived = YES;
    for (RealmEntry *entry in entryArray) {
      if (excludeArchivedEntriesFromTotalValue && entry.isArchived) {
        continue;
      }
      totalValue  = (entry.debtDirection == DebtDirectionOut ?
                     totalValue - entry.value.doubleValue :
                     totalValue + entry.value.doubleValue);

      allEntriesAreArchived &= entry.isArchived;
    }

    RealmEntryGroup *group = [[RealmEntryGroup alloc] init];
    group.fullName = [[entryArray.firstObject.fullName capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    group.entries = [entryArray filter:^BOOL(RealmEntry *entry) {
      return ![entryIdsToExcludeFromDisplay containsObject:entry.uniqueId];
    }];
    group.totalValue = @(totalValue);
    group.allEntriesAreArchived = allEntriesAreArchived;

    BOOL filterOutArchivedGroup = (filterToArchivedGroupsOnly && !group.allEntriesAreArchived);
    if (group.entries.count > 0 && !filterOutArchivedGroup) {
      [entryGroups addObject:group];
    }
  }];

  // sort groups alphabetically
  [entryGroups sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]]];

  return [entryGroups copy];
}

@implementation RealmEntryGroup

- (NSDate *)dateForSorting {
  return _entries.firstObject.debtDate;
}

@end
