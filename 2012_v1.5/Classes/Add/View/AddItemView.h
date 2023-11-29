//
//  AddItemView.h
//  StillWaitin
//
//  Created by devmob on 24.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddDescriptionButton.h"
#import "AddPhotoButton.h"
#import "EditLocationButton.h"
#import "ChangeDateButton.h"
#import "DebtDirectionSwitchButton.h"
#import "Entry.h"
#import "NumberKeyboardView.h"
#import <UIKit/UIKit.h>

@class AddViewController;

@interface AddItemView : UIView <NumberKeyboardDelegate>
{
	// reference to calling view controller for saving user data
	AddViewController* mAddViewController;

	// item text field shows the money or item title
	UILabel* mValueLabel;
	UIImageView* mValueBackgroundImageView;

	// number keyboard view is for adding numbers for money debts
	NumberKeyboardView* mNumberKeyboardView;

	// debt direction switch button
	DebtDirectionSwitchButton* mDebtDirectionSwitchButton;

	// photo button
	AddPhotoButton* mPhotoButton;
    
	// add description button ui
	AddDescriptionButton* mAddDescriptionButton;
    
	// add edit location ui
	EditLocationButton* mEditLocationButton;
    
	// ok button ui
	UIButton* mOkButton;

	// debt direction indicator image
	UIImageView* mDebtDirectionIndicatorImageView;

	NSNumberFormatter* mNumberFormatter;

	long mCurrentValue;
}

- (void) setAddViewController: (AddViewController*) viewController;

- (void) shrinkUi;
- (void) expandUi;
- (void) addUi;
- (void) addOkButtonUi;
- (void) addAddDescriptionButtonUi;
- (void) addInputUi;
- (void) addNumberKeyboardUi;
- (void) addDebtDirectionSwitchButtonUi;
- (void) addDebtDirectionIndicatorUi;
- (void) addPhotoButtonUi;
- (void) addEditLocationButtonUi;

- (void) okButtonTouchHandler: (id) sender;
- (void) photoButtonButtonTouchHandler: (id) sender;
- (void) photoSet: (BOOL) boolean;
- (void) descriptionSet: (BOOL) boolean;
- (void) locationSet: (BOOL) boolean;

- (void) complete;

- (void) setEntry: (Entry*) entry;

@end