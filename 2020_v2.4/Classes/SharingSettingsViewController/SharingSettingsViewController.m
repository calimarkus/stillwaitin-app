//
//  SharingSettingsViewController.m
//  StillWaitin
//
//

#import "SharingSettingsViewController.h"

#import "DebtSenderTemplates.h"
#import "SWColors.h"
#import "SWSettingsCell.h"
#import "SharingEditTextViewController.h"
#import "SimpleTableView.h"
#import "UITableView+iOS11.h"
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>

@implementation SharingSettingsViewController {
  DebtSenderTemplates *_templates;
  DebtSenderTemplates *_originalTemplates;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _templates = CurrentDebtSenderTemplates();
    _originalTemplates = OriginalDebtSenderTemplates();
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

  __weak typeof(self) weakSelf = self;
  simpleTableView.sectionModels = @[[STVSection sectionWithTitle:NSLocalizedString(@"keyShareOther", nil) sectionIndexTitle:nil rows:
                                     @[[STVRow
                                        rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                        title:NSLocalizedString(@"keySharingIncoming", nil)
                                        subtitle:nil
                                        configureCellBlock:nil
                                        didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                                          [weakSelf _presentEditControllerWithTitle:NSLocalizedString(@"keySharingIncoming", nil)
                                                                            keyPath:@"otherSharingFormatIn"];
                                        }],
                                       [STVRow
                                        rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                        title:NSLocalizedString(@"keySharingOutgoing", nil)
                                        subtitle:nil
                                        configureCellBlock:nil
                                        didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                                          [weakSelf _presentEditControllerWithTitle:NSLocalizedString(@"keySharingOutgoing", nil)
                                                                            keyPath:@"otherSharingFormatOut"];
                                        }]]
                                     ],
                                    [STVSection sectionWithTitle:NSLocalizedString(@"keyEmail", nil) sectionIndexTitle:nil rows:
                                     @[[STVRow
                                        rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                        title:NSLocalizedString(@"keySharingMailIncoming", nil)
                                        subtitle:nil
                                        configureCellBlock:nil
                                        didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                                          [weakSelf _presentEditControllerWithTitle:NSLocalizedString(@"keySharingMailIncoming", nil)
                                                                            keyPath:@"emailFormatIn"];
                                        }],
                                       [STVRow
                                        rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                        title:NSLocalizedString(@"keySharingMailOutgoing", nil)
                                        subtitle:nil
                                        configureCellBlock:nil
                                        didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                                          [weakSelf _presentEditControllerWithTitle:NSLocalizedString(@"keySharingMailOutgoing", nil)
                                                                            keyPath:@"emailFormatOut"];
                                        }],
                                       [STVRow
                                        rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                        title:NSLocalizedString(@"keySharingMailSummary", nil)
                                        subtitle:nil
                                        configureCellBlock:nil
                                        didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                                          [weakSelf _presentEditControllerWithTitle:NSLocalizedString(@"keySharingMailSummary", nil)
                                                                            keyPath:@"emailFormatSummary"];
                                        }]]
                                     ],
                                    [STVSection sectionWithTitle:NSLocalizedString(@"keyReset", nil) sectionIndexTitle:nil rows:
                                     @[[STVRow
                                        rowWithCellReuseIdentifier:SWSettingsCellReuseIdentifier
                                        title:NSLocalizedString(@"keySharingResetToDefaults", nil)
                                        subtitle:nil
                                        configureCellBlock:nil
                                        didSelectBlock:^(STVRow *rowModel, UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath) {
                                          [weakSelf _alertToResetTemplatesToDefaults];
                                        }]]
                                     ]];
}

- (void)_presentEditControllerWithTitle:(NSString *)title keyPath:(NSString *)keyPath {
  SharingEditTextViewController *controller = [[SharingEditTextViewController alloc]
                                               initWithText:[_templates valueForKeyPath:keyPath]
                                               keywords:[self _findReplaceableTokensInString:
                                                         [_originalTemplates valueForKeyPath:keyPath]]];
  controller.title = title;

  __weak typeof(self) weakSelf = self;
  controller.didSaveBlock = ^(NSString *newText){
    [weakSelf _saveText:newText forKeyPath:keyPath];
    [weakSelf.navigationController popViewControllerAnimated:YES];
  };
  [self.navigationController pushViewController:controller animated:YES];
}

- (NSArray *)_findReplaceableTokensInString:(NSString *)text {
  NSMutableArray *const keywords = [NSMutableArray array];
  NSMutableCharacterSet *const mutableCharacterSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
  [mutableCharacterSet addCharactersInString:@",./?!:-\\'\""];
  for (NSString *substring in [text componentsSeparatedByCharactersInSet:mutableCharacterSet]) {
    if ([substring hasPrefix:@"#"] && [substring hasSuffix:@"#"]) {
      [keywords addObject:substring];
    }
  };
  return [keywords copy];
}

- (void)_saveText:(NSString *)text forKeyPath:(NSString *)keyPath {
  [_templates setValue:text forKeyPath:keyPath];
  SetCurrentDebtSenderTemplates(_templates);
}

- (void)_alertToResetTemplatesToDefaults {
  __weak typeof(self) weakSelf = self;
  [UIAlertController presentAlertFromViewController:self
                                          withTitle:NSLocalizedString(@"keyNotice", nil)
                                            message:NSLocalizedString(@"keySharingAlertMessageForReset", nil)
                                            buttons:@[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyOk", nil)],
                                                      [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]
                                      buttonHandler:^(UIAlertAction *action) {
    if (![action.title isEqualToString:NSLocalizedString(@"keyCancel", nil)]) {
      [weakSelf _resetTemplatesToDefaults];
    }
  }];
}

- (void)_resetTemplatesToDefaults {
  _templates = _originalTemplates;
  SetCurrentDebtSenderTemplates(nil);
}

@end
