//
//  SavingView.m
//  StillWaitin
//
//  Created by devmob on 17.07.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "SavingView.h"

@implementation SavingView

- (id) initWithFrame: (CGRect) aFrame
{
	self = [super initWithFrame: aFrame];
	if (self != nil)
	{
		self.backgroundColor = [UIColor colorWithWhite: 0 alpha: 0.8];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        ai.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
		ai.frame = CGRectMake(0, 0, 20, 20);
		ai.center = CGPointMake(0, aFrame.size.height/2.0);
		[ai startAnimating];

		UILabel* label = [[UILabel alloc] init];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
		label.center = CGPointMake(0, aFrame.size.height/2.0);
		label.text = NSLocalizedString(@"keySavingEntry", nil);
		label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentLeft;
		label.textColor = [UIColor whiteColor];
		label.shadowColor = [UIColor blackColor];
		label.shadowOffset = CGSizeMake(-1, -1);
		
		// Center String and ActivityView
		CGSize size = [label.text sizeWithFont: label.font];
		int totalwidth = ai.frame.size.width + 15 + size.width;
		
		CGRect newframe = ai.frame;
		newframe.origin.x = (aFrame.size.width-totalwidth)/2;
		ai.frame = newframe;
		
		newframe = label.frame;
		newframe.size.width = size.width;
		newframe.size.height = size.height;
		newframe.origin.x = ai.frame.origin.x + ai.frame.size.width + 15;
		newframe.origin.y -= newframe.size.height/2 + 1;
		label.frame = newframe;
		// End centering

		[self addSubview: ai];
		[self addSubview: label];
		[ai release];
		[label release];
	}
	return self;
}

@end