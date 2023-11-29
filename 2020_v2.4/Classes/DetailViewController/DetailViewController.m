//
//  DetailViewController.m
//  StillWaitin
//

#import "DetailViewController.h"

#import "AddressBookUtility.h"
#import "CurrencyManager.h"
#import "DatePickerController.h"
#import "DebtSender.h"
#import "EditLocationViewController.h"
#import "EditableDateButton.h"
#import "EditableValueLabel.h"
#import "EnterPersonViewController.h"
#import "ImageScaling.h"
#import "MapAnnotation.h"
#import "PhotoViewController.h"
#import "RealmEntry.h"
#import "RealmEntryStorage.h"
#import "SWColors.h"
#import "SWValueKeyboard.h"
#import "SimpleActivityView.h"
#import "SimpleLocalNotification.h"
#import "ZoomInteractiveTransition.h"
#import <QuartzCore/QuartzCore.h>
#import <Realm/RLMRealm.h>
#import <SimpleUIKit/NSAttributedString+SimpleUIKit.h>
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>
#import <SimpleUIKit/UIView+SimplePositioning.h>

const CGFloat DetailViewControllerEditButtonsMargin = 10.0;

@interface DetailViewController () <EditLocationViewControllerDelegate,
MKMapViewDelegate,
UIDocumentInteractionControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextViewDelegate,
ZoomTransitionProtocol>
@end

@implementation DetailViewController {
  DebtSender *_debtSender;
  ZoomInteractiveTransition * _transition;
  UIView *_viewForZoomTransition;
  BOOL _addingNewEntry;
  RealmEntry *_originalEntry;
  UIImage *_temporaryPhoto;
  UILabel *_titleLabel;
  UIImagePickerController *_imagePickerController;
  EditLocationViewController *_editLocationViewController;
  CGRect _latestKeyboardIntersectionFrame;
}

- (instancetype)init {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _latestKeyboardIntersectionFrame = CGRectNull;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
  }
  return self;
}

- (instancetype)initWithAddresBookContact:(AddressBookContact*)contact {
  self = [self init];
  if (self) {
    RealmEntry *realmEntry = [[RealmEntry alloc] init];
    realmEntry.fullName = [[contact.fullName capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    realmEntry.email = contact.email;
    realmEntry.phoneNumber = contact.phoneNumber;
    _realmEntry = realmEntry;

    _addingNewEntry = YES;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = SWColorGrayWash();

  CGFloat safeBottomMargin = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] safeAreaInsets].bottom;
  self.bottomButtonsView.backgroundColor = SWColorGreenSecondary();
  self.bottomButtonsView.frameY += safeBottomMargin;
  self.bottomButtonsView.frameHeight += safeBottomMargin;

  _transition = [[ZoomInteractiveTransition alloc] initWithNavigationController:self.navigationController];
  _transition.transitionDuration = 0.22;
  _transition.transitionAnimationOption = UIViewKeyframeAnimationOptionCalculationModeCubicPaced;

  NSString *const deletionTitle = (_realmEntry.isArchived ?
                                   NSLocalizedString(@"keyDelete", nil) :
                                   NSLocalizedString(@"keyArchive", nil));
  [self.deleteButton setTitle:deletionTitle forState:UIControlStateNormal];
  [self.deleteButton setTitle:deletionTitle forState:UIControlStateHighlighted];
  self.deleteButton.backgroundColor = SWColorGreenMain();

  [self.mailButton setTitle:NSLocalizedString(@"keyDetailsShare", nil) forState:UIControlStateNormal];
  [self.mailButton setTitle:NSLocalizedString(@"keyDetailsShare", nil) forState:UIControlStateHighlighted];
  self.mailButton.backgroundColor = SWColorGreenMain();

  self.notificationButton.backgroundColor = SWColorGreenMain();

  self.valueTextField.enabled = NO;
  self.valueTextField.textColor = SWColorHighContrastTextColor();

  self.checkmarkIconView.tintColor = SWColorGrayWash();

  _titleLabel = [[UILabel alloc] init];
  _titleLabel.textColor = [UIColor whiteColor];
  _titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
  _titleLabel.backgroundColor = [UIColor clearColor];
  [_titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapped:)]];
  self.navigationItem.titleView = _titleLabel;

  __weak typeof(self) blockSelf = self;
  self.valueTextField.textDidChangeBlock = ^(EditableValueLabel *label) {
    // only update entry, when editing
    if (self.isEditing) {
      blockSelf.realmEntry.value = label.value;
    }
  };

  self.notificationButton.titleLabel.numberOfLines = 0;
  self.debtDirectionIndicatorView.layer.cornerRadius = self.debtDirectionIndicatorView.frameWidth/2.0;
  [self reloadData];

  // set initial state, so bar buttons are set correctly
  [self setEditing:_addingNewEntry animated:NO];

  // auto set current location, if user authorized location usage already
  if (_addingNewEntry) {
    [[self editLocationViewController] updateLocationIfAuthorized];
  }

  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self reloadData];
  [self updateValueTextFieldInputView];

  // Log event
}

