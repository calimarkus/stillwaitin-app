//
//  RealmEntry.m
//  StillWaitin
//

#import "RealmEntry.h"

NSString *PhotoFilePathForRealmEntry(RealmEntry *entry) {
  if (entry.photofilename) {
    static NSString *documentsDirectory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      documentsDirectory = [paths objectAtIndex:0];
    });
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:entry.photofilename];
    return filePath;
  } else {
    return nil;
  }
}

@implementation RealmLocation : RLMObject

+ (NSDictionary *)defaultPropertyValues {
  return @{@"uniqueId" : [[NSUUID UUID] UUIDString]};
}

- (id)copyWithZone:(NSZone *)zone {
  RealmLocation *location = [[RealmLocation alloc] init];
  location.uniqueId = [self.uniqueId copy];
  location.latitude = self.latitude;
  location.longitude = self.longitude;
  return location;
}

@end

@implementation RealmEntry : RLMObject

+ (NSString *)primaryKey {
  return @"uniqueId";
}

+ (NSArray<NSString *> *)indexedProperties {
  return @[@"fullName",
           @"debtDate",
           @"isArchived"];
}

+ (NSDictionary *)defaultPropertyValues {
  return @{@"uniqueId" : [[NSUUID UUID] UUIDString],
           @"createdAtDate": [NSDate date],
           @"debtDate": [NSDate date],
           @"value": @0};
}

- (id)copyWithZone:(NSZone *)zone {
  RealmEntry *entry = [[RealmEntry alloc] init];
  entry.uniqueId = [self.uniqueId copy];
  entry.createdAtDate = [[self createdAtDate] copy];
  [entry updateWithEntry:self];
  return entry;
}

- (void)updateWithEntry:(RealmEntry *)entry {
  self.fullName = [entry.fullName copy];
  self.email = [entry.email copy];
  self.phoneNumber = [entry.phoneNumber copy];
  self.entryDescription = [entry.entryDescription copy];
  self.photofilename = [entry.photofilename copy];
  self.debtDate = [entry.debtDate copy];
  self.notificationDate = [entry.notificationDate copy];
  self.value = [entry.value copy];
  self.debtDirection = entry.debtDirection;
  self.location = [entry.location copy];
  self.isArchived = entry.isArchived;
}

@end
