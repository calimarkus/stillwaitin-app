    //
//  SettingsViewController.m
//  StillWaitin
//
//  Created by devmob on 14.10.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "SettingsViewController.h"

#import "BackButton.h"
#import "NavButton.h"
#import "RateAppAlert.h"
#import "PasswordViewController.h"

#import <QuartzCore/QuartzCore.h>



@implementation SettingsViewController

@synthesize listViewController = mListViewController;

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super init])
	{
		mViewRectangle = frame;
    }
	
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:mViewRectangle];
	
	int topmargin   = 90;
	int btnfontsize = 15;
	
	// Background Image
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_bg.png"]];
    backgroundImageView.frameBottom = mViewRectangle.size.height + kSTATUS_BAR_HEIGHT;
	[self.view addSubview:backgroundImageView];
	[backgroundImageView release];
	
	// add navbar background image
	UIImageView* navigationBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_bg_empty.png"]];
	[self.view addSubview: navigationBarImageView];
	[navigationBarImageView release];
	
	// add navbar back button
	BackButton *backButton = [BackButton buttonAtPoint: CGPointMake(6, 9)];
	[backButton addTarget:self action:@selector(backButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	// navbar label
	int margin = 10;
	float left = backButton.frame.size.width + backButton.frame.origin.x + margin;
	float width = mViewRectangle.size.width - left*2;
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(floor(left), 0, width, 47)];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	titleLabel.shadowColor = kCOLOR_SHADOW_DETAIL_DATE;
	titleLabel.shadowOffset = kSIZE_SHADOW_DETAIL_DATE;
	titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	titleLabel.text = NSLocalizedString(@"keySettingsTitle", nil);
	[self.view addSubview:titleLabel];
	[titleLabel release];
	
	// Sorting Buttons
	UIImage* sortImageA = [UIImage imageNamed: @"btn_settings_A.png"];
	UIImage* sortImageB = [UIImage imageNamed: @"btn_settings_A_selected.png"];
	mSortButtonA = [UIButton buttonWithType: UIButtonTypeCustom];
	mSortButtonA.frame = CGRectMake((mViewRectangle.size.width-sortImageA.size.width)/2.0, topmargin+25, sortImageA.size.width, sortImageA.size.height);
	[mSortButtonA setImage: sortImageA forState: UIControlStateNormal];
	[mSortButtonA setImage: sortImageB forState: UIControlStateSelected];
	[mSortButtonA addTarget:self action:@selector(sortButtonClickHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: mSortButtonA];
	
	BOOL active = [[NSUserDefaults standardUserDefaults] boolForKey: kKEY_SORTING_ORDER_ALPHABETICALLY];
	if (active) {
		mSortButtonA.selected = YES;
	}
	
	sortImageA = [UIImage imageNamed: @"btn_settings_B.png"];
	sortImageB = [UIImage imageNamed: @"btn_settings_B_selected.png"];
	mSortButtonB = [UIButton buttonWithType: UIButtonTypeCustom];
	mSortButtonB.frame = CGRectMake((mViewRectangle.size.width-sortImageA.size.width)/2.0, topmargin+70, sortImageA.size.width, sortImageA.size.height);
	[mSortButtonB setImage: sortImageA forState: UIControlStateNormal];
	[mSortButtonB setImage: sortImageB forState: UIControlStateSelected];
	[mSortButtonB addTarget:self action:@selector(sortButtonClickHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: mSortButtonB];
	
	if (!active) {
		mSortButtonB.selected = YES;
	}
	
	// Label
	
	UILabel* sortingTitle = [[UILabel alloc] initWithFrame: mSortButtonA.frame];
	sortingTitle.center = CGPointMake(mViewRectangle.size.width/2.0, topmargin);
	sortingTitle.text = NSLocalizedString(@"keySortingTitle", nil);
	sortingTitle.backgroundColor = [UIColor clearColor];
	sortingTitle.textAlignment = UITextAlignmentCenter;
	sortingTitle.font = [UIFont boldSystemFontOfSize: 16];
	sortingTitle.textColor = [UIColor colorWithWhite: 0.9 alpha: 1.0];
	sortingTitle.shadowOffset = CGSizeMake(-1, -1);
	sortingTitle.shadowColor = [UIColor darkGrayColor];
	[self.view addSubview: sortingTitle];
	[sortingTitle release];
	
	CGRect aFrame = mSortButtonA.frame;
	aFrame.origin.x += 20;
	aFrame.size.width -= 40;
	
	UILabel* sortingMethodA = [[UILabel alloc] initWithFrame: aFrame];
	sortingMethodA.text = NSLocalizedString(@"keySortingMethodA", nil);
	sortingMethodA.backgroundColor = [UIColor clearColor];
	sortingMethodA.textAlignment = UITextAlignmentLeft;
	sortingMethodA.font = [UIFont boldSystemFontOfSize: btnfontsize];
	sortingMethodA.textColor = [UIColor colorWithWhite: 0.8 alpha: 1.0];
	[self.view addSubview: sortingMethodA];
	[sortingMethodA release];
	
	aFrame = mSortButtonB.frame;
	aFrame.origin.x += 20;
	aFrame.size.width -= 40;
	
	UILabel* sortingMethodB = [[UILabel alloc] initWithFrame: aFrame];
	sortingMethodB.text = NSLocalizedString(@"keySortingMethodB", nil);
	sortingMethodB.backgroundColor = [UIColor clearColor];
	sortingMethodB.textAlignment = UITextAlignmentLeft;
	sortingMethodB.font = [UIFont boldSystemFontOfSize: btnfontsize];
	sortingMethodB.textColor = [UIColor colorWithWhite: 0.8 alpha: 1.0];
	[self.view addSubview: sortingMethodB];
	[sortingMethodB release];
	
	// Show Total Sum Button
	UIImage* btnImage = [UIImage imageNamed: @"btn_settings_C_clear.png"];
	UIButton * showTotalSumButton = [UIButton buttonWithType: UIButtonTypeCustom];
	showTotalSumButton.frame = CGRectMake((mViewRectangle.size.width-btnImage.size.width)/2.0, topmargin+130, btnImage.size.width, btnImage.size.height);
	[showTotalSumButton setImage: btnImage forState: UIControlStateNormal];
	[showTotalSumButton setImage: [UIImage imageNamed: @"btn_settings_C_selected.png"] forState: UIControlStateSelected];
	[showTotalSumButton addTarget:self action:@selector(showTotalSumButton:) forControlEvents: UIControlEventTouchUpInside];
	[showTotalSumButton setSelected: [[NSUserDefaults standardUserDefaults] boolForKey: kKEY_SETTING_SHOW_TOTALSUM]];
	[self.view addSubview: showTotalSumButton];
	
	aFrame = showTotalSumButton.frame;
	aFrame.origin.x += 20;
	aFrame.size.width -= 40;
	
	UILabel* showTotalSumLabel = [[UILabel alloc] initWithFrame: aFrame];
	showTotalSumLabel.text = NSLocalizedString(@"keyShowTotalSum", nil);
	showTotalSumLabel.backgroundColor = [UIColor clearColor];
	showTotalSumLabel.textAlignment = UITextAlignmentLeft;
	showTotalSumLabel.font = [UIFont boldSystemFontOfSize: btnfontsize];
	showTotalSumLabel.textColor = [UIColor colorWithWhite: 0.8 alpha: 1.0];
	[self.view addSubview: showTotalSumLabel];
	[showTotalSumLabel release];
	
	// Use Password Button
	btnImage = [UIImage imageNamed: @"btn_settings_C.png"];
	UIButton * usePasswordButton = [UIButton buttonWithType: UIButtonTypeCustom];
	usePasswordButton.frame = CGRectMake((mViewRectangle.size.width-btnImage.size.width)/2.0, topmargin+185, btnImage.size.width, btnImage.size.height);
	[usePasswordButton setImage: btnImage forState: UIControlStateNormal];
	[usePasswordButton addTarget:self action:@selector(passwordButtonClickHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: usePasswordButton];
	
	aFrame = usePasswordButton.frame;
	aFrame.origin.x += 20;
	aFrame.size.width -= 40;
	
	UILabel* usePasswordLabel = [[UILabel alloc] initWithFrame: aFrame];
	usePasswordLabel.text = NSLocalizedString(@"keySetupPassword", nil);
	usePasswordLabel.backgroundColor = [UIColor clearColor];
	usePasswordLabel.textAlignment = UITextAlignmentLeft;
	usePasswordLabel.font = [UIFont boldSystemFontOfSize: btnfontsize];
	usePasswordLabel.textColor = [UIColor colorWithWhite: 0.8 alpha: 1.0];
	[self.view addSubview: usePasswordLabel];
	[usePasswordLabel release];
	
	// Rate App Button
	btnImage = [UIImage imageNamed: @"btn_settings_C.png"];
	UIButton * rateAppButton = [UIButton buttonWithType: UIButtonTypeCustom];
	rateAppButton.frame = CGRectMake((mViewRectangle.size.width-btnImage.size.width)/2.0, topmargin+240, btnImage.size.width, btnImage.size.height);
	[rateAppButton setImage: btnImage forState: UIControlStateNormal];
	[rateAppButton addTarget:self action:@selector(rateButtonClickHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: rateAppButton];
	
	aFrame = rateAppButton.frame;
	aFrame.origin.x += 20;
	aFrame.size.width -= 40;
	
	UILabel* rateAppLabel = [[UILabel alloc] initWithFrame: aFrame];
	rateAppLabel.text = NSLocalizedString(@"keyRateApp", nil);
	rateAppLabel.backgroundColor = [UIColor clearColor];
	rateAppLabel.textAlignment = UITextAlignmentLeft;
	rateAppLabel.font = [UIFont boldSystemFontOfSize: btnfontsize];
	rateAppLabel.textColor = [UIColor colorWithWhite: 0.8 alpha: 1.0];
	[self.view addSubview: rateAppLabel];
	[rateAppLabel release];
}


- (void) showListView
{
	[self.navigationController pushViewController: mListViewController animated: YES];
}


// User did touch back-button
- (void) backButtonClickHandler:(id)sender
{
	[self showListView];
}

// User did touch sort-button
- (void) sortButtonClickHandler:(id)sender
{
	BOOL buttonAselected = NO;
	if (sender == mSortButtonA) {
		
		buttonAselected = YES;
	}
	
	mSortButtonA.selected = buttonAselected;
	mSortButtonB.selected = !buttonAselected;
	
	[[NSUserDefaults standardUserDefaults] setBool: buttonAselected forKey: kKEY_SORTING_ORDER_ALPHABETICALLY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


// User did touch totalSum-button
- (void) showTotalSumButton: (UIButton*) sender
{	
	BOOL showTotalSum = [[NSUserDefaults standardUserDefaults] boolForKey: kKEY_SETTING_SHOW_TOTALSUM];
	[[NSUserDefaults standardUserDefaults] setBool: !showTotalSum forKey: kKEY_SETTING_SHOW_TOTALSUM];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	sender.selected = !showTotalSum;
}


// User did touch password-button
- (void) passwordButtonClickHandler: (UIButton*) sender
{
	[PasswordViewController showOnViewControllerWithEditModeEnabled: self];
}


// User did touch rate-button
- (void) rateButtonClickHandler:(id)sender
{
	[RateAppAlert showWithMessageKey:@"keyOpenAppStore"];
}

@end
