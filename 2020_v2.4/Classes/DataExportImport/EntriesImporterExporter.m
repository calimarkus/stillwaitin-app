//
//  EntryStorage+DataExchange.m
//  StillWaitin
//
//

#import "EntriesImporterExporter.h"
#import "RealmEntry.h"

#import <CHCSVParser/CHCSVParser.h>

double const EntryMaxValue = 9999999999999.99;

static RealmEntry *RealmEntryFromJSONObject(NSDictionary * entryDict) {
  // check, if the minimum required properties exist
  if (![entryDict objectForKey:@"person"] || ![entryDict objectForKey:@"value"]) {
    return nil;
  }

  // create entry
  RealmEntry *entry = [[RealmEntry alloc] init];
  entry.fullName = [[entryDict[@"person"] capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  entry.value = @([entryDict[@"value"] doubleValue]);
  entry.debtDirection = ([entryDict[@"direction"] isEqualToString:@"IOU"] ?
                         DebtDirectionOut :
                         DebtDirectionIn);
  entry.entryDescription = entryDict[@"description"] ?: @"";
  entry.debtDate = [NSDate dateWithTimeIntervalSince1970:[entryDict[@"dateGMT"] doubleValue]];

  BOOL isLocationAvailable = [entryDict[@"locationAvailable"] boolValue];
  if (isLocationAvailable) {
    entry.location = [[RealmLocation alloc] init];
    entry.location.latitude = [entryDict[@"latitude"] doubleValue];
    entry.location.longitude = [entryDict[@"longitude"] doubleValue];
  }

  entry.isArchived = [entryDict[@"isArchived"] boolValue];

  // respect max/min value
  if ([entry.value doubleValue] < -EntryMaxValue ||
      [entry.value doubleValue] > EntryMaxValue) {
    return nil;
  }

  return entry;
}

static NSDictionary *JsonRepresentationForEntry(RealmEntry *entry) {
  return @{@"person":entry.fullName,
           @"direction": (entry.debtDirection == DebtDirectionIn ? @"YOM" : @"IOU"),
           @"description":entry.entryDescription ?: @"",
           @"value":entry.value,
           @"dateGMT":@((int)[entry.debtDate timeIntervalSince1970]),
           @"locationAvailable":@(entry.location != nil),
           @"latitude":@(entry.location.latitude),
           @"longitude":@(entry.location.longitude),
           @"isArchived":@(entry.isArchived)};
}

static NSArray *OrderedCSVKeys(void) {
  return @[@"person",
           @"direction",
           @"description",
           @"value",
           @"dateGMT",
           @"locationAvailable",
           @"latitude",
           @"longitude",
           @"isArchived"];
}

@implementation EntriesImporterExporter

+ (NSString*)exportEntriesToDisk:(NSArray<RealmEntry *> *)entries
                 usingJsonFormat:(BOOL)usingJsonFormat {
  // create file path
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filename = usingJsonFormat ? @"export.json" : @"export.csv";
  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];

  // create json dictionary
  NSMutableArray *jsonDebts = [NSMutableArray arrayWithCapacity:entries.count];
  [entries enumerateObjectsUsingBlock:^(RealmEntry *entry, NSUInteger idx, BOOL *stop) {
    [jsonDebts addObject:JsonRepresentationForEntry(entry)];
  }];

  // JSON export
  if (usingJsonFormat) {
    // add meta data
    NSDictionary *metaData = @{@"appName":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"],
                               @"appVersion":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                               @"model":[UIDevice currentDevice].model,
                               @"systemName":[UIDevice currentDevice].systemName,
                               @"systemVersion":[UIDevice currentDevice].systemVersion,
                               @"exportDateGMT":@((int)[[NSDate date] timeIntervalSince1970])
                               };

    // create export dictionary
    NSMutableDictionary *exportDictionary = [NSMutableDictionary dictionary];
    [exportDictionary setObject:jsonDebts forKey:@"entries"];
    [exportDictionary setObject:metaData forKey:@"meta"];

    // write json file
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:exportDictionary options:0 error:nil];
    BOOL success = [jsonData writeToFile:filePath atomically:YES];
    if (!success) return nil;
  }

  // CSV export
  else {
    NSArray *keys = OrderedCSVKeys();
    CHCSVWriter* writer = [[CHCSVWriter alloc] initForWritingToCSVFile:filePath];
    [writer writeLineOfFields:keys];
    [jsonDebts enumerateObjectsUsingBlock:^(NSDictionary *entryDict, NSUInteger idx, BOOL *stop) {
      for (NSString *key in keys) {
        [writer writeField:[entryDict objectForKey:key]];
      }
      [writer finishLine];
    }];
    [writer closeStream];
  }

  return filePath;
}

+ (NSArray*)importDataFromFilePath:(NSString*)filePath {
  NSArray *entries = nil;
  NSError *error;

  // try JSON import
  NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
  if (data && !error) {
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!error) {
      entries = [self importJSONDictionary:jsonDict];
    }
  }

  // try CSV import
  if ((!data || error) && !entries) {
    NSArray *csvArray = [NSArray arrayWithContentsOfCSVURL:[NSURL fileURLWithPath:filePath]];
    if (csvArray) {
      entries = [self importCSVArray:csvArray];
    }
  }

  // delete file
  [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];

  return entries;
}

+ (NSArray*)importCSVArray:()csvArray {
  // create json dictionary
  NSArray *keys;
  NSMutableArray *entryDicts = [NSMutableArray array];
  for (NSArray *valueArray in csvArray) {
    if ([valueArray[0] isEqualToString:@"person"]) {
      keys = valueArray;
      continue;
    }
    if (keys && keys.count == valueArray.count) {
      NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
      [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (valueArray.count != keys.count) return;
        entryDict[key] = valueArray[idx];
      }];
      [entryDicts addObject:entryDict];
    }
  }

  // use json importer
  NSDictionary *jsonDict = @{@"entries":entryDicts};
  return [self importJSONDictionary:jsonDict];
}

+ (NSArray*)importJSONDictionary:(NSDictionary*)jsonDict {
  if(jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
    NSArray *entrieDicts = jsonDict[@"entries"];
    if (entrieDicts) {
      NSMutableArray *entries = [NSMutableArray arrayWithCapacity:entrieDicts.count];
      for (NSDictionary *entryDict in entrieDicts) {
        RealmEntry *entry = RealmEntryFromJSONObject(entryDict);
        if (entry) {
          [entries addObject:entry];
        }
      }
      return entries;
    }
  }
  return nil;
}

@end

