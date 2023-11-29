//
//  DebtDirectionSwitchButton.h
//  StillWaitin
//
//  Created by devmob on 09.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	SwitchStateOn,
	SwitchStateOff
} SwitchState;

@interface DebtDirectionSwitchButton : UIButton
{
	SwitchState switchState;
}

@property (nonatomic, assign) SwitchState switchState;

@end