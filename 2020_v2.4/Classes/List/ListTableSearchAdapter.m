//
//  ListSearchView.m
//  StillWaitin
//

#import "ListTableSearchAdapter.h"

#import "SWColors.h"
#import <UIView+SimplePositioning.h>

@interface ListTableSearchAdapter () <UISearchBarDelegate>
@end

@implementation ListTableSearchAdapter {
  __weak UITableView *_attachedTableView;
  BOOL _applyContentTypeToGroups;

  UISearchBar *_searchBar;
  UISegmentedControl *_segmentedControl;
}

- (instancetype)initWithTableView:(UITableView *)tableView
         applyContentTypeToGroups:(BOOL)applyContentTypeToGroups
    shouldHideContentTypeSelector:(BOOL)shouldHideContentTypeSelector
              selectedContentType:(ListViewDataSourceContentType)selectedContentType {
  self = [super init];
  if (self) {
    _attachedTableView = tableView;
    _applyContentTypeToGroups = applyContentTypeToGroups;

    // Search Bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, shouldHideContentTypeSelector ? -51.0 : -90.0, _attachedTableView.frameWidth, 40.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    searchBar.placeholder = NSLocalizedString(@"keySearch", nil);
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.delegate = self;
    searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.tintColor = SWColorGreenContrastTintColor();
    [_attachedTableView addSubview:searchBar];
    _searchBar = searchBar;

    if (!shouldHideContentTypeSelector) {
      UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(8, -40, _attachedTableView.frameWidth-16, 29.0)];
      segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
      segmentedControl.tintColor = SWColorListFilterControlTintColor();
      [segmentedControl insertSegmentWithTitle:NSLocalizedString(@"keyOpenEntries", nil) atIndex:0 animated:NO];
      [segmentedControl insertSegmentWithTitle:NSLocalizedString(@"keyArchivedEntries", nil) atIndex:1 animated:NO];
      [segmentedControl insertSegmentWithTitle:NSLocalizedString(@"keyAllEntries", nil) atIndex:2 animated:NO];
      [segmentedControl setSelectedSegmentIndex:SegementedControlIndexForDataSourceContentType(selectedContentType)];
      [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
      [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: SWColorHighContrastTextColor()}
                                      forState:UIControlStateNormal];
      [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: SWColorGreenMain()}
                                      forState:UIControlStateSelected];
      [_attachedTableView addSubview:segmentedControl];
      _segmentedControl = segmentedControl;
    }
  }
  return self;
}

#pragma mark - Scroll handling

- (BOOL)isSearchBarFullyVisible {
  return ([_attachedTableView.superview convertPoint:_searchBar.frameOrigin fromView:_attachedTableView].y >= 0);
}

- (BOOL)_isSegmentedControlCenterVisible {
  return ([_attachedTableView.superview convertPoint:_segmentedControl.center fromView:_attachedTableView].y >= 0);
}

- (void)tableViewDidScroll {
  if (![self isSearchBarFullyVisible]) {
    [_searchBar resignFirstResponder];
  }
  [self _HACK_revertSearchBarSuperViewIfNeeded];
}

- (void)scrollTableViewToShowSearchView {
  [self _setTopContentInsetWhileKeepingContentOffset:fabs(_searchBar.frameY - 10)];
  [_attachedTableView setContentOffset:CGPointMake(0, _searchBar.frameOrigin.y - 10) animated:YES];
}

- (void)_scrollTableViewToHideSearchView {
  [self _HACK_revertSearchBarSuperViewIfNeeded];

  __weak __typeof(self) weakSelf = self;
  [UIView animateWithDuration:0.33 animations:^{
    self->_attachedTableView.contentOffset = CGPointZero;
  } completion:^(BOOL finished) {
    [weakSelf _setTopContentInsetWhileKeepingContentOffset:0];
  }];
}

