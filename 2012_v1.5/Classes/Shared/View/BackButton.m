//
//  BackButton.m
//  StillWaitin
//
//  Created by devmob on 31.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "BackButton.h"


@implementation BackButton

+ (BackButton *) button
{	
	return [self stretchableButton: NO];
}

+ (BackButton *) stretchableButton: (BOOL) stretchable
{
	BackButton * btn = [BackButton buttonWithType: UIButtonTypeCustom];
	
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

+ (BackButton *) buttonAtPoint: (CGPoint) point
{
	BackButton * btn = [self stretchableButton: NO];
	
	CGRect btnFrame = btn.frame;
	btnFrame.origin = point;
	btn.frame = btnFrame;
	
	return btn;
}

+ (BackButton *) buttonAtPoint: (CGPoint) point withTitle: (NSString *) title
{
	BackButton * btn = [self stretchableButton: YES];
	
	UILabel *myTitleLabel = [[UILabel alloc] initWithFrame: CGRectMake(38, 7, 0, 0)];
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
