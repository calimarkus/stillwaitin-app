//
//  AddressBookContact.h
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AddressBookContact : NSObject
{
	NSString *firstName;
	NSString *lastName;
	NSString *email;
}

@property (assign) NSString *firstName;
@property (assign) NSString *lastName;
@property (assign) NSString *email;

@end
