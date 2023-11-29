//
//  SharingSettingsViewController.m
//  StillWaitin
//
//

#import "SettingsSelectListOptionViewController.h"

#import "NSArray+Map.h"
#import "SWColors.h"
#import "SWSettingsCell.h"
#import "SimpleTableView.h"
#import "UITableView+iOS11.h"

@implementation ListOption {
  NSString *_displayName;
  NSInteger _value;
}

+ (instancetype)optionWithDisplayName:(NSString *)displayName value:(NSInteger)value {
  ListOption *listOption = [ListOption new];
  listOption->_displayName = [displayName copy];
  listOption->_value = value;
  return listOption;
}

@end

@implementation SettingsSelectListOptionViewController {
  NSArray<ListOption *> *_options;
  NSInteger _defaultValue;
  NSString *_userDefaultsKey;
  void(^_didSelectCallback)(void);
}

- (instancetype)initWithOptions:(NSArray<ListOption *> *)options
                   defaultValue:(NSInteger)defaultValue
                userDefaultsKey:(NSString *)userDefaultsKey
              didSelectCallback:(void(^)(void))didSelectCallback {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _options = options;
    _defaultValue = defaultValue;
    _userDefaultsKey = userDefaultsKey;
    _didSelectCallback = [didSelectCallback copy];
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

  NSInteger const defaultValue = _defaultValue;
  NSString *const userDefaultsKey = _userDefaultsKey;
  void(^didSelectCallback)(void) = _didSelectCallback;
  simpleTableView.sectionModels = @[[STVSection sectionWithTitle:nil sectionIndexTitle:nil rows:[_options map:^id(ListOption *listOption) {
    return [STVRow
            rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
            title:listOption.displayName
            subtitle:nil
            configureCellBlock:^(STVRow *STVRow, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
              NSNumber *const savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:userDefaultsKey];
              NSInteger const currentValue = (savedValue ? [savedValue integerValue] : defaultValue);
              [(SWSettingsCell *)cell setShowsCheckmark:(currentValue == listOption.value)];
            } didSelectBlock:^(STVRow *rowModel, UITableViewCell *selectedCell, UITableView *tableView, NSIndexPath *indexPath) {
              for (SWSettingsCell *cell in tableView.visibleCells) {
                [cell setShowsCheckmark:NO];
              }
              [(SWSettingsCell *)selectedCell setShowsCheckmark:YES];

              [[NSUserDefaults standardUserDefaults] setObject:@(listOption.value) forKey:userDefaultsKey];

              if (didSelectCallback) {
                didSelectCallback();
              }
            }];
  }]]];
}

@end
