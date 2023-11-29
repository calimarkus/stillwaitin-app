//
//  main.m
//  StillWaitin
//
//  Created by devmob on 22.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"StillWaitinAppDelegate");
    [pool release];
    return retVal;
}