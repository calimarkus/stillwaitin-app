//
//  BackButton.h
//  StillWaitin
//
//  Created by devmob on 31.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NavButton : UIButton {}

// Class methods

+ (NavButton *) editButtonAtPoint: (CGPoint) point;

+ (NavButton *) deleteButtonAtPoint: (CGPoint) point;

+ (NavButton *) buttonAtPoint: (CGPoint) point withTitle: (NSString *) title;

// Instance methods

@end
