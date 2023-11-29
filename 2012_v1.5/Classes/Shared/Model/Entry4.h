//
//  Entry4.h
//  StillWaitin
//
//  Created by devmob on 23.05.10.
//  Copyright 2010 devmob. All rights reserved.
//

#import "Entry.h"

@interface Entry4 : Entry
{
	UILocalNotification* notification;
}

@property (nonatomic, retain) UILocalNotification* notification;

@end