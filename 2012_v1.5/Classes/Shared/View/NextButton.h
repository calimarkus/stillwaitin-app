//
//  NextButton.h
//  StillWaitin
//
//  Created by devmob on 06.06.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NextButton : UIButton {}

// Class methods

+ (NextButton *) button;
+ (NextButton *) stretchableButton: (BOOL) stretchable;

+ (NextButton *) buttonAtPoint: (CGPoint) point;
+ (NextButton *) buttonAtPoint: (CGPoint) point withTitle: (NSString *) title;

// Instance methods

@end