#pragma mark - Update View Contents

- (void)setRealmEntry:(RealmEntry *)realmEntry {
  _realmEntry = [realmEntry copy];
  [self reloadData];
}

- (void)reloadData {
  if (![self isViewLoaded]) return;

  // notification button text
  {
    NSString *mainText = NSLocalizedString(@"keyDetailsReminder", nil);
    NSString *dateTimeText = @"";

    if (_realmEntry.notificationDate) {
      NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateStyle: NSDateFormatterFullStyle];
      [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
      NSString* dateString = [dateFormatter stringFromDate:_realmEntry.notificationDate];
      dateTimeText = [NSString stringWithFormat:@"\n%@", dateString];
    }

    UIFont *mainFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont *dateTimeFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    UIColor *mainColor = [self.notificationButton titleColorForState:UIControlStateNormal];
    UIColor *highlightedColor = [self.notificationButton titleColorForState:UIControlStateHighlighted];

    NSString *fullText = [NSString stringWithFormat: @"%@%@", mainText, dateTimeText];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
    [attributedText setFont:mainFont color:mainColor forRangeOfString:nil];
    [attributedText setFont:dateTimeFont color:mainColor forRangeOfString:dateTimeText];
    [self.notificationButton setAttributedTitle:attributedText forState:UIControlStateNormal];

    NSMutableAttributedString *highlightedText = [[NSMutableAttributedString alloc] initWithString:fullText];
    [highlightedText setFont:mainFont color:highlightedColor forRangeOfString:nil];
    [highlightedText setFont:dateTimeFont color:highlightedColor forRangeOfString:dateTimeText];
    [self.notificationButton setAttributedTitle:highlightedText forState:UIControlStateHighlighted];
  }

  // update title
  self.title = _realmEntry.fullName;

  // update description (and placeholder)
  self.descriptionTextView.text = _realmEntry.entryDescription;
  if ([self.descriptionTextView.text length] == 0) {
    self.descriptionTextView.text = NSLocalizedString(@"keyNoDescription", nil);
  }

  // update value label
  self.valueTextField.value = _realmEntry.value;

  // update date labels
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"dd. MMM"];
  NSString *localizedDateString = [dateFormatter stringFromDate:_realmEntry.debtDate];
  [self.dateButton setTitle:localizedDateString forState:UIControlStateNormal];

  // update debt direction indicator
  [self updateEntryDirectionColorAnimated:NO];
  self.checkmarkIconView.hidden = !_realmEntry.isArchived;

  // update map & photo buttons
  NSString *mapImageName = (_realmEntry.location!= nil) ? @"addLocationActive" : @"addLocation";
  NSString *photoImageName = (_realmEntry.photofilename != nil || _temporaryPhoto != nil) ? @"addPhotoActive" : @"addPhoto";
  UIImage *mapImage = [UIImage imageNamed:mapImageName];
  UIImage *photoImage = [UIImage imageNamed:photoImageName];
  [self.editLocationButton setImage:mapImage forState:UIControlStateNormal];
  [self.editPhotoButton setImage:photoImage forState:UIControlStateNormal];

  // update map & photo
  [self updateMap];
  [self updatePhoto];
  [self.view setNeedsLayout];
}

- (void)setTitle:(NSString *)title {
  [super setTitle:title];

  if (!self.editing) {
    _titleLabel.attributedText = nil;
    _titleLabel.text = title;
  } else {
    _titleLabel.attributedText = [[NSAttributedString alloc]
                                      initWithString:title
                                      attributes:@{NSUnderlineStyleAttributeName:@2.0,
                                                   NSUnderlineColorAttributeName:SWColorGreenContrastTintColor(),
                                                   NSFontAttributeName:_titleLabel.font,
                                                   NSForegroundColorAttributeName:[UIColor whiteColor]}];
  }
  [_titleLabel sizeToFit];
}

