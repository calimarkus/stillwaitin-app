//
//  NumberKeyboardView.m
//  StillWaitin
//
//  Created by devmob on 24.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "NumberKeyboardView.h"

@implementation NumberKeyboardView

@synthesize delegate = mNumberKeyboardDelegate;

#pragma mark initialization

- (id) initWithFrame: (CGRect) frame
{
	if ( (self = [super initWithFrame: frame]) )
	{
		[self addUi];
	}
	return self;
}

#pragma mark add ui

- (void) addUi
{
	// add num pad background
	UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"add_numpad_bg.png"]];
	backgroundImageView.frame = CGRectMake(0, 0, 211, 288);
	[self addSubview: backgroundImageView];
	[backgroundImageView release];

	// add number buttons
	UIButton* oneButton = [UIButton buttonWithType: UIButtonTypeCustom];
	oneButton.frame = CGRectMake(12, 25, 57, 57);
	oneButton.tag = 1;
	[oneButton setImage:[UIImage imageNamed: @"add_numpad_1.png"] forState: UIControlStateNormal];
	[oneButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: oneButton];

	UIButton* twoButton = [UIButton buttonWithType: UIButtonTypeCustom];
	twoButton.frame = CGRectMake(77, 25, 57, 57);
	twoButton.tag = 2;
	[twoButton setImage:[UIImage imageNamed: @"add_numpad_2.png"] forState: UIControlStateNormal];
	[twoButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: twoButton];

	UIButton* threeButton = [UIButton buttonWithType: UIButtonTypeCustom];
	threeButton.frame = CGRectMake(142, 25, 57, 57);
	threeButton.tag = 3;
	[threeButton setImage:[UIImage imageNamed: @"add_numpad_3.png"] forState: UIControlStateNormal];
	[threeButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: threeButton];

	UIButton* fourButton = [UIButton buttonWithType: UIButtonTypeCustom];
	fourButton.frame = CGRectMake(12, 89, 57, 57);
	fourButton.tag = 4;
	[fourButton setImage:[UIImage imageNamed: @"add_numpad_4.png"] forState: UIControlStateNormal];
	[fourButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: fourButton];

	UIButton* fiveButton = [UIButton buttonWithType: UIButtonTypeCustom];
	fiveButton.frame = CGRectMake(77, 89, 57, 57);
	fiveButton.tag = 5;
	[fiveButton setImage:[UIImage imageNamed: @"add_numpad_5.png"] forState: UIControlStateNormal];
	[fiveButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: fiveButton];

	UIButton* sixButton = [UIButton buttonWithType: UIButtonTypeCustom];
	sixButton.frame = CGRectMake(142, 89, 57, 57);
	sixButton.tag = 6;
	[sixButton setImage:[UIImage imageNamed: @"add_numpad_6.png"] forState: UIControlStateNormal];
	[sixButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: sixButton];

	UIButton* sevenButton = [UIButton buttonWithType: UIButtonTypeCustom];
	sevenButton.frame = CGRectMake(12, 153, 57, 57);
	sevenButton.tag = 7;
	[sevenButton setImage:[UIImage imageNamed: @"add_numpad_7.png"] forState: UIControlStateNormal];
	[sevenButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: sevenButton];

	UIButton* eightButton = [UIButton buttonWithType: UIButtonTypeCustom];
	eightButton.frame = CGRectMake(77, 153, 57, 57);
	eightButton.tag = 8;
	[eightButton setImage:[UIImage imageNamed: @"add_numpad_8.png"] forState: UIControlStateNormal];
	[eightButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: eightButton];

	UIButton* nineButton = [UIButton buttonWithType: UIButtonTypeCustom];
	nineButton.frame = CGRectMake(142, 153, 57, 57);
	nineButton.tag = 9;
	[nineButton setImage:[UIImage imageNamed: @"add_numpad_9.png"] forState: UIControlStateNormal];
	[nineButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: nineButton];

	UIButton* pointButton = [UIButton buttonWithType: UIButtonTypeCustom];
	pointButton.frame = CGRectMake(12, 217, 57, 57);
	pointButton.tag = 10;
	[pointButton setImage:[UIImage imageNamed: @"add_numpad_point.png"] forState: UIControlStateNormal];
	[pointButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: pointButton];

	UIButton* zeroButton = [UIButton buttonWithType: UIButtonTypeCustom];
	zeroButton.frame = CGRectMake(77, 217, 57, 57);
	zeroButton.tag = 0;
	[zeroButton setImage:[UIImage imageNamed: @"add_numpad_0.png"] forState: UIControlStateNormal];
	[zeroButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: zeroButton];

	UIButton* backButton = [UIButton buttonWithType: UIButtonTypeCustom];
	backButton.frame = CGRectMake(142, 217, 57, 57);
	backButton.tag = 11;
	[backButton setImage:[UIImage imageNamed: @"add_numpad_back.png"] forState: UIControlStateNormal];
	[backButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
	[self addSubview: backButton];
}

- (void) buttonClicked: (id) sender
{
	UIButton* senderButton = (UIButton*)sender;

	if (10 > senderButton.tag)
	{
		if ([mNumberKeyboardDelegate respondsToSelector: @selector(evaluateNumber:)])
		{
			[mNumberKeyboardDelegate evaluateNumber: senderButton.tag];
			return;
		}
	}

	if (10 == senderButton.tag)
	{
		if ([mNumberKeyboardDelegate respondsToSelector: @selector(realizePoint)])
		{
			[mNumberKeyboardDelegate realizePoint];
			return;
		}
	}

	if (11 == senderButton.tag)
	{
		if ([mNumberKeyboardDelegate respondsToSelector: @selector(realizeDeletion)])
		{
			[mNumberKeyboardDelegate realizeDeletion];
			return;
		}
	}
}

#pragma mark memory management

- (void) dealloc
{
	[super dealloc];
}

@end