- (void)updateTargetContentOffsetAfterScrollingEnded:(inout CGPoint *)targetContentOffset {
  const BOOL isCurrentlySticky = (_attachedTableView.contentInset.top != 0);
  const BOOL segmentedControlCenterVisible = [self _isSegmentedControlCenterVisible];
  const BOOL searchBarFullyVisible = [self isSearchBarFullyVisible];
  if (!isCurrentlySticky && segmentedControlCenterVisible) {
    [self _setTopContentInsetWhileKeepingContentOffset:fabs(_searchBar.frameY - 10)];
    *targetContentOffset = CGPointMake(0, _searchBar.frameY - 10);
  } else if (isCurrentlySticky && !searchBarFullyVisible) {
    CGPoint previousOffset = _attachedTableView.contentOffset;
    [self _setTopContentInsetWhileKeepingContentOffset:0];
    if (previousOffset.y < 0) {
      *targetContentOffset = CGPointZero;
    }
  }
}

- (void)_setTopContentInsetWhileKeepingContentOffset:(CGFloat)topContentInset {
  CGPoint previousOffset = _attachedTableView.contentOffset;
  UIEdgeInsets insets = _attachedTableView.contentInset;
  insets.top = topContentInset;
  _attachedTableView.contentInset = insets;
  _attachedTableView.contentOffset = previousOffset;
}

#pragma mark - SegmentedControl

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
  ListViewDataSourceContentType selectedContentType = DataSourceContentTypeForSegementedControlIndex(segmentedControl.selectedSegmentIndex,
                                                                                                     _applyContentTypeToGroups);
  [_delegate searchViewDidSelectContentType:selectedContentType];
}

static ListViewDataSourceContentType DataSourceContentTypeForSegementedControlIndex(NSInteger index,
                                                                                    BOOL applyContentTypeToGroups) {
  switch (index) {
    case 2:
      return ListViewDataSourceContentTypeAll;
    case 1:
      return (applyContentTypeToGroups
              ? ListViewDataSourceContentTypeArchivedGroups
              : ListViewDataSourceContentTypeArchivedEntries);
    case 0:
    default:
      return ListViewDataSourceContentTypeActive;
  }
}

static NSInteger SegementedControlIndexForDataSourceContentType(ListViewDataSourceContentType contentType) {
  switch (contentType) {
    case ListViewDataSourceContentTypeActive:
      return 0;
    case ListViewDataSourceContentTypeArchivedGroups:
    case ListViewDataSourceContentTypeArchivedEntries:
      return 1;
    case ListViewDataSourceContentTypeAll:
      return 2;
  }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  [self _HACK_changeSearchBarSuperViewSoTableViewDoesntScrollIfNeeded];
  [searchBar setShowsCancelButton:YES animated:YES];
  return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
  [searchBar setShowsCancelButton:NO animated:YES];
  return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  [_delegate searchViewDidUpdateSearchString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [_searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [_searchBar resignFirstResponder];
  _searchBar.text = nil;
  [self _scrollTableViewToHideSearchView];
  [_delegate searchViewDidUpdateSearchString:nil];
}

#pragma mark - Fix stupid SearchBar animation

static CGRect HACK_previousSearchBarRect;
- (void)_HACK_changeSearchBarSuperViewSoTableViewDoesntScrollIfNeeded {
  if (_searchBar.superview == _attachedTableView) {
    HACK_previousSearchBarRect = _searchBar.frame;
    [_searchBar removeFromSuperview];
    [_attachedTableView.superview addSubview:_searchBar];
    _searchBar.frameOrigin = CGPointMake(0, 10);
  }
}

- (void)_HACK_revertSearchBarSuperViewIfNeeded {
  if (_searchBar.superview == _attachedTableView.superview) {
    [_searchBar removeFromSuperview];
    [_attachedTableView addSubview:_searchBar];
    _searchBar.frame = HACK_previousSearchBarRect;
  }
}

@end
