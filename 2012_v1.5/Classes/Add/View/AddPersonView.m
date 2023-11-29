//
//  AddPersonView.m
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddPersonSearchTableCell.h"
#import "AddPersonView.h"
#import "FontSizeLayer.h"
#import <QuartzCore/QuartzCore.h>

@implementation AddPersonView

- (id) initWithFrame: (CGRect) frame
{
	if ( (self = [super initWithFrame: frame]) )
	{
		[self addUi];
		[self readContacts];
	}
	return self;
}

- (void) setAddViewController: (AddViewController*) viewController
{
	mAddViewController = viewController;
}

- (void) setEntry: (Entry*) entry
{
	mPersonTextField.text = entry.person;

	// disable textfield thus it is not editable in adding phase
	mPersonTextField.enabled = NO;
	// set background invisible (was just set to fix the loupe while editing)
	mPersonTextField.backgroundColor = [UIColor clearColor];

	// hide keyboard
	[mPersonTextField resignFirstResponder];

	[mHintLabel removeFromSuperview];
}

#pragma mark add ui

- (void) addUi
{
	// add text field background
	mBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"addinput_bg.png"]];
	[self addSubview: mBackgroundImageView];

	// add text field
	//mPersonTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 18, 296, 47)];
	mPersonTextField = [[FontSizeTextField alloc] initWithFrame: CGRectMake(12, 18, 296, 46)];
	mPersonTextField.font = [UIFont boldSystemFontOfSize: 23.0];
	mPersonTextField.textColor = [UIColor colorWithWhite: 1.0 alpha: 1.0];
	mPersonTextField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"loupefix_person.png"]];
	mPersonTextField.delegate = self;
	mPersonTextField.returnKeyType = UIReturnKeyNext;
	mPersonTextField.enablesReturnKeyAutomatically = YES;
	mPersonTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	mPersonTextField.keyboardType = UIKeyboardTypeDefault;
	[mPersonTextField addTarget: self action: @selector(updateLabelUsingContentsOfTextField:) forControlEvents: UIControlEventEditingChanged];
	[mPersonTextField becomeFirstResponder];
	[self addSubview: mPersonTextField];

	// add hint label
	mHintLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 9, 296, 47)];
	mHintLabel.backgroundColor = [UIColor clearColor];
	mHintLabel.font = [UIFont boldSystemFontOfSize: 16.0];
	mHintLabel.textColor = [UIColor colorWithWhite: 1.0 alpha: 0.15];
	mHintLabel.text = NSLocalizedString(@"keyPerson", nil);
	[self addSubview: mHintLabel];
}

/**
 *	Read all contacts from address book of device.
 *
 */
- (void) readContacts
{
	if (!mPersonArray)
	{
        [AddressBookUtility getAllPeopleFromAddressBookWithCompletion:^(NSMutableArray *people, NSError *error) {
            
            if (error)
            {
                #warning "Show error in a label"
            }
            
            mPersonArray = [people retain];
        }];
	}
	
	// Read custom saved names
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedCustomPersonsArray = (NSArray*)[defaults objectForKey:kCUSTOM_PERSONS_USER_DEFAULTS_KEY];
	
	if (savedCustomPersonsArray == nil)
		return;
	
	AddressBookContact *customContact = nil;
	for (uint i = 0; i < savedCustomPersonsArray.count; i++)
	{
		customContact = [[AddressBookContact alloc] init];
		NSDictionary* personDictionary = (NSDictionary*)[savedCustomPersonsArray objectAtIndex:i];
		customContact.firstName = (NSString*)[personDictionary objectForKey: @"person"];
		customContact.lastName = @"";
		
		[mPersonArray addObject:customContact];
		[customContact release];
	}
}

- (void) addSearchTableUi
{
	mSearchTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, mPersonTextField.frameBottom, SCREENSIZE.width,
	                                                                  SCREENSIZE.height - kSTATUS_BAR_HEIGHT - mPersonTextField.frameBottom - 256)
	                    style: UITableViewStylePlain];
	mSearchTableView.rowHeight = 46;
	mSearchTableView.delegate = self;
	mSearchTableView.dataSource = self;
	[self insertSubview: mSearchTableView belowSubview: mBackgroundImageView];
}

- (void) removeSearchTableUi
{
	if (nil == mSearchTableView)
		return;
	
	[mSearchTableView removeFromSuperview];
	mSearchTableView = nil;
}

