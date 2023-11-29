//
//  DatePickerController.m
//  StillWaitin
//

#import "DatePickerController.h"

#import "SWColors.h"
#import "SimpleLocalNotification.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

@interface DatePickerController ()
@property (nonatomic, strong) NSDate* selectedDate;
@property (nonatomic, strong) NSDate* minimumDate;

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@end

@implementation DatePickerController

- (id)initWithSelectedDate:(NSDate *)selectedDate minimumDate:(NSDate *)minimumDate {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    self.mode = UIDatePickerModeDateAndTime;
    self.selectedDate = selectedDate;
    self.minimumDate = minimumDate;

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
      self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"keyClose", nil)
                                              style:UIBarButtonItemStylePlain target:self
                                              action:@selector(dismissButtonTouched:)];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = SWColorGrayWash();

  [self.datePicker sizeToFit];
  self.datePicker.date = _selectedDate ?: [NSDate date];
  self.datePicker.minimumDate = self.minimumDate;
  self.datePicker.datePickerMode = self.mode;
  self.datePicker.minuteInterval = 1;

  [self updateDeleteButtonVisibilityAnimated:NO];
  [self.deleteButton setTitle:NSLocalizedString(@"keyDelete", nil)
                     forState:UIControlStateNormal];
}

- (void)setShowsDeleteButton:(BOOL)showsDeleteButton {
  [self setShowsDeleteButton:showsDeleteButton animated:NO];
}

- (void)setShowsDeleteButton:(BOOL)showsDeleteButton animated:(BOOL)animated {
  _showsDeleteButton = showsDeleteButton;
  [self updateDeleteButtonVisibilityAnimated:animated];
}

- (void)updateDeleteButtonVisibilityAnimated:(BOOL)animated {
  CGFloat frameY = self.view.frameHeight;
  frameY -= [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom;

  if (self.showsDeleteButton) {
    frameY -= self.deleteButton.frameHeight;
  }

  [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
    self.deleteButton.frameY = frameY;
    self.deleteButton.alpha = self.showsDeleteButton ? 1.0 : 0.0;
  }];
}

#pragma mark -
#pragma mark inform delegate

- (void)dismissButtonTouched:(UIButton*)sender {
  if (self.shouldDismissBlock) {
    self.shouldDismissBlock(self, NO);
  }
}

- (IBAction)deleteButtonTouched:(UIButton*)sender {
  if (self.shouldDismissBlock) {
    self.shouldDismissBlock(self, YES);
  }
}

- (IBAction)datePickerDateDidChange:(UIDatePicker*)picker {
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithTitle:NSLocalizedString(@"keyDone", nil)
                                            style:UIBarButtonItemStylePlain target:self
                                            action:@selector(dismissButtonTouched:)];

  if (self.didChangeDateBlock) {
    self.didChangeDateBlock(self, picker.date);
  }
}

@end

