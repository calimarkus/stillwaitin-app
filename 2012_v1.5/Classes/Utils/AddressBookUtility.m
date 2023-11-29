//
//  AddressBookUtility.m
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddressBookUtility.h"
#import "AddressBookContact.h"
#import <AddressBook/AddressBook.h>


@implementation AddressBookUtility

+ (void)getAllPeopleFromAddressBookWithCompletion:(AddressBookBlock)addressBookBlock;
{
    __block NSError *theError = nil;
    
    // we need an addressBook for any operation, create at the start
    ABAddressBookRef addressBook;
    if (ABAddressBookCreateWithOptions != NULL) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    } else {
        addressBook = ABAddressBookCreate();
    }
    
    // array for all read contacts
    NSMutableArray *masterList = [[NSMutableArray alloc] init];
    
    // in most cases we have access, start with YES
    __block BOOL accessGranted = YES;
    
    // handle authorization on iOS 6
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        // ask for authorization, if not done yet
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
                
                if (error)
                {
                    theError = [NSError errorWithDomain:@"No authorization" code:1001 userInfo:nil];
                    accessGranted = NO;
                }
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_release(sema);
        }
        // in case we don't have access, set accesGranted to NO
        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied
                || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
        {
            theError = [NSError errorWithDomain:@"No authorization" code:1001 userInfo:nil];
            accessGranted = NO;
        }
    }
    
    if (accessGranted)
    {
        // ensuring to have no crashs
        if (!addressBook) {
            addressBookBlock([NSArray array], theError);
            return;
        }
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        // ensuring to have no crashs
        if (!allPeople) {
            addressBookBlock([NSArray array], theError);
            return;
        }
        
        // read contact details
        for (int i = 0; i < nPeople; i++)
        {
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
            AddressBookContact *contact = [[AddressBookContact alloc] init];
            
            CFTypeRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            if(nil == firstName)
                contact.firstName = @"";
            else
                contact.firstName = (NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            
            CFTypeRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            if(nil == lastName)
                contact.lastName = @"";
            else
                contact.lastName = (NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
            
            ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
            CFStringRef email = nil;
            if (ABMultiValueGetCount(emails) > 0)
            {
                email = ABMultiValueCopyValueAtIndex(emails, 0);
            }
            
            if(nil == email)
                contact.email = @"";
            else
                contact.email = (NSString*)email;
            
            if (firstName != NULL)
            {
                CFRelease(firstName);
            }
            if (lastName != NULL)
            {
                CFRelease(lastName);
            }
            if (email != NULL)
            {
                CFRelease(email);
            }
            [masterList addObject:contact];
            [contact release];
        }
        
        CFRelease(addressBook);
        CFRelease(allPeople);
    }
	
    // call completion block
    if (addressBookBlock) {
        addressBookBlock(masterList, theError);
    }
}

/*
 * unused code
 *

+ (NSInteger)getNumberOfAllPeopleFromAddressBook
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	CFRelease(addressBook);
	
	return nPeople;
}

+ (AddressBookContact *)getContactFromAddressBookAtIndex:(NSInteger)index
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, index);
	CFRelease(addressBook);
	CFRelease(allPeople);
	
	AddressBookContact *contact = [[[AddressBookContact alloc] init] autorelease];
	contact.firstName = (NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
	contact.lastName = (NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
	contact.email = (NSString *)ABRecordCopyValue(ref, kABPersonEmailProperty);
	
	return contact;
}
 
*/

@end
