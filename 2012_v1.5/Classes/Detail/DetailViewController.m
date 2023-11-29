//
//  DetailViewController.m
//  StillWaitin
//
//  Created by devmob on 17.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "DetailViewController.h"

#import "UILabel+MultilineFontAdjustment.h"
#import "UIDevice+Addition.h"
#import "MapAnnotation.h"
#import "AddViewController.h"
#import "LocalNotificationCenter.h"

#import "DDAnnotation.h"
#import "DDAnnotationView.h"

#import <QuartzCore/QuartzCore.h>



@interface DetailViewController ()
{
    UIAlertView *_deletionAlertView;
}

@end


@implementation DetailViewController

@synthesize entry = mEntry;

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super init])
	{
		mViewRectangle = frame;
		self.view.frame = frame;
    }
	
    return self;
}

- (void)dealloc
{	
    self.entry = nil;
    
    [mPhotoArrow release];
    
    if (mMapView)
        mMapView.delegate = nil;
    
    [_deletionAlertView release];
    
    [super dealloc];
}

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:mViewRectangle];	
	
	// add permantent background for all add screens
	[self addBackgroundUi];
	
	// add data ui
	[self addDataBackground];
	
	// add value label ui
	[self addDescriptionLabelUi];
	
	// add date label ui
	[self addDateLabelUi];
	
	// add value label ui
	[self addValueLabelUi];
	
	// add debt direction indicator ui
	[self addDebtDirectionIndicatorUi];
	
	// add navigation bar for add screen
	[self addNavigationBarUi];
	
	// add shadows
	[self addShadows];
	
	// add delete button ui
	[self addBottomBarUi];
}

- (void) setEntry:(Entry*)aEntry
{
    [aEntry retain];
    [mEntry release];
	mEntry = aEntry;
	
	[self update];
}

