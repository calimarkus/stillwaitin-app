//
//  PersonListViewController.m
//  StillWaitin
//

#import "PersonListViewController.h"

#import "AddEntryPresentationHelper.h"
#import "DetailViewController.h"
#import "EmptyListView.h"
#import "EnterPersonViewController.h"
#import "EntryListViewController.h"
#import "EntryStorage.h"
#import "ListTableSearchAdapter.h"
#import "ListViewDataProvider.h"
#import "MigrationController.h"
#import "PasswordViewController.h"
#import "PersonListCell.h"
#import "RealmEntry.h"
#import "RealmEntryGroup.h"
#import "RealmEntryStorage.h"
#import "SWColors.h"
#import "SWSettings.h"
#import "SimpleActivityView.h"
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>
#import <SimpleUIKit/UIView+SimplePositioning.h>


@interface PersonListViewController () <
UITableViewDelegate,
UITableViewDataSource,
UIAlertViewDelegate,
ListTableSearchAdapterDelegate
>
@end

@implementation PersonListViewController {
  BOOL _ignoreDataUpdates;
  ListTableSearchAdapter *_listSearchAdapter;
  EmptyListView *_emptyListView;
  ListViewDataProvider *_dataProvider;
  id<RealmEntryStorageListenerCancelable> _updateListener;
}

@synthesize delegate = _delegate;
@synthesize tableView = _tableView;

- (instancetype)init {
  self = [super init];
  if (self) {
    _dataProvider = [[ListViewDataProvider alloc] initWithRealmEntryStorage:[RealmEntryStorage sharedStorage]];
    _dataProvider.shouldSearchForPersonMatches = YES;
    _dataProvider.contentType = DefaultDataSourceContentType();

    // listen for data changes
    __weak typeof(self) blockSelf = self;
    _updateListener = [[RealmEntryStorage sharedStorage] addUpdateListenerBlock:^{
      [blockSelf _realmDataDidChange];
    }];

    // navbar config
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_sw"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_add"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addButtonTouchHandler:)];
  }
  return self;
}

- (void)dealloc {
  [_updateListener invalidate];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // add list table for showing all entries
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _tableView.backgroundColor = SWColorGrayWash();
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _tableView.cellLayoutMarginsFollowReadableWidth = NO;
  _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  if (@available(iOS 13.0, *)) {
    _tableView.automaticallyAdjustsScrollIndicatorInsets = NO;
  }

  _tableView.delegate = self;
  _tableView.dataSource = self;
  [self.view addSubview:_tableView];

  // register cell classes
  [_tableView registerClass:[PersonListCell class] forCellReuseIdentifier:NSStringFromClass([PersonListCell class])];

  // setup search
  _listSearchAdapter = [[ListTableSearchAdapter alloc] initWithTableView:_tableView
                                             applyContentTypeToGroups:YES
                                        shouldHideContentTypeSelector:NO
                                                  selectedContentType:_dataProvider.contentType];
  _listSearchAdapter.delegate = self;

  // empty view
  _emptyListView = [[EmptyListView alloc] initWithFrame:self.view.bounds];
  [_emptyListView sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // reload data
  [self _didUpdateData];

  // Log event
}

#pragma mark - Notifications

- (void)_realmDataDidChange {
  if (!_ignoreDataUpdates) {
    [self _didUpdateData];
  }
}

#pragma mark - Helper

- (void)_migrateToRealmModelsIfNeeded {
  __weak typeof(self) weakSelf = self;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    const BOOL needsMigration = [MigrationController needsMigration];
    if (needsMigration) {
      [[SimpleActivityView activityViewWithTitle:NSLocalizedString(@"keyUpdating", nil)]
       presentActivityViewOnView:self.navigationController.view
       activityBlock:^(SimpleActivityView * _Nonnull simpleActivityView, SimpleActivityViewDismissBlock  _Nonnull dismissBlock) {
        MigrationController *migrationController = [[MigrationController alloc]
                                                    initWithEntryStorage:[EntryStorage sharedStorage]
                                                    realmEntryStorage:[RealmEntryStorage sharedStorage]];
        [migrationController executeMigration];
        [migrationController markMigrationCompleted];
        [weakSelf _logMigrationCompleted];
        dismissBlock();
      }];
    }
  });
}

