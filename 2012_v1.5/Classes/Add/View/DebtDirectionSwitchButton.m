//
//  DebtDirectionSwitchButton.m
//  StillWaitin
//
//  Created by devmob on 09.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "DebtDirectionSwitchButton.h"

@implementation DebtDirectionSwitchButton

@synthesize switchState;

- (id) initWithFrame: (CGRect) frame
{
	if (self = [super initWithFrame: frame])
	{
		UIImage* image = [UIImage imageNamed: @"add_switch_in.png"];
		[self setImage: image forState: UIControlStateSelected];

		image = [UIImage imageNamed: @"add_switch_out.png"];
		[self setImage: image forState: UIControlStateNormal];

		[self setSelected: YES];
		[self setAdjustsImageWhenHighlighted: NO];
	}
	return self;
}

- (void) setSelected: (BOOL) select
{
	[super setSelected: select];

	if (select) {
		switchState = SwitchStateOn;
	} else {
		switchState = SwitchStateOff;
	}
}

@end