- (void)update
{
	// check, if current notification is in the past
	// and delete it, if needed
	if ([mEntry isMemberOfClass: [Entry4 class]])
	{
		Entry4* entry = (Entry4*)mEntry;
		if (entry.notification != nil)
		{
			NSDate* notificationDate = entry.notification.fireDate;
			if ([notificationDate timeIntervalSinceNow] < 0)
			{
				[self notificationView: nil touchedButtonWithType: eNotificationViewButtonTypeDelete];
			}
		}
	}
	
	// change button text, if notification is available
	if ([mEntry isMemberOfClass: [Entry4 class]])
	{
		Entry4* entry = (Entry4*)mEntry;
		if (entry.notification)
		{
			NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateStyle: NSDateFormatterMediumStyle];
			[dateFormatter setTimeStyle: NSDateFormatterNoStyle];
			NSString* dateString = [dateFormatter stringFromDate: entry.notification.fireDate];
			[dateFormatter release];
			
			mNotificationButton.titleLabel.font = [UIFont boldSystemFontOfSize: 11];
			[mNotificationButton setTitle: [NSString stringWithFormat: @"  %@", dateString] forState: UIControlStateNormal];
		}
		else
		{
			mNotificationButton.titleLabel.font = [UIFont systemFontOfSize: 11];
			[mNotificationButton setTitle: [NSString stringWithFormat: @"  %@", NSLocalizedString(@"keyNotification", nil)] forState:UIControlStateNormal];
		}
	}

	
	
	// update person label
	mPersonLabel.text = mEntry.person;
	
	// Use placeholder, if no description is available
	mDescriptionLabel.text = mEntry.description;
	if ([mDescriptionLabel.text length] == 0) {
		mDescriptionLabel.text = NSLocalizedString(@"keyNoDescription", nil);
		mDescriptionLabel.alpha = 0.5;
	}
	
	// height of description
	CGSize maximumSize = CGSizeMake(mDescriptionLabel.frame.size.width, 9999);
    UIFont *descriptionFont = [UIFont systemFontOfSize:16];
    CGSize descriptionStringSize = [mDescriptionLabel.text sizeWithFont:descriptionFont 
								                  constrainedToSize:maximumSize 
													  lineBreakMode:mDescriptionLabel.lineBreakMode];
	int descriptionLabelHeight = descriptionStringSize.height;
	
	// height of value label
	int valueLabelHeight = mValueLabel.frame.size.height;
	
	// calculate height of data background image
	int dataBackgroundOffset = 12;
	int dataBackgroundHeight = descriptionLabelHeight + valueLabelHeight + dataBackgroundOffset;
	dataBackgroundHeight = dataBackgroundHeight < 97 ? 97 : dataBackgroundHeight;
	
	// update data background
	CGRect dataBackgroundFrame = CGRectMake(mDataBackgroundImageView.frame.origin.x,
											mDataBackgroundImageView.frame.origin.y,
											mDataBackgroundImageView.frame.size.width,
											dataBackgroundHeight);
	mDataBackgroundImageView.frame = dataBackgroundFrame;
	
	// update value label
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
	
	mValueLabel.text = [numberFormatter stringFromNumber:mEntry.value];
	
	int valueLabelY = mDataBackgroundImageView.frame.origin.y + mDataBackgroundImageView.frame.size.height - mValueLabel.frame.size.height - dataBackgroundOffset/2;
	CGRect valueFrame = CGRectMake(mValueLabel.frame.origin.x, valueLabelY, mValueLabel.frame.size.width, mValueLabel.frame.size.height);
	mValueLabel.frame = valueFrame;
	[mValueLabel adjustMultilineFontsize:40 minimum:20];
	
	// update date labels
	NSDateFormatter* monthFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[monthFormatter setDateFormat:NSLocalizedString(@"keyDatePatternMonth", nil)];
	NSString *localizedMonthString = [monthFormatter stringFromDate:mEntry.date];
	
	CGRect monthLabelFrame = CGRectMake(mMonthLabel.frame.origin.x,
							  		    mDataBackgroundImageView.frame.origin.y + mDataBackgroundImageView.frame.size.height - dataBackgroundOffset/2 - mMonthLabel.frame.size.height,
									    mMonthLabel.frame.size.width,
									    mMonthLabel.frame.size.height);
	mMonthLabel.frame = monthLabelFrame;
	mMonthLabel.text = [localizedMonthString uppercaseString];
	
	NSDateFormatter* dayFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dayFormatter setDateFormat:NSLocalizedString(@"keyDatePatternDay", nil)];
	NSString *localizedDayString = [dayFormatter stringFromDate:mEntry.date];
	
	CGRect dayLabelFrame = CGRectMake(mDayLabel.frame.origin.x,
									  mMonthLabel.frame.origin.y + 3 - mDayLabel.frame.size.height,
									  mDayLabel.frame.size.width,
									  mDayLabel.frame.size.height);
	mDayLabel.frame = dayLabelFrame;
	mDayLabel.text = localizedDayString;
	
	// update description label
	int descriptionLabelY = valueLabelY - descriptionLabelHeight;
	CGRect descriptionFrame = CGRectMake(mDescriptionLabel.frame.origin.x, descriptionLabelY, mDescriptionLabel.frame.size.width, descriptionStringSize.height);
	mDescriptionLabel.frame = descriptionFrame;
	
	// update debt direction indicator
	if(DebtDirectionOut == mEntry.direction)	
		[mDebtDirectionIndicatorImageView setImage:[UIImage imageNamed:@"detail_indicator_red.png"]];
	else
		[mDebtDirectionIndicatorImageView setImage:[UIImage imageNamed:@"detail_indicator_green.png"]];
	
	// update shadows
	CGRect shadowFrame = CGRectMake(mShadowTopImageView.frame.origin.x,
									mDataBackgroundImageView.frame.origin.y + mDataBackgroundImageView.frame.size.height,
									mShadowTopImageView.frame.size.width,
									mShadowTopImageView.frame.size.height);
	mShadowTopImageView.frame = shadowFrame;
	
	// add and update map ui if location is stored for entry
	if(YES == mEntry.isLocationAvailable)
	{
		[self addAndUpdateMapUi];
        
        [mPhotoButton removeFromSuperview];
        [mPhotoButton release];
        mPhotoButton = nil;
        
        [mPhotoArrow removeFromSuperview];
        [mPhotoArrow release];
        mPhotoArrow = nil;
		
		// show photo
		[self addPhotoAsButton];
	}
	else
	{
        if (nil != mMapView)
        {
            mMapView.delegate = nil;
            [mMapView removeFromSuperview];
            mMapView = nil;
        }
        
        [mPhotoButton removeFromSuperview];
        [mPhotoButton release];
        mPhotoButton = nil;
        
        [mPhotoArrow removeFromSuperview];
        [mPhotoArrow release];
        mPhotoArrow = nil;
        
		// show photo fullsize
		[self addPhotoAtFullSize];
	}

	
}

#pragma mark add ui

/**
 *	Adding the background image for all add screens.
 *
 */
- (void)addBackgroundUi
{
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addcontent_bg.png"]];
    backgroundImageView.frameBottom = mViewRectangle.size.height;
	[self.view addSubview:backgroundImageView];
	[backgroundImageView release];
}

/**
 *	Adding the navigation bar which also contains a back button.
 *	The backbutton causes the hiding of this view controller.
 *
 */
