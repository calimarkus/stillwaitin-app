//
//  Entry4.m
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "Entry4.h"


@implementation Entry4

@synthesize notification;

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder: encoder];
	
	[encoder encodeObject:notification forKey:@"notification"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder: decoder];
	
	self.notification = [decoder decodeObjectForKey:@"notification"];
	
	return self;
}

- (void)dealloc
{
	self.notification	= nil;
	
	[super dealloc];
}

@end