- (void)updateEntryDirectionColorAnimated:(BOOL)animated {
  UIView *const view = self.debtDirectionIndicatorView;
  UIColor *const color = (_realmEntry.isArchived ?
                          SWColorHighContrastTextColor() :
                          SWIndicatorColorForDebtDirection(_realmEntry.debtDirection));

  if (animated) {
    [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
      view.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1.0, 0);
    } completion:^(BOOL finished) {
      view.backgroundColor = color;
      [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.layer.transform = CATransform3DIdentity;
      } completion:nil];
    }];
  } else {
    view.backgroundColor = color;
  }
}

- (void)updateMap {
  BOOL visible = (_realmEntry.location != nil);
  if (self.isEditing) visible = NO; // always hide when editing
  self.mapView.hidden = !visible;
  self.mapButton.hidden = !visible;

  if (visible) {
    // Add Annotation
    [self.mapView removeAnnotations:self.mapView.annotations];
    MapAnnotation* debtLocation = [[MapAnnotation alloc] init];
    debtLocation.coordinate = CLLocationCoordinate2DMake(_realmEntry.location.latitude, _realmEntry.location.longitude);
    [self.mapView addAnnotation: debtLocation];

    // Zoom to Annotation
    MKCoordinateRegion newRegion;
    newRegion.center.longitude = debtLocation.coordinate.longitude;
    newRegion.center.latitude = debtLocation.coordinate.latitude;
    newRegion.span.latitudeDelta = 0.02;
    newRegion.span.longitudeDelta = 0.02;
    [self.mapView setRegion:newRegion animated:NO];
  }
}

- (void)updatePhoto {
  // always hide while editing, else check if image exists
  UIImage *image = nil;
  if (!self.isEditing) {
    if(nil != _realmEntry.photofilename) {
      NSString *filePath = PhotoFilePathForRealmEntry(_realmEntry);
      image = [UIImage imageWithContentsOfFile:filePath];
      if (image == nil) {
        NSLog(@"couldn't load image from: %@", filePath);
        _realmEntry.photofilename = nil;
      }
    }
    // set / reset image also if it is nil
    self.photoView.image = image;
  }

  // hide / show photo view
  BOOL shouldHideViews = (image == nil);
  self.photoView.hidden = shouldHideViews;
  self.photoButton.hidden = shouldHideViews;
}

#pragma mark - Notifications

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
  CGRect windowKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  _latestKeyboardIntersectionFrame = CGRectIntersection([self.view.window convertRect:windowKeyboardFrame toView:self.view], self.view.frame);
  [self.view setNeedsLayout];
}

#pragma mark - Layouting

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self layoutSubviews];
}

- (void)layoutSubviews {
  CGPoint descriptionOrigin = CGPointMake(_valueTextField.frameX - 2,
                                          _valueTextField.frameBottom + 6);

  // size to fit description label
  CGFloat descriptionWidth = self.dateButton.frameRight - descriptionOrigin.x;
  if (self.isEditing) {
    descriptionWidth -= DetailViewControllerEditButtonsMargin*2 + self.editLocationButton.frameWidth;
  }

  CGFloat fittingHeight = [self.descriptionTextView sizeThatFits:CGSizeMake(descriptionWidth, 2000)].height;
  CGFloat maxHeight = (self.isEditing
                       ? (CGRectIsNull(_latestKeyboardIntersectionFrame) ? self.view.frameHeight : _latestKeyboardIntersectionFrame.origin.y) - descriptionOrigin.y - 20
                       : _bottomButtonsView.frameY - descriptionOrigin.y - 150);
  CGFloat height = (self.isEditing
                    ? maxHeight // enlarge tap area
                    : MIN(fittingHeight, maxHeight)); // respect max height
  self.descriptionTextView.frame = CGRectMake(descriptionOrigin.x,
                                              descriptionOrigin.y,
                                              descriptionWidth,
                                              height);

  // update button layout
  [self layoutMapAndPhotoButton];
}

