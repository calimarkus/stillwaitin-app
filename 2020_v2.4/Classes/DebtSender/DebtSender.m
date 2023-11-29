//
//  DebtSender.m
//  StillWaitin
//
//

#import "DebtSender.h"

#import "AddressBookContact.h"
#import "CurrencyManager.h"
#import "DebtSenderTemplates.h"
#import "DetailViewController.h"
#import "RealmEntry.h"
#import "RealmEntryGroup.h"
#import "RealmEntryStorage.h"
#import "SWColors.h"
#import <MessageUI/MessageUI.h>
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>

@interface DebtSender () <
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate
>
@end

@implementation DebtSender {
  RealmEntry *_entry;
  NSNumberFormatter *_numberFormatter;
  NSDateFormatter *_dateFormatter;
  DebtSenderTemplates *_templates;
}

- (instancetype)initWithEntry:(RealmEntry *)entry {
  self = [super init];
  if (self) {
    _entry = entry;
    _numberFormatter = [CurrencyManager currencyNumberFormatter];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    _templates = CurrentDebtSenderTemplates();
  }
  return self;
}

- (void)presentSelectionFromViewController:(UIViewController *)viewController
                                    sender:(UIView *)sender {
  const BOOL canSendSMS = [MFMessageComposeViewController canSendText];
  const BOOL canSendMail = [MFMailComposeViewController canSendMail];

  if (canSendMail || canSendSMS) {
    NSMutableArray<SimpleAlertButton *> *buttons = [NSMutableArray array];
    if (canSendMail) {
      [buttons addObject:[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyEmail", nil)]];
    }
    if (canSendSMS) {
      [buttons addObject:[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keySMS", nil)]];
    }
    [buttons addObject:[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyShareOther", nil)]];
    [buttons addObject:[SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]];

    __weak typeof(self) weakSelf = self;
    [UIAlertController presentActionSheetFromViewController:viewController
                                                 sourceView:sender
                                                  withTitle:nil
                                                    message:nil
                                                    buttons:buttons
                                              buttonHandler:^(UIAlertAction *action) {
      if ([action.title isEqualToString:NSLocalizedString(@"keyEmail", nil)]) {
        [weakSelf _showEmailSelectionFromViewController:viewController sender:sender];
      } else if([action.title isEqualToString:NSLocalizedString(@"keySMS", nil)]) {
        [weakSelf _showSMSComposerFromViewController:viewController];
      } else if([action.title isEqualToString:NSLocalizedString(@"keyShareOther", nil)]) {
        [weakSelf _showActivityVCFromViewController:viewController
                                             sender:sender];
      }
    }];
  } else {
    [self _showActivityVCFromViewController:viewController
                                     sender:sender];
  }
}

- (void)_showEmailSelectionFromViewController:(UIViewController *)viewController
                                       sender:(UIView *)sender {
  NSArray<RealmEntry *> *const currentEntry = @[_entry];
  NSArray *const entriesForPerson = [[RealmEntryStorage sharedStorage] entriesMatchingFullName:_entry.fullName withFilter:RealmEntryStorageFilterActiveEntries];
  NSArray *const dateSortedEntriesForPerson = [entriesForPerson sortedArrayUsingDescriptors:
                                               @[[NSSortDescriptor sortDescriptorWithKey:@"debtDate" ascending:YES]]];

  if ([dateSortedEntriesForPerson count] > 1) {
    __weak __typeof(self) weakSelf = self;
    [UIAlertController presentActionSheetFromViewController:viewController
                                                 sourceView:sender
                                                  withTitle:nil
                                                    message:nil
                                                    buttons:@[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyMailAllDebtsOfPerson", nil)],
                                                              [SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyMailSingleDebt", nil)],
                                                              [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]
                                              buttonHandler:^(UIAlertAction *action) {
      if([action.title isEqualToString:NSLocalizedString(@"keyMailSingleDebt", nil)]) {
        [weakSelf _showEmailComposerFromViewController:viewController entriesToShare:currentEntry];
      } else if([action.title isEqualToString:NSLocalizedString(@"keyMailAllDebtsOfPerson", nil)]) {
        [weakSelf _showEmailComposerFromViewController:viewController entriesToShare:dateSortedEntriesForPerson];
      }
    }];
  } else {
    [self _showEmailComposerFromViewController:viewController entriesToShare:currentEntry];
  }
}

- (void)_showSMSComposerFromViewController:(UIViewController *)viewController {
  MFMessageComposeViewController *smsController = [[MFMessageComposeViewController alloc] init];
  smsController.view.tintColor = SWColorGreenContrastTintColor();
  smsController.messageComposeDelegate = self;
  [smsController setBody:[self _shortShareText]];
  if (_entry.phoneNumber) {
    [smsController setRecipients:@[_entry.phoneNumber]];
  }
  [viewController presentViewController:smsController animated:YES completion:nil];
}

- (void)_showActivityVCFromViewController:(UIViewController *)viewController
                                   sender:(UIView *)sender {
  UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[self _shortShareText]]
                                                                                       applicationActivities:nil];
  activityViewController.popoverPresentationController.sourceView = sender;
  activityViewController.popoverPresentationController.sourceRect = sender.bounds;

  [viewController presentViewController:activityViewController animated:YES completion:nil];
}

- (void)_showEmailComposerFromViewController:(UIViewController *)viewController
                             entriesToShare:(NSArray<RealmEntry *> *)entriesToShare {
  if (![MFMailComposeViewController canSendMail]) return;

  MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
  mailController.modalPresentationStyle = UIModalPresentationFormSheet;
  mailController.mailComposeDelegate = self;
  mailController.view.tintColor = SWColorGreenContrastTintColor();

  [mailController setSubject:NSLocalizedString(@"keyMailSubject", nil)];

  [mailController setMessageBody:MailBodyForEntries(entriesToShare, _templates, _dateFormatter, _numberFormatter)
                          isHTML:YES];

  if (_entry.email.length > 0) {
    [mailController setToRecipients:[NSArray arrayWithObjects:_entry.email, nil]];
  }

  if (entriesToShare.count == 1 && _entry.photofilename != nil) {
    UIImage * image = [UIImage imageWithContentsOfFile:PhotoFilePathForRealmEntry(_entry)];
    if (image != nil) {
      NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
      [mailController addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"photo.jpg"];
    }
  }

  [viewController presentViewController:mailController animated:YES completion:nil];
}

#pragma mark - Helper

- (NSString *)_shortShareText {
  NSString *const shareBody = StringWithReplacedTokens((_entry.debtDirection == DebtDirectionIn ?
                                                        _templates.otherSharingFormatIn :
                                                        _templates.otherSharingFormatOut),
                                                       @{@"name" : _entry.fullName,
                                                         @"value" : [_numberFormatter stringFromNumber:_entry.value],
                                                         @"date" : [_dateFormatter stringFromDate:_entry.debtDate],
                                                         @"description" : (_entry.entryDescription.length > 0 ?
                                                                           _entry.entryDescription :
                                                                           NSLocalizedString(@"keyNoDescription", nil))}
                                                       );

  NSString * const sharingFooterTextWithAppstoreLink = [NSString stringWithFormat:NSLocalizedString(@"keySentWithAppLinkFormat", nil), @"http://is.gd/stillwaitin"];
  NSString * const shareBodyWithAppstoreLink = [shareBody stringByAppendingString:sharingFooterTextWithAppstoreLink];
  return shareBodyWithAppstoreLink;
}

static NSString *StringWithReplacedTokens(NSString *sourceString, NSDictionary<NSString *, NSString *> *tokenToStringMapping) {
  NSMutableString *mutableString = [sourceString mutableCopy];
  [tokenToStringMapping enumerateKeysAndObjectsUsingBlock:^(NSString *tokenKey, NSString *string, BOOL *stop) {
    [mutableString replaceOccurrencesOfString:[NSString stringWithFormat:@"#%@#", tokenKey]
                                   withString:string
                                      options:0
                                        range:NSMakeRange(0, mutableString.length)];
  }];
  return [mutableString copy];
}

static NSString *ContentsOfHTMLFileNamed(NSString *fileName) {
  return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"html"]
                                   encoding:NSUTF8StringEncoding
                                      error:nil];
}

static NSString *LocationBodyForEntry(RealmEntry *entry, NSDateFormatter *dateFormatter) {
  if (entry.location != nil) {
    return StringWithReplacedTokens(ContentsOfHTMLFileNamed(@"location"),
                                    @{@"latitude" : [NSString stringWithFormat: @"%@", @(entry.location.latitude)],
                                      @"longitude" : [NSString stringWithFormat: @"%@", @(entry.location.longitude)]});
  } else {
    return @"";
  }
}

static NSString *FormattedSummaryForEntryGroup(RealmEntryGroup *entryGroup,
                                               NSDateFormatter *dateFormatter,
                                               NSNumberFormatter *numberFormatter) {
  NSMutableString *const debtList = [NSMutableString string];
  [debtList appendString:@"<table>\n"];
  for (RealmEntry* entry in entryGroup.entries) {
    if (entry.isArchived) {
      continue;
    }
    [debtList appendString:[NSString stringWithFormat:
                            @"<tr><td><b>%@</b></td><td>%@</td><td>%@</td></tr>\n",
                            [dateFormatter stringFromDate:entry.debtDate],
                            (entry.entryDescription.length > 50 ?
                             [NSString stringWithFormat:@"%@…", [entry.entryDescription substringToIndex:50]] :
                             (entry.entryDescription.length > 0 ?
                              entry.entryDescription :
                              @"")),
                            [numberFormatter stringFromNumber:
                             (entry.debtDirection == DebtDirectionOut ?
                              @(-1 * [entry.value doubleValue]) :
                              entry.value)]]];
  }
  [debtList appendString:@"</table>"];
  return debtList;
}

static NSString *MailBodyForEntries(NSArray<RealmEntry *> *entries,
                                    DebtSenderTemplates *templates,
                                    NSDateFormatter *dateFormatter,
                                    NSNumberFormatter *numberFormatter) {
  NSString *const mainTemplate = ContentsOfHTMLFileNamed(@"mail_template");
  NSString *const footerString = ContentsOfHTMLFileNamed(@"footer");
  NSString *const contentFormat = (entries.count > 1 ?
                                   templates.emailFormatSummary :
                                   (DebtDirectionOut == entries.firstObject.debtDirection ?
                                    templates.emailFormatOut :
                                    templates.emailFormatIn));

  if (mainTemplate.length == 0 || footerString.length == 0 || contentFormat.length == 0) {
    return nil;
  } else {
    RealmEntry *const firstEntry = entries.firstObject;
    NSString *const contentFormatWithReplacedNewlines = [contentFormat
                                                         stringByReplacingOccurrencesOfString:@"\n"
                                                         withString:@"<br/>\n"];
    NSString *const formattedContent = StringWithReplacedTokens(contentFormatWithReplacedNewlines,
                                                                @{@"name" : firstEntry.fullName,
                                                                  @"value" : [numberFormatter stringFromNumber:firstEntry.value],
                                                                  @"date" : [dateFormatter stringFromDate:firstEntry.debtDate],
                                                                  @"description" : (firstEntry.entryDescription.length > 0 ?
                                                                                    firstEntry.entryDescription :
                                                                                    NSLocalizedString(@"keyNoDescription", nil)),
                                                                  @"location" : (entries.count == 1 ?
                                                                                 LocationBodyForEntry(firstEntry, dateFormatter) :
                                                                                 @"")});

    if (entries.count == 1) {
      return StringWithReplacedTokens(mainTemplate,
                                      @{@"content" : formattedContent,
                                        @"footer" : footerString});
    } else {
      RealmEntryGroup *const entryGroup = [EntryGroupsForEntries(entries, nil, NO, NO) firstObject];
      NSString *const formattedSummary = StringWithReplacedTokens(formattedContent,
                                                                  @{@"debt_list" : FormattedSummaryForEntryGroup(entryGroup, dateFormatter, numberFormatter),
                                                                    @"total_value" : [numberFormatter stringFromNumber:entryGroup.totalValue]});
      return StringWithReplacedTokens(mainTemplate,
                                      @{@"content" : formattedSummary,
                                        @"footer" : footerString});
    }
  }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
  [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
  [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