- (void)_logMigrationCompleted {
}

- (void)_didUpdateData {
  if (!_ignoreDataUpdates) {
    [self _refetchData];
    [_tableView reloadData];
  }
}

- (void)_refetchData {
  _ignoreDataUpdates = YES;
  [self _migrateToRealmModelsIfNeeded];
  [_dataProvider refetchData];
  [self _showOrHideEmptyListInfo];
  [_delegate listViewControllerDidUpdateToTotalSum:_dataProvider.totalSumAcrossAllEntries];
  _ignoreDataUpdates = NO;
}

- (void)_showOrHideEmptyListInfo {
  const BOOL shouldAddEmptyListInfoView = (_dataProvider.entryGroups.count == 0 &&
                                        _dataProvider.currentSearchString.length == 0);
  if (shouldAddEmptyListInfoView) {
    [self.view addSubview:_emptyListView];
    [_emptyListView setVisibleAnimated:![self->_listSearchAdapter isSearchBarFullyVisible]];
  } else {
    [_emptyListView removeFromSuperview];
  }
}

- (void)_showConfirmationAndScrollToShowSegmentedControlIfArchivedFirstEntry {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *const didArchiveFirstEntryKey = @"SWDidDeleteFirstEntryKey";
    BOOL didArchiveFirstEntry = [[NSUserDefaults standardUserDefaults] boolForKey:didArchiveFirstEntryKey];
    if (!didArchiveFirstEntry) {
      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:didArchiveFirstEntryKey];
      [[NSUserDefaults standardUserDefaults] synchronize];

      [_listSearchAdapter scrollTableViewToShowSearchView];

      [UIAlertController presentAlertFromViewController:self
                                              withTitle:nil
                                                message:[NSString stringWithFormat:NSLocalizedString(@"keyArchivedEntriesExplanationFormat", nil),
                                                         NSLocalizedString(@"keyArchivedEntries", nil)]
                                confirmationButtonTitle:NSLocalizedString(@"keyOk", nil)];
    }
  });
}

#pragma mark - Button actions

- (void)addButtonTouchHandler:(id)sender {
  [AddEntryPresentationHelper presentAddEntryFlowForNewPersonOnViewController:self];
}

#pragma mark - ListSearchViewDelegate

- (void)searchViewDidSelectContentType:(ListViewDataSourceContentType)selectedContentType {
  _dataProvider.contentType = selectedContentType;
  [self _didUpdateData];
}

