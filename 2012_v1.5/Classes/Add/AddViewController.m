//
//  AddViewController.m
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddViewController.h"
#import "UIDevice+Hardware.h"


#import <MobileCoreServices/UTCoreTypes.h>
#import "AddressBookUtility.h"

@interface AddViewController (private)

- (BOOL) isNewPerson;
- (BOOL) isNewInSavedCustomPersons;
- (BOOL) isNewInAddressBook;
- (void) saveEditedEntryWithDelay: (NSTimer*) timer;

@end


@implementation AddViewController

@synthesize temporaryEntry = mTemporaryEntry;
@synthesize temporaryPhoto = mTemporaryPhoto;
@synthesize locationManager;
@synthesize detailViewController = mDetailViewController;

- (id) initWithFrame: (CGRect) frame andInitialEntry:(Entry*)initialEntry
{
	if (self = [super init])
	{
		self.view.frame = frame;

		mSavingOverlay = [[SavingView alloc] initWithFrame: CGRectMake(0, 0, SCREENSIZE.width, SCREENSIZE.height-20)];
		
		self.locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		[locationManager release];

		if (nil == initialEntry)
		{
			// If used iOS is greater 3.x use Entry4 class instead of Entry class
			NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"4.0" options: NSNumericSearch];
			Entry* entry = nil;
			if (order == NSOrderedSame || order == NSOrderedDescending)
			{
				entry = [[Entry4 alloc] init];
			}
			else
			{
				entry = [[Entry alloc] init];
			}
			
			self.temporaryEntry = entry;
			mTemporaryEntry.hasPhoto = NO;
			mTemporaryEntry.description = @"";
			mTemporaryEntry.value = [NSNumber numberWithInt: 0];
			[entry release];
			
			// save current date
			mTemporaryEntry.date = [NSDate date];
			
			// location manager
			mTemporaryEntry.isLocationAvailable = NO;
            mTemporaryEntry.location = CLLocationCoordinate2DMake(48.5, 23.383333);
			
			// get current location
			[locationManager startUpdatingLocation];
		}
		else
		{
			self.temporaryEntry = initialEntry;
			
			if (self.temporaryEntry.photofilename != nil)
			{
				BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: self.temporaryEntry.photofilename];
				
				// photo could not be found, remove path from entry
				if (!fileExists)
				{
					self.temporaryEntry.hasPhoto = NO;
					self.temporaryEntry.photofilename = nil;
				}
			}
		}
	}

	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	// set first add phase
	mAddPhase = AddPhaseNone;
	
	// add permantent background for all add screens
	[self addBackgroundUi];
	
	// add navigation bar for add screen
	[self addNavigationBarUi];
	
	// add image picker controller
	[self initImagePickerController];
	
	if (mTemporaryEntry.person)
	{
		[self recreateAddViews];
	}
	else
	{
		// show the first add screen
		[self showViewByAddPhase: AddPhasePerson];
	}
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    
    mEditLocationView = nil;
}

- (void) addEventListener
{
	// add complete event listener
	[self addListenerForAddCompleteEvents];

	// add button touch event listener
	[self addListenerForAddButtonsTouch];
}

- (void)setEditMode:(EditMode)editMode
{	
	mEditMode = editMode;
}

- (void) recreateAddViews
{	
	[self addAddPersonUi];
	[mAddPersonView setEntry: mTemporaryEntry];
	[mAddPersonView shrinkUi];

	[self addChangeDateButtonUi];

	[self addAddItemUi];
	
	mAddItemView.frame = CGRectMake( 0,
	                                37 + mNavigationBarImageView.frame.size.height,
	                                SCREENSIZE.width,
	                                SCREENSIZE.height - (kSTATUS_BAR_HEIGHT + mNavigationBarImageView.frame.size.height) );
	
	[mAddItemView setEntry: mTemporaryEntry];
}

#pragma mark add ui

/**
 *	Adding the background image for all add screens.
 *
 */
- (void) addBackgroundUi
{
	UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"addcontent_bg.png"]];
	[self.view addSubview: backgroundImageView];
	[backgroundImageView release];
}

