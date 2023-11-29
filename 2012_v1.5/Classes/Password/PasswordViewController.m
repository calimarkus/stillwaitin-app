    //
//  PasswordViewController.m
//  StillWaitin
//
//  Created by devmob on 06.02.11.
//  Copyright 2011 devmob. All rights reserved.
//

#import "PasswordViewController.h"



static NSString* kKEY_USERDEFAULTS_PASSWORD = @"kKEY_USERDEFAULTS_PASSWORD";


@interface PasswordViewController (private)
- (void) checkPassword;
- (void) loginSuccessfull;
- (void) savePassword;
- (id) initWithAnimation: (BOOL) animated;
@end


@implementation PasswordViewController


- (id) initWithAnimation: (BOOL) animated
{
	self = [super init];
	if (self != nil)
	{
		mAnimated = animated;
		mInputFinished = NO;
		mEditMode = NO;
		
		mPassword = [[NSUserDefaults standardUserDefaults] objectForKey: kKEY_USERDEFAULTS_PASSWORD];
		if(!mPassword)
		{
			mPassword = @"123";
		}
	}
	return self;
}



- (void) loadView
{
	[super loadView];
	
	// background image
	UIImageView* imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"splash_clear.png"]];
	imageView.frameBottom = SCREENSIZE.height - 20;
	[self.view addSubview: imageView];
	[imageView release];
	
	// logo "S"
	mLogo = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"splash_logo.png"]];
	mLogo.frameY = -20;
	[self.view addSubview: mLogo];
	[mLogo release];
	
	// password field
	mTextField = [[UITextField alloc] init];
	mTextField.secureTextEntry = !mEditMode;
	mTextField.frame = CGRectMake(50, 114, 220, 30);
	mTextField.borderStyle = UITextBorderStyleRoundedRect;
	mTextField.textAlignment = UITextAlignmentCenter;
	mTextField.alpha = 0;
	mTextField.enabled = NO;
	mTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	mTextField.keyboardType = UIKeyboardTypeNumberPad;
	mTextField.text = @"";
	[self.view addSubview: mTextField];
	[mTextField release];

	// keyboard
	mNumberKeyboardView = [[NumberKeyboardView alloc] initWithFrame: CGRectMake(0, 0, 211, 288)];
	mNumberKeyboardView.transform = CGAffineTransformMakeScale(0.85, 0.85);
	mNumberKeyboardView.center = CGPointMake(160, 270);
	mNumberKeyboardView.alpha = 0;
	mNumberKeyboardView.delegate = self;
	[self.view addSubview: mNumberKeyboardView];
	[mNumberKeyboardView release];
	
	// save button
	mSaveButton = [UIButton buttonWithType: UIButtonTypeCustom];
	[mSaveButton setBackgroundImage: [UIImage imageNamed: @"button_password_save.png"] forState: UIControlStateNormal];
	[mSaveButton sizeToFit];
	[mSaveButton addTarget: self action: @selector(savePassword) forControlEvents: UIControlEventTouchUpInside];
	mSaveButton.center = CGPointMake(160, 415);
	[self.view addSubview: mSaveButton];
	mSaveButton.hidden = !mEditMode;
	
	if (!mAnimated)
	{
		mLogo.transform = CGAffineTransformMakeScale(0.75, 0.75);
		mLogo.center = CGPointMake(160, 120);
		mTextField.alpha = 1.0;
		mNumberKeyboardView.alpha = 1.0;
	}
}


- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];
	
	mTextField.text = @"";
	
	if (mAnimated)
	{
		CGFloat duration = 0.7;
		
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDelay: 0.15];
		[UIView setAnimationDuration: duration-0.15];
		[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
		mLogo.transform = CGAffineTransformMakeScale(0.75, 0.75);
		mLogo.center = CGPointMake(160, 120);
		[UIView commitAnimations];
		
		
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDelay: duration];
		[UIView setAnimationDuration: 0.2];
		mTextField.alpha = 1.0;
		mNumberKeyboardView.alpha = 1.0;
		[UIView commitAnimations];
		
		mAnimated = NO;
	}
}


+ (void) showOnViewController: (UIViewController*) viewController animationsEnabled: (BOOL) animated animateIn: (BOOL) animateIn
{
	NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey: kKEY_USERDEFAULTS_PASSWORD];
	if (!password) {
		return;
	}
	
	if (viewController.modalViewController != nil) {
		return;
	}
	
	PasswordViewController* passwordViewController = [[PasswordViewController alloc] initWithAnimation: animated];
	[viewController presentModalViewController: passwordViewController animated: animateIn];
	[passwordViewController release];
}


+ (void) showOnViewControllerWithEditModeEnabled: (UIViewController*) viewController
{
	PasswordViewController* passwordViewController = [[PasswordViewController alloc] initWithAnimation: NO];
	[passwordViewController enableEditMode];
	[viewController presentModalViewController: passwordViewController animated: YES];
	[passwordViewController release];
}


#pragma mark -
#pragma mark NumberKeyboard delegate


- (void) evaluateNumber: (NSInteger) number
{
	if (mInputFinished) {
		return;
	}
	
	mTextField.text = [mTextField.text stringByAppendingFormat: @"%d", number];
	[self checkPassword];
}


- (void) realizeDeletion
{
	if (mInputFinished) {
		return;
	}
	
	NSInteger index = [mTextField.text length]-1;
	
	if (index >= 0)
	{
		mTextField.text = [mTextField.text substringToIndex: index];
	}
}


- (void) realizePoint
{
	if (mInputFinished) {
		return;
	}
	
	mTextField.text = [mTextField.text stringByAppendingFormat: @"."];
	[self checkPassword];
}


- (void) checkPassword
{
	if (mEditMode) {
		return;
	}
	
	if ([mTextField.text isEqualToString: mPassword])
	{
		mInputFinished = YES;
		
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration: 0.25];
		mTextField.alpha = 0;
		mNumberKeyboardView.alpha = 0;
		[UIView commitAnimations];
		
		[NSTimer scheduledTimerWithTimeInterval: 0.35 target: self selector: @selector(loginSuccessfull) userInfo: nil repeats: NO];
	}
}


- (void) loginSuccessfull
{
	[self dismissModalViewControllerAnimated: YES];
}


- (void) savePassword
{
	if ([mTextField.text length] == 0)
    {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey: kKEY_USERDEFAULTS_PASSWORD];
	}
    else
    {
		[[NSUserDefaults standardUserDefaults] setObject: mTextField.text forKey: kKEY_USERDEFAULTS_PASSWORD];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self dismissModalViewControllerAnimated: YES];
}


- (void) enableEditMode
{
	mEditMode = YES;
}

- (void) resetAnimations
{	
	mAnimated = YES;
	
	mLogo.transform = CGAffineTransformMakeScale(1.0, 1.0);
	mLogo.frameY = -20;
	mTextField.alpha = 0.0;
	mNumberKeyboardView.alpha = 0.0;
}

@end
