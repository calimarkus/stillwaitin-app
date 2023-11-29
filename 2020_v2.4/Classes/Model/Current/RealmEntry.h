//
//  RealmEntry.h
//  StillWaitin
//

#import <Realm/RLMObject.h>
#import <Realm/RLMProperty.h>

#import "DebtDirection.h"

@class RealmEntry;

extern NSString * _Nullable PhotoFilePathForRealmEntry(RealmEntry *_Nonnull entry);

@interface RealmLocation : RLMObject <NSCopying>
@property (nonatomic, copy) NSString *_Nonnull uniqueId;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@end

@interface RealmEntry : RLMObject <NSCopying>

@property (nonatomic, copy) NSString *_Nonnull uniqueId;
@property (nonatomic, copy) NSDate *_Nonnull createdAtDate;
@property (nonatomic, copy) NSString *_Nullable fullName;
@property (nonatomic, copy) NSString *_Nullable email;
@property (nonatomic, copy) NSString *_Nullable phoneNumber;
@property (nonatomic, copy) NSString *_Nullable entryDescription;
@property (nonatomic, copy) NSString *_Nullable photofilename;
@property (nonatomic, copy) NSDate *_Nullable debtDate;
@property (nonatomic, copy) NSDate *_Nullable notificationDate;
@property (nonatomic, copy) NSNumber<RLMDouble> *_Nullable value;
@property (nonatomic, assign) DebtDirection debtDirection;
@property (nonatomic, copy) RealmLocation *_Nullable location;
@property (nonatomic, assign) BOOL isArchived;

- (void)updateWithEntry:(RealmEntry *_Nonnull)entry;

@end
