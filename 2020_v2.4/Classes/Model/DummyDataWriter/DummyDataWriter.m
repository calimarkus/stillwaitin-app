//
//  DummyDataWriter.m
//  StillWaitin
//
//

#ifdef kDEBUG

#import "DummyDataWriter.h"

#import "Entry.h"
#import "RealmEntry.h"

@implementation DummyDataWriter

+ (NSArray<RealmEntry *> *)defaultScreenshotEntries {
  NSMutableArray<RealmEntry *> *entries = [NSMutableArray array];

  // add Anna's entries
  NSArray<NSString *> * const descriptions = @[@"Dinner", @"Groceries", @"Movies", @"Weekend Trip"];
  for (NSString *description in descriptions) {
    RealmEntry *entry = [[RealmEntry alloc] init];
    entry.fullName = @"Anna";
    entry.entryDescription = description;
    entry.debtDate = randomDateWithMaxMonthAgo(12);
    if ([description isEqualToString:@"Movies"]) {
      entry.location = realmLocationWithLatLong(37.756244659423828, -122.41918182373047);
    } else {
      CLLocationCoordinate2D location = randomLocationCoordinates();
      entry.location = realmLocationWithLatLong(location.latitude, location.longitude);
    }
    entry.debtDirection = arc4random()%2;
    entry.value = randomEntryValueWithMaxValue(90);
    [entries addObject:entry];
  }

  // add additional entries
  NSArray<NSString *> * const names = @[@"Martin",
                                        @"Alexander",
                                        @"Andy",
                                        @"Christiana",
                                        @"Markus",
                                        @"Daniela",
                                        @"David",
                                        @"Kate"];

  for (NSString *name in names) {
    int entryCount = arc4random()%30+1;
    for (NSInteger i=0; i<entryCount; i++) {
      RealmEntry *entry = [[RealmEntry alloc] init];
      entry.fullName = name;
      entry.debtDate = randomDateWithMaxMonthAgo(12);
      CLLocationCoordinate2D location = randomLocationCoordinates();
      entry.location = realmLocationWithLatLong(location.latitude, location.longitude);
      entry.debtDirection = arc4random()%2;
      entry.isArchived = arc4random()%2;
      entry.value = randomEntryValueWithMaxValue(90);
      if ([name isEqualToString:@"Andy"] && i==0) {
        entry.entryDescription = @"Concert 🎶";
        entry.isArchived = NO;
      }
      [entries addObject:entry];
    }
  }

  return entries;
}

+ (NSArray<RealmEntry *> *)layoutTestEntries {
  NSMutableArray<RealmEntry *> *entries = [NSMutableArray array];

  RealmEntry *entry = [RealmEntry new];
  entry.fullName = @"Fucking super damn long name";
  entry.entryDescription = @"This is nuts!";
  entry.value = @((arc4random() % 500000) + 12345);
  entry.debtDirection = DebtDirectionOut;
  [entries addObject:entry];

  for (NSInteger i=0; i<3; i++) {
    for (NSInteger x=0; x<50; x++) {
      RealmEntry *entry = [RealmEntry new];
      entry.fullName = @[@"No Desc", @"Short Desc", @"Long Desc"][i];
      entry.entryDescription = ((i > 0) ?
                                ((i == 2) ?
                                 @"This is a quite long description to get the max length." :
                                 @"This is short.") :
                                nil);
      NSArray<NSNumber *> *maxValues = @[@100, @100000, @100000000, @100000000000, @8000000000000];
      NSInteger minValue = (x % maxValues.count > 0
                            ? maxValues[(x-1) % maxValues.count].integerValue
                            : 0);
      entry.value = @((arc4random() % (maxValues[x % maxValues.count].integerValue) - minValue) + minValue);
      [entries addObject:entry];
    }
  }

  return entries;
}

+ (NSArray *)createDummyDataWithPersonCount:(NSInteger)personCount
                     maxEntryCountPerPerson:(NSInteger)maxEntryCountPerPerson
                               maxDebtValue:(NSInteger)maxDebtValue
                       shouldUseLegacyModel:(BOOL)shouldUseLegacyModel {
  NSMutableArray *entries = [NSMutableArray array];
  for (NSInteger i=0; i<personCount; i++) {
    NSString *personName = generateRandomName();
    int entryCount = arc4random()%maxEntryCountPerPerson+1;
    for (NSInteger i=0; i<entryCount; i++) {
      NSString *description = (arc4random() % 6 != 0 ?
                               (arc4random() % 2 != 0 ? nil : @"This is a description.") :
                               @"This is a really very long description, so the value wont fit.");

      if (shouldUseLegacyModel) {
        Entry *entry = [[Entry alloc] init];
        entry.person = personName;
        entry.entryDescription = description;
        entry.date = randomDateWithMaxMonthAgo(3);
        entry.location = randomLocationCoordinates();
        entry.direction = arc4random()%2;
        entry.value = randomEntryValueWithMaxValue(maxDebtValue);
        entry.type = DebtTypeMoney;
        entry.isLocationAvailable = YES;
        [entries addObject:entry];
      } else {
        RealmEntry *entry = [[RealmEntry alloc] init];
        entry.fullName = personName;
        entry.entryDescription = description;
        entry.debtDate = randomDateWithMaxMonthAgo(3);
        CLLocationCoordinate2D location = randomLocationCoordinates();
        entry.location = realmLocationWithLatLong(location.latitude, location.longitude);
        entry.debtDirection = arc4random()%2;
        entry.value = randomEntryValueWithMaxValue(maxDebtValue);
        [entries addObject:entry];
      }
    }
  }
  return entries;
}

static NSNumber *randomEntryValueWithMaxValue(NSInteger maxValue) {
  return @((arc4random() % (maxValue*100)) / 100.0 + 1);
}

static NSDate *randomDateWithMaxMonthAgo(NSInteger maxMonthsAgo) {
  return [[NSDate date] dateByAddingTimeInterval:-(arc4random()%(60*60*24*31*maxMonthsAgo))];
}

static CLLocationCoordinate2D randomLocationCoordinates(void) {
  return CLLocationCoordinate2DMake(33+(arc4random()%15000)/1000.0,   // 33 - 48
                                    -73-(arc4random()%50000)/1000.0); // -123 - -73
}

static RealmLocation *realmLocationWithLatLong(CLLocationDegrees latitude, CLLocationDegrees longitude) {
  RealmLocation *realmlLocation = [[RealmLocation alloc] init];
  realmlLocation.latitude = latitude;
  realmlLocation.longitude = longitude;
  return realmlLocation;
}

static NSString *generateRandomName(void) {
  NSString *(^randomChar)(void) = ^(void) {
    return ([NSString stringWithFormat:@"%c", (char)(65+arc4random()%26)]);
  };

  NSString *(^randomVow)(void) = ^(void) {
    return @[@"A", @"E", @"I", @"O", @"U"][(arc4random()%5)];
  };

  NSMutableString *name = [NSMutableString string];
  [name appendString:randomChar()];
  [name appendString:randomVow()];
  if(arc4random()%2==0) { [name appendString:randomVow()]; }
  [name appendString:randomChar()];
  [name appendString:randomVow()];

  return [name capitalizedString];
}

@end

#endif
