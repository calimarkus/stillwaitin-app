//
//  EntryListViewController.m
//  StillWaitin
//

#import "EntryListViewController.h"

#import "AddEntryPresentationHelper.h"
#import "DetailViewController.h"
#import "EmptyListView.h"
#import "EnterPersonViewController.h"
#import "EntryListEntryCell.h"
#import "EntryListHeaderCell.h"
#import "EntryStorage.h"
#import "ListTableSearchAdapter.h"
#import "ListViewDataProvider.h"
#import "RealmEntry.h"
#import "RealmEntryGroup.h"
#import "RealmEntryStorage.h"
#import "SWColors.h"
#import "SWSettings.h"
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>
#import <SimpleUIKit/UIView+SimplePositioning.h>


@interface EntryListViewController () <
UITableViewDelegate,
UITableViewDataSource,
UIAlertViewDelegate,
ListTableSearchAdapterDelegate
>
@end

@implementation EntryListViewController {
  BOOL _ignoreDataUpdates;
  ListTableSearchAdapter *_listSearchAdapter;
  EmptyListView *_emptyListView;
  ListViewDataProvider *_dataProvider;
  id<RealmEntryStorageListenerCancelable> _updateListener;
}

@synthesize delegate = _delegate;
@synthesize tableView = _tableView;

- (instancetype)initWithPersonName:(NSString * _Nullable)personName
                       contentType:(ListViewDataSourceContentType)contentType {
  self = [super init];
  if (self) {
    _dataProvider = [[ListViewDataProvider alloc] initWithRealmEntryStorage:[RealmEntryStorage sharedStorage]];
    _dataProvider.exactFullName = personName;
    _dataProvider.contentType = contentType;
    _dataProvider.shouldSearchForPersonMatches = (personName.length == 0);
    _dataProvider.shouldSearchForEntryMatches = YES;

    // listen for data changes
    __weak typeof(self) blockSelf = self;
    _updateListener = [[RealmEntryStorage sharedStorage] addUpdateListenerBlock:^{
      [blockSelf _realmDataDidChange];
    }];

    // navbar config
    self.title = personName;
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
  [_tableView registerClass:[EntryListEntryCell class] forCellReuseIdentifier:NSStringFromClass([EntryListEntryCell class])];
  [_tableView registerClass:[EntryListHeaderCell class] forCellReuseIdentifier:NSStringFromClass([EntryListHeaderCell class])];

  // setup search
  _listSearchAdapter = [[ListTableSearchAdapter alloc] initWithTableView:_tableView
                                             applyContentTypeToGroups:NO
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

- (void)_didUpdateData {
  if (!_ignoreDataUpdates) {
    [self _refetchData];
    [_tableView reloadData];
  }
}

- (void)_refetchData {
  _ignoreDataUpdates = YES;
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

- (RealmEntry *)_entryForIndexPath:(NSIndexPath *)indexPath {
  return _dataProvider.entryGroups[indexPath.section].entries[indexPath.row - 1];
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
  if (_dataProvider.exactFullName.length > 0 && _dataProvider.entryGroups.firstObject != nil) {
    [AddEntryPresentationHelper presentAddEntryFlowForExistingEntryGroup:_dataProvider.entryGroups.firstObject
                                                        onViewController:self];
  } else {
    [AddEntryPresentationHelper presentAddEntryFlowForNewPersonOnViewController:self];
  }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _dataProvider.entryGroups.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  return _dataProvider.entryGroups[section].entries.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return [EntryListHeaderCell height];
  } else {
    return [EntryListEntryCell height];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    // first row is the custom header
    EntryListHeaderCell* cell = (EntryListHeaderCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EntryListHeaderCell class])];
    cell.shouldUsePastTense = _dataProvider.contentType == ListViewDataSourceContentTypeArchivedEntries;
    cell.entryGroup = _dataProvider.entryGroups[indexPath.section];
    return cell;
  } else {
    EntryListEntryCell* cell = (EntryListEntryCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([EntryListEntryCell class])];
    [cell setEntry:[self _entryForIndexPath:indexPath]];
    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row > 0) {
    // create and show detail view controller
    DetailViewController* detailViewController = [[DetailViewController alloc] init];
    [detailViewController setRealmEntry:[self _entryForIndexPath:indexPath]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
      UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
      navController.navigationBar.translucent = NO;
      navController.modalPresentationStyle = UIModalPresentationFormSheet;
      [self presentViewController:navController animated:YES completion:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
  BOOL const alwaysShowDeletion = [[[NSUserDefaults standardUserDefaults] valueForKey:SWSettingsKeyListSwipeBehavior] isEqual:@(SWListSwipeSettingDelete)];
  RealmEntry *const entryForRow = [self _entryForIndexPath:indexPath];
  return (entryForRow.isArchived || alwaysShowDeletion  ?
          NSLocalizedString(@"keyDelete", nil) :
          NSLocalizedString(@"keyArchive", nil));
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  RealmEntry *entryToDelete = [self _entryForIndexPath:indexPath];
  BOOL const alwaysUseDeletion = [[[NSUserDefaults standardUserDefaults] valueForKey:SWSettingsKeyListSwipeBehavior] isEqual:@(SWListSwipeSettingDelete)];
  BOOL shouldFullyDeleteEntry = (entryToDelete.isArchived || alwaysUseDeletion);

  BOOL const skipDeletionAlert = [[NSUserDefaults standardUserDefaults] boolForKey:SWSettingsSkipDeletionAlerts];
  if (shouldFullyDeleteEntry && !skipDeletionAlert) {
    __weak __typeof(self) weakSelf = self;
    [UIAlertController presentAlertFromViewController:self
                                            withTitle:NSLocalizedString(@"keyDeleteSingleEntryConfirmation", nil)
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

  const NSInteger numberOfRowsInSectionBeforeDeletion = [self tableView:_tableView numberOfRowsInSection:indexPath.section];

  // delete entry from storage
  RealmEntry *entryToDelete = [self _entryForIndexPath:indexPath];
  if (shouldFullyDeleteEntry) {
    [[RealmEntryStorage sharedStorage] deleteEntry:entryToDelete];
  } else {
    [[RealmEntryStorage sharedStorage] archiveEntry:entryToDelete];
  }
  [self _refetchData];

  // update table view
  if (_dataProvider.contentType == ListViewDataSourceContentTypeAll && !shouldFullyDeleteEntry) {
    // reload summary & affected row
    NSIndexPath* firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[firstRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [_tableView endUpdates];
  } else if (numberOfRowsInSectionBeforeDeletion <= 2) {
    // delete whole section animated
    [_tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
  } else {
    // delete entry row & reload summary row animated
    NSIndexPath* firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[firstRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [_tableView endUpdates];
  }

  _ignoreDataUpdates = NO;

  if (!shouldFullyDeleteEntry) {
    [self _showConfirmationAndScrollToShowSegmentedControlIfArchivedFirstEntry];
  } else if (_dataProvider.entryGroups.count == 0) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.row > 0);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

@end
