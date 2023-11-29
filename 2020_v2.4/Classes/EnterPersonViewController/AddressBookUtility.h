//
//  AddressBookUtility.h
//  StillWaitin
//

#import <Foundation/Foundation.h>
#import "AddressBookContact.h"

typedef void(^AddressBookBlock)(NSArray<AddressBookContact *> *people, NSError *error);

@interface AddressBookUtility : NSObject

+ (void)readAllContactsFromAddressBookWithCompletion:(AddressBookBlock)addressBookBlock;
+ (void)rememberContactNameForSearchIfNotAlreadyExisting:(NSString*)name;
+ (void)forgetContactNameForSearch:(NSString*)name;
+ (NSArray<AddressBookContact *> *)previouslyUsedContacts;

@end
