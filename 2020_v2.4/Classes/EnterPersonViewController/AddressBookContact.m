//
//  AddressBookContact.m
//  StillWaitin
//

#import "AddressBookContact.h"

@implementation AddressBookContact

@synthesize fullName = _fullName;
@synthesize email = _email;
@synthesize phoneNumber = _phoneNumber;
@synthesize lastUsedDate = _lastUsedDate;
@synthesize allowDeletion = _allowDeletion;

- (instancetype)initWithFullName:(NSString *)fullName
                           email:(nullable NSString *)email
                     phoneNumber:(nullable NSString *)phoneNumber
                    lastUsedDate:(nullable NSDate *)lastUsedDate
                   allowDeletion:(BOOL)allowDeletion {
  self = [super init];
  if (self) {
    _fullName = [fullName copy];
    _email = [email copy] ?: @"";
    _phoneNumber = [phoneNumber copy] ?: @"";
    _lastUsedDate = [lastUsedDate copy];
    _allowDeletion = allowDeletion;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat: @"%@ \"%@\"", [super description], _fullName];
}

@end