- (void) search
{
	[mPersonCopyArray release];
	mPersonCopyArray = [[NSMutableArray alloc] init];

	// search for whole range of search text in contacts
	NSString* searchPhrase = mPersonTextField.text;

	for (AddressBookContact* tempAddressBookContact in mPersonArray)
	{
		NSString* personString = [NSString stringWithFormat: @"%@ %@", tempAddressBookContact.firstName, tempAddressBookContact.lastName];
		NSRange resultsRange = [personString rangeOfString: searchPhrase options: NSCaseInsensitiveSearch];

		if (resultsRange.length > 0)
		{
			[mPersonCopyArray addObject: tempAddressBookContact];
		}
	}
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
	if (mPersonCopyArray)
	{
		return 1;
	}
	return 0;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
	if (mPersonCopyArray)
	{
		return mPersonCopyArray.count;
	}
	return 0;
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	NSString* CellIdentifier = @"AddPersonSearchTableCell";

	AddPersonSearchTableCell* cell = (AddPersonSearchTableCell*)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	if (nil == cell)
	{
		cell = [[[AddPersonSearchTableCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	AddressBookContact* contact = (AddressBookContact*)[mPersonCopyArray objectAtIndex: indexPath.row];
	NSString* personString = NSLocalizedString(@"keyAddressBookContactPattern", nil);
	personString = [personString stringByReplacingOccurrencesOfString: @"#firstName#" withString: contact.firstName];
	personString = [personString stringByReplacingOccurrencesOfString: @"#lastName#" withString: contact.lastName];
	[cell setPerson: personString];

	return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{	
	// set selected text to input text field
	AddressBookContact* contact = (AddressBookContact*)[mPersonCopyArray objectAtIndex: indexPath.row];
	NSString* personString = NSLocalizedString(@"keyAddressBookContactPattern", nil);
	personString = [personString stringByReplacingOccurrencesOfString: @"#firstName#" withString: contact.firstName];
	personString = [personString stringByReplacingOccurrencesOfString: @"#lastName#" withString: contact.lastName];
	mPersonTextField.text = personString;
	
	// Save email to use it in email notification in detail view
	mAddViewController.temporaryEntry.email = contact.email;

	// remove the search table, because the search is completed
	[self removeSearchTableUi];

	// user decided the person, so complete
	[self complete];
}

/**
 *	checks after editing the textfield whether there are enough characters used (at least one)
 *	if there are enough characters activate the next button for the user
 *
 */
- (void) updateLabelUsingContentsOfTextField: (id) sender
{
	// check the length of the text field
	if ([mPersonTextField.text length] > 0)
	{
		[mHintLabel removeFromSuperview];

		if (!mSearchTableView)
			[self addSearchTableUi];
		[self search];
		[mSearchTableView reloadData];
	}
	else
	{
		[self addSubview: mHintLabel];

		//mAddViewController.nextButton.enabled = NO;
		[self removeSearchTableUi];
		return;
	}

	// update the copy of adress book and thus the search table
}

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
	[self complete];

	return YES;
}

#pragma mark shrink ui

- (void) shrinkUi
{
	[self removeSearchTableUi];
	
	// animate font size
	//[mPersonTextField animateFontSizeToSize:newFontSize withDuration:0.3 andDelay: 0.1];

	// set font size
	int newFontSize = 13;
	mPersonTextField.font = [UIFont boldSystemFontOfSize: newFontSize];

	// determine future size of textfield to position it to right alignment
	UIFont* font = [UIFont boldSystemFontOfSize: newFontSize];
	CGSize stringsize = [mPersonTextField.text sizeWithFont: font];
	float halfstringwidth = stringsize.width / 2;

	CGRect aFrame = mBackgroundImageView.frame;
	aFrame.size.height = 60;
	//aFrame.origin.y -= aFrame.size.height;
	mBackgroundImageView.frame = aFrame;

	aFrame = mPersonTextField.frame;
	aFrame.origin.x = round(118 - halfstringwidth);
	//aFrame.origin.y -= 9;  // + mBackgroundImageView.frame.size.height;
	aFrame.size.height = 20;
	mPersonTextField.frame = aFrame;
}

- (void) complete
{
	// Delete customs saved names which are not used last days
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedCustomPersonsArray = (NSArray*)[defaults objectForKey:kCUSTOM_PERSONS_USER_DEFAULTS_KEY];
	
	NSMutableArray* newSavedCustomPersonsArray = [[NSMutableArray alloc] init];
	
	for (uint i = 0; i < savedCustomPersonsArray.count; i++)
	{
		NSMutableDictionary* personDictionary = (NSMutableDictionary*)[[savedCustomPersonsArray objectAtIndex:i] mutableCopy];
		NSString* personString = (NSString*)[personDictionary objectForKey: @"person"];
		NSDate* personDate = (NSDate*)[personDictionary objectForKey: @"date"];
		
		if( [[NSDate date] timeIntervalSinceDate: personDate] < kCUSTOM_PERSONS_DELETE_INTERVAL )
		{			
			if( [personString isEqualToString: [mPersonTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] )
			{
				[personDictionary setObject: [NSDate date] forKey: @"date"];
			}
			[newSavedCustomPersonsArray addObject: personDictionary];
		}
		[personDictionary release];
	}
	
	[defaults setObject: newSavedCustomPersonsArray forKey: kCUSTOM_PERSONS_USER_DEFAULTS_KEY];
	[newSavedCustomPersonsArray release];
	
	// save data from text field
	mAddViewController.temporaryEntry.person = [mPersonTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	// disable textfield thus it is not editable in adding phase
	mPersonTextField.enabled = NO;
	// set background invisible (was just set to fix the loupe while editing)
	mPersonTextField.backgroundColor = [UIColor clearColor];

	// remove search table view if created
	[self removeSearchTableUi];

	// hide keyboard
	[mPersonTextField resignFirstResponder];

	// send notification of completion, add view controller is listening
	[[NSNotificationCenter defaultCenter] postNotificationName: @"addPersonComplete" object: nil];
}

#pragma mark memory management

- (void) dealloc
{
	[mPersonArray release];
	[mPersonCopyArray release];
	[mBackgroundImageView release];
	[mPersonTextField release];
	[mSearchTableView release];
	[mHintLabel release];

	[super dealloc];
}

@end