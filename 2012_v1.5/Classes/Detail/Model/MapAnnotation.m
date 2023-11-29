//
//  MapAnnotation
//  StillWaitin
//
//  Created by devmob on 13.07.10.
//

#import "MapAnnotation.h"


@implementation MapAnnotation 


@synthesize entry = mEntry;


- (id)initWithEntry:(Entry *)entry
{
    self = [super initWithCoordinate:entry.location addressDictionary:nil];
    if (nil != self)
    {
        self.entry = entry;
    }
    
    return self;
}

- (void)dealloc
{
    [mEntry release];
    
    [super dealloc];
}

- (void)setEntry:(Entry *)entry
{
    [mEntry release];
    mEntry = [entry retain];
    
	CLLocationCoordinate2D locationCoordinate;
	locationCoordinate.latitude  = mEntry.location.latitude;
	locationCoordinate.longitude = mEntry.location.longitude;
	
	//_coordinate = locationCoordinate;
}

- (NSString *)title
{
    return mEntry.person;
}

- (NSString *)subtitle
{
	return mEntry.description;
}


@end