//
//  DetailViewController.h
//  StillWaitin
//
//  Created by devmob on 17.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "Entry.h"
#import "BackButton.h"
#import "NavButton.h"
#import "NotificationView.h"
#import "EditLocationView.h"


@interface DetailViewController : UIViewController <MKMapViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, NotificationViewDelegate, UIActionSheetDelegate>
{
	CGRect mViewRectangle;
	
	// model
	Entry *mEntry;
	
	// person label
	UILabel *mPersonLabel;
	
	// value label
	UILabel *mValueLabel;
	
	// description label
	UILabel *mDescriptionLabel;
	
	// navbar bg
	UIImageView *mNavBar;
	
	UIImageView *mDataBackgroundImageView;
		
	// debt direction indicator image
	UIImageView *mDebtDirectionIndicatorImageView;
	
	// mail button ui
	UIButton *mMailButton;
	// notification button ui
	UIButton *mNotificationButton;
	// delete button ui
	UIButton *mDeleteButton;
	
	// photo
	UIButton * mPhotoButton;
	UIImageView * mPhotoArrow;
	CGRect mOriginalPhotoFrame;
	
	// map view ui and location management
	MKMapView *mMapView;
	
	UILabel *mDayLabel;
	UILabel *mMonthLabel;
	
	// shadows
	UIImageView *mShadowTopImageView;
	UIImageView *mShadowBottomImageView;
}

@property (nonatomic, retain) Entry*	entry;

- (id)initWithFrame:(CGRect)frame;

//- (void)setEntry:(Entry *)entry;
- (void)update;

- (void)addBackgroundUi;
- (void)addDataBackground;
- (void)addShadows;
- (void)addDescriptionLabelUi;
- (void)addNavigationBarUi;
- (void)addDateLabelUi;
- (void)addValueLabelUi;
- (void)addDebtDirectionIndicatorUi;
- (void)addBottomBarUi;
- (void)addAndUpdateMapUi;
- (void)addPhotoAsButton;
- (void)addPhotoAtFullSize;

- (void)deletionConfirmed;

@end
