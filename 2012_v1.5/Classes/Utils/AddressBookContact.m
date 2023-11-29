//
//  AddressBookContact.m
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddressBookContact.h"


@implementation AddressBookContact

@synthesize firstName;
@synthesize lastName;
@synthesize email;

- (void)dealloc
{
	firstName = nil;
	lastName = nil;
	email = nil;
	
	[super dealloc];
}

@end
