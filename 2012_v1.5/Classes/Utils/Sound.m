//
//  Sound.m
//  StillWaitin
//
//  Created by devmob on 05.07.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "Sound.h"

@implementation Sound

+ (void) soundEffect:(int)soundNumber
{
    NSString *effect = @"tap";
    NSString *type = @"aif";	
    SystemSoundID soundID;
	
    NSString *path = [[NSBundle mainBundle] pathForResource:effect ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
	
    AudioServicesCreateSystemSoundID ((CFURLRef)url, &soundID);
	
    AudioServicesPlaySystemSound(soundID);
}

- (void)dealloc
{
    [super dealloc];
}

@end