/**
 *	Adding the navigation bar which also contains a back button.
 *	The backbutton causes the hiding of this view controller.
 *
 */
- (void) addNavigationBarUi
{
	// add background image
	mNavigationBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"navbar_bg_add.png"]];
	[self.view addSubview: mNavigationBarImageView];

	// add back button
	BackButton* backButton = [BackButton buttonAtPoint: CGPointMake(6, 9)];
	[backButton addTarget: self action: @selector(backButtonClickHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: backButton];
}

/**
 *
 *
 */
- (void) addAddPersonUi
{
	mAddPersonView = [[AddPersonView alloc] initWithFrame: CGRectMake(0,
	                                                                  mNavigationBarImageView.frame.size.height - 8,
	                                                                  SCREENSIZE.width,
	                                                                  SCREENSIZE.height - mNavigationBarImageView.frame.size.height + 8)];
	[mAddPersonView setAddViewController: self];
	[self.view insertSubview: mAddPersonView belowSubview: mNavigationBarImageView];
}

/**
 *
 *
 */
- (void) addAddItemUi
{
	CGRect rect = CGRectMake(0,
	                         self.view.frame.size.height - kSTATUS_BAR_HEIGHT - mNavigationBarImageView.frame.size.height,
	                         self.view.frame.size.width,
	                         self.view.frame.size.height - kSTATUS_BAR_HEIGHT - mNavigationBarImageView.frame.size.height - 32);

	mAddItemView = [[AddItemView alloc] initWithFrame: rect];
	[mAddItemView setAddViewController: self];

	[self.view insertSubview: mAddItemView belowSubview: mNavigationBarImageView];
}

- (void) showAddItemUi
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.4];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];

	// 37 is height of shrinked 'addinput_bg.png'
	mAddItemView.frame = CGRectMake( 0,
	                                37 + mNavigationBarImageView.frame.size.height,
	                                SCREENSIZE.width,
	                                SCREENSIZE.height - (kSTATUS_BAR_HEIGHT + mNavigationBarImageView.frame.size.height) );

	[UIView commitAnimations];
}

/**
 *
 *
 */
- (void) addAddDateUi
{
	mAddDateView = [[AddDateView alloc] initWithFrame: CGRectMake(0,
	                                                              SCREENSIZE.height - mNavigationBarImageView.frame.size.height,
	                                                              SCREENSIZE.width,
	                                                              301)];
	[mAddDateView setAddViewController: self];
	[self.view insertSubview: mAddDateView belowSubview: mNavigationBarImageView];
}

- (void) removeAddDateUi
{
	[mAddDateView removeFromSuperview];
	mAddDateView = nil;

	mAddPhase = AddPhaseItem;
}

- (void) showAddDateUi
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.4];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];

	mAddDateView.frame = CGRectMake(0,
	                                self.view.frame.size.height - mAddDateView.frame.size.height,
	                                SCREENSIZE.width,
	                                SCREENSIZE.height - mNavigationBarImageView.frame.size.height);

	[UIView commitAnimations];
}

- (void) hideAddDateUi
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.4];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(removeAddDateUi)];

	mAddDateView.frame = CGRectMake(0,
	                                SCREENSIZE.height,
	                                SCREENSIZE.width,
	                                301);

	[UIView commitAnimations];
}

/**
 *
 *
 */
- (void) addAddDescriptionUi
{
	mAddDescriptionView = [[AddDescriptionView alloc] initWithFrame: CGRectMake(0,
	                                                                            SCREENSIZE.height,
	                                                                            SCREENSIZE.width,
	                                                                            SCREENSIZE.height - kSTATUS_BAR_HEIGHT - mNavigationBarImageView.frame.size.height)];

	[mAddDescriptionView setAddViewController: self];
	[self.view insertSubview: mAddDescriptionView belowSubview: mNavigationBarImageView];
}

- (void) removeAddDescriptionUi
{
	[mAddDescriptionView removeFromSuperview];
	mAddDescriptionView = nil;

	mAddPhase = AddPhaseItem;
}

- (void) showAddDescriptionUi
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.3];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];

	mAddDescriptionView.frame = CGRectMake(0,
	                                       mNavigationBarImageView.frame.size.height - 2,
	                                       SCREENSIZE.width,
	                                       SCREENSIZE.height - kSTATUS_BAR_HEIGHT);

	[UIView commitAnimations];
}

