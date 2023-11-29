//
//  InternalSettingsViewController.m
//  StillWaitin
//

#import "InternalSettingsViewController.h"

#import "DataImportHelper.h"
#import "DummyDataWriter.h"
#import "InAppPurchaseManager.h"
#import "RealmEntry.h"
#import "RealmEntryStorage.h"
#import "SWColors.h"
#import "SWSettingsCell.h"
#import "SimpleLocalNotification.h"
#import "SimpleTableView.h"
#import "UITableView+iOS11.h"
#import <Realm/RLMRealm.h>
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>

#ifdef kDEBUG
@interface InAppPurchaseManager (ExposeInternalMethod)
- (void)saveSuccessfullDataExportPurchase;
@end
#endif

@implementation InternalSettingsViewController

#ifdef kDEBUG

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Internal Settings";
  }
  return self;
}

- (void)loadView {
  SimpleTableView *simpleTableView = [[SimpleTableView alloc] initWithTableViewStyle:UITableViewStyleGrouped];
  simpleTableView.tableView.backgroundColor = SWColorGrayWash();
  [simpleTableView.tableView registerClass:[SWSettingsCell class] forCellReuseIdentifier:SWSettingsCellReuseIdentifier];
  simpleTableView.sectionModels = [self _setupSections];
  [simpleTableView.tableView sw_setupBottomInsetAndDisableAutomaticContentInsetAdjustment];
  self.view = simpleTableView;
}

- (NSArray<STVSection *> *)_setupSections {
  __weak typeof(self) weakSelf = self;
  return @[[STVSection sectionWithTitle:@"Entries" sectionIndexTitle:nil rows:
            @[[STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Add 5 persons (1-30 entries pP)"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
              [weakSelf _storeEntriesAndShowConfirmationAlert:[DummyDataWriter
                                                               createDummyDataWithPersonCount:5
                                                               maxEntryCountPerPerson:30
                                                               maxDebtValue:2345
                                                               shouldUseLegacyModel:NO]];
            }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Add 200 persons (1-30 entries pP)"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [weakSelf _storeEntriesAndShowConfirmationAlert:[DummyDataWriter
                                                                 createDummyDataWithPersonCount:500
                                                                 maxEntryCountPerPerson:30
                                                                 maxDebtValue:10000
                                                                 shouldUseLegacyModel:NO]];
              }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Add Cell Layout Test Entries"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [weakSelf _storeEntriesAndShowConfirmationAlert:[DummyDataWriter layoutTestEntries]];
              }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Add Default Screenshot Data"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [weakSelf _storeEntriesAndShowConfirmationAlert:[DummyDataWriter defaultScreenshotEntries]];
              }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Delete all entries"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [[RLMRealm defaultRealm] beginWriteTransaction];
                [[RLMRealm defaultRealm] deleteAllObjects];
                [[RLMRealm defaultRealm] commitWriteTransaction];
                [UIAlertController presentAlertFromViewController:weakSelf
                                                        withTitle:@"Done"
                                                          message:@"All entries deleted."
                                          confirmationButtonTitle:@"Ok"];
              }]]],
           [STVSection sectionWithTitle:@"Misc" sectionIndexTitle:nil rows:
            @[[STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Show /Documents contents"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
              [weakSelf _showContentsOfDocumentsDirectory];
            }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Mark export as purchased"
               subtitle:nil
               configureCellBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [(SWSettingsCell *)cell
                 setShowsCheckmark:[[InAppPurchaseManager sharedInstance] didPurchaseDataExport]];
              }
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [[InAppPurchaseManager sharedInstance] saveSuccessfullDataExportPurchase];
                [(SWSettingsCell *)cell setShowsCheckmark:YES];
              }]]],
           [STVSection sectionWithTitle:@"Local Notifications" sectionIndexTitle:nil rows:
            @[[STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Schedule in 1s"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
              [weakSelf _scheduleLocalNotifInNSeconds:1];
            }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Schedule in 5s"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [weakSelf _scheduleLocalNotifInNSeconds:5];
              }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Schedule in 10s"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [weakSelf _scheduleLocalNotifInNSeconds:10];
              }],
              [STVRow
               rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
               title:@"Schedule in 30s"
               subtitle:nil
               configureCellBlock:nil
               didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                [weakSelf _scheduleLocalNotifInNSeconds:30];
              }]]]];
}

- (void)_showContentsOfDocumentsDirectory {
  UITextView *textView = [UITextView new];
  textView.text = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:
                    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                     objectAtIndex: 0] error: nil] description];

  UIViewController *viewController = [UIViewController new];
  viewController.view = textView;
  viewController.title = @"Document Directory";
  [self.navigationController pushViewController:viewController animated:YES];
}

- (void)_storeEntriesAndShowConfirmationAlert:(NSArray<RealmEntry *> *)entries {
  [[RealmEntryStorage sharedStorage] saveEntries:entries];

  [UIAlertController presentAlertFromViewController:self
                                          withTitle:@"Done"
                                            message:[NSString stringWithFormat:@"%@ Entries added.", @(entries.count)]
                            confirmationButtonTitle:@"Ok"];
}

- (void)_scheduleLocalNotifInNSeconds:(NSTimeInterval)timeInterval {
  NSString *entryId = [[[[RealmEntryStorage sharedStorage] entriesWithFilter:RealmEntryStorageFilterActiveEntries] firstObject] uniqueId];
  if (entryId) {
    [SimpleLocalNotification scheduleLocalNotificationWithAlertBody:[NSString stringWithFormat:@"Test notif %fs", timeInterval]
                                                timeIntervalFromNow:timeInterval
                                                   uniqueIdentifier:entryId
                                                         completion:nil];
  } else {
    [UIAlertController presentAlertFromViewController:self
                                            withTitle:@"Error"
                                              message:@"No entries found"
                              confirmationButtonTitle:@"Ok"];
  }
}

#endif

@end
