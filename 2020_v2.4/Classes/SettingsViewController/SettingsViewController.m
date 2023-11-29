//
//  SettingsViewController.m
//  StillWaitin
//

#import "SettingsViewController.h"

#import "ChooseCurrencyViewController.h"
#import "CurrencyManager.h"
#import "EntriesImporterExporter.h"
#import "EntryListHeaderCell.h"
#import "ExportHelpViewController.h"
#import "InAppPurchaseManager.h"
#import "InternalSettingsViewController.h"
#import "ListViewControllerFactory.h"
#import "PasswordViewController.h"
#import "RateAppAlertPresenter.h"
#import "RealmEntryStorage.h"
#import "SWColors.h"
#import "SWSettings.h"
#import "SWSettingsCell.h"
#import "SettingsModalTransitionDelegate.h"
#import "SettingsSelectListOptionViewController.h"
#import "SettingsViewControllerDelegate.h"
#import "SharingSettingsViewController.h"
#import "SimpleActivityView.h"
#import "SimpleTableView.h"
#import "UITableView+iOS11.h"

#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>

@interface SettingsViewController () <
MFMailComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate
>
@end

@implementation SettingsViewController {
  SimpleTableView *_simpleTableView;
  UIDocumentInteractionController *_documentInteractionController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"keySettingsTitle", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self
                                              action:@selector(dismissButtonClickHandler:)];
  }
  return self;
}

- (void)loadView {
  _simpleTableView = [[SimpleTableView alloc] initWithTableViewStyle:UITableViewStyleGrouped];
  _simpleTableView.tableView.backgroundColor = SWColorGrayWash();
  [_simpleTableView.tableView sw_setupBottomInsetAndDisableAutomaticContentInsetAdjustment];
  [_simpleTableView.tableView registerClass:[SWSettingsCell class]
                     forCellReuseIdentifier:SWSettingsCellReuseIdentifier];
  self.view = _simpleTableView;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadData];

  // Log event
}

- (void)reloadData {
  __weak typeof(self) weakSelf = self;

  NSMutableArray *const sections = [NSMutableArray array];

#ifdef kDEBUG
  [sections addObject:
   [STVSection sectionWithTitle:@"Debugging" sectionIndexTitle:nil rows:
    @[[STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:@"Internal Settings"
       subtitle:nil
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
         [weakSelf.navigationController
          pushViewController:[[InternalSettingsViewController alloc] init]
          animated:YES];
       }]]]];
