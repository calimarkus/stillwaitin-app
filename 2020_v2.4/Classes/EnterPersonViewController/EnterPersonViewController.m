//
//  EnterPersonViewController.m
//  StillWaitin
//
//

#import "EnterPersonViewController.h"

#import "AddressBookUtility.h"
#import "EnterPersonTableViewCell.h"
#import "NSArray+Map.h"
#import "RealmEntry.h"
#import "RealmEntryStorage.h"
#import "SWColors.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

#import <QuartzCore/QuartzCore.h>

@interface EnterPersonViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<AddressBookContact *>* existingEntryContacts;
@property (nonatomic, copy) NSArray<AddressBookContact *>* existingAndAdressBookContactsArray;
@property (nonatomic, copy) NSArray<AddressBookContact *>* matchedPersonsArray;

@property (nonatomic, strong) UILabel* placeholderLabel;
@property (nonatomic, strong) UITextField* personTextField;
@property (nonatomic, strong) UITableView* autoCompleteTableView;

@property (nonatomic, copy) NSString *initalName;

@end

@implementation EnterPersonViewController

- (instancetype)init {
  return [self initWithNameString:nil];
}

- (instancetype)initWithNameString:(NSString*)name {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    // set title & initial name
    if (!name) {
      self.title = NSLocalizedString(@"keyNew", nil);
    } else {
      self.initalName = name;
      self.title = NSLocalizedString(@"keyEdit", nil);
    }

    // fix layout
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
      self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    // done button on ipad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                            target:self action:@selector(dismissButtonClickHandler:)];
    }

    NSMutableSet<NSString *> *alreadyAddedNames = [NSMutableSet set];
    self.existingEntryContacts = [[[RealmEntryStorage sharedStorage] entriesWithFilter:RealmEntryStorageFilterAllEntries] map:^AddressBookContact *(RealmEntry *entry) {
      if (![alreadyAddedNames containsObject:entry.fullName]) {
        [alreadyAddedNames addObject:entry.fullName];
        return [[AddressBookContact alloc] initWithFullName:entry.fullName
                                                      email:entry.email
                                                phoneNumber:entry.phoneNumber
                                               lastUsedDate:nil
                                              allowDeletion:NO];
      } else {
        return nil;
      }
    }];
    self.existingAndAdressBookContactsArray = self.existingEntryContacts;
    [self _reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];

  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // add text field background
  UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frameWidth, 63.0)];
  backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  backgroundView.backgroundColor = SWColorGreenMain();
  [self.view addSubview: backgroundView];

  // add text field
  self.personTextField = [[UITextField alloc] initWithFrame: CGRectMake(12, 18, self.view.frameWidth-24, 30)];
  self.personTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  self.personTextField.textColor = [UIColor colorWithWhite: 1.0 alpha: 1.0];
  self.personTextField.backgroundColor = SWColorGreenMain();
  self.personTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
  self.personTextField.delegate = self;
  self.personTextField.returnKeyType = UIReturnKeyDone;
  self.personTextField.enablesReturnKeyAutomatically = YES;
  self.personTextField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.personTextField.keyboardType = UIKeyboardTypeDefault;
  [self.personTextField addTarget: self action: @selector(_reloadData) forControlEvents: UIControlEventEditingChanged];
  [self.personTextField becomeFirstResponder];
  [self.view addSubview: self.personTextField];

  // add placeholder label
  self.placeholderLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 9, self.view.frameWidth-40, 47)];
  self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
  self.placeholderLabel.backgroundColor = [UIColor clearColor];
  self.placeholderLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  self.placeholderLabel.textColor = [UIColor colorWithWhite: 1.0 alpha: 0.15];
  self.placeholderLabel.text = NSLocalizedString(@"keyPerson", nil);
  [self.view addSubview: self.placeholderLabel];

  // add autocomplete table
  CGRect tableViewFrame = CGRectMake(0,
                                     backgroundView.frameHeight,
                                     self.view.frameWidth,
                                     self.view.frameHeight - backgroundView.frameHeight);
  self.autoCompleteTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
  self.autoCompleteTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.autoCompleteTableView.rowHeight = 46;
  self.autoCompleteTableView.delegate = self;
  self.autoCompleteTableView.dataSource = self;
  self.autoCompleteTableView.backgroundColor = SWColorGrayWash();
  self.autoCompleteTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  if (@available(iOS 13.0, *)) {
    self.autoCompleteTableView.automaticallyAdjustsScrollIndicatorInsets = NO;
  }
  [self.view insertSubview: self.autoCompleteTableView belowSubview: backgroundView];

  // set initial state
  if (self.initalName) {
    self.personTextField.text = self.initalName;
    [self _reloadData];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  __weak typeof(self) weakSelf = self;
  [self _reloadAdressbookContactsWithCompletion:^{
    [weakSelf _reloadData];
  }];
}

