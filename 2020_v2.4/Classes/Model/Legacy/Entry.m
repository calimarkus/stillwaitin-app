//
//  Entry.m
//  StillWaitin
//

#import "CurrencyManager.h"

#import "Entry.h"

NSInteger const EntryMaxDescriptionLength = 120;

@implementation Entry

- (instancetype)init {
  self = [super init];
  if (self) {
    // set default values
    _person = @"";
    _entryDescription = @"";
    _date = [NSDate date];
    _value = @(0);
    _totalValueForPerson = @(0);
    _location = CLLocationCoordinate2DMake(0, 0);
    _isLocationAvailable = NO;
    _hasPhoto = NO;
  }
  return self;
}

- (NSNumber *)signedValue {
  if (self.direction == DebtDirectionIn) {
    return self.value;
  } else {
    return @(-[self.value doubleValue]);
  }
}

- (NSString *)photoPath {
  if (!self.photofilename) return nil;

  static NSString *documentsDirectory;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
  });

  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.photofilename];
  return filePath;
}

- (void)setEntryDescription:(NSString *)entryDescription {
  if (entryDescription.length > EntryMaxDescriptionLength) {
    entryDescription = [entryDescription substringToIndex:EntryMaxDescriptionLength];
  }

  _entryDescription = entryDescription;
}

- (NSString *)description {
  return [NSString stringWithFormat:
          @"%@ (\n\
          EntryId: %@, \n\
          Date: %@\n\
          Description: %@\n\
          Direction: %@\n\
          Email: %@\n\
          hasPhoto: %@\n\
          Location: %@, %@\n\
          IsLocationAvailable: %@\n\
          Person: %@\n\
          Photofilename: %@\n\
          Type: %@\n\
          Value: %@\n\
          )",
          [super description],
          self.entryId,
          self.date,
          self.entryDescription,
          @(self.direction),
          self.email,
          @(self.hasPhoto),
          @(self.location.latitude),
          @(self.location.longitude),
          @(self.isLocationAvailable),
          self.person,
          self.photofilename,
          @(self.type),
          self.value];
}

@end

#pragma mark - reverting

@implementation Entry (RevertSupport)

- (void)updateWithEntry:(Entry*)entry {
  self.value = entry.value;
  self.person = entry.person;
  self.email = entry.email;
  self.phoneNumber = entry.phoneNumber;
  self.entryDescription = entry.entryDescription;
  self.photofilename = entry.photofilename;
  self.date = entry.date;
  self.value = entry.value;
  self.totalValueForPerson = entry.totalValueForPerson;
  self.location = entry.location;
  self.isLocationAvailable = entry.isLocationAvailable;
  self.hasPhoto = entry.hasPhoto;
  self.direction = entry.direction;
  self.type = entry.type;
}

@end

#pragma mark - NSCopying logic

@implementation Entry (NSCopying)

- (id)copyWithZone:(NSZone *)zone {
  Entry *entry = [[Entry allocWithZone:zone] init];
  entry.entryId               = self.entryId;
  entry.date                  = self.date;
  entry.entryDescription      = self.entryDescription;
  entry.direction             = self.direction;
  entry.email                 = self.email;
  entry.hasPhoto              = self.hasPhoto;
  entry.location              = self.location;
  entry.isLocationAvailable   = self.isLocationAvailable;
  entry.person                = self.person;
  entry.photofilename         = self.photofilename;
  entry.type                  = self.type;
  entry.value                 = self.value;
  entry.totalValueForPerson   = self.totalValueForPerson;
  return entry;
}

@end

#pragma mark - NSCoding logic

@implementation Entry (NSCoding)

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.entryId forKey:@"entryId"];
  [encoder encodeObject:self.entryDescription forKey:@"description"];
  [encoder encodeObject:self.email forKey:@"email"];
  [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
  [encoder encodeObject:self.person forKey:@"person"];
  [encoder encodeObject:self.value forKey:@"value"];
  [encoder encodeObject:self.date forKey:@"date"];
  [encoder encodeObject:self.photofilename forKey:@"photofilename"];
  [encoder encodeInteger:self.direction forKey:@"direction"];
  [encoder encodeInteger:self.type forKey:@"type"];
  [encoder encodeInteger:self.isLocationAvailable forKey:@"isLocationAvailable"];
  [encoder encodeInteger:self.hasPhoto forKey:@"hasPhoto"];

  [encoder encodeDouble:self.location.latitude forKey:@"locationLatitude"];
  [encoder encodeDouble:self.location.longitude forKey:@"locationLongitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  self.entryId				= [decoder decodeObjectForKey:@"entryId"];
  self.entryDescription		= [decoder decodeObjectForKey:@"description"];
  self.email					= [decoder decodeObjectForKey:@"email"];
  self.phoneNumber			= [decoder decodeObjectForKey:@"phoneNumber"];
  self.person					= [decoder decodeObjectForKey:@"person"];
  self.value					= [decoder decodeObjectForKey:@"value"];
  self.date					= [decoder decodeObjectForKey:@"date"];
  self.photofilename			= [decoder decodeObjectForKey:@"photofilename"];
  self.direction				= (DebtDirection)[decoder decodeIntegerForKey:@"direction"];
  self.type					= (DebtType)[decoder decodeIntegerForKey:@"type"];
  self.isLocationAvailable	= [decoder decodeIntegerForKey:@"isLocationAvailable"];
  self.hasPhoto				= [decoder decodeIntegerForKey:@"hasPhoto"];

  double longitude			= [decoder decodeDoubleForKey:@"locationLongitude"];
  double latitude				= [decoder decodeDoubleForKey:@"locationLatitude"];
  self.location				= (CLLocationCoordinate2D){latitude, longitude};

  return self;
}

@end


// needed to read old NSCoding encoded Entry4 instances
@implementation Entry4
@end

