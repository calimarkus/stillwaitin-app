//
//  AddressBookUtility.m
//  StillWaitin
//

#import "AddressBookUtility.h"
#import "AddressBookContact.h"

#import <Contacts/Contacts.h>


// Don't change this key, because it is used in old versions already
static NSString *const SWPreviouslyUsedContactsUserDefaultsKey = @"customPerson";

// How long should used persons be remembered?
// 2678400 sec = 31 days (31*24*60*60)
static NSTimeInterval const SWpreviouslyUsedContactsLifeTime = 2678400;

@implementation AddressBookUtility

+ (void)requestPermissionIfNeededWithCompletion:(void(^)(BOOL accessGranted, NSError *error))completion {
  NSParameterAssert(completion);

  switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
    case CNAuthorizationStatusNotDetermined: {
      [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(granted, error);
        });
      }];
      break;
    }
    case CNAuthorizationStatusAuthorized: {
      completion(YES, nil);
      break;
    }
    case CNAuthorizationStatusDenied:
    case CNAuthorizationStatusRestricted: {
      completion(NO, nil);
      break;
    }
  }
}

+ (void)readAllContactsFromAddressBookWithCompletion:(AddressBookBlock)addressBookBlock {
  NSParameterAssert(addressBookBlock);

  [self requestPermissionIfNeededWithCompletion:^(BOOL accessGranted, NSError *error) {
    if (!accessGranted) {
      addressBookBlock([NSArray array], error);
    } else {
      NSMutableArray<AddressBookContact *> *allContacts = [[NSMutableArray alloc] init];

      CNContactStore *contactStore = [[CNContactStore alloc] init];
      CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey,
                                                                                                 CNContactGivenNameKey,
                                                                                                 CNContactMiddleNameKey,
                                                                                                 CNContactFamilyNameKey,
                                                                                                 CNContactOrganizationNameKey,
                                                                                                 CNContactEmailAddressesKey,
                                                                                                 CNContactPhoneNumbersKey]];

      NSError *fetchError;
      [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
        if (contact.givenName.length > 0 || contact.middleName.length > 0 || contact.familyName.length > 0) {
          NSString *fullName = [[NSString stringWithFormat:@"%@ %@",
                                 contact.givenName ?: @"",
                                 (contact.familyName.length > 0
                                  ? contact.familyName
                                  : (contact.middleName.length > 0
                                     ? contact.middleName
                                     : (contact.givenName.length > 0 && contact.organizationName.length > 0
                                        ? [NSString stringWithFormat:@"(%@)", contact.organizationName]
                                        : @"")))]
                                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

          AddressBookContact *abContact = [[AddressBookContact alloc] initWithFullName:fullName
                                                                                 email:contact.emailAddresses.firstObject.value
                                                                           phoneNumber:contact.phoneNumbers.firstObject.value.stringValue
                                                                          lastUsedDate:nil
                                                                         allowDeletion:NO];
          [allContacts addObject:abContact];
        }
      }];

      addressBookBlock(allContacts, fetchError);
    }
  }];
}

