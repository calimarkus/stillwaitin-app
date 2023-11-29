//
//  EditLocationView.m
//  StillWaitin
//
//  Created by devmob on 19.06.11.
//  Copyright 2011 devmob. All rights reserved.
//

#import "EditLocationView.h"

#import "MapAnnotation.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"

NSString* const editLocationViewDidChangeLocationNotification = @"editLocationViewDidChangeLocationNotification";


@interface EditLocationView (private)
- (void)coordinateChanged: (NSNotification *)notification;
@end


@implementation EditLocationView

@synthesize entry = mEntry;

- (id)initWithEntry: (Entry *)entry
{
    self = [super initWithFrame: [UIScreen mainScreen].bounds];
    if (self)
    {
        self.entry = entry;
        
        [self setupUI];
        
        // NOTE: This is only fired in iPhone OS 3, not in iOS 4.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.entry = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void) setupUI
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    mMapView = [[MKMapView alloc] initWithFrame: self.frame];
    mMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mMapView.delegate = self;
    [self addSubview: mMapView];
    [mMapView release];
    
    [self addAnnotation];
}

- (void) addAnnotation
{
    // remove all annotations
    [mMapView removeAnnotations: mMapView.annotations];
    
    // add new annotation
    MapAnnotation* mapAnnotation = [[MapAnnotation alloc] initWithCoordinate: mEntry.location addressDictionary: nil];
    [mapAnnotation setEntry: mEntry];
    [mMapView addAnnotation: mapAnnotation];
    [mapAnnotation release];
	
    // If default location set (Middle of Europe) then zoom out
    MKCoordinateRegion newRegion;
    newRegion.center.longitude = mEntry.location.longitude;
    newRegion.center.latitude = mEntry.location.latitude;
    if (mEntry.location.latitude == 48.5
        && mEntry.location.longitude == 23.383333)
    {
        newRegion.span.latitudeDelta = 30.0;
        newRegion.span.longitudeDelta = 30.0;
    }
    // Zoom to Annotation
    else
    {
        newRegion.span.latitudeDelta = 0.06;
        newRegion.span.longitudeDelta = 0.06;
    }
	
    [mMapView setRegion:newRegion animated:NO];
}

- (void) setNewLocation: (CLLocationCoordinate2D) coordinate
{
    mEntry.location	= coordinate;
    mEntry.isLocationAvailable = YES;
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName: editLocationViewDidChangeLocationNotification object: nil]; 
}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{	
	MapAnnotation* annotation = notification.object;
    
	[self setNewLocation: annotation.coordinate];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
	if (oldState == MKAnnotationViewDragStateDragging)
	{
        [self setNewLocation: annotationView.annotation.coordinate];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{	
    if ([annotation isKindOfClass:[MKUserLocation class]])
	{
        return nil;		
	}
	
	// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
	MKAnnotationView* draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier: nil mapView: mapView];
    
	if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) // draggablePinView is DDAnnotationView on iOS 3.
	{
		
	}
	else // draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
	{
		draggablePinView.canShowCallout = NO;
	}	
	
	return draggablePinView;
}

@end
