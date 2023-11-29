//
//  BackButton.m
//  StillWaitin
//
//  Created by devmob on 31.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "NavButton.h"


@implementation NavButton

+ (NavButton *) editButtonAtPoint: (CGPoint) point
{
	return [self buttonAtPoint: point withTitle: NSLocalizedString(@"keyEdit", nil)];
}

+ (NavButton *) deleteButtonAtPoint: (CGPoint) point
{
	return [self buttonAtPoint: point withTitle: NSLocalizedString(@"keyDelete", nil)];
}

+ (NavButton *) buttonAtPoint: (CGPoint) point withTitle: (NSString *) title
{
	NavButton * btn = [NavButton buttonWithType: UIButtonTypeCustom];
	
	UIImage * tmp1 = [UIImage imageNamed: @"navbar_btn_default.png"];
	UIImage * tmp2 = [UIImage imageNamed: @"navbar_btn_pressed.png"];
	
	UIImage * state1 = [tmp1 stretchableImageWithLeftCapWidth: 6 topCapHeight: 9];
	UIImage * state2 = [tmp2 stretchableImageWithLeftCapWidth: 6 topCapHeight: 9];
	
	[btn setBackgroundImage: state1 forState: UIControlStateNormal];
	[btn setBackgroundImage: state2 forState: UIControlStateHighlighted];
	
	CGRect btnFrame = btn.frame;
	btnFrame.origin = point;
	btn.frame = btnFrame;
	
	UILabel *myTitleLabel = [[UILabel alloc] initWithFrame: CGRectMake(11, 8, 0, 0)];
	myTitleLabel.font = [UIFont boldSystemFontOfSize: 13];
	myTitleLabel.textColor = [UIColor colorWithWhite: 1.0 alpha: 0.62];
	myTitleLabel.backgroundColor = [UIColor clearColor];
	myTitleLabel.text = title;
	[myTitleLabel sizeToFit];
	[btn addSubview: myTitleLabel];
	[myTitleLabel release];
	
	CGSize size = [title sizeWithFont: myTitleLabel.font];
	btn.frame = CGRectMake(point.x, point.y, size.width+20, 32);
	
	return btn;
}

@end