- (void) hideAddDescriptionUi
{
	if ([mTemporaryEntry.description isEqualToString: @""])
	{
		[mAddItemView descriptionSet: NO];
	}
	else
	{
		[mAddItemView descriptionSet: YES];
	}
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.3];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(removeAddDescriptionUi)];

	mAddDescriptionView.frame = CGRectMake(0,
	                                       SCREENSIZE.height,
	                                       SCREENSIZE.width,
	                                       SCREENSIZE.height - kSTATUS_BAR_HEIGHT - mNavigationBarImageView.frame.size.height);

	[UIView commitAnimations];
}

- (void) addChangeDateButtonUi
{
	mChangeDateButton = [UIButton buttonWithType: UIButtonTypeCustom];

	// TODO: warum - 2?
	mChangeDateButton.frame = CGRectMake(self.view.frame.size.width - 103,
	                                     mNavigationBarImageView.frame.size.height - 3,
	                                     103,
	                                     38);

	[mChangeDateButton setBackgroundImage:[UIImage imageNamed: @"change_date_btn.png"] forState: UIControlStateNormal];
	[mChangeDateButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
	mChangeDateButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
	[mChangeDateButton addTarget: self action: @selector(changeDateButtonTouchHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self.view insertSubview: mChangeDateButton belowSubview: mNavigationBarImageView];

	[self updateDateButton];
}

- (void) updateDateButton
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat: NSLocalizedString(@"keyShortDatePattern", nil)];
	NSString* dateLabel = [NSString stringWithFormat: @"%@", [dateFormatter stringFromDate: mTemporaryEntry.date]];
	[dateFormatter release];

	[mChangeDateButton setTitle: dateLabel forState: UIControlStateNormal];
}

- (void) changeDateLabel: (id) sender
{
	UIDatePicker* datePicker = (UIDatePicker*)sender;

	mTemporaryEntry.date = datePicker.date;

	[self updateDateButton];
}

/**
 *
 *
 */
- (void) showViewByAddPhase: (AddPhase) addPhase
{
	if (addPhase == mAddPhase)
		return;
    
	mAddPhase = addPhase;

	switch (addPhase)
	{
        case AddPhasePerson:
        {
            if (nil == mAddPersonView)
            {
                [self addAddPersonUi];
            }

            if (nil != mAddItemView)
            {
                [mAddItemView removeFromSuperview];
                mAddItemView = nil;
            }

            if (nil != mAddDateView)
            {
                [mAddDateView removeFromSuperview];
                mAddDateView = nil;
            }

            break;
        }
        case AddPhaseItem:
        {
            // add change date button ui
            if (nil == mChangeDateButton)
            {
                [self addChangeDateButtonUi];
            }

            if (nil == mAddItemView)
            {
                [mAddPersonView shrinkUi];
                [self addAddItemUi];
                [self showAddItemUi];
            }
            else
            {
                if (![@"iPhone1,1" isEqualToString:[UIDevice platform]])
                {
                    [mAddItemView expandUi];
                }
            }

            if (nil != mAddDateView)
            {
                [self hideAddDateUi];
            }

            break;
        }
        case AddPhaseDate:
        {
            if (nil == mAddDateView)
            {
                if (![@"iPhone1,1" isEqualToString:[UIDevice platform]])
                {
                    [mAddItemView shrinkUi];
                }

                [self addAddDateUi];
                [self showAddDateUi];
            }

            break;
        }
        case AddPhaseDescription:
        {
            if (nil == mAddDescriptionView)
            {
                [self addAddDescriptionUi];
                [self showAddDescriptionUi];
            }
            break;
        }
        default:
            break;
	}
}

#pragma mark back handling

/**
 *	If user touches back button
 *
 */
- (void) backButtonClickHandler: (id) sender
{
	if (mAddPhase == AddPhaseDate)
	{
		[mAddDateView completeButtonTouchHandler: nil];
	}
	else if (mAddPhase == AddPhaseDescription)
	{
		[mAddDescriptionView complete];
	}
    else if (mEditLocationView && mEditLocationView.superview != nil)
    {
        [mDeleteButton removeFromSuperview];
        
        [self hideEditLocationView];
    }   
	else
	{
		[self.navigationController popViewControllerAnimated: YES];
	}

}

