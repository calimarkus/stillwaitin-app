//
//  AddDateView.h
//  StillWaitin
//
//  Created by devmob on 06.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddDateView : UIView <UIPickerViewDelegate>
{
	// reference to calling view controller for saving user data
	AddViewController *mAddViewController;
	
	// date picker shows first the current date, the user can change the value
	UIDatePicker *mDatePicker;
	
	// custom mask over date picker
	UIImageView *mDatePickerMask;
	
	UIButton *mDateCompleteButton;
}

- (void)setAddViewController:(AddViewController *)viewController;
- (void)addUi;
- (void)completeButtonTouchHandler:(id)sender;

@end