- (void)addNavigationBarUi
{
	// add navbar background image
	mNavBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_bg_empty.png"]];
	[self.view addSubview: mNavBar];
	[mNavBar release];
	
	// add back button
	BackButton *backButton = [BackButton buttonAtPoint: CGPointMake(6, 9)];
	[backButton addTarget:self action:@selector(backButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	// Add edit button
	NavButton *editButton = [NavButton editButtonAtPoint: CGPointZero];
	[editButton setCenter: CGPointMake(320 - editButton.frame.size.width/2 - 8, 9 + editButton.frame.size.height/2)];
	[editButton addTarget:self action:@selector(editButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:editButton];
	
	// person label
	int margin = 10;
	float left = backButton.frame.size.width + backButton.frame.origin.x + margin + (editButton.frame.size.width-backButton.frame.size.width)/3;
	float width = editButton.frame.origin.x - left - margin;
	mPersonLabel = [[UILabel alloc] initWithFrame:CGRectMake(floor(left), 0, width, 47)];
	mPersonLabel.textAlignment = UITextAlignmentCenter;
	mPersonLabel.backgroundColor = [UIColor clearColor];
	mPersonLabel.font = [UIFont boldSystemFontOfSize:16.0];
	mPersonLabel.shadowColor = kCOLOR_SHADOW_DETAIL_DATE;
	mPersonLabel.shadowOffset = kSIZE_SHADOW_DETAIL_DATE;
	mPersonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	[self.view addSubview:mPersonLabel];
	[mPersonLabel release];
}

- (void)addShadows
{
	mShadowTopImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_shadow_top.png"]];
    mShadowTopImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	mShadowTopImageView.frame = CGRectMake(0, 173, self.view.frameWidth, 20);
	[self.view addSubview:mShadowTopImageView];
	[mShadowTopImageView release];
	
	mShadowBottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_shadow_bottom.png"]];
    mShadowBottomImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	mShadowBottomImageView.frame = CGRectMake(0, self.view.frame.size.height - 30 - mShadowBottomImageView.frame.size.height, self.view.frameWidth, mShadowBottomImageView.frame.size.height);
	[self.view addSubview:mShadowBottomImageView];
	[mShadowBottomImageView release];
}

- (void)addDataBackground
{
	mDataBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_data_bg.png"]];
    mDataBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	mDataBackgroundImageView.frame = CGRectMake(0, 55, self.view.frameWidth, 118);
	[self.view addSubview:mDataBackgroundImageView];
	[mDataBackgroundImageView release];
}

- (void)addDateLabelUi
{	
	mDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 52, 26)];
	mDayLabel.backgroundColor = [UIColor clearColor];
	mDayLabel.textAlignment = UITextAlignmentCenter;
	mDayLabel.font = [UIFont boldSystemFontOfSize:26];
	mDayLabel.textColor = [UIColor whiteColor];
	mDayLabel.shadowColor = kCOLOR_SHADOW_DETAIL_DATE;
	mDayLabel.shadowOffset = kSIZE_SHADOW_DETAIL_DATE;
	[self.view addSubview:mDayLabel];
	[mDayLabel release];
	
	mMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 146, 52, 20)];
	mMonthLabel.backgroundColor = [UIColor clearColor];
	mMonthLabel.textAlignment = UITextAlignmentCenter;
	mMonthLabel.font = [UIFont boldSystemFontOfSize:14];
	mMonthLabel.textColor = [UIColor whiteColor];
	mMonthLabel.shadowColor = kCOLOR_SHADOW_DETAIL_DATE;
	mMonthLabel.shadowOffset = kSIZE_SHADOW_DETAIL_DATE;
	[self.view addSubview:mMonthLabel];
	[mMonthLabel release];
}

- (void)addDescriptionLabelUi
{
	// add value label
	mDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 62, 230, 0)];
	mDescriptionLabel.textAlignment = UITextAlignmentRight;
	mDescriptionLabel.backgroundColor = [UIColor clearColor];
	mDescriptionLabel.font = [UIFont systemFontOfSize:16];
	mDescriptionLabel.textColor = kCOLOR_GREEN_MAIN;
	mDescriptionLabel.shadowColor = kCOLOR_SHADOW_MAIN;
	mDescriptionLabel.shadowOffset = kSIZE_SHADOW_MAIN;
	mDescriptionLabel.numberOfLines = 0;
	[self.view addSubview:mDescriptionLabel];
	[mDescriptionLabel release];
}

- (void)addValueLabelUi
{	
	// add value label
	mValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 114, 230, 44)];
	mValueLabel.textAlignment = UITextAlignmentRight;
	mValueLabel.backgroundColor = [UIColor clearColor];
	mValueLabel.font = [UIFont boldSystemFontOfSize:40];
	mValueLabel.textColor = kCOLOR_GREEN_MAIN;
	mValueLabel.shadowColor = kCOLOR_SHADOW_MAIN;
	mValueLabel.shadowOffset = kSIZE_SHADOW_MAIN;
	[self.view addSubview:mValueLabel];
	[mValueLabel release];
}

