//
//  DataImportHelper.h
//  StillWaitin
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataImportHelper : NSObject

+ (void)evaluateImportOfURL:(NSURL *)url
   mainNavigationController:(UINavigationController *)mainNavigationController;

@end

NS_ASSUME_NONNULL_END
