//
//  EditLocationView.h
//  StillWaitin
//

#import <CoreLocation/CoreLocation.h>

@protocol EditLocationViewControllerDelegate;

@interface EditLocationViewController : UIViewController

@property (nonatomic, weak) id<EditLocationViewControllerDelegate> delegate;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) BOOL showsDeleteButton;
@property (nonatomic, assign) BOOL editingEnabled;

- (void)updateLocationIfAuthorized;

@end


@protocol EditLocationViewControllerDelegate <NSObject>
@required
- (void)editLocationViewControllerShouldDismiss:(EditLocationViewController*)controller
                         shouldDeleteCoordinate:(BOOL)shouldDelete;
@optional
- (void)editLocationViewController:(EditLocationViewController*)controller
               didUpdateCoordinate:(CLLocationCoordinate2D)coordinate;
@end
