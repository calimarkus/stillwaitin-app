//
//  BackButton.h
//  StillWaitin
//
//  Created by devmob on 31.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BackButton : UIButton {}

// Class methods

+ (BackButton *) button;
+ (BackButton *) stretchableButton: (BOOL) stretchable;

+ (BackButton *) buttonAtPoint: (CGPoint) point;
+ (BackButton *) buttonAtPoint: (CGPoint) point withTitle: (NSString *) title;

// Instance methods

@end
