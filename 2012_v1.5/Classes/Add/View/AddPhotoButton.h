//
//  AddPhotoButton.h
//  StillWaitin
//
//  Created by devmob on 16.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	PhotoNotAvailable,
	PhotoAvailable
} Photo;

@interface AddPhotoButton : UIButton
{
	Photo isPhotoAvailable;
}

@property (nonatomic, assign) Photo isPhotoAvailable;

@end