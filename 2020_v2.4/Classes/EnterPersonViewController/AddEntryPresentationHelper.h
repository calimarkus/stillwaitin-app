//
//  AddEntryPresentationHelper.h
//  StillWaitin
//

#import <Foundation/Foundation.h>

@class RealmEntryGroup;

NS_ASSUME_NONNULL_BEGIN

@interface AddEntryPresentationHelper : NSObject

+ (void)presentAddEntryFlowForExistingEntryGroup:(RealmEntryGroup *)entryGroup
                                onViewController:(UIViewController *)viewController;

+ (void)presentAddEntryFlowForNewPersonOnViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
