//
//  AddDateView.m
//  StillWaitin
//
//  Created by devmob on 06.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddDateView.h"

@implementation AddDateView

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

	mDatePicker.date = mAddViewController.temporaryEntry.date;
}

#pragma mark add ui

- (void) addUi
{
	// add date picker filled with current date
	mDatePicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, 0, 320, 216)];
	mDatePicker.datePickerMode = UIDatePickerModeDate;
	mDatePicker.hidden = NO;
	mDatePicker.date = [NSDate date];
	mDatePicker.highlighted = NO;
  mDatePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
  mDatePicker.backgroundColor = [UIColor whiteColor];
	[mDatePicker addTarget: mAddViewController
	 action: @selector(changeDateLabel:)
	 forControlEvents: UIControlEventValueChanged];

	[self addSubview: mDatePicker];

	// add date picker mask
	mDatePickerMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"datepicker_overlay.png"]];
	[self addSubview: mDatePickerMask];

	// add complete button
	mDateCompleteButton = [UIButton buttonWithType: UIButtonTypeCustom];
	mDateCompleteButton.frame = CGRectMake(82,
	                                       240,
	                                       156,
	                                       33);
	[mDateCompleteButton setImage:[UIImage imageNamed: @"datepicker_okay_btn.png"] forState: UIControlStateNormal];
	[mDateCompleteButton addTarget: self action: @selector(completeButtonTouchHandler:) forControlEvents: UIControlEventTouchUpInside];

	[self addSubview: mDateCompleteButton];
}

- (void) completeButtonTouchHandler: (id) sender
{
	mAddViewController.temporaryEntry.date = mDatePicker.date;

	// send notification of completion, add view controller is listening
	[[NSNotificationCenter defaultCenter] postNotificationName: @"addDateComplete" object: nil];
}

- (void) dealloc
{
	[mDatePicker release];
	[mDatePickerMask release];

	[super dealloc];
}

@end
