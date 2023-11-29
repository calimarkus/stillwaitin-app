//
//  NumberKeyboardView.h
//  StillWaitin
//
//  Created by devmob on 24.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

@protocol NumberKeyboardDelegate;


@interface NumberKeyboardView : UIView
{
	id <NumberKeyboardDelegate> mNumberKeyboardDelegate;
}

@property (nonatomic, assign) id <NumberKeyboardDelegate> delegate;

- (void) addUi;

@end


@protocol NumberKeyboardDelegate <NSObject>

@required
- (void) evaluateNumber: (NSInteger) number;
- (void) realizeDeletion;
- (void) realizePoint;

@end