//
//  DetailViewController.h
//  StillWaitin
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressBookContact.h"

@class Entry, RealmEntry, EditableValueLabel, EditableDateButton;

@interface DetailViewController : UIViewController

// entry
@property (nonatomic, strong) RealmEntry *realmEntry;

// labels
@property (nonatomic, weak) IBOutlet UIView *debtDirectionIndicatorView;
@property (nonatomic, weak) IBOutlet UIImageView *checkmarkIconView;
@property (nonatomic, weak) IBOutlet EditableValueLabel *valueTextField;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet EditableDateButton *dateButton;

// map
@property (weak, nonatomic) IBOutlet UIButton *editLocationButton;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIButton *mapButton;

// photo
@property (weak, nonatomic) IBOutlet UIButton *editPhotoButton;
@property (nonatomic, weak) IBOutlet UIImageView *photoView;
@property (nonatomic, weak) IBOutlet UIButton *photoButton;

@property (nonatomic, weak) IBOutlet UIView *bottomButtonsView;
@property (nonatomic, weak) IBOutlet UIButton *mailButton;
@property (nonatomic, weak) IBOutlet UIButton *notificationButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (instancetype)initWithAddresBookContact:(AddressBookContact*)contact;

@end