- (void)addDebtDirectionIndicatorUi
{
	mDebtDirectionIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_indicator_green.png"]];
	mDebtDirectionIndicatorImageView.frame = CGRectMake(0, 48, SCREENSIZE.width, 8);
	[self.view addSubview: mDebtDirectionIndicatorImageView];
	[mDebtDirectionIndicatorImageView release];
}

/**
 *	Add map view for showing marker where debt was entered
 *
 */
- (void)addAndUpdateMapUi
{
	mMapView = [[MKMapView alloc] initWithFrame: CGRectZero];
	
	mMapView.frame = CGRectMake(0, mDataBackgroundImageView.frameBottom,
								SCREENSIZE.width,
								SCREENSIZE.height - 20 - mDataBackgroundImageView.frameBottom - 38); // 38 == bottom bar
	
	mMapView.delegate = self;
	[self.view insertSubview:mMapView belowSubview:mShadowTopImageView];
    [mMapView release];
	
	// Add Annotation
	MapAnnotation* debtLocation = [[MapAnnotation alloc] initWithEntry:mEntry];
	[mMapView addAnnotation: debtLocation];
    [debtLocation release];
	
	// Zoom to Annotation
    MKCoordinateRegion newRegion;
    newRegion.center.longitude = mEntry.location.longitude;
    newRegion.center.latitude = mEntry.location.latitude;
    newRegion.span.latitudeDelta = 0.02;
    newRegion.span.longitudeDelta = 0.02;
	
    [mMapView setRegion:newRegion animated:NO];
}


- (void)addPhotoAtFullSize
{
	if(nil != mEntry.photofilename)
	{
		UIImage * image = [UIImage imageWithContentsOfFile: mEntry.photofilename];
		
		if (image == nil)
		{
			LogDebug(@"couldnt load image from: %@", mEntry.photofilename);
		}
		else
		{
			LogDebug(@"did load and will show image");

			UIImageView * photoView = [[UIImageView alloc] initWithFrame: CGRectZero];
			
			photoView.frame = CGRectMake(0,
										mDataBackgroundImageView.frame.origin.y + mDataBackgroundImageView.frame.size.height,
										SCREENSIZE.width,
										self.view.frame.size.height - (mDataBackgroundImageView.frame.origin.y + mDataBackgroundImageView.frame.size.height));
			
			photoView.image = image;
			[self.view insertSubview:photoView belowSubview:mShadowTopImageView];
			
			[photoView release];
		}
	}
}


