//
//  EditLocationView.m
//  StillWaitin
//

#import "EditLocationViewController.h"

#import "MapAnnotation.h"
#import "SWColors.h"
#import "ZoomTransitionProtocol.h"
#import <MapKit/MapKit.h>
#import <SimpleUIKit/UIView+SimplePositioning.h>

@interface EditLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate, ZoomTransitionProtocol>
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, weak) IBOutlet UIView* buttonContainerView;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end


@implementation EditLocationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
      self.edgesForExtendedLayout = UIRectEdgeNone;
    }
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.deleteButton.backgroundColor = SWColorGreenMain();

  CGFloat safeBottomMargin = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] safeAreaInsets].bottom;
  self.buttonContainerView.frameY += safeBottomMargin;
  self.buttonContainerView.frameHeight += safeBottomMargin;
  self.buttonContainerView.backgroundColor = SWColorGreenSecondary();
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self updateDeleteButtonVisibilityAnimated:NO];
  [self.deleteButton setTitle:NSLocalizedString(@"keyDelete", nil)
                     forState:UIControlStateNormal];

  if (self.coordinate.latitude != 0 || self.coordinate.longitude != 0) {
    [self addAnnotation];
  }

  // add current location button
  if (self.editingEnabled) {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location_pin"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(currentLocationButtonTouched:)];
  } else {
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (self.coordinate.latitude == 0 && self.coordinate.longitude == 0) {
    [self addAnnotation];
  }
}

- (UIView *)viewForZoomTransition {
  return self.mapView;
}

- (void)addAnnotation {
  // remove all annotations
  [self.mapView removeAnnotations:self.mapView.annotations];

  // use map center, if no coordinate is set
  CLLocationCoordinate2D coordinate = self.coordinate;
  if (self.coordinate.latitude == 0 && self.coordinate.longitude == 0) {
    coordinate = self.mapView.centerCoordinate;
  }

  // create annotation
  MapAnnotation* mapAnnotation = [[MapAnnotation alloc] init];
  mapAnnotation.coordinate = coordinate;
  [self.mapView addAnnotation:mapAnnotation];

  // zoom to annotation, if a coordinate is set
  if (self.coordinate.latitude != 0 || self.coordinate.longitude != 0) {
    MKCoordinateRegion newRegion;
    newRegion.center = coordinate;
    newRegion.span.latitudeDelta = 0.06;
    newRegion.span.longitudeDelta = 0.06;

    // update region & title
    [self.mapView setRegion:newRegion animated:YES];
    [self updateTitle];
  }

  // update coordinate
  self.coordinate = coordinate;
}

- (void)updateTitle {
  __weak typeof(self) blockSelf = self;
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
    CLPlacemark *placemark = [placemarks firstObject];
    if (!error && placemark) {
      blockSelf.title = [NSString stringWithFormat: @"%@", placemark.name];
    }
  }];
}

#pragma mark current location


- (void)updateLocationIfAuthorized {
  if ([CLLocationManager locationServicesEnabled]) {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
      [self.locationManager startUpdatingLocation];
    }
  }
}

- (void)currentLocationButtonTouched:(id)sender {
  // start updates / get authorization
  if ([CLLocationManager locationServicesEnabled]) {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
      [self.locationManager requestWhenInUseAuthorization];
      [self.locationManager startUpdatingLocation];
    } else if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
      [self.locationManager startUpdatingLocation];
    }
  }
}

#pragma mark - delete button

- (void)setShowsDeleteButton:(BOOL)showsDeleteButton {
  _showsDeleteButton = showsDeleteButton;
  [self updateDeleteButtonVisibilityAnimated:YES];
}

- (void)updateDeleteButtonVisibilityAnimated:(BOOL)animated {
  CGRect mapFrame = self.view.bounds;
  CGFloat frameY = self.view.frameHeight;
  if (self.showsDeleteButton) {
    frameY -= self.buttonContainerView.frameHeight;
    mapFrame.size.height -= self.buttonContainerView.frameHeight;
  }

  [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
    self.buttonContainerView.frameY = frameY;
    self.mapView.frame = mapFrame;
  }];
}

- (IBAction)deleteButtonTouched:(UIButton*)sender {
  [self.delegate editLocationViewControllerShouldDismiss:self shouldDeleteCoordinate:YES];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
  if (oldState == MKAnnotationViewDragStateDragging) {
    self.coordinate = annotationView.annotation.coordinate;
    if ([self.delegate respondsToSelector:@selector(editLocationViewController:didUpdateCoordinate:)]) {
      [self.delegate editLocationViewController:self didUpdateCoordinate:self.coordinate];
    }
    [self updateTitle];
    [self setShowsDeleteButton:YES];
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;

  static NSString* identifier = @"draggablePin";
  MKPinAnnotationView* draggablePinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
  if (!draggablePinView) {
    draggablePinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
  }

  draggablePinView.draggable = self.editingEnabled;
  draggablePinView.canShowCallout = NO;

  return draggablePinView;
}

#pragma mark CLLocationManagerDelegate

- (CLLocationManager *)locationManager {
  if (_locationManager == nil) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
  }
  return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusNotDetermined) {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *newLocation = [locations firstObject];
  CLLocationCoordinate2D coord = newLocation.coordinate;

  // save new location
  if (ABS([newLocation.timestamp timeIntervalSinceNow]) < 60*5 &&
      (coord.latitude != 0.0 || coord.longitude != 0.0)) {
    self.coordinate = coord;

    // update pin & title
    [self addAnnotation];
    [self updateTitle];

    // show delete button
    self.showsDeleteButton = YES;

    // inform delegate
    if ([self.delegate respondsToSelector:@selector(editLocationViewController:didUpdateCoordinate:)]) {
      [self.delegate editLocationViewController:self didUpdateCoordinate:self.coordinate];
    }

    // stop updating
    [manager stopUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  if (error.code != kCLErrorLocationUnknown) {
    [manager stopUpdatingLocation];
  }
}

@end


