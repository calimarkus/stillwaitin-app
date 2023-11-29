//
//  ChooseCurrencyViewController.m
//  StillWaitin
//
//

#import "ChooseCurrencyViewController.h"

#import "ChooseRegionViewController.h"
#import "ListTableSearchAdapter.h"
#import "NSArray+Map.h"
#import "SWColors.h"
#import "SWSettingsCell.h"
#import "SimpleTableView.h"
#import "UITableView+iOS11.h"

static NSMutableDictionary<NSString *, NSMutableArray<NSLocale *> *> *staticCurrencyNameToLocalesMap;
static NSArray<NSString *> *staticSortedCurrencyNames;
static NSArray<NSString *> *staticCurrentLocaleCurrencyNames;

@interface ChooseCurrencyViewController () <
ListTableSearchAdapterDelegate,
SimpleTableViewScrollViewDelegate
>
@end

@implementation ChooseCurrencyViewController {
  SimpleTableView *_simpleTableView;
  ListTableSearchAdapter *_listSearchAdapter;

  NSArray<NSString *> *_searchResults;
}

- (void)loadView {
  self.title = NSLocalizedString(@"keyChooseCurrency", nil);

  SimpleTableView *simpleTableView = [[SimpleTableView alloc] initWithTableViewStyle:UITableViewStyleGrouped];
  simpleTableView.tableView.backgroundColor = SWColorGrayWash();
  simpleTableView.tableView.tableFooterView = [UIView new];
  simpleTableView.scrollDelegate = self;
  [simpleTableView.tableView registerClass:[SWSettingsCell class] forCellReuseIdentifier:SWSettingsCellReuseIdentifier];
  [simpleTableView.tableView sw_setupBottomInsetAndDisableAutomaticContentInsetAdjustment];
  self.view = simpleTableView;
  _simpleTableView = simpleTableView;

  // list search view
  _listSearchAdapter = [[ListTableSearchAdapter alloc] initWithTableView:simpleTableView.tableView
                                             applyContentTypeToGroups:NO
                                        shouldHideContentTypeSelector:YES
                                                  selectedContentType:ListViewDataSourceContentTypeAll];
  _listSearchAdapter.delegate = self;

  // loading state
  simpleTableView.sectionModels = @[[STVSection
                                     sectionWithTitle:nil
                                     sectionIndexTitle:nil
                                     rows:@[[STVRow
                                             rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                             title:NSLocalizedString(@"keyLoading", nil)
                                             subtitle:nil
                                             configureCellBlock:nil
                                             didSelectBlock:nil
                                             ]]]];

  // start loading data
  __weak typeof(self) weakSelf = self;
  [self reloadDataWithCompletion:^{
    [weakSelf updateSectionModels];
  }];
}

- (void)updateSectionModels {
  NSMutableArray<STVRow *> *currentLocaleCurrencyRows = [NSMutableArray array];
  NSMutableArray<STVRow *> *allCurrencyRows = [NSMutableArray array];
  for (NSArray *currencyNames in @[staticCurrentLocaleCurrencyNames, _searchResults ?: staticSortedCurrencyNames]) {
    BOOL isCurrentLocaleCurrency = (currencyNames == staticCurrentLocaleCurrencyNames);
    for (NSString *currencyName in currencyNames) {
      STVRow *row = [STVRow rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                                 title:currencyName
                                              subtitle:(isCurrentLocaleCurrency ? NSLocalizedString(@"keyCurrencyDefaultRegion", nil) : @"")
                                    configureCellBlock:nil
                                        didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
        [self didSelectCurrencyName:currencyName
                skipRegionSelection:isCurrentLocaleCurrency];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
      }];

      if (isCurrentLocaleCurrency) {
        [currentLocaleCurrencyRows addObject:row];
      } else {
        [allCurrencyRows addObject:row];
      }
    }
  }

  _simpleTableView.sectionModels = (currentLocaleCurrencyRows.count > 0
                                    ? @[[STVSection sectionWithTitle:nil sectionIndexTitle:nil rows:currentLocaleCurrencyRows],
                                        [STVSection sectionWithTitle:nil sectionIndexTitle:nil rows:allCurrencyRows]]
                                    : @[[STVSection sectionWithTitle:nil sectionIndexTitle:nil rows:allCurrencyRows]]);
}