- (void) addPhotoAsButton
{	
	if(nil != mEntry.photofilename)
	{
		UIImage * image = [UIImage imageWithContentsOfFile: mEntry.photofilename];
		
		if (image == nil)
		{
			LogDebug(@"couldnt load image from: %@", mEntry.photofilename);
		}
		else
		{
			LogDebug(@"did load and will show image");

			mPhotoButton = [[UIButton alloc] init];
			mPhotoButton.frame = CGRectMake(210, mDataBackgroundImageView.frame.origin.y + mDataBackgroundImageView.frame.size.height + 10, 100, 100);
			mPhotoButton.layer.cornerRadius = 9;
			mPhotoButton.layer.masksToBounds = YES;
			mPhotoButton.adjustsImageWhenHighlighted = NO;
			[mPhotoButton setImage: image forState: UIControlStateNormal];
			[mPhotoButton addTarget: self action: @selector(photoTouchHandler:) forControlEvents: UIControlEventTouchDown];
			[self.view insertSubview:mPhotoButton belowSubview:mShadowTopImageView];
			
			mOriginalPhotoFrame = mPhotoButton.frame;
			
			UIImage * arrowImage = [UIImage imageNamed: @"detail_photo_arrow.png"];
			mPhotoArrow = [[UIImageView alloc] initWithImage: arrowImage];
			
			CGRect frame = mPhotoArrow.frame;
			frame.origin.x = mPhotoButton.frame.origin.x;
			frame.origin.y = mPhotoButton.frame.origin.y+mPhotoButton.frame.size.height-frame.size.height;
			mPhotoArrow.frame = frame;
			
			[self.view insertSubview:mPhotoArrow belowSubview:mShadowTopImageView];
			//[mPhotoArrow release]; do not release - we have to re-add it to subview again
		}
		
		// Show contents of Documents directory
		//NSError * error;
		LogDebug(@"Documents directory: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0] error:nil]);
	}
	else
	{
		LogDebug(@"no filename saved in entry.. %@", mEntry.photofilename);
	}
}

/**
 *	Add bottom bar, mail button, delete button ui
 *
 */
- (void) addBottomBarUi
{	
	// Add mail button
	UIImage* bgImage = [[UIImage imageNamed:@"detail_mail_btn_bg.png"] stretchableImageWithLeftCapWidth: 10 topCapHeight: 8];
	mMailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mMailButton.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height+8);
    mMailButton.frameBottom = SCREENSIZE.height-20;
	[mMailButton setBackgroundImage: bgImage forState: UIControlStateNormal];
	[mMailButton setBackgroundImage: [UIImage imageNamed:@"detail_mail_btn_bg_pressed.png"] forState: UIControlStateHighlighted];
	[mMailButton setImage:[UIImage imageNamed:@"detail_mail_btn.png"] forState:UIControlStateNormal];
	[mMailButton setTitle: [NSString stringWithFormat: @"  %@", NSLocalizedString(@"keyMail", nil)] forState:UIControlStateNormal];
	[mMailButton setTitleColor:kCOLOR_GREEN_MAIN forState:UIControlStateNormal];
	[mMailButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
	[mMailButton addTarget:self action:@selector(mailButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:mMailButton];
	
	// Add notification button
	bgImage = [[UIImage imageNamed:@"detail_timer_btn_bg.png"] stretchableImageWithLeftCapWidth: 10 topCapHeight: 8];
	mNotificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mNotificationButton.frame = CGRectMake(mMailButton.frame.size.width, 0, bgImage.size.width, bgImage.size.height+8);
    mNotificationButton.frameBottom = mMailButton.frameBottom;
	[mNotificationButton setBackgroundImage: bgImage forState: UIControlStateNormal];
	[mNotificationButton setBackgroundImage: [UIImage imageNamed:@"detail_timer_btn_bg_pressed.png"] forState: UIControlStateHighlighted];
	[mNotificationButton setImage:[UIImage imageNamed:@"detail_timer_btn.png"] forState:UIControlStateNormal];
	[mNotificationButton setTitle: [NSString stringWithFormat: @"  %@", NSLocalizedString(@"keyNotification", nil)] forState:UIControlStateNormal];
	[mNotificationButton setTitleColor:kCOLOR_GREEN_MAIN forState:UIControlStateNormal];
	[mNotificationButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
	[mNotificationButton addTarget:self action:@selector(notificationButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:mNotificationButton];
	
	// Add delete button
	bgImage = [[UIImage imageNamed:@"detail_delete_btn_bg.png"] stretchableImageWithLeftCapWidth: 10 topCapHeight: 8];
	mDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mDeleteButton.frame = CGRectMake(mNotificationButton.frame.origin.x+mNotificationButton.frame.size.width, 0, bgImage.size.width, bgImage.size.height+8);
    mDeleteButton.frameBottom = mNotificationButton.frameBottom;
	[mDeleteButton setBackgroundImage: bgImage forState: UIControlStateNormal];
	[mDeleteButton setBackgroundImage: [UIImage imageNamed:@"detail_delete_btn_bg_pressed.png"] forState: UIControlStateHighlighted];
	[mDeleteButton setImage: [UIImage imageNamed:@"detail_delete_btn.png"] forState: UIControlStateNormal];
	[mDeleteButton setTitle: [NSString stringWithFormat: @"  %@", NSLocalizedString(@"keyDelete", nil)] forState: UIControlStateNormal];
	[mDeleteButton setTitleColor:kCOLOR_GREEN_MAIN forState: UIControlStateNormal];
	[mDeleteButton.titleLabel setFont:[UIFont systemFontOfSize: 12]];
	[mDeleteButton addTarget:self action:@selector(deleteButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:mDeleteButton];
	
	if (![[UIApplication sharedApplication] respondsToSelector: @selector(scheduleLocalNotification:)])
	{
		[mNotificationButton removeFromSuperview];
		mMailButton.frameWidth = SCREENSIZE.width/2;
		mDeleteButton.frameWidth = SCREENSIZE.width/2;
		mDeleteButton.frameX = SCREENSIZE.width/2;
	}
}

#pragma mark -
#pragma mark bottom bar buttons

/**
 *	If user touches mail button open modal mail view
 *
 */
- (void)mailButtonTouchHandler:(id)sender
{
	NSMutableArray* entries = [NSMutableArray arrayWithCapacity: 10];
	
	// load all saved entries from user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
	NSArray* savedEntryArray = [NSKeyedUnarchiver unarchiveObjectWithData: data];
	
	// find all entries of current person
	for (Entry* entry in savedEntryArray)
    {
		if ([[entry.person lowercaseString] isEqualToString: [self.entry.person lowercaseString]])
        {
			[entries addObject: entry];
		}
	}
	
	if ([entries count] > 1)
	{
		UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: @""
																 delegate: self
														cancelButtonTitle: NSLocalizedString(@"keyCancel", nil)
												   destructiveButtonTitle: nil
														otherButtonTitles: NSLocalizedString(@"keyMailAllDebtsOfPerson", nil),
									  NSLocalizedString(@"keyMailSingleDebt", nil),
									  nil];
		[actionSheet showInView: self.view];
		[actionSheet release];
	}
	else
	{
		[self actionSheet: nil didDismissWithButtonIndex: 1];
	}
}

- (void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex
{
    if (buttonIndex != 0 && buttonIndex != 1)
    {
        return;
    }
	
	// check, if a summary should be sent
	BOOL SEND_SUMMARY = (buttonIndex == 0);
    
	MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;
	[mailController setSubject: NSLocalizedString(@"keyMailSubject", nil)];
	
	// Determine which file to use
	NSString* fileName = nil;
		
	// send summary
	if (SEND_SUMMARY)
	{
		fileName = @"mail_multidebt";
	}
	else
	{
		if (DebtDirectionOut == mEntry.direction)
		{
			// yes 'mail_singledebt_in' is the right direction.. mail templates are named wrong
			fileName = @"mail_singledebt_in";
		}
		else
		{
			fileName = @"mail_singledebt_out";
		}
	}		
    
    // read file contents
    NSString* filePath = [[NSBundle mainBundle] pathForResource: fileName ofType: @"html"];
	NSMutableString* mailBodyString = [[[NSString stringWithContentsOfFile: filePath encoding: NSUTF8StringEncoding error: nil] mutableCopy] autorelease];

	if (!mailBodyString) {
        return;
    }
    
	// replace proxies with real data
	[mailBodyString replaceOccurrencesOfString: @"#person#"
                                    withString: mEntry.person
                                       options: 0
                                         range: NSMakeRange(0, [mailBodyString length])];
    
	// init formatter
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle: NSDateFormatterMediumStyle];
	
	// Send single debt email
	if (!SEND_SUMMARY)
	{
		if (mEntry.isLocationAvailable)
		{        
			// remove location placeholder
			[mailBodyString replaceOccurrencesOfString: @"#locationstart#"
											withString: @""
											   options: 0
												 range: NSMakeRange(0, [mailBodyString length])];
			
			[mailBodyString replaceOccurrencesOfString: @"#locationend#"
											withString: @""
											   options: 0
												 range: NSMakeRange(0, [mailBodyString length])];
			
			[mailBodyString replaceOccurrencesOfString: @"#latitude#" 
											withString: [NSString stringWithFormat: @"%0.5f", mEntry.location.latitude]
											   options: 0
												 range: NSMakeRange(0, [mailBodyString length])];
			
			[mailBodyString replaceOccurrencesOfString: @"#longitude#"
											withString: [NSString stringWithFormat: @"%0.5f", mEntry.location.longitude]
											   options: 0
												 range: NSMakeRange(0, [mailBodyString length])];
		}
		else
		{
			// remove google maps button
			NSRange start = [mailBodyString rangeOfString: @"#locationstart#"];
			NSRange end   = [mailBodyString rangeOfString: @"#locationend#"];
			
			NSRange rangeToDelete = NSUnionRange(start, end);
			[mailBodyString replaceCharactersInRange: rangeToDelete withString: @""];
		}
		
		
		NSString* valueString = [numberFormatter stringFromNumber: mEntry.value];
		[mailBodyString replaceOccurrencesOfString: @"#value#"
										withString: valueString
										   options: 0
											 range: NSMakeRange(0, [mailBodyString length])];
		
		NSString* dateString = [dateFormatter stringFromDate: mEntry.date];
		[mailBodyString replaceOccurrencesOfString: @"#date#"
										withString: dateString
										   options: 0
											 range: NSMakeRange(0, [mailBodyString length])];
		
		if(mEntry.description != nil && ![mEntry.description isEqualToString:@""])
		{
			[mailBodyString replaceOccurrencesOfString: @"#description#"
											withString: mEntry.description
											   options: 0
												 range: NSMakeRange(0, [mailBodyString length])];
		}
		else
		{
			// insert no description text
			[mailBodyString replaceOccurrencesOfString: @"#description#"
											withString: NSLocalizedString(@"keyNoDescription", nil)
											   options: 0
												 range: NSMakeRange(0, [mailBodyString length])];
		}
		
		UIImage * image = [UIImage imageWithContentsOfFile: mEntry.photofilename];
		if (image != nil)
		{
			NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
			[mailController addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"photo.jpg"];
		}
	}
	// Send summary debt
	else
	{
		NSMutableArray* entries = [NSMutableArray arrayWithCapacity: 10];
		
		// load all saved entries from user defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
		NSArray* savedEntryArray = [NSKeyedUnarchiver unarchiveObjectWithData: data];
		
		// find all entries of current person
		for (Entry* entry in savedEntryArray) {
			if ([[entry.person lowercaseString] isEqualToString: [self.entry.person lowercaseString]]) {
				[entries addObject: entry];
			}
		}
		
		// order by date
		[entries sortUsingDescriptors: [NSArray arrayWithObject: [NSSortDescriptor sortDescriptorWithKey: @"date" ascending: YES]]];
	
		CGFloat totalValue = 0.0;
		NSMutableString* debtList = [NSMutableString stringWithCapacity: 50];
		
		[debtList appendString: @"<table>\n"];
		
		for (Entry* entry in entries)
		{
			CGFloat value = [entry.value floatValue];
			if (entry.direction == DebtDirectionOut) {
				value *= -1;
			}
			totalValue += value;
			
			NSString* description = entry.description;
			if ([entry.description length] > 15)
			{
				description = [NSString stringWithFormat: @"%@…", [entry.description substringToIndex: 15]];
			}
			
			NSString* formattedValue = [numberFormatter stringFromNumber: [NSNumber numberWithFloat: ABS(value)]];
			if (value < 0) {
				formattedValue = [NSString stringWithFormat: @"-%@", formattedValue];
			}
			
			NSString* format = @"<tr><td><b>%@</b></td><td>%@</td><td>%@</td></tr>\n";
			NSString* entryString = [NSString stringWithFormat: format,
									 [dateFormatter stringFromDate: entry.date],
									 description,
									 formattedValue];
			
			[debtList appendString: entryString];
		}
		
		[debtList appendString: @"</table>"];
		
		[mailBodyString replaceOccurrencesOfString: @"#debt_list#"
										withString: debtList
										   options: 0
											 range: NSMakeRange(0, [mailBodyString length])];

		NSString* formattedValue = [numberFormatter stringFromNumber: [NSNumber numberWithFloat: ABS(totalValue)]];
		if (totalValue < 0) {
			formattedValue = [NSString stringWithFormat: @"-%@", formattedValue];
		}
		[mailBodyString replaceOccurrencesOfString: @"#total_value#"
										withString: formattedValue
										   options: 0
											 range: NSMakeRange(0, [mailBodyString length])];

	}
	
	[numberFormatter release];
	[dateFormatter release];
	
	if (![mEntry.email isEqualToString: @""])
	{
		[mailController setToRecipients:[NSArray arrayWithObjects: mEntry.email, nil]];
	}
    
	[mailController setMessageBody: mailBodyString isHTML: YES];
	[self presentModalViewController: mailController animated: YES];
	[mailController release];
}

/**
 *	Delegate of mail compose view controller
 *
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
	if (result == MFMailComposeResultSent)
	{
		//
	}
	
	[self dismissModalViewControllerAnimated:YES];
}


/**
 *	If user touches notification button
 *
 */
- (void)notificationButtonTouchHandler:(id)sender
{
	// show notification UI
	int infoBoxBottom = mDataBackgroundImageView.frame.size.height + mDataBackgroundImageView.frame.origin.y;
	NotificationView* notificationView = [[NotificationView alloc] initWithFrame: CGRectMake(0, infoBoxBottom, 320, self.view.frame.size.height-infoBoxBottom)];
	CGRect tmp = notificationView.frame;
	tmp.origin.y = self.view.frame.size.height - 30;
	notificationView.frame = tmp;
	notificationView.delegate = self;
	
	if ([mEntry isMemberOfClass: [Entry4 class]])
	{
		Entry4* entry = (Entry4*)mEntry;
		if (entry.notification != nil)
		{
			[notificationView showDeleteButton: YES];
			notificationView.selectedDate = entry.notification.fireDate;
		}
	}
	
	[self.view addSubview: notificationView];
	[notificationView release];
	
	[UIView beginAnimations: @"notificationView" context: nil];
	
	tmp.origin.y -= notificationView.frame.size.height - 30;
	notificationView.frame = tmp;
	
	[UIView commitAnimations];
}


/**
 *	If user touches delete button send notification
 *
 */
- (void)deleteButtonTouchHandler:(id)sender
{
	_deletionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"keyAttention", nil)
                                                    message:NSLocalizedString(@"keyDeleteAttentionMessage", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"keyCancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"keyOk", nil),
                          nil];
	[_deletionAlertView show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(_deletionAlertView != nil)
    {
        if ([_deletionAlertView isEqual:alertView] &&
            buttonIndex == 1)
        {
            [self deletionConfirmed];
        }
        
        [_deletionAlertView release];
        _deletionAlertView = nil;
    }
}

- (void) deletionConfirmed
{
	// send notification of deletion, list view controller is listening
	[[NSNotificationCenter defaultCenter] postNotificationName:@"detailDeletion" object:nil];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark NotificationView delegate

- (void) notificationView: (NotificationView*) notificationView touchedButtonWithType: (eNotificationViewButtonType) buttonType
{
	// cancel current notification
	if ([mEntry isMemberOfClass: [Entry4 class]])
	{
		Entry4* entry = (Entry4*)mEntry;
		if (buttonType != eNotificationViewButtonTypeCancel && entry.notification != nil)
		{
			[[UIApplication sharedApplication] cancelLocalNotification: entry.notification];
		}
	}
	
	switch (buttonType)
	{
		case eNotificationViewButtonTypeDelete:
		{
			if ([mEntry isMemberOfClass: [Entry4 class]])
			{
				Entry4* entry = (Entry4*)mEntry;
				entry.notification = nil;
			}
			break;
		}
		case eNotificationViewButtonTypeSave:
		{
			if (notificationView == nil) {
				break;
			}
			
			// only save notifications in the future
			if ([notificationView.selectedDate timeIntervalSinceNow] < 0) {
				break;
			}
			
			NSString* text = NSLocalizedString(@"keyFooterOutPattern", nil);
			if (mEntry.direction == DebtDirectionIn)
			{
				text = NSLocalizedString(@"keyFooterInPattern", nil);
			}
			
			// update value label
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[numberFormatter setMaximumFractionDigits:2];
			[numberFormatter setMinimumFractionDigits:2];
			
			text = [text stringByReplacingOccurrencesOfString: @"#person#" withString: mEntry.person];
			text = [text stringByReplacingOccurrencesOfString: @"#value#" withString: [numberFormatter stringFromNumber:mEntry.value]];
			
			[numberFormatter release];
			
			if ([mEntry.description length] > 0)
			{
				text = [text stringByAppendingFormat: @"\n%@: %@", NSLocalizedString(@"keyDescription", nil), mEntry.description];
			}
			
			// UILocalNotification
			id localNotification = [[LocalNotificationCenter sharedInstance] scheduleLocalNotificationWithAlertBody: text
																								 andIconBadgeNumber: 0
																									   andSoundName: nil
																										andFireDate: notificationView.selectedDate
																										andTimeZone: [NSTimeZone defaultTimeZone]
																										andUserInfo: [NSDictionary dictionaryWithObject: mEntry.entryId forKey: @"entryId"]];
			if ([mEntry isMemberOfClass: [Entry4 class]])
			{
				Entry4* entry = (Entry4*)mEntry;
				entry.notification = localNotification;
			}
			break;
		}
        default:
            break;
	}
	
	if (notificationView != nil) {
		[notificationView dismissAnimated];
	}
	
	// Save Entry
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *data = [defaults objectForKey:kENTRY_USER_DEFAULTS_KEY];
	
	if (data == nil)
		return;
	
	NSMutableArray *savedEntryArray = [(NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
	
	for (uint i = 0; i < savedEntryArray.count; i++)
	{
		Entry* savedEntry = [savedEntryArray objectAtIndex: i];
		if ([mEntry.entryId isEqualToString: savedEntry.entryId])
		{
			[savedEntryArray replaceObjectAtIndex: i withObject: mEntry];	
			break;
		}
	}
	
	// Save the new entry array
	data = [NSKeyedArchiver archivedDataWithRootObject: savedEntryArray];
	[defaults setObject: data forKey: kENTRY_USER_DEFAULTS_KEY];
	[savedEntryArray release];
	
	// update view
	[self update];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{	
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
	if(!annotationView)
    {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
        annotationView.enabled = NO;
    }
	
    return annotationView;
}


#pragma mark -
#pragma mark other buttons

/**
 *	If user touches back button
 *
 */
- (void)backButtonClickHandler:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

/**
 *	If user touches edit button
 *
 */
- (void)editButtonClickHandler:(id)sender
{
	AddViewController* addViewController = [[AddViewController alloc] initWithFrame:CGRectMake(0, 0, SCREENSIZE.width, SCREENSIZE.height-kSTATUS_BAR_HEIGHT) andInitialEntry: mEntry];
	addViewController.detailViewController = self;
	[addViewController setEditMode: EditModeOn];
	[self.navigationController pushViewController:addViewController animated:YES];
	[addViewController recreateAddViews];
	[addViewController release];
}

- (void)photoTouchHandler:(id)sender
{
	BOOL scalingFromSmallToBig = CGRectGetWidth(mPhotoButton.frame) == CGRectGetWidth(mOriginalPhotoFrame);
	CGAffineTransform transform;
	
	// setup
	if (scalingFromSmallToBig)
	{
		mPhotoArrow.alpha = 1.0;
		[mPhotoArrow removeFromSuperview];
		transform = CGAffineTransformConcat(CGAffineTransformMakeScale(2.45, 2.45), CGAffineTransformMakeTranslation(-75,75));
	}
	else
	{
		mPhotoArrow.alpha = 0.0;
		[self.view addSubview: mPhotoArrow];
		//[mPhotoArrow release]; do not release - we have to re-add it to subview again
		transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 1.0), CGAffineTransformMakeTranslation(0,0));
	}
	
	// animate
	[UIView beginAnimations: @"photobtn" context: nil];
	[UIView setAnimationDuration: 0.15];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	
	[mPhotoButton setTransform: transform];
	mPhotoArrow.alpha = 1.0;
	
	[UIView commitAnimations];
}


@end
