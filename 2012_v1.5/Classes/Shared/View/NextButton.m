//
//  NextButton.m
//  StillWaitin
//
//  Created by devmob on 06.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "NextButton.h"


@implementation NextButton

+ (NextButton *) button
{	
	return [self stretchableButton: NO];
}

+ (NextButton *) stretchableButton: (BOOL) stretchable
{
	NextButton * btn = [NextButton buttonWithType: UIButtonTypeCustom];
	
	UIImage * state1;
	UIImage * state2;
	
	if (stretchable) {
		
		UIImage * tmp1 = [UIImage imageNamed: @"navbar_btn_back_default_stretch.png"];
		UIImage * tmp2 = [UIImage imageNamed: @"navbar_btn_back_pressed_stretch.png"];
		
		state1 = [tmp1 stretchableImageWithLeftCapWidth: 33 topCapHeight: 7];
		state2 = [tmp2 stretchableImageWithLeftCapWidth: 33 topCapHeight: 7];
	} else {
		
		state1 = [UIImage imageNamed:@"navbar_btn_back_default.png"];
		state2 = [UIImage imageNamed:@"navbar_btn_back_pressed.png"];
		
		btn.frame = CGRectMake(0, 0, 45, 32);
	}
	
	[btn setBackgroundImage: state1 forState: UIControlStateNormal];
	[btn setBackgroundImage: state2 forState: UIControlStateHighlighted];
	
	return btn;
}

+ (NextButton *) buttonAtPoint: (CGPoint) point
{
	NextButton * btn = [self stretchableButton: NO];
	
	CGRect btnFrame = btn.frame;
	btnFrame.origin = point;
	btn.frame = btnFrame;
	
	return btn;
}

+ (NextButton *) buttonAtPoint: (CGPoint) point withTitle: (NSString *) title
{
	NextButton * btn = [self stretchableButton: YES];
	
	UILabel * myTitleLabel = [[UILabel alloc] initWithFrame: CGRectMake(38, 7, 0, 0)];
	myTitleLabel.font = [UIFont boldSystemFontOfSize: 13];
	myTitleLabel.textColor = [UIColor colorWithWhite: 1.0 alpha: 0.62];
	myTitleLabel.backgroundColor = [UIColor clearColor];
	myTitleLabel.text = title;
	[myTitleLabel sizeToFit];
	[btn addSubview: myTitleLabel];
	[myTitleLabel release];
	
	CGSize size = [title sizeWithFont: myTitleLabel.font];
	btn.frame = CGRectMake(point.x, point.y, size.width+50, 32);
	
	return btn;
}

@end