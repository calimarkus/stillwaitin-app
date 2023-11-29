//
//  AddItemView.m
//  StillWaitin
//
//  Created by devmob on 24.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddItemView.h"
#import "UILabel+MultilineFontAdjustment.h"

@implementation AddItemView

- (id) initWithFrame: (CGRect) frame
{
	if ( (self = [super initWithFrame: frame]) )
	{
		[self addUi];
	}
	return self;
}

- (void) setAddViewController: (AddViewController*) viewController
{
	mAddViewController = viewController;
}

- (void) setEntry: (Entry*) entry
{
	// recalculate saved value
	int value = [entry.value floatValue] * 100;

	int minimumFractionDigits = (value % 100) == 0 ? 0 : 2;
	minimumFractionDigits = (value % 10) == 0 ? MIN(1, minimumFractionDigits) : minimumFractionDigits;

	value = value / ( pow(10, 2 - minimumFractionDigits) );

	mNumberFormatter.minimumFractionDigits = minimumFractionDigits;
	mNumberFormatter.maximumFractionDigits = minimumFractionDigits;
	mNumberFormatter.alwaysShowsDecimalSeparator = minimumFractionDigits > 0 ? YES : NO;

	mCurrentValue = value;

	double currencyValue = 0;
	if (YES == mNumberFormatter.alwaysShowsDecimalSeparator)
	{
		currencyValue = mCurrentValue / ( pow(10, mNumberFormatter.minimumFractionDigits) );
	}
	else
	{
		currencyValue = mCurrentValue;
	}

	mValueLabel.text = [mNumberFormatter stringFromNumber:[NSNumber numberWithDouble: currencyValue]];
	[mValueLabel adjustMultilineFontsize: 52 minimum: 12];

	// update debt direction indicator and debt switch button
	if (DebtDirectionIn == mAddViewController.temporaryEntry.direction)
	{
		[mDebtDirectionSwitchButton setSelected: YES];

		[mDebtDirectionIndicatorImageView setImage:[UIImage imageNamed: @"add_betrag_indicator_green.png"]];
	}
	else
	{
		[mDebtDirectionSwitchButton setSelected: NO];

		[mDebtDirectionIndicatorImageView setImage:[UIImage imageNamed: @"add_betrag_indicator_red.png"]];
	}

	// update photo switch button
    [self photoSet: entry.hasPhoto];

	// update description switch button
    BOOL descriptionSet = ![@"" isEqualToString: entry.description];
    [self descriptionSet: descriptionSet];
    
	// update location button
    [self locationSet: entry.isLocationAvailable];
}

#pragma mark add ui

- (void) addUi
{
	// add input ui
	[self addInputUi];

	// add OK button which is used to complete this add phase
	[self addOkButtonUi];

	// add button to write a description
	[self addAddDescriptionButtonUi];

	// add debt direction switchable button to determine whether the user owes someone or lent someone
	[self addDebtDirectionSwitchButtonUi];
    
	// add button to take a photo
	[self addPhotoButtonUi];
    
	// add button to edit location
	[self addEditLocationButtonUi];

	// add debt direction indicator which shows the current direction state
	[self addDebtDirectionIndicatorUi];

	// add ui of number keyboard
	[self addNumberKeyboardUi];
}

- (void) addInputUi
{
	// add value input background
	mValueBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"add_betrag_bg_73.png"]];
	mValueBackgroundImageView.frame = CGRectMake(0, 0, 320, 73);
	[self addSubview: mValueBackgroundImageView];

	// add value input
	mValueLabel = [[UILabel alloc] initWithFrame: CGRectMake(18, 0, 204, 73)];
	mValueLabel.textAlignment = UITextAlignmentCenter;
	mValueLabel.backgroundColor = [UIColor clearColor];
	mValueLabel.font = [UIFont boldSystemFontOfSize: 52];
	mValueLabel.textColor = kCOLOR_GREEN_MAIN;
	mValueLabel.shadowColor = kCOLOR_SHADOW_MAIN;
	mValueLabel.shadowOffset = kSIZE_SHADOW_MAIN;
	mValueLabel.text = @"";
	[self addSubview: mValueLabel];

	// @TODO: use only one formatter in whole app, no redundant things!
	mNumberFormatter = [[NSNumberFormatter alloc] init];
	[mNumberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
	[mNumberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	[mNumberFormatter setMaximumFractionDigits: 0];
	[mNumberFormatter setMinimumFractionDigits: 0];

	mCurrentValue = 0;
	mValueLabel.text = [mNumberFormatter stringFromNumber:[NSNumber numberWithInt: mCurrentValue]];
	[mValueLabel adjustMultilineFontsize: 52 minimum: 12];
}

#pragma mark shrink ui

- (void) shrinkUi
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.4];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];

	mNumberKeyboardView.alpha = 0;
	mPhotoButton.alpha = 0;
	mAddDescriptionButton.alpha = 0;
	mOkButton.alpha = 0;

	[UIView commitAnimations];
}

