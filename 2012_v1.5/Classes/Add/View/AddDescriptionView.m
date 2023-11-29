//
//  AddDescriptionView.m
//  StillWaitin
//
//  Created by devmob on 10.07.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddDescriptionView.h"


@implementation AddDescriptionView

- (id)initWithFrame:(CGRect)frame
{	
    if ((self = [super initWithFrame:frame]))
	{
        [self addUi];
    }
    return self;
}

- (void)setAddViewController:(AddViewController *)viewController
{
	mAddViewController = viewController;
	
	mDescriptionTextField.text = mAddViewController.temporaryEntry.description;
}

#pragma mark add ui

- (void)addUi
{
	// add text field background
	mBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addcontent_bg.png"]];
	[self addSubview:mBackgroundImageView];
	
	// add hint label
	mHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 296, 47)];
	mHintLabel.backgroundColor = [UIColor clearColor];
	mHintLabel.font = [UIFont boldSystemFontOfSize:16.0];
	mHintLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.15];
	mHintLabel.text = NSLocalizedString(@"keyDescription", nil);
	[self addSubview:mHintLabel];
	
	// add description text field
	mDescriptionTextField = [[UITextView alloc] initWithFrame:CGRectMake(13, 48, 296, 140)];
	mDescriptionTextField.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"loupefix_description.png"]];
	//mDescriptionTextField.backgroundColor = [UIColor clearColor];
	mDescriptionTextField.font = [UIFont boldSystemFontOfSize:23.0];
	mDescriptionTextField.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	[mDescriptionTextField becomeFirstResponder];
	mDescriptionTextField.delegate = self;
	mDescriptionTextField.returnKeyType = UIReturnKeyDone;
	mDescriptionTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
	mDescriptionTextField.keyboardType = UIKeyboardTypeDefault;
	mDescriptionTextField.scrollEnabled = NO;
	[self addSubview:mDescriptionTextField];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([textView.text length] - range.length + [text length] > 80 ) {
		return NO;
	}
	
    if([text isEqualToString:@"\n"])
	{
        [textView resignFirstResponder];
		[self complete];
        return NO;
    }
	
    return YES;
}

- (void)complete
{
	// save data from text field
	mAddViewController.temporaryEntry.description = mDescriptionTextField.text;
	
	// hide keyboard
	[mDescriptionTextField resignFirstResponder];
	
	// send notification of completion, add view controller is listening
	[[NSNotificationCenter defaultCenter] postNotificationName:@"addDescriptionComplete" object:nil];
}

- (void)dealloc
{
	[mBackgroundImageView release];
	[mDescriptionTextField release];
	[mHintLabel release];
	
    [super dealloc];
}

@end
