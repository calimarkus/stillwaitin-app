//
//  AddPhotoButton.m
//  StillWaitin
//
//  Created by devmob on 16.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddPhotoButton.h"

@implementation AddPhotoButton

@synthesize isPhotoAvailable;

- (id) initWithFrame: (CGRect) frame
{
	if (self = [super initWithFrame: frame])
	{
		UIImage* image = [UIImage imageNamed: @"add_btn_photo2.png"];
		[self setImage: image forState: UIControlStateSelected];

		UIImage* image2 = [UIImage imageNamed: @"add_btn_photo1.png"];
		[self setImage: image2 forState: UIControlStateNormal];
	}
	return self;
}

/* this is needed for the correct 'touched' state, while selected */
- (void) setSelected: (BOOL) select
{
	[super setSelected: select];

	UIImage* image = nil;
	if (select)
	{
		image = [UIImage imageNamed: @"add_btn_photo2.png"];
		isPhotoAvailable = PhotoNotAvailable;
	}
	else
	{
		image = [UIImage imageNamed: @"add_btn_photo1.png"];
		isPhotoAvailable = PhotoAvailable;
	}
	[self setImage: image forState: UIControlStateNormal];
}

@end