- (void)dismissButtonClickHandler:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
  CGRect windowKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  CGRect viewKeyboardFrame = [self.view.window convertRect:windowKeyboardFrame toView:self.view];
  CGRect intersection = CGRectIntersection(self.autoCompleteTableView.frame, viewKeyboardFrame);
  self.autoCompleteTableView.contentInset = (CGRectIsNull(intersection)
                                             ? UIEdgeInsetsZero
                                             : UIEdgeInsetsMake(0, 0, intersection.size.height, 0));
  self.autoCompleteTableView.scrollIndicatorInsets = self.autoCompleteTableView.contentInset;
}

#pragma mark - Data

static NSMutableDictionary<NSString *, AddressBookContact *> *nameKeyedDictionaryForContacts(NSArray<AddressBookContact *> *contacts) {
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:contacts.count];
  for (AddressBookContact *contact in contacts) {
    NSString * const key = [contact.fullName.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    dictionary[key] = contact;
  }
  return dictionary;
}

- (void)_reloadAdressbookContactsWithCompletion:(void(^)(void))completion {
  __weak typeof(self) weakSelf = self;
  [AddressBookUtility readAllContactsFromAddressBookWithCompletion:^(NSArray<AddressBookContact *> *addressBookContacts, NSError *error) {
    NSMutableDictionary<NSString *, AddressBookContact *> *mergedContactsDictionary = [NSMutableDictionary dictionaryWithCapacity:addressBookContacts.count];

    // 1) add previously used contacts
    [mergedContactsDictionary addEntriesFromDictionary:nameKeyedDictionaryForContacts([AddressBookUtility previouslyUsedContacts])];

    // 2) add contacts from existing entries (overwriting previously used contacts, if existing)
    [mergedContactsDictionary addEntriesFromDictionary:nameKeyedDictionaryForContacts(self.existingEntryContacts)];

    // 3) add contacts from addressBook (overwriting any of the above, if existing)
    [mergedContactsDictionary addEntriesFromDictionary:nameKeyedDictionaryForContacts(addressBookContacts)];

    NSArray<NSSortDescriptor *> *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]];
    weakSelf.existingAndAdressBookContactsArray = [[mergedContactsDictionary allValues] sortedArrayUsingDescriptors:sortDescriptors];

    if (completion) {
      completion();
    }
  }];
}

- (void)_reloadData {
  [self _search];
  [self.autoCompleteTableView reloadData];

  // check the length of the text field
  self.placeholderLabel.hidden = (self.personTextField.text.length > 0);
}

- (NSArray<AddressBookContact *> *)_currentPersonList {
  return (self.matchedPersonsArray != nil ?
          self.matchedPersonsArray :
          self.existingAndAdressBookContactsArray);
}

#pragma mark - Search

- (void)_search {
  // find search text in contacts names
  NSString *const searchPhrase = self.personTextField.text;
  if (searchPhrase.length > 0) {
    NSMutableArray *matchedPersonsArray = [[NSMutableArray alloc] init];
    for (AddressBookContact* tempAddressBookContact in self.existingAndAdressBookContactsArray) {
      NSRange resultsRange = [tempAddressBookContact.fullName rangeOfString:searchPhrase options:NSCaseInsensitiveSearch];
      if (resultsRange.length > 0) {
        [matchedPersonsArray addObject:tempAddressBookContact];
      }
    }
    self.matchedPersonsArray = matchedPersonsArray;
  } else {
    self.matchedPersonsArray = nil;
  }
}

#pragma mark - UITableViewViewDelegate / UITableViewViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self _currentPersonList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString* cellIdentifier = @"EnterPersonTableViewCell";
  EnterPersonTableViewCell* cell = (EnterPersonTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[EnterPersonTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
  }

  [cell setContact:[[self _currentPersonList] objectAtIndex:indexPath.row]];

  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self _currentPersonList][indexPath.row].allowDeletion;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  [AddressBookUtility forgetContactNameForSearch:[[self _currentPersonList] objectAtIndex:indexPath.row].fullName];

  __weak __typeof(self) weakSelf = self;
  [self _reloadAdressbookContactsWithCompletion:^{
    [weakSelf _search];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
  }];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
  // set selected text to input text field
  self.personTextField.text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;

  // user decided the person, so complete
  [self _didSelectPerson];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
  [self _didSelectPerson];
  return YES;
}

#pragma mark - Selection

- (void)_didSelectPerson {
  // trim entered string
  NSString *personName = [[self.personTextField.text capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  AddressBookContact *selectedContact = nil;

  // check for additional contact information
  for (AddressBookContact *contact in [self _currentPersonList]) {
    if ([contact.fullName caseInsensitiveCompare:personName] == NSOrderedSame) {
      selectedContact = contact;
    }
  }

  // create fake contact
  if (!selectedContact) {
    selectedContact = [[AddressBookContact alloc] initWithFullName:personName
                                                             email:nil
                                                       phoneNumber:nil
                                                      lastUsedDate:nil
                                                     allowDeletion:NO];
  }

  // hide keyboard & placeholder
  self.placeholderLabel.hidden = YES;
  [self.personTextField resignFirstResponder];

  // call completion block
  if (self.didSelectPersonBlock) {
    self.didSelectPersonBlock(selectedContact);
  }
}

@end