- (void)layoutMapAndPhotoButton {
  BOOL isIpad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
  CGFloat margin =  isIpad ? 15.0 : 8.0;
  CGFloat sideLength = floor((self.view.frameWidth - margin*3)/2.0);

  // both views visible
  CGRect mapRect=CGRectZero, photoRect=CGRectZero;
  mapRect = CGRectMake(margin, 0, sideLength, sideLength);

  CGFloat reference = (self.photoView.hidden && self.mapView.hidden) ? self.view.frameBottom : self.bottomButtonsView.frameY;
  mapRect.origin.y = reference-margin-sideLength;
  photoRect = mapRect;
  photoRect.origin.x += margin+sideLength;

  // check if only one view is visible
  BOOL hasLocation = (self.realmEntry.location != nil);
  BOOL hasPhoto = (_realmEntry.photofilename != nil);
  if (!self.isEditing && (hasLocation != hasPhoto)) {
    mapRect.size.width = self.view.frameWidth;
    mapRect.origin.x = 0;
    if (hasPhoto) {
      photoRect = mapRect;
    }
  }

  // fix layout, if text is too long (3.5 inch phone, or ipad landscape)
  NSInteger newY = self.descriptionTextView.frameBottom + 10;
  if (newY > mapRect.origin.y) {
    NSInteger diff = newY - mapRect.origin.y;
    mapRect.origin.y = newY;
    mapRect.size.height -= diff;
    photoRect.origin.y = newY;
    photoRect.size.height -= diff;
  }

  // apply frames
  self.mapView.frame = CGRectIntegral(mapRect);
  self.mapButton.frame = CGRectIntegral(mapRect);
  self.photoView.frame = CGRectIntegral(photoRect);
  self.photoButton.frame = CGRectIntegral(photoRect);
}

#pragma mark - ZoomTransitionProtocol

- (UIView *)viewForZoomTransition {
  return _viewForZoomTransition;
}

#pragma mark - Map button / MKMapViewDelegate

- (IBAction)mapButtonTouched:(id)sender {
  [self findAndResignFirstResponder];
  _transition.transitionEnabled = NO;

  EditLocationViewController* viewController = [self editLocationViewController];
  viewController.coordinate = CLLocationCoordinate2DMake(_realmEntry.location.latitude, _realmEntry.location.longitude);
  viewController.editingEnabled = self.isEditing;
  viewController.showsDeleteButton = self.isEditing && (_realmEntry.location != nil);
  [self.navigationController pushViewController:viewController animated:YES];
}

- (EditLocationViewController*)editLocationViewController {
  if (!_editLocationViewController) {
    EditLocationViewController* viewController = [[EditLocationViewController alloc] init];
    viewController.delegate = self;
    _editLocationViewController = viewController;
  }
  return _editLocationViewController;
}

- (void)editLocationViewControllerShouldDismiss:(EditLocationViewController *)controller
                         shouldDeleteCoordinate:(BOOL)shouldDelete {
  if (shouldDelete) {
    _realmEntry.location = nil;
  }
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)editLocationViewController:(EditLocationViewController*)controller
               didUpdateCoordinate:(CLLocationCoordinate2D)coordinate {
  _realmEntry.location = [[RealmLocation alloc] init];
  _realmEntry.location.latitude = coordinate.latitude;
  _realmEntry.location.longitude = coordinate.longitude;
  [self reloadData];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
  if(!annotationView) {
    annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    annotationView.enabled = NO;
  }

  return annotationView;
}

#pragma mark - Photo button

- (IBAction)photoButtonTouched:(UIButton*)sender {
  _transition.transitionEnabled = YES;
  _viewForZoomTransition = self.photoView;
  PhotoViewController *photoController = [[PhotoViewController alloc] initWithPhotoFilePath:PhotoFilePathForRealmEntry(_realmEntry)];
  [self.navigationController pushViewController:photoController animated:YES];
}

