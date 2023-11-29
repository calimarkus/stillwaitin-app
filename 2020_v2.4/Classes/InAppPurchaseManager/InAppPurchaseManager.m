//
//  InAppPurchaseManager.m
//  StillWaitin
//
//

#import "InAppPurchaseManager.h"

@implementation InAppPurchaseManager

+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[self alloc] init];
  });

  return _sharedInstance;
}

#pragma mark public access

- (void)prepareManager {
  // used to load product, if needed
}

- (BOOL)didPurchaseDataExport {
  // used to mark product as purchased in keychain
  return YES;
}

- (void)restorePurchasesWithCompletion:(InAppPurchaseCompletionBlock)completion {
  // used to restore purchases
  completion(YES);
}

- (void)purchaseDataExportWithPresentingViewController:(UIViewController *)presentingViewController
                                            completion:(InAppPurchaseCompletionBlock)completion {
  // used to trigger a purchase flow, if needed
  completion(YES);
}

@end
