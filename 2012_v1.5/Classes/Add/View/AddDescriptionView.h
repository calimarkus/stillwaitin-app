//
//  AddDescriptionView.h
//  StillWaitin
//
//  Created by devmob on 10.07.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddDescriptionView : UIView <UITextViewDelegate>
{
	// reference to calling view controller for saving user data
	AddViewController *mAddViewController;
	
	// background ui
	UIImageView *mBackgroundImageView;
	
	// hint label
	UILabel *mHintLabel;
	
	// description text field
	UITextView *mDescriptionTextField;
}

- (void)setAddViewController:(AddViewController *)viewController;
- (void)addUi;
- (void)complete;

@end
