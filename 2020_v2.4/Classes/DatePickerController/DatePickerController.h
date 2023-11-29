//
//  DatePickerController.h
//  StillWaitin
//

@class DatePickerController;
@protocol DatePickerControllerDelegate;

typedef void(^DatePickerControllerShouldDismissBlock)(DatePickerController *controller, BOOL shouldDeleteDate);
typedef void(^DatePickerControllerDidChangeDateBlock)(DatePickerController *controller, NSDate *date);

@interface DatePickerController : UIViewController

@property (nonatomic, assign) UIDatePickerMode mode;
@property (nonatomic, assign) BOOL showsDeleteButton;

@property (nonatomic, copy) DatePickerControllerShouldDismissBlock shouldDismissBlock;
@property (nonatomic, copy) DatePickerControllerDidChangeDateBlock didChangeDateBlock;

- (id)initWithSelectedDate:(NSDate*)selectedDate minimumDate:(NSDate*)minimumDate;

- (void)setShowsDeleteButton:(BOOL)showsDeleteButton
                    animated:(BOOL)animated;

@end

