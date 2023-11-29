//
//  AddressBookUtility.h
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBookContact.h"

typedef void(^AddressBookBlock)(NSMutableArray *people, NSError *error);

@interface AddressBookUtility : NSObject

+ (void)getAllPeopleFromAddressBookWithCompletion:(AddressBookBlock)addressBookBlock;

// unused
//+ (NSInteger)getNumberOfAllPeopleFromAddressBook;
//+ (AddressBookContact *)getContactFromAddressBookAtIndex:(NSInteger)index;

@end