#pragma mark change date touch handling

- (void) changeDateButtonTouchHandler: (id) sender
{
	if (AddPhaseDate == mAddPhase)
	{
		[self showViewByAddPhase: AddPhaseItem];
	}
	else
	{
		[self showViewByAddPhase: AddPhaseDate];
	}
}

#pragma mark listen handler

/**
 *
 *
 */
- (void) addPersonCompleteHandler: (id) sender
{
	[self showViewByAddPhase: AddPhaseItem];
}

/**
 *
 *
 */
- (void) addItemCompleteHandler: (id) sender
{
	[self saveEntry];
}

/**
 *
 *
 */
- (void) addDateCompleteHandler: (id) sender
{
	[self showViewByAddPhase: AddPhaseItem];
}

/**
 *
 *
 */
- (void) addDescriptionCompleteHandler: (id) sender
{
	[self hideAddDescriptionUi];

	// tell description button that photo is used
	if ([mTemporaryEntry.description length] > 0)
	{
		[mAddItemView descriptionSet: YES];
	}
	else
	{
		[mAddItemView descriptionSet: NO];
	}
}

#pragma mark save entry

/**
 *
 *
 */
- (void) saveEntry
{
	if (mTemporaryPhoto != nil)
	{
		[self.view addSubview: mSavingOverlay];

		[self.view setNeedsDisplay];
		[self.view setNeedsLayout];
	}
	
	// If edit mode is on, the user comes from detail view, edit entry only and do not add it
	if (EditModeOn == mEditMode)
	{		
		[NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(saveEditedEntryWithDelay:) userInfo: nil repeats: NO];
		return;
	}

	// using a short timer, though the drawloop shows the saving view
	[NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(saveEntryWithDelay:) userInfo: nil repeats: NO];
}

