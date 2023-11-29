//
//  AddPersonView.h
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "AddressBookUtility.h"
#import "Entry.h"
#import "FontSizeTextField.h"
#import <UIKit/UIKit.h>

@class AddViewController;

@interface AddPersonView : UIView <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
	// reference to calling view controller for saving user data
	AddViewController* mAddViewController;

	// data of persons from adress book
	NSMutableArray* mPersonArray;
	NSMutableArray* mPersonCopyArray;

	// other ui
	UIImageView* mBackgroundImageView;
	FontSizeTextField* mPersonTextField;

	// table view showing all auto-complete results
	UITableView* mSearchTableView;

	// hint label
	UILabel* mHintLabel;
}

- (void) setAddViewController: (AddViewController*) viewController;
- (void) addUi;
- (void) shrinkUi;
- (void) readContacts;
- (void) complete;

- (void) setEntry: (Entry*) entry;

@end