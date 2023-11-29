//
//  SettingsViewController.h
//  StillWaitin
//
//  Created by devmob on 14.10.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UIAlertViewDelegate>
{
	CGRect mViewRectangle;
	UIButton* mSortButtonA;
	UIButton* mSortButtonB;
	
	UIViewController* mListViewController;
}

@property (nonatomic, retain) UIViewController* listViewController;

- (id)initWithFrame:(CGRect)frame;

- (void) showListView;

@end