- (void) saveEditedEntryWithDelay: (NSTimer*) timer
{
	[self savePhoto];
	
	if ([mTemporaryEntry isMemberOfClass: [Entry4 class]])
	{
		Entry4* entry = (Entry4*)mTemporaryEntry;
		if (entry.notification != nil)
		{
			[[UIApplication sharedApplication] cancelLocalNotification: entry.notification];
			entry.notification = nil;
		}
	}
	
	// load all saved entries from user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
	
	if (data == nil)
		return;
	
	NSMutableArray *savedEntryArray = [(NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
	
	for (uint i = 0; i < savedEntryArray.count; i++)
	{
		Entry* savedEntry = [savedEntryArray objectAtIndex: i];
		if ([mTemporaryEntry.entryId isEqualToString: savedEntry.entryId])
		{
			[savedEntryArray replaceObjectAtIndex: i withObject: mTemporaryEntry];	
			break;
		}
	}
	
	// Save the new entry array
	data = [NSKeyedArchiver archivedDataWithRootObject: savedEntryArray];
	[defaults setObject: data forKey: kENTRY_USER_DEFAULTS_KEY];
	[savedEntryArray release];
	
	[self.navigationController popViewControllerAnimated:YES];
	
	// Update detail view controller with edited data
	[self.detailViewController setEntry: mTemporaryEntry];
	
	[defaults synchronize];
}


- (void) saveEntryWithDelay: (NSTimer*) timer
{	
	// get unique entryID and increase by one
	int entryID = [[[NSUserDefaults standardUserDefaults] objectForKey: @"KEY_USERDEFAULTS_UNIQUE_ENTRY_ID"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: entryID+1] forKey: @"KEY_USERDEFAULTS_UNIQUE_ENTRY_ID"];
	
	// Add identifier to temporary entry
	mTemporaryEntry.entryId = [NSString stringWithFormat:@"ID_%07d", entryID];
	
	[self savePhoto];

	// temp save into nsuserdefaults
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray* entryArray = nil;

	// check if any data was saved, if not create empty array of entries
	if (nil == [defaults objectForKey: kENTRY_USER_DEFAULTS_KEY])
	{
		NSMutableArray* entryArray = [[[NSMutableArray alloc] init] autorelease];
		NSData* data = [NSKeyedArchiver archivedDataWithRootObject: entryArray];
		[defaults setObject: data forKey: kENTRY_USER_DEFAULTS_KEY];
	}

	// get current saved data
	NSData* data = nil;
	data = [defaults objectForKey: kENTRY_USER_DEFAULTS_KEY];
	entryArray = [NSKeyedUnarchiver unarchiveObjectWithData: data];

	// Save the new entry
	[entryArray addObject: mTemporaryEntry];
	data = [NSKeyedArchiver archivedDataWithRootObject: entryArray];
	[defaults setObject: data forKey: kENTRY_USER_DEFAULTS_KEY];

	[self.navigationController popViewControllerAnimated: YES];
	
	// If new entry person name is never used before add it to user defaults 'custom persons'
	if( YES == [self isNewPerson] )
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *savedCustomPersonsArray = (NSArray*)[defaults objectForKey:kCUSTOM_PERSONS_USER_DEFAULTS_KEY];
		
		NSMutableArray* tempSavedCustomPersonsArray = nil;
		if (savedCustomPersonsArray == nil)
		{
			tempSavedCustomPersonsArray = [NSMutableArray array];
		}
		else
		{
			tempSavedCustomPersonsArray = [NSMutableArray arrayWithArray:savedCustomPersonsArray];
		}
		
		// Remove obsolete spaces
		NSString *trimmedPersonString = [mTemporaryEntry.person stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSMutableDictionary* personDictionary = [[NSMutableDictionary alloc] init];
		[personDictionary setObject: trimmedPersonString forKey: @"person"];
		[personDictionary setObject: [NSDate date] forKey: @"date"];
		[tempSavedCustomPersonsArray addObject: personDictionary];
		[personDictionary release];
		
		[defaults setObject:tempSavedCustomPersonsArray forKey:kCUSTOM_PERSONS_USER_DEFAULTS_KEY];
	}
	
	[defaults synchronize];
}

/*
 *	Person allready in user default or adress book?
 *
 */
- (BOOL)isNewPerson
{
	return [self isNewInSavedCustomPersons] && [self isNewInAddressBook];
}

- (BOOL)isNewInSavedCustomPersons
{
	// Load all saved entries from user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedCustomPersonsArray = (NSArray*)[defaults objectForKey:kCUSTOM_PERSONS_USER_DEFAULTS_KEY];
	
	if (savedCustomPersonsArray == nil)
	{
		return YES;
	}
	
	if (0 == savedCustomPersonsArray.count)
	{
		return YES;
	}
	
	for (uint i = 0; i < savedCustomPersonsArray.count; i++)
	{
		NSDictionary* personDictionary = (NSDictionary*)[savedCustomPersonsArray objectAtIndex:i];
		NSString *savedPerson = (NSString*)[personDictionary objectForKey: @"person"];
		savedPerson = [savedPerson stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([savedPerson isEqualToString: [mTemporaryEntry.person stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]])
		{
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isNewInAddressBook
{
    __block NSError *error;
    __block NSArray *addressBookContacts;
    [AddressBookUtility getAllPeopleFromAddressBookWithCompletion:^(NSMutableArray *people, NSError *anError) {
        error = anError;
        addressBookContacts = people;
    }];
    
    if (error) {
        return NO;
    }
    
    for (AddressBookContact* tempAddressBookContact in addressBookContacts)
    {
        NSString* personString = [NSString stringWithFormat: @"%@ %@", tempAddressBookContact.firstName, tempAddressBookContact.lastName];
        NSRange resultsRange = [personString rangeOfString: mTemporaryEntry.person options: NSCaseInsensitiveSearch];
        
        if (resultsRange.length > 0)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void) savePhoto
{
	if (mTemporaryPhoto == nil)
	{
		return;
	}

	// create filename or use old
	NSString* filename;
	if (mTemporaryEntry.photofilename == nil)
	{
		filename = [NSString stringWithFormat: @"PHOTO_%@.png", mTemporaryEntry.entryId];

		NSArray* directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentsPath = [directories objectAtIndex: 0];

		filename = [documentsPath stringByAppendingPathComponent: filename];
	}
	else
	{
		filename = mTemporaryEntry.photofilename;
	}

	// use own pool for image data / image conversion
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	// scale the image down and save to file
	UIImage* image = [self imageWithImage: mTemporaryPhoto scaledToSizeWithSameAspectRatio: CGSizeMake(500, 500)];
	
	// build PNG image
	NSData* imageData = UIImagePNGRepresentation(image);
	
#if !kDEBUG	
	
	// save image
	[imageData writeToFile: filename atomically: NO];

#else
	
	Boolean couldWriteImageData = [imageData writeToFile: filename atomically: NO];
	
	if (imageData == nil)
	{
		LogDebug(@"error getting PNG data");
	}
	else
	{
		LogDebug(@"created PNG representation");
	}

	if (couldWriteImageData)
	{
		LogDebug(@"saved image");
	}
	else
	{
		LogDebug(@"couldnt save image");
	}

#endif

	// save filename
	mTemporaryEntry.photofilename = filename;

	[pool drain];
}

#pragma mark location

- (void) locationManager: (CLLocationManager*) manager didUpdateToLocation: (CLLocation*) newLocation fromLocation: (CLLocation*) oldLocation
{
    LogInfo(@"locationManager didUpdateToLocation: latitude: %@, longitude: %@", [NSString stringWithFormat: @"%.7f", newLocation.coordinate.latitude], [NSString stringWithFormat: @"%.7f", newLocation.coordinate.longitude]);
    
	// save new location of user
	if (newLocation.coordinate.latitude != 0.0 || newLocation.coordinate.longitude != 0.0)
	{
		mTemporaryEntry.location = newLocation.coordinate;
		mTemporaryEntry.isLocationAvailable = YES;
        [mAddItemView locationSet: YES];
	}
}

- (void) locationManager: (CLLocationManager*) manager didFailWithError: (NSError*) error
{
	LogInfo(@"locationManager didFailWithError");
	
	mTemporaryEntry.isLocationAvailable = NO;
    [mAddItemView locationSet: NO];
}

- (void) editLocationTouchHandler: (id) sender
{
    // Add delete button to navigation bar
	mDeleteButton = [NavButton deleteButtonAtPoint: CGPointZero];
	[mDeleteButton setCenter: CGPointMake(320 - mDeleteButton.frame.size.width/2 - 8, 9 + mDeleteButton.frame.size.height/2)];
	[mDeleteButton addTarget:self action:@selector(deleteButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:mDeleteButton];
    
    if (nil == mEditLocationView)
    {
        mEditLocationView = [[EditLocationView alloc] initWithEntry: mTemporaryEntry];
        mEditLocationView.frame = CGRectMake(0, 0, SCREENSIZE.width, SCREENSIZE.height-kSTATUS_BAR_HEIGHT);
    }
    
    // update entry & annotation
    mEditLocationView.entry = mTemporaryEntry;
    [mEditLocationView addAnnotation];
    
    // move outside of the screen bounds
    CGRect frame = mEditLocationView.frame;
    frame.origin.y = frame.size.height;
    mEditLocationView.frame = frame;
    
    [self.view insertSubview: mEditLocationView belowSubview: mNavigationBarImageView];
    
    // animate back into the screen bounds
    [UIView beginAnimations: @"editLocation" context: nil];
    frame.origin.y = 0;
    mEditLocationView.frame = frame;
    [UIView commitAnimations];
}

- (void)deleteButtonClickHandler:(UIButton*)button
{
    LogDebug(@"deleteButtonClickHandler");
    
    [mDeleteButton removeFromSuperview];
    
    mTemporaryEntry.location = CLLocationCoordinate2DMake(48.5, 23.383333);
    mTemporaryEntry.isLocationAvailable = NO;
    
    [self hideEditLocationView];
}

- (void) hideEditLocationView
{
    CGRect frame = mEditLocationView.frame;
    frame.origin.y = frame.size.height;
    
    // animate out of the screen bounds
    [UIView beginAnimations: @"editLocation" context: nil];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(editLocationViewAnimationFinished)];
    mEditLocationView.frame = frame;
    [UIView commitAnimations];
    
    [mAddItemView locationSet: mTemporaryEntry.isLocationAvailable];
}

- (void) editLocationViewAnimationFinished
{
    [mEditLocationView removeFromSuperview];
}

- (void) customLocationWasSelected: (NSNotification*) notification
{
    // stop location updates, a custom location was selected.
    [locationManager stopUpdatingLocation];
}

#pragma mark photo

- (void) initImagePickerController
{
	mImagePickerController = [[UIImagePickerController alloc] init];
	mImagePickerController.delegate = self;

	if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
	{
		mImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		
		UIView * aview = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SCREENSIZE.width, SCREENSIZE.height)];
		UIView * top = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SCREENSIZE.width, 55)];
		UIView * btm = [[UIView alloc] initWithFrame: CGRectMake(0, 374, SCREENSIZE.width, 55)];
		
		aview.backgroundColor = [UIColor clearColor];
		top.backgroundColor = [UIColor colorWithWhite: 0 alpha:0.5];
		btm.backgroundColor = [UIColor colorWithWhite: 0 alpha:0.5];
		
		aview.userInteractionEnabled = NO;
		top.userInteractionEnabled = NO;
		btm.userInteractionEnabled = NO;
		
		[aview addSubview: top];
		[aview addSubview: btm];
		
		mImagePickerController.cameraOverlayView = aview;
		
		[top release];
		[btm release];
		[aview release];
	}
	else
	{
		mImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	}
}

- (void) addPhotoTouchHandler: (id) sender
{
	if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
	{
		UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: nil
																 delegate: self
														cancelButtonTitle: NSLocalizedString(@"keyCancel", nil)
												   destructiveButtonTitle: nil
														otherButtonTitles: NSLocalizedString(@"keyAddPhotoTakeNew", nil), NSLocalizedString(@"keyAddPhotoFromLibrary", nil), nil];
		[actionSheet showInView: self.view];
		[actionSheet release];
	}
	else
	{
		// present image picker modal
		[self presentModalViewController: mImagePickerController animated: YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;
	
	switch (buttonIndex)
	{
		case 1:
			mImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
		case 0:
		default:
			mImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			break;
	}
	
	[self presentModalViewController: mImagePickerController animated: YES];
}

- (void) addDescriptionButtonTouchHandler: (id) sender
{
	// show description view
	[self showViewByAddPhase: AddPhaseDescription];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
	// remove picker view
	[self dismissModalViewControllerAnimated: YES];
}

- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info
{
	LogDebug(@"didFinishPickingMediaWithInfo");
	
	mTemporaryEntry.hasPhoto = YES;

	NSString* mediaType = [info objectForKey: UIImagePickerControllerMediaType];

	// only for images
	if (CFStringCompare( (CFStringRef)mediaType, kUTTypeImage, 0 ) == kCFCompareEqualTo)
	{
		if( [mAddItemView respondsToSelector: @selector(photoSet:)] )
		{
			[mAddItemView photoSet:YES];
		}
		
		// Save Image temporary
		UIImage* img = [info objectForKey: UIImagePickerControllerOriginalImage];
		self.temporaryPhoto = img;
	}

	// remove picker view
	[self dismissModalViewControllerAnimated: YES];
}

// TODO: shorten up, no orientation needed atm
- (UIImage*) imageWithImage: (UIImage*) sourceImage scaledToSizeWithSameAspectRatio: (CGSize) targetSize
{
	if (!sourceImage)
	{
		LogDebug(@"error with source image");

		return nil;
	}
	
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

	if (CGSizeEqualToSize(imageSize, targetSize) == NO)
	{
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;

		if (widthFactor > heightFactor)
		{
			scaleFactor = widthFactor; // scale to fit height
		}
		else
		{
			scaleFactor = heightFactor; // scale to fit width
		}

		scaledWidth = width * scaleFactor;
		scaledHeight = height * scaleFactor;

		// center the image
		if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		}
		else
		if (widthFactor < heightFactor)
		{
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}

	CGImageRef imageRef = [sourceImage CGImage];
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);

	if (bitmapInfo == kCGImageAlphaNone)
	{
		bitmapInfo = kCGImageAlphaNoneSkipLast;
	}

	CGContextRef bitmap;
	size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);

	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown)
	{
		bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, bitsPerComponent, targetWidth*bitsPerComponent, colorSpaceInfo, bitmapInfo);
	}
	else
	{
		bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, bitsPerComponent, targetWidth*bitsPerComponent, colorSpaceInfo, bitmapInfo);
	}
	
	// error in creating context
	if (!bitmap)
	{
		LogDebug(@"error in creating context");

		return NULL;
	}

	// In the right or left cases, we need to switch scaledWidth and scaledHeight,
	// and also the thumbnail point
	if (sourceImage.imageOrientation == UIImageOrientationLeft)
	{
		thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
		CGFloat oldScaledWidth = scaledWidth;
		scaledWidth = scaledHeight;
		scaledHeight = oldScaledWidth;

		CGContextRotateCTM( bitmap, 90 * (3.1415927 / 180.0) );
		CGContextTranslateCTM(bitmap, 0, -targetHeight);
	}
	else
	if (sourceImage.imageOrientation == UIImageOrientationRight)
	{
		thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
		CGFloat oldScaledWidth = scaledWidth;
		scaledWidth = scaledHeight;
		scaledHeight = oldScaledWidth;

		CGContextRotateCTM( bitmap, -90 * (3.1415927 / 180.0) );
		CGContextTranslateCTM(bitmap, -targetWidth, 0);
	}
	else
	if (sourceImage.imageOrientation == UIImageOrientationUp)
	{
		// NOTHING
	}
	else
	if (sourceImage.imageOrientation == UIImageOrientationDown)
	{
		CGContextTranslateCTM(bitmap, targetWidth, targetHeight);
		CGContextRotateCTM( bitmap, -180 * (3.1415927 / 180.0) );
	}

	CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage: ref];

	CGContextRelease(bitmap);
	CGImageRelease(ref);

	return newImage;
}

