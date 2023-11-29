//
//  EditLocationButton.m
//  StillWaitin
//
//  Created by devmob on 19.06.11.
//  Copyright 2011 devmob. All rights reserved.
//

#import "EditLocationButton.h"

@implementation EditLocationButton

- (id) initWithFrame: (CGRect) frame
{
	if (self = [super initWithFrame: frame])
	{
		UIImage* image = [UIImage imageNamed: @"add_btn_location2.png"];
		[self setImage: image forState: UIControlStateSelected];
        
		image = [UIImage imageNamed: @"add_btn_location1.png"];
		[self setImage: image forState: UIControlStateNormal];
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
		image = [UIImage imageNamed: @"add_btn_location2.png"];
	}
	else
	{
		image = [UIImage imageNamed: @"add_btn_location1.png"];
	}
	[self setImage: image forState: UIControlStateNormal];
}

@end
