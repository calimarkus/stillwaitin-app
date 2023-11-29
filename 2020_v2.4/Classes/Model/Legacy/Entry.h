//
//  Entry.h
//  StillWaitin
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

#import "DebtDirection.h"

extern NSInteger const EntryMaxDescriptionLength;
extern double const EntryMaxValue;

typedef enum {
	DebtTypeItem,
	DebtTypeMoney
} DebtType;

@interface Entry : NSObject

@property (nonatomic, copy) NSString *entryId;
@property (nonatomic, copy) NSString *person;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *entryDescription;
@property (nonatomic, copy) NSString *photofilename;
@property (nonatomic, readonly) NSString *photoPath;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, readonly) NSNumber *signedValue;
@property (nonatomic, strong) NSNumber *totalValueForPerson;

@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) BOOL isLocationAvailable;
@property (nonatomic, assign) BOOL hasPhoto;
@property (nonatomic, assign) DebtDirection direction;
@property (nonatomic, assign) DebtType type; // unused but needed to read old entries

@end

// revert entry with another entry
@interface Entry (RevertSupport)
- (void)updateWithEntry:(Entry*)entry;
@end

// implements NSCoding only
@interface Entry (NSCopying) <NSCopying>
@end

// implements NSCoding only
@interface Entry (NSCoding) <NSCoding>
@end

// needed to read old NSCoding encoded Entry4 instances
@interface Entry4 : Entry
@end


