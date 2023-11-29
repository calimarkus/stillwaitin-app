//
//  UIDevice+Addition.m
//  StillWaitin
//
//  Created by devmob on 18.02.11.
//

#import "UIDevice+Addition.h"

@implementation UIDevice (Addition)

+ (BOOL) isIOS4Installed
{
	NSString *version = [[UIDevice currentDevice] systemVersion];
	return [version floatValue] >= 4.0;
}

@end
