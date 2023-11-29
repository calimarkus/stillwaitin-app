//
//  Entry.h
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

typedef enum
{
	DebtDirectionIn,
	DebtDirectionOut
} DebtDirection;

typedef enum
{
	DebtTypeItem,
	DebtTypeMoney
} DebtType;

@interface Entry : NSObject <NSCoding>
{
	NSString *entryId;
	NSString *person;
	NSString *email;
	NSString *description;
	NSString *photofilename;
	NSString *footer;
	NSNumber *value;
	NSDate *date;
	
	CLLocationCoordinate2D location;
	BOOL isLocationAvailable;
	BOOL hasPhoto;
	DebtDirection direction;
	DebtType type;
}

@property (nonatomic, retain) NSString *entryId;
@property (nonatomic, retain) NSString *person;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *photofilename;
@property (nonatomic, retain) NSString *footer;
@property (nonatomic, retain) NSNumber *value;
@property (nonatomic, retain) NSDate *date;

@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) BOOL isLocationAvailable;
@property (nonatomic, assign) BOOL hasPhoto;
@property (nonatomic, assign) DebtDirection direction;
@property (nonatomic, assign) DebtType type;

- (BOOL) isItem;
- (BOOL) isMoney;
- (BOOL) hasDirectionIn;
- (BOOL) hasDirectionOut;

@end