#endif

  [sections addObject:
   [STVSection sectionWithTitle:NSLocalizedString(@"keySettingsSectionBehavior", nil) sectionIndexTitle:nil rows:
    @[[STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keyShowTotalSum", nil)
       subtitle:nil
       configureCellBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
      [(SWSettingsCell *)cell setShowsCheckmark:[[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsKeyShouldShowTotalSum]];
    }
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
      BOOL showTotalSum = [[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsKeyShouldShowTotalSum];
      [[NSUserDefaults standardUserDefaults] setBool:!showTotalSum forKey:SWSettingsKeyShouldShowTotalSum];
      [[NSUserDefaults standardUserDefaults] synchronize];
      [(SWSettingsCell *)cell setShowsCheckmark:!showTotalSum];
      [weakSelf _notifyDelegateAboutChangedSettings];
    }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:[NSString stringWithFormat:NSLocalizedString(@"keyShouldOpenToAllFormat", nil), NSLocalizedString(@"keyAllEntries", nil)]
       subtitle:nil
       configureCellBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        [(SWSettingsCell *)cell setShowsCheckmark:[[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsKeyOpenToAll]];
      }
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        BOOL openToAll = [[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsKeyOpenToAll];
        [[NSUserDefaults standardUserDefaults] setBool:!openToAll forKey:SWSettingsKeyOpenToAll];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [(SWSettingsCell *)cell setShowsCheckmark:!openToAll];
      }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keyShouldSkipDeletionAlerts", nil)
       subtitle:nil
       configureCellBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        [(SWSettingsCell *)cell setShowsCheckmark:[[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsSkipDeletionAlerts]];
      }
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        BOOL openToAll = [[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsSkipDeletionAlerts];
        [[NSUserDefaults standardUserDefaults] setBool:!openToAll forKey:SWSettingsSkipDeletionAlerts];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [(SWSettingsCell *)cell setShowsCheckmark:!openToAll];
      }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keySingleListMode", nil)
       subtitle:nil
       configureCellBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        [(SWSettingsCell *)cell setShowsCheckmark:[[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsSingleListMode]];
      }
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        BOOL openToAll = [[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsSingleListMode];
        [[NSUserDefaults standardUserDefaults] setBool:!openToAll forKey:SWSettingsSingleListMode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [(SWSettingsCell *)cell setShowsCheckmark:!openToAll];

        [weakSelf _notifyDelegateAboutRootVCUpdate];
      }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keyChooseCurrency", nil)
       subtitle:[CurrencyManager currencyNumberFormatter].currencyCode
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        [weakSelf.navigationController pushViewController:[[ChooseCurrencyViewController alloc] init] animated:YES];
      }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keyChooseSwipeDeletionBehavior", nil)
       subtitle:([[[NSUserDefaults standardUserDefaults] valueForKey:SWSettingsKeyListSwipeBehavior] isEqual:@(SWListSwipeSettingDelete)] ?
                 NSLocalizedString(@"keyDelete", nil) :
                 NSLocalizedString(@"keyArchive", nil))
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        UIViewController *const vc = [[SettingsSelectListOptionViewController alloc]
                                      initWithOptions:@[[ListOption optionWithDisplayName:NSLocalizedString(@"keyArchive", nil) value:SWListSwipeSettingArchive],
                                                        [ListOption optionWithDisplayName:NSLocalizedString(@"keyDelete", nil) value:SWListSwipeSettingDelete]]
                                      defaultValue:SWListSwipeSettingArchive
                                      userDefaultsKey:SWSettingsKeyListSwipeBehavior
                                      didSelectCallback:nil];
        vc.title = NSLocalizedString(@"keyChooseSwipeDeletionBehavior", nil);
        [weakSelf.navigationController pushViewController:vc animated:YES];
      }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keyCustomizeEmailShareText", nil)
       subtitle:nil
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        SharingSettingsViewController *controller = [[SharingSettingsViewController alloc] init];
        controller.title = NSLocalizedString(@"keyEmailShareText", nil);
        [weakSelf.navigationController pushViewController:controller animated:YES];
      }]
    ]]];

  [sections addObject:
   [STVSection sectionWithTitle:NSLocalizedString(@"keySettingsSectionPassword", nil) sectionIndexTitle:nil rows:
    @[[STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keySetupPassword", nil)
       subtitle:nil
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
         [weakSelf _presentPasswordController];
       }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keyPasswordNeededAfter", nil)
       subtitle:^(){
         NSNumber *const currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:SWSilenceTimeIntervalUserDefaultsKey] ?: @0;
         return ([currentValue integerValue] == 0 ?
                 NSLocalizedString(@"keyPasswordAlways", nil) :
                 ([currentValue integerValue] <= 60 ?
                  [NSString stringWithFormat:NSLocalizedString(@"keyPasswordSecondsShortFormat", nil), currentValue] :
                  [NSString stringWithFormat:NSLocalizedString(@"keyPasswordMinutesShortFormat", nil), @(floor([currentValue doubleValue]/60.0))]));
       }()
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
         UIViewController *const vc = [[SettingsSelectListOptionViewController alloc]
                                       initWithOptions:@[[ListOption optionWithDisplayName:NSLocalizedString(@"keyPasswordAlways", nil) value:0],
                                                         [ListOption optionWithDisplayName:[NSString stringWithFormat: @"10 %@", NSLocalizedString(@"keyPasswordSeconds", nil)] value:10],
                                                         [ListOption optionWithDisplayName:[NSString stringWithFormat: @"2 %@", NSLocalizedString(@"keyPasswordMinutes", nil)] value:120],
                                                         [ListOption optionWithDisplayName:[NSString stringWithFormat: @"5 %@", NSLocalizedString(@"keyPasswordMinutes", nil)] value:300],
                                                         [ListOption optionWithDisplayName:[NSString stringWithFormat: @"10 %@", NSLocalizedString(@"keyPasswordMinutes", nil)] value:600]]
                                       defaultValue:0
                                       userDefaultsKey:SWSilenceTimeIntervalUserDefaultsKey
                                       didSelectCallback:nil];
         vc.title = NSLocalizedString(@"keyPasswordNeededAfter", nil);
         [weakSelf.navigationController pushViewController:vc animated:YES];
       }]]]];

  [sections addObject:
   [STVSection sectionWithTitle:NSLocalizedString(@"keySettingsSectionFeedback", nil) sectionIndexTitle:nil rows:
    @[[STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keyRateApp", nil)
       subtitle:nil
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
      [[RateAppAlertPresenter sharedInstance] presentStoreProductViewControllerFromViewController:weakSelf];
    }],
      [STVRow
       rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
       title:NSLocalizedString(@"keySendMail", nil)
       subtitle:nil
       configureCellBlock:nil
       didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        [weakSelf _sendFeedback];
      }]]]];

  NSMutableArray *const exportRows = [NSMutableArray array];
  [exportRows addObject:
   [STVRow
    rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
    title:NSLocalizedString(@"keyExportData", nil)
    subtitle:nil
    configureCellBlock:nil
    didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
      [weakSelf _presentExportDataOptionsFromCell:cell];
    }]];

  if (![[InAppPurchaseManager sharedInstance] didPurchaseDataExport]) {
    [exportRows addObject:
     [STVRow
      rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
      title:NSLocalizedString(@"keyRestorePurchases", nil)
      subtitle:nil
      configureCellBlock:nil
      didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        [weakSelf _restorePurchases];
      }]];
  }

  [exportRows addObject:
   [STVRow
    rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
    title:NSLocalizedString(@"keyExportDataHelp", nil)
    subtitle:nil
    configureCellBlock:nil
    didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
      ExportHelpViewController *vc = [ExportHelpViewController new];
      vc.title = rowModel.title;
      [weakSelf.navigationController pushViewController:vc animated:YES];
    }]];

  [sections addObject:
   [STVSection sectionWithTitle:NSLocalizedString(@"keySettingsSectionExport", nil)
              sectionIndexTitle:nil
                           rows:exportRows]];

  _simpleTableView.sectionModels = [sections copy];
}

