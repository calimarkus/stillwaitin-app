//
//  RateAppAlert.h
//  StillWaitin
//
//  Created by devmob on 13.11.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RateAppAlert : UIAlertView <UIAlertViewDelegate>

+ (void) showWithMessageKey: (NSString*) messageKey;

@end