+ (NSArray<AddressBookContact *> *)previouslyUsedContacts {
  NSMutableArray<NSDictionary *> *savedCustomPersonsArray = [self _rawPreviouslyUsedContacts];

  BOOL didRemovePerson = NO;
  NSMutableArray<AddressBookContact *> *recentPersons = [NSMutableArray array];

  // create contact objects
  AddressBookContact *customContact = nil;
  for (NSInteger i=0; i<savedCustomPersonsArray.count; i++) {
    NSDictionary *personDict = savedCustomPersonsArray[i];

    NSDate* personDate = [personDict objectForKey: @"date"];
    if ([[NSDate date] timeIntervalSinceDate: personDate] < SWpreviouslyUsedContactsLifeTime ) {
      customContact = [[AddressBookContact alloc] initWithFullName:[personDict objectForKey:@"person"]
                                                             email:nil
                                                       phoneNumber:nil
                                                      lastUsedDate:personDate
                                                     allowDeletion:YES];
      [recentPersons addObject:customContact];
    } else {
      didRemovePerson = YES;
      [savedCustomPersonsArray removeObject:personDict];
      i--; // fix index, because we removed one object
    }
  }

  // save new array, if smth changed
  if (didRemovePerson) {
    [self _storePreviouslyUsedContacts:savedCustomPersonsArray];
  }

  [recentPersons sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastUsedDate" ascending:NO]]];
  return recentPersons;
}

+ (void)rememberContactNameForSearchIfNotAlreadyExisting:(NSString*)name {
  NSMutableArray<AddressBookContact *> *allContacts = [[NSMutableArray alloc] init];
  [allContacts addObjectsFromArray:[self previouslyUsedContacts]];

  if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
    [self readAllContactsFromAddressBookWithCompletion:^(NSArray *people, NSError *error) {
      [allContacts addObjectsFromArray:people];
    }];
  }

  // search for person
  BOOL personFound = NO;
  for (AddressBookContact *contact in allContacts) {
    if ([contact.fullName caseInsensitiveCompare:name] == NSOrderedSame) {
      [self _updateUsageDateOfPerson:name];
      personFound = YES;
      break;
    }
  }

  // not found, so save person
  if (NO == personFound) {
    // build person dictionary
    NSMutableDictionary* personDictionary = [[NSMutableDictionary alloc] init];
    [personDictionary setObject:name forKey:@"person"];
    [personDictionary setObject:[NSDate date] forKey:@"date"];

    // save new persons array
    NSMutableArray *savedCustomPersonsArray = [self _rawPreviouslyUsedContacts];
    [savedCustomPersonsArray addObject: personDictionary];
    [self _storePreviouslyUsedContacts:savedCustomPersonsArray];
  }
}

+ (void)forgetContactNameForSearch:(NSString*)name {
  BOOL didRemovePerson = NO;
  NSMutableArray<NSDictionary *> *savedCustomPersonsArray = [self _rawPreviouslyUsedContacts];
  for (NSInteger i=0; i<savedCustomPersonsArray.count; i++) {
    NSDictionary *personDict = [savedCustomPersonsArray objectAtIndex:i];
    NSString *personString = [personDict objectForKey:@"person"];
    if ([personString caseInsensitiveCompare:name] == NSOrderedSame) {
      [savedCustomPersonsArray removeObjectAtIndex:i];
      didRemovePerson = YES;
      break;
    }
  }

  if (didRemovePerson) {
    [self _storePreviouslyUsedContacts:savedCustomPersonsArray];
  }
}

#pragma mark - Internal

+ (NSMutableArray<NSDictionary *> *)_rawPreviouslyUsedContacts {
  NSArray *savedCustomPersonsArray = [[NSUserDefaults standardUserDefaults] objectForKey:SWPreviouslyUsedContactsUserDefaultsKey];
  return (savedCustomPersonsArray == nil
          ? [NSMutableArray array]
          : [savedCustomPersonsArray mutableCopy]);
}

+ (void)_storePreviouslyUsedContacts:(NSArray*)previousPersons {
  [[NSUserDefaults standardUserDefaults] setObject:previousPersons forKey:SWPreviouslyUsedContactsUserDefaultsKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)_updateUsageDateOfPerson:(NSString*)name {
  NSMutableArray *savedCustomPersonsArray = [self _rawPreviouslyUsedContacts];

  for (NSInteger i=0; i<savedCustomPersonsArray.count; i++) {
    NSDictionary *personDict = [savedCustomPersonsArray objectAtIndex:i];
    NSString* personString = [personDict objectForKey:@"person"];
    if( [personString isEqualToString:name] ) {
      NSMutableDictionary *mutablePerson = [personDict mutableCopy];
      [mutablePerson setObject:[NSDate date] forKey:@"date"];
      [savedCustomPersonsArray replaceObjectAtIndex:i withObject:mutablePerson];
      [self _storePreviouslyUsedContacts:savedCustomPersonsArray];
      return YES;
    }
  }

  return NO;
}

@end
