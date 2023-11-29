//
//  PasswordViewController.h
//  StillWaitin
//
//  Created by devmob on 06.02.11.
//  Copyright 2011 devmob. All rights reserved.
//


#import "NumberKeyboardView.h"


@interface PasswordViewController : UIViewController <UITextFieldDelegate, NumberKeyboardDelegate>
{
	UIImageView* mLogo;
	UITextField* mTextField;
	NumberKeyboardView* mNumberKeyboardView;
	UIButton* mSaveButton;
	
	BOOL mAnimated;
	BOOL mInputFinished;
	BOOL mEditMode;
	
	NSString* mPassword;
}

+ (void) showOnViewController: (UIViewController*) viewController animationsEnabled: (BOOL) animated animateIn: (BOOL) animateIn;
+ (void) showOnViewControllerWithEditModeEnabled: (UIViewController*) viewController;

- (void) enableEditMode;

- (void) resetAnimations;

@end
