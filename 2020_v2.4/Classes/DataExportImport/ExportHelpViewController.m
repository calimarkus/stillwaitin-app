//
//  ExportHelpViewController.m
//  StillWaitin
//
//

#import "ExportHelpViewController.h"

#import "SWColors.h"
#import "UITableView+iOS11.h"
#import <SimpleUIKit/SimpleTableView.h>
#import <SimpleUIKit/UIView+SimplePositioning.h>

NSString *const ExportHelpViewControllerCellIdentifier = @"ExportHelpViewControllerCellIdentifier";

@interface ExportHelpViewTableCell : UITableViewCell
+ (CGFloat)heightForText:(NSString *)text detailText:(NSString *)detailText width:(CGFloat)width;
@end
@implementation ExportHelpViewTableCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
  }
  return self;
}
+ (CGFloat)heightForText:(NSString *)text detailText:(NSString *)detailText width:(CGFloat)width {
  CGSize const maximumSize = CGSizeMake(width - 15*2, 2000);
  NSStringDrawingOptions const options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
  CGRect textBounds = [text boundingRectWithSize:maximumSize options:options attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]} context:nil];
  CGRect detailTextBounds = [detailText boundingRectWithSize:maximumSize options:options attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]} context:nil];
  return textBounds.size.height + detailTextBounds.size.height + 28.0;
}
@end

@implementation ExportHelpViewController

- (void)loadView {
  SimpleTableView *simpleTableView = [[SimpleTableView alloc] initWithTableViewStyle:UITableViewStyleGrouped];
  simpleTableView.tableView.backgroundColor = SWColorGrayWash();
  [simpleTableView.tableView registerClass:[ExportHelpViewTableCell class] forCellReuseIdentifier:ExportHelpViewControllerCellIdentifier];
  [simpleTableView.tableView sw_setupBottomInsetAndDisableAutomaticContentInsetAdjustment];
  self.view = simpleTableView;

  __weak typeof(self) weakSelf = self;
  simpleTableView.rowHeightProvider = ^(STVRow *rowModel, UITableView *tableView, NSIndexPath *indexPath){
    return [ExportHelpViewTableCell heightForText:rowModel.title
                                       detailText:rowModel.subtitle
                                            width:weakSelf.view.frameWidth];
  };

  simpleTableView.sectionModels = [self _setupSections];
}

- (NSArray<STVSection *> *)_setupSections {
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"ExportHelp" withExtension:@"plist" subdirectory:nil];
  NSArray *data = [[NSArray alloc] initWithContentsOfURL:url];
  NSMutableArray<STVSection *> *sections = [NSMutableArray array];
  for (NSDictionary *dict in data) {
    [sections addObject:
     [STVSection sectionWithTitle:nil
                sectionIndexTitle:nil
                             rows:@[[STVRow
                                     rowWithCellReuseIdentifier:ExportHelpViewControllerCellIdentifier
                                     title:dict[@"title"]
                                     subtitle:dict[@"subtitle"]
                                     configureCellBlock:nil
                                     didSelectBlock:nil]]]];
  }
  return sections;
}

@end
