//
//  ListViewController.m
//  StillWaitin
//
//  Created by devmob on 22.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "ListViewController.h"
#import "ListTableCell.h"
#import "ListTableViewHeaderCell.h"
#import "ListTableViewFooterCell.h"
#import "Entry.h"
#import "SettingsViewController.h"


#import <QuartzCore/QuartzCore.h>


@implementation ListViewController


@synthesize allentries = mEntryArray;


- (id)initWithFrame:(CGRect)frame
{
	if(self = [super init])
	{
		mViewRectangle = frame;
		self.view.frame = frame;
		
		// load entries, so they are available after appstart before viewWillAppear
		[self loadStoredEntries];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(localNotificationReceived:) name: @"SWLocalNotificationReceived" object: nil];
    }
	
    return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"SWLocalNotificationReceived" object: nil];
	
	[mEntryArray release];
	[mCurrencyFormatter release];
	[mSelectedCellIndexPath release];
	
    [super dealloc];
}


- (void)loadView
{
	[super loadView];
	
	[self createCurrencyFormatter];
	[self addListenerForDetailDeletion];
	[self addUi];
}

// if view appears (re)load the data of table view.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// if the list view will show up again, load all stored data
	// maybe the user added a new entry since the last reload
	[self reloadData];
	
	// Show contents of Documents directory
	LogDebug(@"Documents directory: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:
									   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
										objectAtIndex: 0] error: nil]);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	// Log event

}

- (void) viewDidUnload
{
	mNavigationBarImageView = nil;
	mListTableView = nil;
	mArrowImageView = nil;
	mInfoLabel = nil;
    
	[super viewDidUnload];
}


- (void) reloadData
{
	[self reloadDataWithTableReload: YES];
}

- (void) reloadDataWithTableReload: (BOOL) tableReload
{
	[self loadStoredEntries];
	if (tableReload) {
		[mListTableView reloadData];
	}
	
	[self addInitialInfoIfNoEntriesAvailable];
	[self removeInitialInfoIfEntriesAvailable];
	[self updateTotalSumBar];
}

- (void) updateTotalSumBar
{
	BOOL showTotalSum = [[NSUserDefaults standardUserDefaults] boolForKey: kKEY_SETTING_SHOW_TOTALSUM];
	
	// hide totalSumBar, when no entry is available
	mTotalSumBar.hidden = !([self hasEntries] && showTotalSum);    
    
	if (mTotalSumBar.hidden) {
		// reset tableview rect
        mListTableView.frame = CGRectMake(mViewRectangle.origin.x, 50.0, mViewRectangle.size.width, mViewRectangle.size.height - 50.0);
		mListTableView.scrollIndicatorInsets = UIEdgeInsetsMake(4, 0, 2, 0);
        
		return;
	}
	
	// udate tableview rect
    mListTableView.frame = CGRectMake(mViewRectangle.origin.x, 50.0, mViewRectangle.size.width, mViewRectangle.size.height - 58.0);
	mListTableView.scrollIndicatorInsets = UIEdgeInsetsMake(4, 0, 11, 0);
	
	// update totalSum value
	CGFloat totalSum = 0;
	for (NSArray* personArray in mEntryArray)
	{
		for (Entry* entry in personArray)
		{
			if (entry.direction == DebtDirectionIn)
			{
				totalSum += [entry.value floatValue];
			}
			else
			{
				totalSum -= [entry.value floatValue];
			}
		}
	}
	mTotalSumBar.totalSum = totalSum;
}


/**
 *	Create the currency formatter for showing localized currency value
 *
 */
