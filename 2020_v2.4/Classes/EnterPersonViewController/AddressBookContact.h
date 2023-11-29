//
//  AddressBookContact.h
//  StillWaitin
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddressBookContact : NSObject

@property (nonatomic, copy, readonly) NSString *fullName;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *phoneNumber;

@property (nonatomic, copy, nullable, readonly) NSDate *lastUsedDate;
@property (nonatomic, assign, readonly) BOOL allowDeletion;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithFullName:(NSString *)fullName
                           email:(nullable NSString *)email
                     phoneNumber:(nullable NSString *)phoneNumber
                    lastUsedDate:(nullable NSDate *)lastUsedDate
                   allowDeletion:(BOOL)allowDeletion NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
