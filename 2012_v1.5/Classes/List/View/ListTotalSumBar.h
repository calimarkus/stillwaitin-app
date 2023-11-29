//
//  ListTotalSumBar.h
//  StillWaitin
//
//  Created by devmob on 30.01.11.
//  Copyright 2011 devmob. All rights reserved.
//



@interface ListTotalSumBar : UIImageView
{
	UILabel* mLabel;
	UIImageView* mArrowImageIn;
	UIImageView* mArrowImageOut;
	
	NSNumberFormatter* mNumberFormatter;
}

@property (nonatomic) CGFloat totalSum;

@end
