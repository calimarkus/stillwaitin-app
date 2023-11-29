//
//  NotificationView.h
//  StillWaitin
//
//  Created by devmob on 05.12.10.
//  Copyright 2010 devmob. All rights reserved.
//

typedef enum {
	eNotificationViewButtonTypeCancel,
	eNotificationViewButtonTypeDelete,
	eNotificationViewButtonTypeSave
} eNotificationViewButtonType;

@protocol NotificationViewDelegate;

@interface NotificationView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
{
	UIButton* mCancelButton;
	UIButton* mDeleteButton;
	UIButton* mSaveButton;
	
	id<NotificationViewDelegate> mDelegate;
}

@property (nonatomic, assign) id<NotificationViewDelegate> delegate;
@property (nonatomic, assign) NSDate* selectedDate;

- (void) showDeleteButton: (BOOL) showDeleteButton;

- (void) dismissAnimated;

@end


@protocol NotificationViewDelegate
- (void) notificationView: (NotificationView*) notificationView touchedButtonWithType: (eNotificationViewButtonType) buttonType;
@end