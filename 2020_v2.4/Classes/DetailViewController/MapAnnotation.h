//
//  MapAnnotation.h
//  StillWaitin
//

#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

