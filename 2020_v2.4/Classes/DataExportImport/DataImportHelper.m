//
//  DataImportHelper.m
//  StillWaitin
//

#import "DataImportHelper.h"

#import "EntriesImporterExporter.h"
#import "InAppPurchaseManager.h"
#import "RealmEntryStorage.h"
#import "SimpleActivityView.h"
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>

@implementation DataImportHelper

+ (void)evaluateImportOfURL:(NSURL *)url
   mainNavigationController:(UINavigationController *)mainNavigationController {
  if (url && [url.absoluteString rangeOfString:@"Inbox"].location != NSNotFound) {

    __weak __typeof(self) weakSelf = self;
    [[InAppPurchaseManager sharedInstance] purchaseDataExportWithPresentingViewController:mainNavigationController.topViewController completion:^(BOOL success) {
      if (success) {
        NSArray<RealmEntry *> *entries = [EntriesImporterExporter importDataFromFilePath:[url path]];
        [weakSelf _confirmImportOfEntries:entries mainNavigationController:mainNavigationController];
      }
    }];
  }
}

+ (void)_confirmImportOfEntries:(NSArray<RealmEntry *> *)entries
       mainNavigationController:(UINavigationController *)mainNavigationController {
  // hide any modals (e.g. Settings or iPad details)
  if (mainNavigationController.topViewController.presentedViewController) {
    [mainNavigationController.topViewController dismissViewControllerAnimated:YES completion:nil];
  }

  // reset to main list
  [mainNavigationController setViewControllers:@[mainNavigationController.viewControllers.firstObject] animated:YES];

  if(entries.count > 0) {
    __weak typeof(self) weakSelf = self;
    [UIAlertController presentAlertFromViewController:mainNavigationController
                                            withTitle:NSLocalizedString(@"keyImportTitle", nil)
                                              message:[NSString stringWithFormat:
                                                       NSLocalizedString(@"keyImportMessageFormat", nil),
                                                       entries.count]
                                              buttons:@[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyStartImport", nil)],
                                                        [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]
                                        buttonHandler:^(UIAlertAction *action) {
      if (action.style != UIAlertActionStyleCancel) {
        [weakSelf _executeImportWithEntries:entries mainNavigationController:mainNavigationController];
      } else {
      }
    }];
  } else {
    [UIAlertController presentAlertFromViewController:mainNavigationController
                                            withTitle:NSLocalizedString(@"keyImportTitle", nil)
                                              message:NSLocalizedString(@"keyImportError", nil)
                              confirmationButtonTitle:NSLocalizedString(@"keyOk", nil)];
  }
}

+ (void)_executeImportWithEntries:(NSArray<RealmEntry *> *)entries
         mainNavigationController:(UINavigationController *)mainNavigationController {
  [[SimpleActivityView activityViewWithTitle:NSLocalizedString(@"keyImporting", nil)]
   presentActivityViewOnView:mainNavigationController.view
   activityBlock:^(SimpleActivityView *simpleActivityView, SimpleActivityViewDismissBlock dismissBlock) {
    [[RealmEntryStorage sharedStorage] saveEntries:entries];
    dismissBlock();
  }];
}

@end
