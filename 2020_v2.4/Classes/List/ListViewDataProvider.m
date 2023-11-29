//
//  ListViewDataSource.m
//  StillWaitin
//

#import "ListViewDataProvider.h"

#import "NSArray+Map.h"
#import "RealmEntry.h"
#import "RealmEntryGroup.h"
#import "RealmEntryStorage.h"

@implementation ListViewDataProvider {
  RealmEntryStorage *_entryStorage;
  NSArray<RealmEntryGroup *> *_entryGroups;
}

- (instancetype)initWithRealmEntryStorage:(RealmEntryStorage *)entryStorage {
  self = [super init];
  if (self) {
    _entryStorage = entryStorage;
  }
  return self;
}

#pragma mark - Public

- (void)refetchData {
  NSArray<RealmEntry *> *entries = EntriesForSettings(_entryStorage, _contentType, _exactFullName);

  NSSet<NSString *> *entryIdsToExcludeFromDisplay = EntryIdsToExcludeFromDisplayForSearchString(entries,
                                                                                                _currentSearchString,
                                                                                                _shouldSearchForPersonMatches,
                                                                                                _shouldSearchForEntryMatches);
  [_entryStorage removeOutdatedNotificationDatesFromEntries:entries];
  _entryGroups = EntryGroupsForEntries(entries,
                                       entryIdsToExcludeFromDisplay,
                                       _contentType == ListViewDataSourceContentTypeAll,
                                       _contentType == ListViewDataSourceContentTypeArchivedGroups);
  _totalSumAcrossAllEntries = TotalSumForEntryGroups(_entryGroups);
}

#pragma mark - Internal

static NSArray<RealmEntry *> *EntriesForSettings(RealmEntryStorage *entryStorage,
                                                 ListViewDataSourceContentType contentType,
                                                 NSString *exactFullName) {
  if (exactFullName.length > 0) {
    switch (contentType) {
      case ListViewDataSourceContentTypeActive:
        return [entryStorage entriesMatchingFullName:exactFullName withFilter:RealmEntryStorageFilterActiveEntries];
      case ListViewDataSourceContentTypeArchivedEntries:
        return [entryStorage entriesMatchingFullName:exactFullName withFilter:RealmEntryStorageFilterArchivedEntries];
      case ListViewDataSourceContentTypeAll:
      case ListViewDataSourceContentTypeArchivedGroups:
        return [entryStorage entriesMatchingFullName:exactFullName withFilter:RealmEntryStorageFilterAllEntries];
    }
  } else {
    switch (contentType) {
      case ListViewDataSourceContentTypeActive:
        return [entryStorage entriesWithFilter:RealmEntryStorageFilterActiveEntries];
      case ListViewDataSourceContentTypeArchivedEntries:
        return [entryStorage entriesWithFilter:RealmEntryStorageFilterArchivedEntries];
      case ListViewDataSourceContentTypeAll:
      case ListViewDataSourceContentTypeArchivedGroups:
        return [entryStorage entriesWithFilter:RealmEntryStorageFilterAllEntries];
    }
  }
}

static NSSet<NSString *> *EntryIdsToExcludeFromDisplayForSearchString(NSArray<RealmEntry *> *entries,
                                                                      NSString * _Nullable searchString,
                                                                      BOOL shouldSearchForPersonMatches,
                                                                      BOOL shouldSearchForEntryMatches) {
  if (searchString.length == 0) {
    return nil;
  } else {
    NSMutableSet *excludedEntries = [NSMutableSet set];
    for (RealmEntry *entry in entries) {
      BOOL matchesSearch = ((shouldSearchForPersonMatches
                             && [entry.fullName localizedCaseInsensitiveContainsString:searchString])
                            || (shouldSearchForEntryMatches
                                && [entry.entryDescription localizedCaseInsensitiveContainsString:searchString]));
      if (!matchesSearch) {
        [excludedEntries addObject:entry.uniqueId];
      }
    }
    return excludedEntries;
  }
}

static double TotalSumForEntryGroups(NSArray<RealmEntryGroup *> *entryGroups) {
  double totalSum = 0;
  for (RealmEntryGroup *entryGroup in entryGroups) {
    totalSum += [entryGroup.totalValue doubleValue];
  }
  return totalSum;
}

@end
