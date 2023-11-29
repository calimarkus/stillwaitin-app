//
//  InAppPurchaseManager.h
//  StillWaitin
//
//

typedef void(^InAppPurchaseCompletionBlock)(BOOL success);

@interface InAppPurchaseManager : NSObject

+ (instancetype)sharedInstance;

- (void)prepareManager;
- (BOOL)didPurchaseDataExport;

- (void)restorePurchasesWithCompletion:(InAppPurchaseCompletionBlock)completion;
- (void)purchaseDataExportWithPresentingViewController:(UIViewController *)presentingViewController
                                            completion:(InAppPurchaseCompletionBlock)completion;

@end