#pragma mark listen

- (void)addListenerForAddCompleteEvents
{
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addPersonCompleteHandler:)
                                                 name: @"addPersonComplete"
                                               object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addItemCompleteHandler:)
                                                 name: @"addItemComplete"
                                               object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addDateCompleteHandler:)
                                                 name: @"addDateComplete"
                                               object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addDescriptionCompleteHandler:)
                                                 name: @"addDescriptionComplete"
                                               object: nil];
}

- (void) removeListenerForAddCompleteEvents
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"addPersonComplete" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"addItemComplete" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"addDateComplete" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"addDescriptionComplete" object: nil];
}

- (void) addListenerForAddButtonsTouch
{
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addDescriptionButtonTouchHandler:)
                                                 name: @"addDescriptionButtonTouch"
                                               object: nil];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(addPhotoTouchHandler:)
                                                 name: @"addPhotoTouch"
                                               object: nil];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(editLocationTouchHandler:)
                                                 name: @"editLocationTouch"
                                               object: nil];
}

- (void) removeListenerForAddButtonsTouch
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"addDescriptionButtonTouch" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"addPhotoTouch" object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"editLocationTouch" object: nil];
}

#pragma mark memory management

- (void) viewWillAppear:(BOOL)animated
{
	[self addEventListener];
    
    // add listener for custom location changes
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(customLocationWasSelected:) name: editLocationViewDidChangeLocationNotification object: nil];
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear: (BOOL) animated
{
	[self removeListenerForAddCompleteEvents];
	[self removeListenerForAddButtonsTouch];
    
    // remove listener for custom location changes
    [[NSNotificationCenter defaultCenter] removeObserver: self name: editLocationViewDidChangeLocationNotification object: nil];

	[super viewWillDisappear: animated];
}

- (void) dealloc
{	
	[locationManager stopUpdatingLocation];
	self.locationManager = nil;

	[mTemporaryEntry release];
	[mTemporaryPhoto release];

	[mNavigationBarImageView release];
	[mImagePickerController release];
	[mSavingOverlay release];
	[mAddItemView release];
	[mAddPersonView release];
    [mEditLocationView release];
	
	[super dealloc];
}

@end
