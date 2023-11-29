//
//  NotificationView.m
//  StillWaitin
//
//  Created by devmob on 05.12.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

@synthesize delegate = mDelegate;
@dynamic selectedDate;

#pragma mark -
#pragma mark setup

- (id) initWithFrame: (CGRect) rect
{
	self = [super initWithFrame: rect];
	if (self != nil)
	{
		self.backgroundColor = [UIColor colorWithRed: 18/255.0 green: 21/255.0 blue: 22/255.0 alpha: 1.0];
		
		// Date Picker
		UIDatePicker* datePicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, 30, 320, 216)];
		datePicker.tag = 999;
		datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        datePicker.minimumDate = [NSDate date];
		[self addSubview: datePicker];
		[datePicker release];
		
		//check, if AM/PM Symbol is used
		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle: NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle: NSDateFormatterFullStyle];
		[dateFormatter setLocale: [NSLocale currentLocale]];
		// search for 'a' character, because a stands for 'AM/PM' and similar
		BOOL has24HourFormat = [[dateFormatter dateFormat] rangeOfString: @"a"].location == NSNotFound;
		[dateFormatter release];
		
		// set width for overlay images
		CGFloat marginWidth = 24;
		if (has24HourFormat) {
			marginWidth = 48;
		}
		CGFloat centerWidth = 320 - marginWidth*2;
		
		// Overlay Image
		UIImage* overlayLeft	= [[UIImage imageNamed: @"notification_overlay_l.png"] stretchableImageWithLeftCapWidth: 13 topCapHeight: 0];
		UIImage* overlayCenter	= [[UIImage imageNamed: @"notification_overlay_c.png"] stretchableImageWithLeftCapWidth: 0 topCapHeight: 0];
		UIImage* overlayRight	= [[UIImage imageNamed: @"notification_overlay_r.png"] stretchableImageWithLeftCapWidth: 13 topCapHeight: 0];
		
		UIImageView* imageViewLeft = [[UIImageView alloc] initWithImage: overlayLeft];
		imageViewLeft.tag = 777;
		imageViewLeft.frame = CGRectMake(0, 0, marginWidth, imageViewLeft.frame.size.height);
		[self addSubview: imageViewLeft];
		[imageViewLeft release];
		
		UIImageView* imageViewCenter = [[UIImageView alloc] initWithImage: overlayCenter];
		imageViewCenter.frame = CGRectMake(marginWidth, 0, centerWidth, imageViewCenter.frame.size.height);
		[self addSubview: imageViewCenter];
		[imageViewCenter release];
		
		UIImageView* imageViewRight = [[UIImageView alloc] initWithImage: overlayRight];
		imageViewRight.frame = CGRectMake(marginWidth+centerWidth, 0, marginWidth, imageViewRight.frame.size.height);
		[self addSubview: imageViewRight];
		[imageViewRight release];
		
		// Title
		UIImage* iconImage = [UIImage imageNamed:@"detail_timer_btn.png"];
		UILabel* title = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, 300, 30)];
		title.font = [UIFont systemFontOfSize: 12];
		title.textAlignment = UITextAlignmentCenter;
		title.text = NSLocalizedString(@"keyNotification", nil);
		[title sizeToFit];
		title.center = self.center;
		title.frame = CGRectMake(floor(title.frame.origin.x + (iconImage.size.width+4)/2.0), 0, title.frame.size.width, 30);
		title.backgroundColor = [UIColor clearColor];
		[self addSubview: title];
		[title release];
		
		UIImageView* icon = [[UIImageView alloc] initWithImage: iconImage];
		icon.contentMode = UIViewContentModeCenter;
		icon.center = title.center;
		icon.frame = CGRectMake(floor(title.frame.origin.x - title.frame.size.width/2.0 - 4 + (iconImage.size.width+4)/2.0), 1, iconImage.size.width, 29);
		[self addSubview: icon];
		[icon release];
		
		// Cancel button
		UIImage* bgImage = [UIImage imageNamed:@"btn_notification_left.png"];
		mCancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		mCancelButton.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
		[mCancelButton setBackgroundImage: bgImage forState: UIControlStateNormal];
		[mCancelButton setImage:[UIImage imageNamed:@"notification_icon_cancel.png"] forState:UIControlStateNormal];
		[mCancelButton setTitle: [NSString stringWithFormat: @"  %@", NSLocalizedString(@"keyCancel", nil)] forState:UIControlStateNormal];
		[mCancelButton setTitleColor:kCOLOR_GREEN_MAIN forState:UIControlStateNormal];
		[mCancelButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
		[mCancelButton addTarget:self action:@selector(cancelButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
		
		// Delete button
		bgImage = [UIImage imageNamed:@"btn_notification_center.png"];
		mDeleteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		mDeleteButton.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
		[mDeleteButton setBackgroundImage: bgImage forState: UIControlStateNormal];
		[mDeleteButton setImage:[UIImage imageNamed:@"notification_icon_delete.png"] forState:UIControlStateNormal];
		[mDeleteButton setTitle: [NSString stringWithFormat: @"  %@", NSLocalizedString(@"keyDelete", nil)] forState:UIControlStateNormal];
		[mDeleteButton setTitleColor:kCOLOR_GREEN_MAIN forState:UIControlStateNormal];
		[mDeleteButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
		[mDeleteButton addTarget:self action:@selector(deleteButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
		
		// Save button
		bgImage = [UIImage imageNamed:@"btn_notification_right.png"];
		mSaveButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		mSaveButton.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
		[mSaveButton setBackgroundImage: bgImage forState: UIControlStateNormal];
		[mSaveButton setImage: [UIImage imageNamed:@"notification_icon_ok.png"] forState: UIControlStateNormal];
		[mSaveButton setTitle: [NSString stringWithFormat: @"  %@", NSLocalizedString(@"keySave", nil)] forState: UIControlStateNormal];
		[mSaveButton setTitleColor:kCOLOR_GREEN_MAIN forState: UIControlStateNormal];
		[mSaveButton.titleLabel setFont:[UIFont systemFontOfSize: 12]];
		[mSaveButton addTarget:self action:@selector(saveButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview: mCancelButton];
		[self addSubview: mSaveButton];
		[self showDeleteButton: NO];
	}
	return self;
}


- (void) dealloc
{
	[mCancelButton release];
	[mDeleteButton release];
	[mSaveButton release];
	[super dealloc];
}


- (void) showDeleteButton: (BOOL) showDeleteButton
{	
	CGFloat width = self.frame.size.width;
	CGFloat btnwidth = mCancelButton.frame.size.width + mSaveButton.frame.size.width;
	CGFloat posx;
	
	if (showDeleteButton)
	{
		[self addSubview: mDeleteButton];
		btnwidth += mDeleteButton.frame.size.width;
	}
	else
	{
		[mDeleteButton removeFromSuperview];
	}
	
	posx = (width-btnwidth)/2.0;
	int posy = 30 + 210 + ((self.frame.size.height-30-210-mCancelButton.frame.size.height)/2.0);
	
	mCancelButton.frame = CGRectMake(posx, posy, mCancelButton.frame.size.width, mCancelButton.frame.size.height);
	posx += mCancelButton.frame.size.width;
	
	if (showDeleteButton)
	{
		mDeleteButton.frame = CGRectMake(posx, posy, mDeleteButton.frame.size.width, mDeleteButton.frame.size.height);
		posx += mDeleteButton.frame.size.width;
	}
	
	mSaveButton.frame = CGRectMake(posx, posy, mSaveButton.frame.size.width, mSaveButton.frame.size.height);
	posx += mSaveButton.frame.size.width;
}

#pragma mark -
#pragma mark datePicker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 4;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel* label;
	
	if (view) {
		label = (UILabel*)view;
	} else {
		label = [[[UILabel alloc] initWithFrame: CGRectMake(0, 0, 260, 30)] autorelease];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize: 20];
		label.textAlignment = UITextAlignmentCenter;
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(1, 1);
	}
	
	switch (row)
	{
		case 0:
			label.text = @"Keine Wiederholung";
			break;
		case 1:
			label.text = @"Täglich wiederholen";
			break;
		case 2:
			label.text = @"Monatlich wiederholen";
			break;
		case 3:
			label.text = @"Jährlich wiederholen";
			break;
	}
	
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

#pragma mark -
#pragma mark date

- (void) setSelectedDate: (NSDate*) date
{
	UIDatePicker* datePicker = (UIDatePicker*)[self viewWithTag: 999];
	datePicker.date = date;
}

- (NSDate*) selectedDate
{
	UIDatePicker* datePicker = (UIDatePicker*)[self viewWithTag: 999];
	return datePicker.date;
}

#pragma mark -
#pragma mark inform delegate

- (void) cancelButtonTouchHandler: (UIButton*) sender
{
	if (mDelegate) {
		[mDelegate notificationView: self touchedButtonWithType: eNotificationViewButtonTypeCancel];
	}
}

- (void) deleteButtonTouchHandler: (UIButton*) sender
{
	if (mDelegate) {
		[mDelegate notificationView: self touchedButtonWithType: eNotificationViewButtonTypeDelete];
	}
}

- (void) saveButtonTouchHandler: (UIButton*) sender
{
	if (mDelegate) {
		[mDelegate notificationView: self touchedButtonWithType: eNotificationViewButtonTypeSave];
	}
	
	// Not finished: Show selection for setup of repeating notifications
	
	/*
	// show pickerview
	UIView* overlay = (UIDatePicker*)[self viewWithTag: 777];
	UIDatePicker* datePicker = (UIDatePicker*)[self viewWithTag: 999];
	UIPickerView* pickerView = [[UIPickerView alloc] initWithFrame: datePicker.frame];
	[self insertSubview: pickerView belowSubview: overlay];
	[pickerView release];
	pickerView.delegate = self;
	pickerView.dataSource = self;
	pickerView.alpha = 0;
	pickerView.showsSelectionIndicator = NO;
	
	// animate in
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: 1.0];
	pickerView.alpha = 1;
	[UIView commitAnimations];
	*/
}

#pragma mark -
#pragma mark dismiss


- (void) dismissAnimated
{
	[UIView beginAnimations: @"notificationDismissAnimation" context: nil];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(animationFinished:)];
	
	CGRect tempRect = self.frame;
	tempRect.origin.y += self.frame.size.height;
	self.frame = tempRect;
	
	[UIView commitAnimations];
}

- (void) animationFinished: (id) sender
{
	[self removeFromSuperview];
}

@end
