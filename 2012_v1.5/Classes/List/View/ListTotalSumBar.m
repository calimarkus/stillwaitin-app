//
//  ListTotalSumBar.m
//  StillWaitin
//
//  Created by devmob on 30.01.11.
//  Copyright 2011 devmob. All rights reserved.
//

#import "ListTotalSumBar.h"


@interface ListTotalSumBar (private)
- (void) align;
@end


@implementation ListTotalSumBar

@dynamic totalSum;

- (id)init
{    
    self = [super initWithImage: [UIImage imageNamed: @"totalsum_bg.png"]];
    if (self)
	{
		mNumberFormatter = [[NSNumberFormatter alloc] init];
		[mNumberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[mNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[mNumberFormatter setMaximumFractionDigits:2];
		[mNumberFormatter setMinimumFractionDigits:2];
		
        mLabel = [[UILabel alloc] init];
		mLabel.font = [UIFont boldSystemFontOfSize: 12];
		mLabel.backgroundColor = [UIColor clearColor];
		mLabel.textColor = [UIColor colorWithWhite: 0.75 alpha: 1.0];
		mLabel.textAlignment = UITextAlignmentCenter;
		mLabel.shadowOffset = CGSizeMake(-1, -1);
		mLabel.shadowColor = [UIColor colorWithWhite: 0.2 alpha: 1.0];
		[self addSubview: mLabel];
		
		mArrowImageIn  = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"totalsum_in.png"]];
		mArrowImageOut = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"totalsum_out.png"]];
		[self addSubview: mArrowImageIn];
		[self addSubview: mArrowImageOut];
		
		self.totalSum = 0.0;
    }
    return self;
}


- (void) dealloc
{
	[mLabel release];
	[mArrowImageIn release];
	[mArrowImageOut release];
	[mNumberFormatter release];
	
	[super dealloc];
}



- (void) align
{
	mLabel.frame = CGRectMake(0, 4, 320, 16);
	[mLabel sizeToFit];
	
	CGFloat totalWidth = mLabel.frame.size.width + mArrowImageIn.image.size.width + 6;
	CGFloat left = floor((320-totalWidth)/2.0);
	CGFloat right = floor(320-left);
	
	mLabel.frame = CGRectMake(left, 2, mLabel.frame.size.width, 16);
	
	mArrowImageIn.frame = CGRectMake(right-mArrowImageIn.image.size.width, 7, mArrowImageIn.image.size.width, mArrowImageIn.image.size.height);
	mArrowImageOut.frame = mArrowImageIn.frame;
}


#pragma mark -
#pragma mark public access


- (void) setTotalSum: (CGFloat) totalSum
{
	NSString* sumString = [mNumberFormatter stringFromNumber: [NSNumber numberWithFloat: ABS(totalSum)]];
	mLabel.text = [NSString stringWithFormat: @"%@", sumString];
	
	mArrowImageIn.hidden = (totalSum < 0);
	mArrowImageOut.hidden = !mArrowImageIn.hidden;
	
	[self align];
}

- (CGFloat) totalSum
{
	return 0.0;
}

@end