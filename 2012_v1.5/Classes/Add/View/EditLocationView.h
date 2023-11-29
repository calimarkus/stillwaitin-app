//
//  EditLocationView.h
//  StillWaitin
//
//  Created by devmob on 19.06.11.
//  Copyright 2011 devmob. All rights reserved.
//

#import "Entry.h"
#import <MapKit/MapKit.h>

extern NSString* const editLocationViewDidChangeLocationNotification;

@interface EditLocationView : UIView <MKMapViewDelegate>
{
    Entry* mEntry;
    
    MKMapView* mMapView;
}

@property (nonatomic, retain) Entry* entry;

- (id)initWithEntry: (Entry*) entry;

- (void) setupUI;
- (void) addAnnotation;

- (void) setNewLocation: (CLLocationCoordinate2D) coordinate;

@end
