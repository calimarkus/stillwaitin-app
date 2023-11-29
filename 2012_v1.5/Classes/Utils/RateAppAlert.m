//
//  RateAppAlert.m
//  StillWaitin
//
//  Created by devmob on 13.11.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "RateAppAlert.h"

@interface RateAppAlert (private)
- (id) initWithMessageKey: (NSString *) messageKey;
@end


@implementation RateAppAlert


- (id) initWithMessageKey: (NSString*) messageKey
{
	NSString* aTitle = NSLocalizedString(@"keyRateApp", nil);
	NSString* aMessage = NSLocalizedString(messageKey, nil);
	NSString* cancelText = NSLocalizedString(@"keyCancel", nil);
	NSString* rateText = NSLocalizedString(@"keyRate",nil);
	
	return [super initWithTitle: aTitle	
						message: aMessage 
					   delegate: self 
			  cancelButtonTitle: cancelText 
			  otherButtonTitles: rateText, nil];
}

+ (void) showWithMessageKey: (NSString*) messageKey
{
	RateAppAlert *rateAppAlert = [[RateAppAlert alloc] initWithMessageKey: messageKey];
	[rateAppAlert show];
	[rateAppAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
		return;
	
    NSURL* url = nil;
#ifdef _IS_FREE_VERSION
	url = [NSURL URLWithString: @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=495509762"];
#elif _IS_LITE_VERSION
    url = [NSURL URLWithString: @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=514384669"];
#else
    url = [NSURL URLWithString: @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=385448071"];
#endif
	[[UIApplication sharedApplication] openURL: url];
}


@end