- (IBAction)editPhotoButtonTouched:(UIButton*)sender {
  [self findAndResignFirstResponder];

  const BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
  const BOOL hasPhotoAttached = (_realmEntry.photofilename != nil || _temporaryPhoto != nil);

  NSArray<SimpleAlertButton *> *buttons = (hasPhotoAttached ?
                                           (cameraAvailable ?
                                            @[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyAddPhotoTakeNew", nil)],
                                              [SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyAddPhotoChooseNew", nil)],
                                              [SimpleAlertButton destructiveButtonWithTitle:NSLocalizedString(@"keyAddPhotoDelete", nil)],
                                              [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]] :
                                            @[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyAddPhotoChooseNew", nil)],
                                              [SimpleAlertButton destructiveButtonWithTitle:NSLocalizedString(@"keyAddPhotoDelete", nil)],
                                              [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]) :
                                           (cameraAvailable ?
                                            @[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyAddPhotoTake", nil)],
                                              [SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyAddPhotoFromLibrary", nil)],
                                              [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]] :
                                            @[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyAddPhotoFromLibrary", nil)],
                                              [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]));

  __weak typeof(self) blockSelf = self;
  [UIAlertController presentActionSheetFromViewController:self
                                               sourceView:sender
                                                withTitle:nil
                                                  message:nil
                                                  buttons:buttons
                                            buttonHandler:^(UIAlertAction *action) {
    if (action.style != UIAlertActionStyleCancel) {
      [blockSelf handlePhotoSheetSelectionWithAlertAction:action sender:sender];
    }
  }];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
  return self;
}

#pragma mark - Select photo

- (void)handlePhotoSheetSelectionWithAlertAction:(UIAlertAction *)action
                                          sender:(UIButton *)sender {
  if ([action.title isEqualToString:NSLocalizedString(@"keyAddPhotoDelete", nil)]) {
    if (_realmEntry.photofilename) {
      [[NSFileManager defaultManager]
       removeItemAtPath:PhotoFilePathForRealmEntry(_realmEntry)
       error:nil];
      _realmEntry.photofilename = nil;
    }
    _temporaryPhoto = nil;
    [self reloadData];
  } else {
    const BOOL didChooseCamera = ([action.title isEqualToString:NSLocalizedString(@"keyAddPhotoTake", nil)] ||
                                  [action.title isEqualToString:NSLocalizedString(@"keyAddPhotoTakeNew", nil)]);

    if(!_imagePickerController) {
      _imagePickerController = [[UIImagePickerController alloc] init];
      _imagePickerController.delegate = self;
    }

    if (didChooseCamera) {
      _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
      _imagePickerController.cameraFlashMode   = UIImagePickerControllerCameraFlashModeOff;
      _imagePickerController.cameraDevice      = UIImagePickerControllerCameraDeviceRear;
      _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
      _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    } else {
      _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      _imagePickerController.modalPresentationStyle = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone
                                                       ? UIModalPresentationFullScreen
                                                       : UIModalPresentationPopover);
    }

    UIPopoverPresentationController *popoverPresentationController = [_imagePickerController popoverPresentationController];
    popoverPresentationController.sourceView = sender;
    popoverPresentationController.sourceRect = sender.bounds;

    [self presentViewController:_imagePickerController animated:YES completion:nil];
  }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  _temporaryPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
  [self reloadData];

  // dismiss
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  // dismiss
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Done Button

- (void)doneButtonTouched:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Mail Button

- (IBAction)mailButtonTouchHandler:(id)sender {
  if (!_debtSender) {
    _debtSender = [[DebtSender alloc] initWithEntry:_realmEntry];
  }
  [_debtSender presentSelectionFromViewController:self sender:sender];
}

#pragma mark - Archive/Delete button

- (IBAction)archiveButtonTouchHandler:(UIButton*)sender {
  BOOL isArchived = _realmEntry.isArchived;
  __weak typeof(self) blockSelf = self;
  [UIAlertController presentActionSheetFromViewController:self
                                               sourceView:sender
                                                withTitle:nil
                                                  message:nil
                                                  buttons:@[(isArchived ?
                                                             [SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyUnarchive", nil)] :
                                                             [SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyArchive", nil)]),
                                                            [SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyDelete", nil)],
                                                            [SimpleAlertButton cancelButtonWithTitle:NSLocalizedString(@"keyCancel", nil)]]
                                            buttonHandler:^(UIAlertAction *action) {
    if (action.style != UIAlertActionStyleCancel) {
      if ([action.title isEqualToString:NSLocalizedString(@"keyDelete", nil)]) {
        [[RealmEntryStorage sharedStorage] deleteEntry:blockSelf.realmEntry];
      } else if ([action.title isEqualToString:NSLocalizedString(@"keyArchive", nil)]) {
        [[RealmEntryStorage sharedStorage] archiveEntry:blockSelf.realmEntry];
      } else if ([action.title isEqualToString:NSLocalizedString(@"keyUnarchive", nil)]) {
        [[RealmEntryStorage sharedStorage] unarchiveEntry:blockSelf.realmEntry];
      }
      [blockSelf.navigationController popViewControllerAnimated:YES];
      [blockSelf dismissViewControllerAnimated:YES completion:nil];
    }
  }];
}

#pragma mark - Notification button / DatePickerControllerDelegate

- (IBAction)notificationButtonTouchHandler:(id)sender {
  __weak typeof(self) blockSelf = self;
  [SimpleLocalNotification registerForLocalNotificationsIfNeededWithCompletion:^(BOOL granted, UNNotificationSettings *settings, NSError *error) {
    if (granted) {
      [blockSelf _presentDatePickerWithSender:sender];
    } else {
      [UIAlertController presentAlertFromViewController:self
                                              withTitle:NSLocalizedString(@"keyNoPermission", nil)
                                                message:NSLocalizedString(@"keyEnableNotificationsInSettings", nil)
                                confirmationButtonTitle:NSLocalizedString(@"keyOk", nil)];
    }
  }];
}

- (void)_presentDatePickerWithSender:(id)sender {
  DatePickerController* notificationController = [[DatePickerController alloc]
                                                  initWithSelectedDate:_realmEntry.notificationDate
                                                  minimumDate:[NSDate date]];

  notificationController.title = NSLocalizedString(@"keyDetailsSetReminder", nil);
  notificationController.showsDeleteButton = (_realmEntry.notificationDate != nil);

  __weak typeof(self) blockSelf = self;
  notificationController.didChangeDateBlock = ^(DatePickerController *controller, NSDate *date){
    [blockSelf datePickerController:controller didSelectDate:date];
  };

  notificationController.shouldDismissBlock = ^(DatePickerController *controller, BOOL shouldDeleteDate){
    if (shouldDeleteDate) {
      [blockSelf deleteLocalNotificationFromEntry];
    }
    [blockSelf.navigationController popViewControllerAnimated:YES];
  };

  [self.navigationController pushViewController:notificationController animated:YES];
}

- (void)datePickerController:(DatePickerController *)controller didSelectDate:(NSDate *)date {
  // only save notifications in the future
  if ([date timeIntervalSinceNow] < 0) return;

  // show delete button, after a change is made
  [controller setShowsDeleteButton:YES animated:YES];

  // build notification text
  NSString* debtFormat = NSLocalizedString(@"keyFooterOutFormat", nil);
  if (_realmEntry.debtDirection == DebtDirectionIn) {
    debtFormat = NSLocalizedString(@"keyFooterInFormat", nil);
  }
  debtFormat = [NSString stringWithFormat: @"%@ %@", _realmEntry.fullName, debtFormat];

  // append entry value
  NSNumberFormatter *numberFormatter = [CurrencyManager currencyNumberFormatter];
  NSString *text = [NSString stringWithFormat:debtFormat, [numberFormatter stringFromNumber:_realmEntry.value]];

  // append description
  if ([_realmEntry.entryDescription length] > 0) {
    text = [text stringByAppendingFormat: @"\n%@: %@", NSLocalizedString(@"keyDescription", nil), _realmEntry.entryDescription];
  }

  // setup UILocalNotification
  [SimpleLocalNotification cancelScheduledLocalNotificationsMatchingUniqueIdentifier:self.realmEntry.uniqueId];

  [SimpleLocalNotification scheduleLocalNotificationWithAlertBody:text
                                              timeIntervalFromNow:[date timeIntervalSinceNow]
                                                 uniqueIdentifier:self.realmEntry.uniqueId
                                                       completion:nil];

  // update & save entry
  self.realmEntry.notificationDate = date;
  [self saveEntry];

  // update view
  [self reloadData];
}

- (void)deleteLocalNotificationFromEntry {
  [SimpleLocalNotification cancelScheduledLocalNotificationsMatchingUniqueIdentifier:self.realmEntry.uniqueId];

  // update entry
  self.realmEntry.notificationDate = nil;
  [self saveEntry];

  // update view
  [self reloadData];
}

#pragma mark first responder helper

- (void)findAndResignFirstResponder {
  [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)
                                             to:nil from:nil forEvent:nil];
}

#pragma mark keyboard size

- (void)updateValueTextFieldInputView {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    SWValueKeyboard *valueKeyboard = (SWValueKeyboard*)self.valueTextField.inputView;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      [valueKeyboard setKeyboardWidth:CGRectGetWidth([[UIScreen mainScreen] bounds])];
    } else {
      [valueKeyboard setKeyboardWidth:self.view.frameWidth];
    }
  }
}

#pragma mark - EDITING
#pragma mark Editing state

- (void)editButtonTouched:(id)sender {
  [self setEditing:YES animated:YES];
  [self reloadData];

  // copy original entry
  _originalEntry = [self.realmEntry copy];
}

- (void)cancelButtonTouched:(id)sender {
  if (!_addingNewEntry) {
    // disable edit mode
    [self setEditing:NO animated:YES];

    // restore original entry
    [self.realmEntry updateWithEntry:_originalEntry];
    _originalEntry = nil;
    [self reloadData];
  } else {
    // dismiss controller
    [self.navigationController popViewControllerAnimated: YES];
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)saveButtonTouched:(id)sender {
  [self reloadData];
  [self saveEntry];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  [super setEditing:editing animated:animated];

  // en-/disable back swipe gesture
  self.navigationController.interactivePopGestureRecognizer.enabled = !editing;

  // update bar button items
  if (!editing) {
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                              target:self action:@selector(editButtonTouched:)];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationItem setRightBarButtonItem:editItem animated:animated];

    // show done button on ipad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self action:@selector(doneButtonTouched:)];
    }
  } else {
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self action:@selector(cancelButtonTouched:)];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                              target:self action:@selector(saveButtonTouched:)];
    [self.navigationItem setLeftBarButtonItem:cancelItem animated:NO];
    [self.navigationItem setRightBarButtonItem:saveItem animated:animated];
  }

  // enable/disable editing on subviews
  self.dateButton.enabled = editing;
  self.valueTextField.enabled = editing;
  self.descriptionTextView.editable = editing;
  _titleLabel.userInteractionEnabled = editing;

  // set input view
  [self setupValueTextFieldInputView];

  // update first responder
  BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
  if (!editing) {
    [self findAndResignFirstResponder];
  } else if ((!animated && !isIpad) || (animated && isIpad)) {
    [self.valueTextField becomeFirstResponder];
  }

  // update layout
  [self reloadData];
  [self updateEditingButtonsFrameForVisibility:!editing];
  [UIView animateWithDuration:animated?0.33:0.0 animations:^{
    [self updateEditingButtonsFrameForVisibility:editing];
    if (editing) {
      self.bottomButtonsView.frameY = self.view.frameHeight;
    } else {
      self.bottomButtonsView.frameBottom = self.view.frameHeight;
    }
  } completion:^(BOOL finished) {
    if ((animated && editing)||(isIpad && editing)) {
      [self.valueTextField becomeFirstResponder];
    }
  }];
}

- (void)updateEditingButtonsFrameForVisibility:(BOOL)visible {
  if (visible) {
    self.editLocationButton.frameRight = self.view.frameRight - DetailViewControllerEditButtonsMargin;
    self.editPhotoButton.frameRight = self.view.frameRight - DetailViewControllerEditButtonsMargin;
  } else {
    self.editLocationButton.frameX = self.view.frameRight + DetailViewControllerEditButtonsMargin;
    self.editPhotoButton.frameX = self.view.frameRight + DetailViewControllerEditButtonsMargin;
  }
}

#pragma mark Other buttons

- (IBAction)dateButtonTouched:(EditableDateButton*)dateButton {
  DatePickerController* datePickerController = [[DatePickerController alloc]
                                                initWithSelectedDate:self.realmEntry.debtDate
                                                minimumDate:nil];
  datePickerController.title = NSLocalizedString(@"keyDate", nil);
  datePickerController.mode = UIDatePickerModeDate;

  __weak typeof(self) blockSelf = self;
  datePickerController.didChangeDateBlock = ^(DatePickerController *controller, NSDate *date) {
    blockSelf.realmEntry.debtDate = date;
    [blockSelf reloadData];
  };

  datePickerController.shouldDismissBlock = ^(DatePickerController *controller, BOOL shouldDeleteDate) {
    [blockSelf.navigationController popViewControllerAnimated:YES];
  };

  // present
  [self findAndResignFirstResponder];
  [self.navigationController pushViewController:datePickerController animated:YES];
}

- (void)titleTapped:(id)sender {
  EnterPersonViewController *epc = [[EnterPersonViewController alloc] initWithNameString:self.title];
  [self.navigationController pushViewController:epc animated:YES];
  epc.didSelectPersonBlock = ^(AddressBookContact *contact){
    self.realmEntry.fullName = contact.fullName;
    [self reloadData];
    [self.navigationController popViewControllerAnimated:YES];
  };
}

- (IBAction)debtDirectionIndicatorTouched:(id)sender {
  if (!self.editing) return;
  self.realmEntry.debtDirection = (self.realmEntry.debtDirection == DebtDirectionOut ?
                                   DebtDirectionIn :
                                   DebtDirectionOut);
  [self updateEntryDirectionColorAnimated:YES];
}

#pragma mark saving

- (void)saveEntry {
  // execute
  if (_temporaryPhoto != nil) {
    __weak typeof(self) blockSelf = self;
    [[SimpleActivityView activityViewWithTitle:NSLocalizedString(@"keySaving", nil)]
     presentActivityViewOnView:self.navigationController.view
     activityBlock:^(SimpleActivityView * _Nonnull simpleActivityView, SimpleActivityViewDismissBlock  _Nonnull dismissBlock) {
       [blockSelf executeSaveEntry];
      dismissBlock();
     }];
  } else {
    [self executeSaveEntry];
  }
}

- (void)executeSaveEntry {
  // save photo to disk
  [self executeSavePhoto];

  // save updated entry
  [[RealmEntryStorage sharedStorage] saveEntry:self.realmEntry];
  _originalEntry = nil;
  self.realmEntry = [self.realmEntry copy]; // create new unmanaged entry, so changes won't persist right away

  // remember person for auto completion
  NSString *person = [self.realmEntry.fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  [AddressBookUtility rememberContactNameForSearchIfNotAlreadyExisting:person];

  if (!_addingNewEntry || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
    // disable edit mode
    [self setEditing:NO animated:YES];
  } else {
    // dismiss controller (iphone only)
    [self.navigationController popViewControllerAnimated: YES];
  }
}

- (void)executeSavePhoto {
  // delete old photo, when it was removed
  if (_temporaryPhoto == nil) {
    if (_originalEntry.photofilename != nil && self.realmEntry.photofilename == nil) {
      NSError *error;
      [[NSFileManager defaultManager] removeItemAtPath:PhotoFilePathForRealmEntry(self.realmEntry)
                                                 error:&error];
      NSAssert(error == nil, @"Could not delete photo: %@", error);
      NSLog(@"Deleted photo.");
    }
    return;
  }

  // create filename or use existing
  NSString *const filename = (self.realmEntry.photofilename ?:
                              [NSString stringWithFormat: @"PHOTO_%@.png", self.realmEntry.uniqueId]);

  // use own pool for image data / image conversion
  @autoreleasepool
  {
    // scale the image down and save to file
    UIImage *const image = UIImageScaledToSizeWithSameAspectRatio(_temporaryPhoto, CGSizeMake(750, 750));

    // build PNG image
    NSData* imageData = UIImagePNGRepresentation(image);
    NSAssert(image != nil, @"Error: Couldn't create PNG representation!");

    // save image
    NSArray<NSString *> *const directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[directories firstObject] stringByAppendingPathComponent:filename];
    const BOOL couldWriteImageData = [imageData writeToFile:filePath atomically:NO];
    NSAssert(couldWriteImageData == YES, @"Error: Couldn't save image!");

    if (couldWriteImageData) {
      // save filename
      self.realmEntry.photofilename = filename;
      _temporaryPhoto = nil;
    }
  }

  [self reloadData];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
  if ([textView.text isEqualToString:NSLocalizedString(@"keyNoDescription", nil)]) {
    textView.text = @"";
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  if ([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
    textView.text = NSLocalizedString(@"keyNoDescription", nil);
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  self.realmEntry.entryDescription = textView.text;
  textView.text = self.realmEntry.entryDescription;
  [self.view setNeedsLayout];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  return YES;
}

#pragma mark helper

- (void)setupValueTextFieldInputView {
  if (!self.valueTextField.inputView)
  {
    SWValueKeyboard *valueKeyboard = [SWValueKeyboard instanciateFromNibFile];
    valueKeyboard.separatorString = [[CurrencyManager currencyNumberFormatter] currencyDecimalSeparator];

    __weak typeof(self) weakSelf = self;
    valueKeyboard.didTouchKeyBlock = ^(SWValueKeyboardKeyType type, NSString *value){
      if (type == SWValueKeyboardKeyTypeNumber ||
          type == SWValueKeyboardKeyTypeSeparator) {
        [weakSelf.valueTextField handleCustomKeyboardInput:value];
      } else if (type == SWValueKeyboardKeyTypeDelete) {
        [weakSelf.valueTextField handleCustomKeyboardInput:@""];
      } else if (type == SWValueKeyboardKeyTypeGot) {
        if(weakSelf.realmEntry.debtDirection == DebtDirectionIn) {
          weakSelf.realmEntry.debtDirection = DebtDirectionOut;
          [weakSelf updateEntryDirectionColorAnimated:YES];
        }
      } else if (type == SWValueKeyboardKeyTypeGave) {
        if(weakSelf.realmEntry.debtDirection == DebtDirectionOut) {
          weakSelf.realmEntry.debtDirection = DebtDirectionIn;
          [weakSelf updateEntryDirectionColorAnimated:YES];
        }
      } else if (type == SWValueKeyboardKeyTypeDone) {
        [weakSelf findAndResignFirstResponder];
      }
    };

    weakSelf.valueTextField.inputView = valueKeyboard;
  }
}

@end

