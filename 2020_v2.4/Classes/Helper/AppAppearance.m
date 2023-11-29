//
//  AppAppearance.m
//  StillWaitin
//
//

#import "AppAppearance.h"

#import "SWColors.h"

@implementation AppAppearance

+ (void)setupAppearance {
  [[UINavigationBar appearance] setTintColor:SWColorGreenContrastTintColor()];
  [[UINavigationBar appearance] setBarTintColor:SWNavbarBackgroundColor()];
  [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

  [[UITextField appearance] setTintColor:SWColorGreenContrastTintColor()];
  [[UITextView appearance] setTintColor:SWColorGreenContrastTintColor()];
}

@end