- (void)didSelectCurrencyName:(NSString *)currencyName
          skipRegionSelection:(BOOL)skipRegionSelection {
  ChooseRegionViewController *regionViewController = [[ChooseRegionViewController alloc] initWithCurrencyDescription:currencyName
                                                                                                             locales:staticCurrencyNameToLocalesMap[currencyName]];
  if (skipRegionSelection) {
    [regionViewController showConfirmationAlertForLocale:staticCurrencyNameToLocalesMap[currencyName].firstObject
                                      fromViewController:self];
  } else {
    [self.navigationController pushViewController:regionViewController animated:YES];
  }
}

#pragma mark - ListTableSearchAdapterDelegate

- (void)searchViewDidUpdateSearchString:(NSString *)searchString {
  if (staticCurrencyNameToLocalesMap != nil) {
    if (searchString.length > 0) {
      _searchResults = [staticSortedCurrencyNames filter:^BOOL(NSString *currencyName) {
        return [currencyName localizedCaseInsensitiveContainsString:searchString];
      }];
    } else {
      _searchResults = nil;
    }
    [self updateSectionModels];
  }
}

- (void)searchViewDidSelectContentType:(ListViewDataSourceContentType)selectedContentType {}

#pragma mark - SimpleTableViewScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [_listSearchAdapter tableViewDidScroll];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  [_listSearchAdapter updateTargetContentOffsetAfterScrollingEnded:targetContentOffset];
}

#pragma mark load data

- (void)reloadDataWithCompletion:(void(^)(void))completion {
  if (staticCurrencyNameToLocalesMap != nil) {
    if (completion) {
      completion();
    }
    return;
  }

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSArray<NSString *> *allLocaleIdentifiers = [NSLocale availableLocaleIdentifiers];
      NSMutableDictionary<NSString *, NSMutableArray<NSLocale *> *> *currencyNameToLocales = [NSMutableDictionary dictionary];

      for (NSString *localeIdentifier in allLocaleIdentifiers) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
        if (locale.currencyCode == nil) {
          continue;
        }

        NSString *currencyDescription = currencyDescriptionForLocale(locale);
        NSMutableArray<NSLocale *> *localesForCurrencyName = currencyNameToLocales[currencyDescription] ?: [NSMutableArray array];
        [localesForCurrencyName addObject:locale];
        currencyNameToLocales[currencyDescription] = localesForCurrencyName;
      }

      // create current locale data
      NSString *currentLocaleCurrencyDescription = currencyDescriptionForLocale([NSLocale currentLocale]);
      if (currentLocaleCurrencyDescription.length > 0) {
        NSMutableArray<NSLocale *> *localesForCurrentLocaleCurrencyName = currencyNameToLocales[currentLocaleCurrencyDescription] ?: [NSMutableArray array];
        [localesForCurrentLocaleCurrencyName removeObject:[NSLocale currentLocale]];
        [localesForCurrentLocaleCurrencyName insertObject:[NSLocale currentLocale] atIndex:0];
        currencyNameToLocales[currentLocaleCurrencyDescription] = localesForCurrentLocaleCurrencyName;
        staticCurrentLocaleCurrencyNames = @[currentLocaleCurrencyDescription];
      } else {
        staticCurrentLocaleCurrencyNames = @[];
      }

      // cache data statically
      staticCurrencyNameToLocalesMap = currencyNameToLocales;
      staticSortedCurrencyNames = [currencyNameToLocales.allKeys sortedArrayUsingSelector:@selector(compare:)];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      if (completion) {
        completion();
      }
    });
  });
}

static NSString *currencyDescriptionForLocale(NSLocale *locale) {
  NSString *localizedCurrencyName = [[NSLocale currentLocale] localizedStringForCurrencyCode:locale.currencySymbol];
  return ([locale.currencyCode isEqualToString:locale.currencySymbol]
          ? (localizedCurrencyName.length > 0
             ? [NSString stringWithFormat:@"%@ (%@)", locale.currencyCode, localizedCurrencyName]
             : locale.currencyCode)
          : [NSString stringWithFormat:@"%@ (%@)", locale.currencyCode, locale.currencySymbol]);
}

@end

