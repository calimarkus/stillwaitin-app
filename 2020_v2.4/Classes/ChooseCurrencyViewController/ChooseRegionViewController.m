//
//  ChooseRegionViewController.m
//  StillWaitin
//
//

#import "ChooseRegionViewController.h"

#import "CurrencyManager.h"
#import "SWColors.h"
#import "SWSettingsCell.h"
#import "SimpleTableView.h"
#import "UIAlertController+SimpleUIKit.h"
#import "UITableView+iOS11.h"

@implementation ChooseRegionViewController {
  NSString *_currencyDescription;
  NSArray<NSLocale *> *_locales;

  NSNumberFormatter *_currencyFormatter;
}

- (instancetype)initWithCurrencyDescription:(NSString *)currencyDescription
                                    locales:(NSArray<NSLocale *> *)locales {
  self = [super init];
  if (self) {
    _currencyDescription = [currencyDescription copy];
    _locales = [locales copy];

    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setMaximumFractionDigits:2];
    [currencyFormatter setMinimumFractionDigits:2];
    _currencyFormatter = currencyFormatter;

    self.title = currencyDescription;
  }
  return self;
}

- (void)loadView {
  SimpleTableView *simpleTableView = [[SimpleTableView alloc] initWithTableViewStyle:UITableViewStyleGrouped];
  simpleTableView.tableView.backgroundColor = SWColorGrayWash();
  simpleTableView.tableView.tableFooterView = [UIView new];
  [simpleTableView.tableView registerClass:[SWSettingsCell class] forCellReuseIdentifier:SWSettingsCellReuseIdentifier];
  [simpleTableView.tableView sw_setupBottomInsetAndDisableAutomaticContentInsetAdjustment];
  self.view = simpleTableView;

  NSMutableSet *allFormattings = [NSMutableSet setWithCapacity:_locales.count];
  NSMutableDictionary *formattingsToLocales = [NSMutableDictionary dictionary];
  for (NSLocale *locale in [_locales reverseObjectEnumerator]) {
    _currencyFormatter.locale = locale;
    NSString *formattedValue = [_currencyFormatter stringFromNumber:@(34567.89)];
    [allFormattings addObject:formattedValue];
    formattingsToLocales[formattedValue] = locale;
  }

  __weak __typeof(self) weakSelf = self;
  NSMutableArray<STVRow *> *allCurrencyRows = [NSMutableArray array];
  NSArray *sortedFormattings = [[allFormattings allObjects] sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *formattedValue in sortedFormattings) {
    STVRow *row = [STVRow rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                               title:formattedValue
                                            subtitle:nil
                                  configureCellBlock:nil
                                      didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
      [weakSelf showConfirmationAlertForLocale:formattingsToLocales[formattedValue] fromViewController:weakSelf];
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];

    [allCurrencyRows addObject:row];
  }

  simpleTableView.sectionModels = @[[STVSection sectionWithTitle:NSLocalizedString(@"keyCurrencyChooseFormatting", nil)
                                               sectionIndexTitle:nil
                                                            rows:allCurrencyRows]];
}

- (void)showConfirmationAlertForLocale:(NSLocale *)locale
                    fromViewController:(UIViewController *)viewController {
  UINavigationController *navigationController = viewController.navigationController;
  [UIAlertController presentAlertFromViewController:viewController
                                          withTitle:[NSString stringWithFormat:NSLocalizedString(@"keyCurrencySettingTitleFormat", nil), _currencyDescription]
                                            message:NSLocalizedString(@"keyCurrencySettingInfo", nil)
                                            buttons:@[[SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)],
                                                      [SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyOk", nil)]]
                                      buttonHandler:^(UIAlertAction *action) {
    if (action.style != UIAlertActionStyleCancel) {
      [CurrencyManager setCurrentCurrencyLocaleIdentifier:locale.localeIdentifier];
      [navigationController popToRootViewControllerAnimated:YES];
    }
  }];
}

@end