- (void) expandUi
{
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 0.4];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseOut];

	mNumberKeyboardView.alpha = 1;
	mPhotoButton.alpha = 1;
	mAddDescriptionButton.alpha = 1;
	mOkButton.alpha = 1;

	[UIView commitAnimations];
}

- (void) addOkButtonUi
{
	mOkButton = [UIButton buttonWithType: UIButtonTypeCustom];
	mOkButton.frame = CGRectMake(self.frame.size.width - 68 - 12,
	                             self.frame.size.height - 67,
	                             68,
	                             81);
	[mOkButton setImage:[UIImage imageNamed: @"add_btn_ok.png"] forState: UIControlStateNormal];
	[mOkButton addTarget: self action: @selector(okButtonTouchHandler:) forControlEvents: UIControlEventTouchUpInside];

	[self addSubview: mOkButton];
}

- (void) addAddDescriptionButtonUi
{
	CGRect frame = CGRectMake(self.frame.size.width - 80, 101 + 52 + 5, 68, 52);
	mAddDescriptionButton = [[AddDescriptionButton alloc] initWithFrame: frame];
	[mAddDescriptionButton addTarget: self action: @selector(addDescriptionButtonTouchHandler:) forControlEvents: UIControlEventTouchUpInside];

	[self addSubview: mAddDescriptionButton];
}

- (void) addNumberKeyboardUi
{
	mNumberKeyboardView = [[NumberKeyboardView alloc] initWithFrame: CGRectMake(12,
	                                                                            76,
	                                                                            211,
	                                                                            288)];
	mNumberKeyboardView.delegate = self;
	[self addSubview: mNumberKeyboardView];
}

- (void) addDebtDirectionSwitchButtonUi
{
	mDebtDirectionSwitchButton = [[DebtDirectionSwitchButton alloc] initWithFrame: CGRectMake(self.frame.size.width - 85, 17, 76, 41)];
	[mDebtDirectionSwitchButton addTarget: self action: @selector(debtDirectionSwitchButtonTouchHandler:) forControlEvents: UIControlEventTouchDown];
	[self addSubview: mDebtDirectionSwitchButton];
}

- (void) addPhotoButtonUi
{
	mPhotoButton = [[AddPhotoButton alloc] initWithFrame: CGRectMake(self.frame.size.width - 80, 101, 68, 52)];

	[mPhotoButton setSelected: mAddViewController.temporaryEntry.photofilename != nil];

	[mPhotoButton addTarget: self action: @selector(photoButtonButtonTouchHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: mPhotoButton];
}

- (void) addEditLocationButtonUi
{
	mEditLocationButton = [[EditLocationButton alloc] initWithFrame: CGRectMake(self.frame.size.width - 80, 101 + 52*2 + 5*2, 68, 52)];
    
    [mEditLocationButton setSelected: mAddViewController.temporaryEntry.isLocationAvailable];
    
    [mEditLocationButton addTarget: self action: @selector(editLocationButtonTouchHandler:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: mEditLocationButton];
}

- (void) addDebtDirectionIndicatorUi
{
	mDebtDirectionIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"add_betrag_indicator_green.png"]];
	[self addSubview: mDebtDirectionIndicatorImageView];
}

#pragma mark ok touch handling

- (void) okButtonTouchHandler: (id) sender
{
	[self complete];
}

#pragma mark add description touch handling

- (void) addDescriptionButtonTouchHandler: (id) sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName: @"addDescriptionButtonTouch" object: nil];
}

#pragma mark debt direction

- (void) debtDirectionSwitchButtonTouchHandler: (id) sender
{
	mAddViewController.temporaryEntry.direction = mAddViewController.temporaryEntry.direction == DebtDirectionIn ? DebtDirectionOut : DebtDirectionIn;

	if (DebtDirectionIn == mAddViewController.temporaryEntry.direction)
	{
		[mDebtDirectionSwitchButton setSelected: YES];

		[mDebtDirectionIndicatorImageView setImage:[UIImage imageNamed: @"add_betrag_indicator_green.png"]];
	}
	else
	{
		[mDebtDirectionSwitchButton setSelected: NO];

		[mDebtDirectionIndicatorImageView setImage:[UIImage imageNamed: @"add_betrag_indicator_red.png"]];
	}
}

