//
//  AddViewController.h
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AddPersonView.h"
#import "AddDateView.h"
#import "AddItemView.h"
#import "AddDescriptionView.h"
#import "SavingView.h"
#import "Entry.h"
#import "Entry4.h"
#import "BackButton.h"
#import "ChangeDateButton.h"
#import "DetailViewController.h"
#import "EditLocationView.h"
#import "NavButton.h"

typedef enum
{
	AddPhaseNone,
    AddPhasePerson,
	AddPhaseItem,
	AddPhaseDate,
	AddPhaseDescription
	
} AddPhase;

typedef enum
{
	EditModeOff,
	EditModeOn
	
} EditMode;

@interface AddViewController : UIViewController <CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{	
	// model
	Entry *mTemporaryEntry;
	UIImage *mTemporaryPhoto;
	
	UIImageView *mNavigationBarImageView;
	
	// stores the current adding phase
	AddPhase mAddPhase;
	
	// Stores the current adding mode
	EditMode mEditMode;
	
	// add views
	AddPersonView *mAddPersonView;
	AddItemView *mAddItemView;
	AddDateView *mAddDateView;
	AddDescriptionView *mAddDescriptionView;
    EditLocationView* mEditLocationView;
    NavButton* mDeleteButton;
	SavingView * mSavingOverlay;
	
	// location
	CLLocationManager *locationManager;
	BOOL isLocationServiceActive;
	
	// photo
	UIImagePickerController *mImagePickerController;
	
	ChangeDateButton *mChangeDateButton;
	
	DetailViewController* mDetailViewController;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) Entry *temporaryEntry;
@property (nonatomic, retain) UIImage *temporaryPhoto;
@property (nonatomic, retain) DetailViewController *detailViewController;

- (id) initWithFrame: (CGRect) frame andInitialEntry:(Entry*)initialEntry;

- (void)initImagePickerController;
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

- (void)recreateAddViews;

- (void)setEditMode:(EditMode)editMode;
- (void)showViewByAddPhase:(AddPhase)addPhase;
- (void)showAddItemUi;
- (void)showAddDateUi;
- (void)addBackgroundUi;
- (void)addNavigationBarUi;
- (void)addAddPersonUi;
- (void)addAddDateUi;
- (void)addAddItemUi;
- (void)addChangeDateButtonUi;
- (void)saveEntry;
- (void)saveEntryWithDelay: (NSTimer *) timer;
- (void)savePhoto;

- (void)backButtonClickHandler:(id)sender;
- (void)changeDateButtonTouchHandler:(id)sender;
- (void)changeDateLabel:(id)sender;

- (void)updateDateButton;

- (void)addEventListener;
- (void)addListenerForAddCompleteEvents;
- (void)addListenerForAddButtonsTouch;

- (void) hideEditLocationView;

@end
