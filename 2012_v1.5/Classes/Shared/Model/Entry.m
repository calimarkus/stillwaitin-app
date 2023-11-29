//
//  Entry.m
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "Entry.h"


@implementation Entry

@synthesize entryId;
@synthesize person;
@synthesize date;
@synthesize description;
@synthesize email;
@synthesize photofilename;
@synthesize direction;
@synthesize type;
@synthesize value;
@synthesize footer;
@synthesize isLocationAvailable;
@synthesize hasPhoto;
@synthesize location;

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:entryId forKey:@"entryId"];
	[encoder encodeObject:description forKey:@"description"];
	[encoder encodeObject:email forKey:@"email"];
	[encoder encodeObject:person forKey:@"person"];
	[encoder encodeObject:value forKey:@"value"];
	[encoder encodeObject:date forKey:@"date"];
	[encoder encodeObject:photofilename forKey:@"photofilename"];
	[encoder encodeInteger:direction forKey:@"direction"];
	[encoder encodeInteger:type forKey:@"type"];
	[encoder encodeInteger:isLocationAvailable forKey:@"isLocationAvailable"];
	[encoder encodeInteger:hasPhoto forKey:@"hasPhoto"];
	
	[encoder encodeDouble:location.latitude forKey:@"locationLatitude"];
	[encoder encodeDouble:location.longitude forKey:@"locationLongitude"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self.entryId				= [decoder decodeObjectForKey:@"entryId"];
	self.description			= [decoder decodeObjectForKey:@"description"];
	self.email					= [decoder decodeObjectForKey:@"email"];
	self.person					= [decoder decodeObjectForKey:@"person"];
	self.value					= [decoder decodeObjectForKey:@"value"];
	self.date					= [decoder decodeObjectForKey:@"date"];
	self.photofilename			= [decoder decodeObjectForKey:@"photofilename"];
	self.direction				= [decoder decodeIntegerForKey:@"direction"];
	self.type					= [decoder decodeIntegerForKey:@"type"];
	self.isLocationAvailable	= [decoder decodeIntegerForKey:@"isLocationAvailable"];
	self.hasPhoto				= [decoder decodeIntegerForKey:@"hasPhoto"];
	
	double longitude			= [decoder decodeDoubleForKey:@"locationLongitude"];
	double latitude				= [decoder decodeDoubleForKey:@"locationLatitude"];
	self.location				= (CLLocationCoordinate2D){latitude, longitude};
	
	return self;
}

- (BOOL) isItem
{
	return type == DebtTypeItem;
}

- (BOOL) isMoney
{
	return type == DebtTypeMoney;
}

- (BOOL) hasDirectionIn
{
	return direction == DebtDirectionIn;
}

- (BOOL) hasDirectionOut
{
	return direction == DebtDirectionOut;
}

- (void)dealloc
{
	self.entryId		= nil;
	self.person			= nil;
	self.email			= nil;
	self.description	= nil;
	self.value			= nil;
	self.date			= nil;
	self.photofilename	= nil;
	self.footer			= nil;
	
	[super dealloc];
}

@end