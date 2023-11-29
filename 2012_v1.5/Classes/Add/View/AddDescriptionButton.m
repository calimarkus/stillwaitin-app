//
//  AddDescriptionButton.m
//  StillWaitin
//
//  Created by devmob on 21.07.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddDescriptionButton.h"

@implementation AddDescriptionButton

- (id) initWithFrame: (CGRect) frame
{
	if (self = [super initWithFrame: frame])
	{
		UIImage* image = [UIImage imageNamed: @"add_description_btn.png"];
		[self setImage: image forState: UIControlStateNormal];
        
		UIImage* image2 = [UIImage imageNamed: @"add_description_btn_2.png"];
		[self setImage: image2 forState: UIControlStateSelected];
	}
	return self;
}

/* this is needed for the correct 'touched' state, while selected */
- (void) setSelected: (BOOL) boolean
{
	[super setSelected: boolean];

	UIImage* image = nil;
	if (YES == boolean)
	{
		image = [UIImage imageNamed: @"add_description_btn_2.png"];
	}
	else
	{
		image = [UIImage imageNamed: @"add_description_btn.png"];
	}

	[self setImage: image forState: UIControlStateNormal];
}

@end