- (void)createCurrencyFormatter
{
	mCurrencyFormatter = [[NSNumberFormatter alloc] init];
	[mCurrencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[mCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[mCurrencyFormatter setMaximumFractionDigits:2];
	[mCurrencyFormatter setMinimumFractionDigits:2];
}

#pragma mark -
#pragma mark add ui

- (void)addUi
{
	// add main content background
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"maincontent_bg.png"]];
    backgroundImageView.frameBottom = mViewRectangle.size.height;
	[self.view addSubview:backgroundImageView];
	[backgroundImageView release];
	
	// add list table for showing all entries
	CGRect tableFrame = CGRectMake(mViewRectangle.origin.x, 50.0, mViewRectangle.size.width, mViewRectangle.size.height-50.0-50.0);
	mListTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	mListTableView.backgroundColor = [UIColor clearColor];
	mListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	mListTableView.delegate = self;
	mListTableView.dataSource = self;
	mListTableView.scrollIndicatorInsets = UIEdgeInsetsMake(4, 0, 2, 0);
	[self.view addSubview: mListTableView];
	[mListTableView release];
	
	// add navbar background
	mNavigationBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_bg_list.png"]];
	[self.view addSubview:mNavigationBarImageView];
	[mNavigationBarImageView release];
	
	// add 'settings' button
	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	settingsButton.frame = CGRectMake(7, 8, 40, 40);
	[settingsButton setImage:[UIImage imageNamed:@"btn_settings.png"] forState:UIControlStateNormal];
	[settingsButton setImage:[UIImage imageNamed:@"btn_settings_pressed.png"] forState:UIControlStateHighlighted];
	[settingsButton addTarget:self action:@selector(settingsButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:settingsButton];
	
	// add 'add' button
	UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addButton.frame = CGRectMake(238, 0, 70, 75);
	[addButton setImage:[UIImage imageNamed:@"btn_add_default.png"] forState:UIControlStateHighlighted];
	[addButton setImage:[UIImage imageNamed:@"btn_add_pressed.png"] forState:UIControlStateNormal];
	[addButton addTarget:self action:@selector(addButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:addButton];
    	
	// Add total sum bar
	mTotalSumBar        = [[ListTotalSumBar alloc] init];
	mTotalSumBar.frameY = self.view.frameHeight - mTotalSumBar.frameHeight;
	[self.view addSubview:mTotalSumBar];
	[mTotalSumBar release];
    
	[self reloadData];
}

- (BOOL) hasEntries
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
	
	if (data == nil)
		return NO;
	
	NSArray *savedEntryArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if( 0 == savedEntryArray.count )
		return NO;
	
	return YES;
}

- (void) addInitialInfoIfNoEntriesAvailable
{
	if( YES == [self hasEntries] )
		return;
	
	// add first info arrow
	if ( nil == mArrowImageView )
	{	
		UIImage * image = [UIImage imageNamed:@"list_info_arrow.png"];
		mArrowImageView = [[UIImageView alloc] initWithImage: image];
		mArrowImageView.frame = CGRectMake(255, 0, image.size.width, image.size.height);
		[self.view insertSubview: mArrowImageView belowSubview: mNavigationBarImageView];
		[mArrowImageView release];
	}
	
	// add first info text
	if ( nil == mInfoLabel )
	{
		mInfoLabel = [[UILabel alloc] initWithFrame: CGRectMake(105, 0, 140, 50)];
		mInfoLabel.textColor= [UIColor whiteColor];
		mInfoLabel.numberOfLines = 2;
		mInfoLabel.lineBreakMode = UILineBreakModeWordWrap;
		mInfoLabel.backgroundColor = [UIColor clearColor];
		mInfoLabel.textAlignment = UITextAlignmentRight;
		mInfoLabel.font = [UIFont fontWithName: @"MarkerFelt-Thin" size: 15];
		mInfoLabel.text = NSLocalizedString(@"keyAddFirstEntry", nil);
		[self.view insertSubview: mInfoLabel belowSubview: mNavigationBarImageView];
		[mInfoLabel release];
	}
	
	[UIView beginAnimations: @"firstEntryInfo" context: nil];
	[UIView setAnimationDelay: 0.15];
	mArrowImageView.frame = CGRectMake(255, 100, mArrowImageView.frame.size.width, mArrowImageView.frame.size.height);
	mInfoLabel.frame = CGRectMake(105, 110, 140, 50);
	[UIView commitAnimations];
}

- (void) removeInitialInfoIfEntriesAvailable
{
	if( NO == [self hasEntries] )
		return;
	
	// remove info images
	if (nil != mArrowImageView) {
		
		[mArrowImageView removeFromSuperview];
		mArrowImageView = nil;
	}
	
	if (nil != mInfoLabel) {
		
		[mInfoLabel removeFromSuperview];
		mInfoLabel = nil;
	}
}

#pragma mark -
#pragma mark change views

/*
 *
 */
- (void) settingsButtonTouchHandler: (id)sender
{
	[self.navigationController popViewControllerAnimated: YES];
}

/**
 *	If add button was touched add the adding screen.
 *
 */
- (void) addButtonTouchHandler: (id)sender
{
	AddViewController* addViewController = [[AddViewController alloc] initWithFrame:mViewRectangle andInitialEntry: nil];
	[self.navigationController pushViewController:addViewController animated:YES];
	[addViewController release];
}

#pragma mark -
#pragma mark local notification

- (void) localNotificationReceived: (NSNotification*) sender
{
	UILocalNotification* notification = [sender.userInfo objectForKey: @"notification"];
	NSString* entryId = [notification.userInfo objectForKey: @"entryId"];
	
	LogDebug(@"localNotificationReceived - with entryId: %@", entryId);
	
	Entry* notificationEntry = nil;
	
	// find entry
	for (NSArray* entryArray in self.allentries)
	{
		for (Entry* entry in entryArray)
		{
			if ([entry.entryId isEqualToString: entryId])
			{
				notificationEntry = entry;
			}
		}
	}
	
	// return if no entry was found
	if (notificationEntry == nil)
	{
		LogDebug(@"could not find entry with entryId: %@", entryId);
		
		return;
	}
	else
	{
		LogDebug(@"will show entry");
	}

	
	// show entry
	// return to list view
	if ([self.navigationController.viewControllers count] > 2)
	{
		[self.navigationController popToViewController: self animated: NO];
	}
	
	// create and show detail view controller
	DetailViewController* detailViewController = [[DetailViewController alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, SCREENSIZE.height-kSTATUS_BAR_HEIGHT)];
	[detailViewController setEntry:notificationEntry];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

#pragma mark -
#pragma mark table delegate/dataSource

/**
 *	Determine how much sections should be shown. One section is one person.
 *
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.allentries.count;
}

/**
 *	Determine the number of rows in one section. Two extra cells for header and footer.
 *
 */
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSArray *personEntryArray = [self.allentries objectAtIndex:section];
	return personEntryArray.count + 2;
}

/**
 *	Determine the height of rows. Header and footer are smaller.
 *
 */
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger total = [self tableView:tableView numberOfRowsInSection:indexPath.section];
	
	// first cell -> show custom header
	if (indexPath.row == 0)
	{		
		return kTABLE_HEADER_HEIGHT + kTABLE_SPACING_HEADER;
	}
	
	// last cell -> show custom footer
	if (indexPath.row == total-1)
	{		
		return kTABLE_FOOTER_HEIGHT + kTABLE_SPACING_FOOTER;
	}
	return 62.0;
}