- (void)searchViewDidUpdateSearchString:(NSString *)searchString {
  BOOL searchStringIsEqualToCurrent = (_dataProvider.currentSearchString == searchString ||
                                       [_dataProvider.currentSearchString isEqualToString:searchString]);
  if (!searchStringIsEqualToCurrent) {
    _dataProvider.currentSearchString = searchString;
    [self _didUpdateData];
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [_emptyListView updateForScrollContentOffset:scrollView.contentOffset];
  [_listSearchAdapter tableViewDidScroll];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
  [_listSearchAdapter updateTargetContentOffsetAfterScrollingEnded:targetContentOffset];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  return _dataProvider.entryGroups.count;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [PersonListCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  PersonListCell* cell = (PersonListCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PersonListCell class])];
  cell.shouldUsePastTense = _dataProvider.contentType == ListViewDataSourceContentTypeArchivedGroups;
  cell.showsSeparator = (_dataProvider.entryGroups.count > indexPath.row + 1);
  cell.entryGroup = _dataProvider.entryGroups[indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  EntryListViewController *personListVC = [[EntryListViewController alloc] initWithPersonName:_dataProvider.entryGroups[indexPath.row].fullName
                                                                                  contentType:(_dataProvider.contentType == ListViewDataSourceContentTypeArchivedGroups
                                                                                               ? ListViewDataSourceContentTypeArchivedEntries
                                                                                               : ListViewDataSourceContentTypeAll)];
  [self.navigationController pushViewController:personListVC animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
  RealmEntryGroup *entryGroupToDelete = _dataProvider.entryGroups[indexPath.row];
  BOOL const alwaysUseDeletion = [[[NSUserDefaults standardUserDefaults] valueForKey:SWSettingsKeyListSwipeBehavior] isEqual:@(SWListSwipeSettingDelete)];
  BOOL shouldFullyDeleteEntry = (entryGroupToDelete.allEntriesAreArchived || alwaysUseDeletion);
  return (shouldFullyDeleteEntry
          ? NSLocalizedString(@"keyDelete", nil)
          : NSLocalizedString(@"keyArchive", nil));
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  RealmEntryGroup *entryGroupToDelete = _dataProvider.entryGroups[indexPath.row];
  BOOL const alwaysUseDeletion = [[[NSUserDefaults standardUserDefaults] valueForKey:SWSettingsKeyListSwipeBehavior] isEqual:@(SWListSwipeSettingDelete)];
  BOOL const shouldFullyDeleteEntry = (entryGroupToDelete.allEntriesAreArchived || alwaysUseDeletion);

  BOOL const skipDeletionAlert = [[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsSkipDeletionAlerts];
  if (!skipDeletionAlert) {
    __weak __typeof(self) weakSelf = self;
    [UIAlertController presentAlertFromViewController:self
                                            withTitle:[NSString stringWithFormat:(shouldFullyDeleteEntry
                                                                                  ? NSLocalizedString(@"keyDeleteGroupConfirmationFormat", nil)
                                                                                  : NSLocalizedString(@"keyArchiveGroupConfirmationFormat", nil)),
                                                       @(entryGroupToDelete.entries.count),
                                                       entryGroupToDelete.fullName]
                                              message:nil
                                              buttons:@[[SimpleAlertButton destructiveButtonWithTitle:(shouldFullyDeleteEntry
                                                                                                       ? NSLocalizedString(@"keyDelete", nil)
                                                                                                       : NSLocalizedString(@"keyArchive", nil))],
                                                        [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]
                                        buttonHandler:^(UIAlertAction * _Nonnull action) {
      if (action.style != UIAlertActionStyleCancel) {
        [weakSelf _execeuteDeletionForIndexPath:indexPath shouldFullyDeleteEntry:shouldFullyDeleteEntry];
      }
    }];
  } else {
    [self _execeuteDeletionForIndexPath:indexPath shouldFullyDeleteEntry:shouldFullyDeleteEntry];
  }
}

- (void)_execeuteDeletionForIndexPath:(NSIndexPath *)indexPath
               shouldFullyDeleteEntry:(BOOL)shouldFullyDeleteEntry {
  _ignoreDataUpdates = YES;

  // delete entry from storage
  RealmEntryGroup *entryGroupToDelete = _dataProvider.entryGroups[indexPath.row];
  for (RealmEntry *entry in entryGroupToDelete.entries) {
    if (shouldFullyDeleteEntry) {
      [[RealmEntryStorage sharedStorage] deleteEntry:entry];
    } else {
      [[RealmEntryStorage sharedStorage] archiveEntry:entry];
    }
  }
  [self _refetchData];

  // update table view
  if (_dataProvider.contentType == ListViewDataSourceContentTypeAll && !shouldFullyDeleteEntry) {
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
  } else {
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
  }

  _ignoreDataUpdates = NO;

  if (!shouldFullyDeleteEntry) {
    [self _showConfirmationAndScrollToShowSegmentedControlIfArchivedFirstEntry];
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

@end