#pragma mark - Actions

- (void)_presentPasswordController {
  void(^presentPWControllerFrom)(UIViewController*) = ^(UIViewController *fromController) {
    PasswordViewController *controller = [[PasswordViewController alloc] init];
    controller.editing = YES;
    controller.shouldDismissBlock = ^(PasswordViewController *passwordViewController) {
      [passwordViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
    [fromController presentViewController:controller animated:YES completion:nil];
  };

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    UIViewController *parent = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
      presentPWControllerFrom(parent);
    }];
  } else {
    presentPWControllerFrom(self);
  }
}

- (void)_notifyDelegateAboutChangedSettings {
  [_delegate settingsViewControllerDidChangeSettings:self];
}

- (void)_notifyDelegateAboutRootVCUpdate {
  [_delegate settingsViewController:self
      providedNewListViewController:createListViewController()];
}

#pragma mark actions

- (void)dismissButtonClickHandler:(id)sender {
  if ([self.navigationController respondsToSelector:@selector(transitioningDelegate)]) {
    if (self.navigationController.transitioningDelegate) {
      SettingsModalTransitionDelegate *delegate = self.navigationController.transitioningDelegate;
      delegate.interactive = NO;
    }
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_sendFeedback {
  if (![MFMailComposeViewController canSendMail]) {
    [UIAlertController presentAlertFromViewController:self
                                            withTitle:NSLocalizedString(@"keyShareNoAccountsTitle", nil)
                                              message:NSLocalizedString(@"keyShareNoEmailAccountError", nil)
                              confirmationButtonTitle:NSLocalizedString(@"keyOk", nil)];
    return;
  }

  NSString *swImage = @"<p><a href=\"http://itunes.apple.com/gb/app/still-waitin-schulden-manager/id385448071?mt=8\"><img src=\"http://stillwaitin.martinstolz.me/images/sw_mailheader_en.jpg\" alt=\"Debt Tracker IOU - still waitin\" width=\"320\" height=\"99\" border=\"0\"></a></p>";
  NSString *bodyText = [NSString stringWithFormat: @"%@<br/><br/><br/><br/><br/><br/><span style='font-size: small;'><b>System</b>: %@ @ iOS %@<br/><b>App</b>: stillwaitin v%@ (%@x)</span>",
                        swImage,
                        [UIDevice currentDevice].model,
                        [UIDevice currentDevice].systemVersion,
                        [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"],
                        @([[RateAppAlertPresenter sharedInstance] appStartCountTotal])];

  MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
  controller.mailComposeDelegate = self;
  controller.navigationBar.translucent = NO;
  if ([controller.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
    controller.navigationBar.tintColor = SWColorGreenContrastTintColor();
  }
  [controller setSubject:@"Feedback zu still waitin"];
  [controller setToRecipients:[NSArray arrayWithObject:@"\"still waitin Support\"<stillwaitin@martinstolz.me>"]];
  [controller setMessageBody:bodyText isHTML:YES];
  [self presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_presentExportDataOptionsFromCell:(UITableViewCell *)cell {

  __weak typeof(self) blockSelf = self;
  [[InAppPurchaseManager sharedInstance] purchaseDataExportWithPresentingViewController:self completion:^(BOOL success) {
    if (success) {
      [UIAlertController presentActionSheetFromViewController:blockSelf
                                                   sourceView:cell
                                                    withTitle:NSLocalizedString(@"keyExportData", nil)
                                                      message:nil
                                                      buttons:@[[SimpleAlertButton defaultButtonWithTitle:@"JSON"],
                                                                [SimpleAlertButton defaultButtonWithTitle:@"CSV"],
                                                                [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)],]
                                                buttonHandler:^(UIAlertAction *action) {
        if (action.style != UIAlertActionStyleCancel) {
          const BOOL shouldUseJSON = [action.title isEqualToString:@"JSON"];
          [blockSelf _exportDataUsingJSON:shouldUseJSON presentFromCell:cell];
        }
      }];

      // update tableView
      [blockSelf reloadData];
    }
  }];
}

- (void)_exportDataUsingJSON:(BOOL)useJSON presentFromCell:(UITableViewCell *)cell {

  __weak typeof(self) weakSelf = self;
  [[SimpleActivityView activityViewWithTitle:NSLocalizedString(@"keyExporting", nil)]
   presentActivityViewOnView:self.navigationController.view
   activityBlock:^(SimpleActivityView * _Nonnull simpleActivityView, SimpleActivityViewDismissBlock  _Nonnull dismissBlock) {
     NSArray<RealmEntry *> *const entries = [[RealmEntryStorage sharedStorage] entriesWithFilter:RealmEntryStorageFilterAllEntries];
     NSString *const filePath = [EntriesImporterExporter exportEntriesToDisk:entries usingJsonFormat:useJSON];

     if (filePath) {
       // show preview + sharing options
        [weakSelf _presentExportPreviewWithFilePath:filePath fromCell:cell];
     } else {
       // show export error
       [UIAlertController presentAlertFromViewController:weakSelf
                                               withTitle:NSLocalizedString(@"keySorry", nil)
                                                 message:NSLocalizedString(@"keyExportFailed", nil)
                                 confirmationButtonTitle:NSLocalizedString(@"keyOk", nil)];
     }

     dismissBlock();
   }];
}

- (void)_presentExportPreviewWithFilePath:(NSString *)filePath
                                 fromCell:(UITableViewCell *)cell {
  _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
  _documentInteractionController.name = [filePath lastPathComponent];
  _documentInteractionController.delegate = self;
  [_documentInteractionController presentOptionsMenuFromRect:[self.view convertRect:cell.frame fromView:_simpleTableView.tableView]
                                                      inView:self.view
                                                    animated:YES];
}

- (void)_restorePurchases {

  __weak typeof(self) blockSelf = self;
  [[InAppPurchaseManager sharedInstance] restorePurchasesWithCompletion:^(BOOL success) {
    // update tableView
    [blockSelf reloadData];

    [UIAlertController presentAlertFromViewController:blockSelf
                                            withTitle:NSLocalizedString(@"keyNotice", nil)
                                              message:(success ?
                                                       ([[InAppPurchaseManager sharedInstance] didPurchaseDataExport] ?
                                                        NSLocalizedString(@"keyRestoreSuccess", nil) :
                                                        NSLocalizedString(@"keyRestoreNothingToRestore", nil)) :
                                                       NSLocalizedString(@"keyRestoreFailed", nil))
                              confirmationButtonTitle:NSLocalizedString(@"keyOk", nil)];
  }];
}

#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
  return self;
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller {
  _documentInteractionController = nil;
}

@end