/**
 *	Determine the cell content and table ui.
 *
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger total = [self tableView:tableView numberOfRowsInSection:indexPath.section];
	
	// first cell -> show custom header
	if (indexPath.row == 0)
	{
		return [self tableView: tableView headerCellForSection: indexPath.section];
	}
	
	// last cell -> show custom footer
	if (indexPath.row == total-1)
	{
		return [self tableView: tableView footerCellForSection: indexPath.section];
	}
	
	// show cells
	NSString* CellIdentifier = @"ListTableCellIdentifier";
	
	ListTableCell* cell = (ListTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(nil == cell)
	{
		cell = [[[ListTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	NSArray *personEntryArray = [self.allentries objectAtIndex:indexPath.section];
	Entry *entry = (Entry *)[personEntryArray objectAtIndex:indexPath.row - 1];
	[cell setEntry:entry];
	 
	return cell;
}

/**
 *	If user selects entry cell show detail view
 *
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	// if cell is a header or footer do not allow to select
	if(NO == [self tableView:tableView canEditRowAtIndexPath:indexPath])
		return;
	
	mSelectedCellIndexPath = [indexPath retain];
	
	NSArray *personEntryArray = [self.allentries objectAtIndex:indexPath.section];
	Entry *selectedEntry = (Entry *)[personEntryArray objectAtIndex:(indexPath.row - 1)];
	
	// create and show detail view controller
	DetailViewController* detailViewController = [[DetailViewController alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, SCREENSIZE.height-kSTATUS_BAR_HEIGHT)];
	[detailViewController setEntry:selectedEntry];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

/**
 *	If delete button was touched delete the corresponding entry.
 *
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{	
	int numOfRows = [tableView numberOfRowsInSection: indexPath.section];
	
	// remove data
	[self removeEntryByIndex:indexPath];
	
	// animate out
	if (numOfRows > 3)
	{
		[tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationMiddle];

        // reload last row
        NSIndexPath* lastRowIndexPath = [NSIndexPath indexPathForRow: numOfRows-2 inSection: indexPath.section];
        [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lastRowIndexPath] withRowAnimation: UITableViewRowAnimationTop];
	} else
	{
		[tableView deleteSections: [NSIndexSet indexSetWithIndex: indexPath.section] withRowAnimation: UITableViewRowAnimationFade];
	}
}

/**
 *	Only cell with entries are allowed to edit. Header and footer are not allowed.
 *
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	int lastRow = [tableView numberOfRowsInSection:indexPath.section] - 1;
	if(0 == indexPath.row || lastRow == indexPath.row)
		return NO;
	else
		return YES;
}

/**
 *	Set editing style to 'delete' for showing the delete button and activate the delegation to 'commitEditingStyle' after touch on delete button.
 *
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

/**
 *	Return the header cell ui.
 *
 */
- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForSection: (NSInteger) section
{
	NSString* CellIdentifier = @"HeaderCellIdentifier";
	
	ListTableViewHeaderCell* cell = (ListTableViewHeaderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(nil == cell)
	{
		cell = [[[ListTableViewHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSArray *personEntryArray = [self.allentries objectAtIndex:section];
	Entry *entry = (Entry *)[personEntryArray objectAtIndex:0];
	cell.title = entry.person;
	
	return cell;
}

/**
 *	Return the footer cell ui.
 *
 */
- (UITableViewCell *)tableView:(UITableView *)tableView footerCellForSection: (NSInteger) section
{
	NSString* CellIdentifier = @"FooterCellIdentifier";
	
	ListTableViewFooterCell* cell = (ListTableViewFooterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(nil == cell)
	{
		cell = [[[ListTableViewFooterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSArray *personEntryArray = [self.allentries objectAtIndex:section];
	Entry *entry = (Entry *)[personEntryArray objectAtIndex:0];
	cell.title = entry.footer;
	
	return cell;
}


// Function is used to sort list
int comparePersons( id obj1, id obj2, void *context )
{
	Entry *first  = (Entry *)[obj1 objectAtIndex:0];
	Entry *second = (Entry *)[obj2 objectAtIndex:0];
	
	return [first.person caseInsensitiveCompare: second.person];
}


/**
 *	Load all stored entries and sort them by person.
 *	Additionally calculate the balance of debts of each person and save the footer string containing the balance string because of performance issues
 *
 */
- (void)loadStoredEntries
{
	// load all saved entries from user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
	
	if (data == nil)
		return;
	
	NSArray* savedEntryArray = [NSKeyedUnarchiver unarchiveObjectWithData: data];
	
	// sort all persons
	NSMutableArray * emptyArray = [[NSMutableArray alloc] init];	
	self.allentries = emptyArray;
	[emptyArray release];
	
	for(uint i = 0; i < savedEntryArray.count; i++)
	{
		Entry* entry = (Entry*)[savedEntryArray objectAtIndex:i];
		
		// add id to all old entries without any id
		if (nil == entry.entryId)
		{
			entry.entryId = [NSString stringWithFormat:@"%d", i];
			
			// load all saved entries from user defaults
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
			
			if (data == nil)
				return;
			
			NSMutableArray *savedEntryArray = [(NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
			
			[savedEntryArray replaceObjectAtIndex: i withObject: entry];
			
			// Save the new entry array
			data = [NSKeyedArchiver archivedDataWithRootObject: savedEntryArray];
			[defaults setObject: data forKey: kENTRY_USER_DEFAULTS_KEY];
			[savedEntryArray release];
		}
		
		// make Entry4 class instance if old entry is still Entry class
		NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"4.0" options: NSNumericSearch];
		if (order == NSOrderedSame || order == NSOrderedDescending)
		{
			if ([entry isMemberOfClass: [Entry class]])
			{
				Entry4* newEntry		= [[Entry4 alloc] init];
				newEntry.entryId		= entry.entryId;
				newEntry.date			= [entry.date copy];
				newEntry.description	= [entry.description copy];
				newEntry.direction		= entry.direction;
				newEntry.email			= [entry.email copy];
				newEntry.footer			= [entry.footer copy];
				newEntry.hasPhoto		= entry.hasPhoto;
				newEntry.location		= entry.location;
				newEntry.isLocationAvailable	= entry.isLocationAvailable;
				newEntry.notification	= nil;
				newEntry.person			= [entry.person copy];
				newEntry.photofilename	= [entry.photofilename copy];
				newEntry.type			= entry.type;
				newEntry.value			= [entry.value copy];
				
				// load all saved entries from user defaults
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
				
				if (data == nil)
					return;
				
				NSMutableArray *savedEntryArray = [(NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
				
				[savedEntryArray replaceObjectAtIndex: i withObject: newEntry];
				
				// Save the new entry array
				data = [NSKeyedArchiver archivedDataWithRootObject: savedEntryArray];
				[defaults setObject: data forKey: kENTRY_USER_DEFAULTS_KEY];
				[savedEntryArray release];
			}
		}
		
		// check, if current notification is in the past
		// and delete it, if needed
		if ([entry isMemberOfClass: [Entry4 class]])
		{
			Entry4* e = (Entry4*)entry;
			if (e.notification != nil)
			{
				NSDate* notificationDate = e.notification.fireDate;
				if ([notificationDate timeIntervalSinceNow] < 0)
				{
					e.notification = nil;
				}
			}
		}
		
		// determine whether entry person exists in entry array
		NSInteger existingPersonPosition = -1;
		for(uint j = 0; j < self.allentries.count; j++)
		{
			NSArray *savedPersonEntryArray = (NSArray *)[self.allentries objectAtIndex:j];
			Entry* savedEntry = (Entry*)[savedPersonEntryArray objectAtIndex:0];
			
			// use lowercase comparism for more consistency
			NSString *cleanEntryPersonString = [[entry.person lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *cleanSavedEntryPersonString = [[savedEntry.person lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			if([cleanEntryPersonString isEqualToString:cleanSavedEntryPersonString])
			{
				existingPersonPosition = j;
				break;
			}
		}
		
		// existingPersonPosition is greater than 0 if an existing saved entry was found for the current person
		if(-1 < existingPersonPosition)
		{
			NSMutableArray *savedPersonEntryArray = (NSMutableArray *)[self.allentries objectAtIndex:existingPersonPosition];
			[savedPersonEntryArray addObject:entry];
		}
		// if not then create a new array with a first new entry
		else
		{
			NSMutableArray *newPersonEntryArray = [[[NSMutableArray alloc] init] autorelease];
			[newPersonEntryArray addObject:entry];
			[self.allentries addObject:newPersonEntryArray];
		}
	}
	
	// calculate the whole balance of each person and save the footer string to entry for saving performance
	for(uint j = 0; j < self.allentries.count; j++)
	{
		float balance = 0.0;
		BOOL owingItems = NO;
		BOOL owingMoney = NO;
		
		NSArray *personEntryArray = [self.allentries objectAtIndex:j];
		Entry* entry = (Entry*)[personEntryArray objectAtIndex:0];
		
		for(uint i = 0; i < personEntryArray.count; i++)
		{
			Entry* tempEntry = (Entry*)[personEntryArray objectAtIndex:i];
			if(DebtTypeItem == tempEntry.type)
			{
				owingItems = YES;
				continue;
			}
			
			owingMoney = YES;
			balance += tempEntry.direction == DebtDirectionIn ? [tempEntry.value floatValue] : -[tempEntry.value floatValue];
		}
		
		// if balance is positive footer will show: "person owes me ..." otherwise "i owe ... person"
		NSString *balanceString = balance > 0.0 ? NSLocalizedString(@"keyFooterInPattern", nil) : NSLocalizedString(@"keyFooterOutPattern", nil);
		
		// make balance positive otherwise the number formatter will add brackets to currency string
		balance = balance < 0.0 ? -balance : balance;
		NSString *currencyString = [mCurrencyFormatter stringFromNumber:[NSNumber numberWithFloat:balance]];
		
		NSString *footerString = nil;
		if(YES == owingMoney)
		{
			footerString = [balanceString stringByReplacingOccurrencesOfString:@"#value#" withString:currencyString];
			
			// if balance is not zero and items are owed add concatening word " and " to footer string
			if(0.0 != balance && YES == owingItems)
				footerString = [NSString stringWithFormat:@" %@ ", [footerString stringByAppendingString:NSLocalizedString(@"keyFooterConcat", nil)]];
			
			// if owing items add phrase " and items"
			if(YES == owingItems)
				footerString = [footerString stringByAppendingString:NSLocalizedString(@"keyFooterItem", nil)];
		}
		else
		{
			footerString = NSLocalizedString(@"keyFooterOnlyItem", nil);
		}
		
		footerString = [footerString stringByReplacingOccurrencesOfString:@"#person#" withString: entry.person];
		
		entry.footer = footerString;
	}
	
	// order alphabetically, if set
	if ([defaults boolForKey: kKEY_SORTING_ORDER_ALPHABETICALLY] == YES)
	{
		[self.allentries sortUsingFunction: comparePersons context: nil];
	}
}

/**
 *	Remove entry by selected cell entry.
 *
 */
- (void)removeEntryByIndex:(NSIndexPath *)indexPath
{
	LogDebug(@"removeEntryByIndex: %d (-1) atSection: %d", (indexPath.row - 1), indexPath.section);
	
	/*
	// ...
	for(uint k = 0; k < self.allentries.count; k++)
	{
		NSArray *savedPersonEntryArray = (NSArray *)[self.allentries objectAtIndex:k];
		for(uint j = 0; j < savedPersonEntryArray.count; j++)
		{
			Entry *savedEntry = (Entry *)[savedPersonEntryArray objectAtIndex:j];
			DebugLog(@"%d %d %@ %f", k, j, savedEntry.person, [savedEntry.value floatValue]);
		}
	}
	
	DebugLog(@"################");
	 */
	
	NSMutableArray *personEntryArray = [self.allentries objectAtIndex:indexPath.section];
	
	Entry* todelete = [personEntryArray objectAtIndex:(indexPath.row - 1)];
	
	
	// Cancel notification if needed
	if ([todelete isMemberOfClass: [Entry4 class]])
	{
		Entry4* entry = (Entry4*)todelete;
		if(entry.notification != nil)
		{
			[[UIApplication sharedApplication] cancelLocalNotification: entry.notification];
			entry.notification = nil;
		}
	}
	
	// Delete photo if needed
	if (todelete.photofilename != nil && todelete.photofilename.length > 0)
	{
		NSError * error;
		if ([[NSFileManager defaultManager] removeItemAtPath:todelete.photofilename error:&error] != YES)
		{
			LogDebug(@"Unable to delete file: %@", [error localizedDescription]);
		}
	}
	
	[personEntryArray removeObjectAtIndex:(indexPath.row - 1)];
	
	if(0 == personEntryArray.count)
	{
		[self.allentries removeObjectAtIndex:indexPath.section];
	}
	
	/*
	// ...
	for(uint k = 0; k < self.allentries.count; k++)
	{
		NSArray *savedPersonEntryArray = (NSArray *)[self.allentries objectAtIndex:k];
		for(uint j = 0; j < savedPersonEntryArray.count; j++)
		{
			Entry *savedEntry = (Entry *)[savedPersonEntryArray objectAtIndex:j];
			DebugLog(@"%d %d %@ %f", k, j, savedEntry.person, [savedEntry.value floatValue]);
		}
	}
	*/
	
	// clear last saved user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:kENTRY_USER_DEFAULTS_KEY];
	
	// fill up the new data
	NSMutableArray *entryArray = [[[NSMutableArray alloc] init] autorelease];
	for(uint k = 0; k < self.allentries.count; k++)
	{
		NSArray *savedPersonEntryArray = (NSArray *)[self.allentries objectAtIndex:k];
		for(uint j = 0; j < savedPersonEntryArray.count; j++)
		{
			Entry *savedEntry = (Entry *)[savedPersonEntryArray objectAtIndex:j];
			[entryArray addObject:savedEntry];
		}
	}
	
	// save the new entry array
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:entryArray];
	[defaults setObject:data forKey:kENTRY_USER_DEFAULTS_KEY];
	
	[self reloadDataWithTableReload: NO];
	
	// log deletion

}

- (void)addListenerForDetailDeletion
{	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(removeSelectedEntry:)
												 name:@"detailDeletion"
											   object:nil];
}

- (void)removeSelectedEntry:(id)sender
{	
	[self removeEntryByIndex:mSelectedCellIndexPath];
}

@end