#pragma mark photo

- (void) photoButtonButtonTouchHandler: (id) sender
{
	// send notification to create photo view
	[[NSNotificationCenter defaultCenter] postNotificationName: @"addPhotoTouch" object: nil];
}

#pragma mark location

- (void) editLocationButtonTouchHandler: (id) sender
{
	// send notification
	[[NSNotificationCenter defaultCenter] postNotificationName: @"editLocationTouch" object: nil];
}

#pragma mark button state setter

/*
 *	Set state of photo button.
 *
 */
- (void) photoSet: (BOOL) boolean
{
	[mPhotoButton setSelected: boolean];
}

/*
 *	Set state of description button.
 *
 */
- (void) descriptionSet: (BOOL) boolean
{
	[mAddDescriptionButton setSelected: boolean];
}


/*
 *	Set state of location button.
 *
 */
- (void) locationSet: (BOOL) boolean
{
    [mEditLocationButton setSelected: boolean];
}

#pragma mark number keyboard delegate

/**
 *	If a number was clicked add it to current value
 *
 */
- (void) evaluateNumber: (NSInteger) number
{
	// if more than two digits after decimal point are shown return with no action
	if (1 < mNumberFormatter.minimumFractionDigits)
		return;if (999999.99 < (mCurrentValue * 10) && NO == mNumberFormatter.alwaysShowsDecimalSeparator)
		return;mCurrentValue *= 10;
	mCurrentValue += number;

	double currencyValue = 0;
	if (YES == mNumberFormatter.alwaysShowsDecimalSeparator)
	{
		mNumberFormatter.minimumFractionDigits++;
		currencyValue = mCurrentValue / ( pow(10, mNumberFormatter.minimumFractionDigits) );
	}
	else
	{
		currencyValue = mCurrentValue;
	}

	mValueLabel.text = [mNumberFormatter stringFromNumber:[NSNumber numberWithDouble: currencyValue]];
	[mValueLabel adjustMultilineFontsize: 52 minimum: 12];

	// save value from value label string
	mAddViewController.temporaryEntry.value = [mNumberFormatter numberFromString: mValueLabel.text];
}

/**
 *	If delete button was clicked remove last number or decimal point
 *
 */
- (void) realizeDeletion
{
	double currencyValue = mCurrentValue;

	// if no numbers are shown after decimal point, remove it
	if (0 == mNumberFormatter.minimumFractionDigits && YES == mNumberFormatter.alwaysShowsDecimalSeparator)
	{
		mNumberFormatter.alwaysShowsDecimalSeparator = NO;
	}
	else
	{
		// remove the last number (floor the value)
		currencyValue = mCurrentValue = floor(mCurrentValue / 10);

		// set number of digits after decimal point
		if (0 < mNumberFormatter.minimumFractionDigits)
			mNumberFormatter.minimumFractionDigits--;if (YES == mNumberFormatter.alwaysShowsDecimalSeparator)
		{
			currencyValue = mCurrentValue / ( pow(10, mNumberFormatter.minimumFractionDigits) );
		}
	}

	mValueLabel.text = [mNumberFormatter stringFromNumber:[NSNumber numberWithDouble: currencyValue]];
	[mValueLabel adjustMultilineFontsize: 52 minimum: 12];

	// save value from value label string
	mAddViewController.temporaryEntry.value = [mNumberFormatter numberFromString: mValueLabel.text];
}

/**
 *	If decimal point was clicked show decimal seperator
 *
 */
- (void) realizePoint;
{
	// if decimal point was added, do not add another one
	if (YES == mNumberFormatter.alwaysShowsDecimalSeparator)
		return;
	
	[mNumberFormatter setAlwaysShowsDecimalSeparator: YES];
	mValueLabel.text = [mNumberFormatter stringFromNumber:[NSNumber numberWithLong: mCurrentValue]];
	[mValueLabel adjustMultilineFontsize: 52 minimum: 12];
}

#pragma mark complete

- (void) complete
{
	// save type
	mAddViewController.temporaryEntry.type = DebtTypeMoney;

	// send notification of completion, add view controller is listening
	[[NSNotificationCenter defaultCenter] postNotificationName: @"addItemComplete" object: nil];
}

#pragma mark memory management

- (void) dealloc
{
	[mValueLabel release];
	[mValueBackgroundImageView release];
	[mNumberKeyboardView release];
	[mDebtDirectionSwitchButton release];
	[mPhotoButton release];
	[mDebtDirectionIndicatorImageView release];
	[mNumberFormatter release];
	[mAddDescriptionButton release];

	[super dealloc];
}

@end