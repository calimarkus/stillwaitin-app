//
//  EnterPersonViewController.h
//  StillWaitin
//
//

#import <UIKit/UIKit.h>

@class AddressBookContact;

typedef void(^EnterPersonViewControllerDidSelectPersonBlock)(AddressBookContact *contact);

@interface EnterPersonViewController : UIViewController

@property (nonatomic, copy) EnterPersonViewControllerDidSelectPersonBlock didSelectPersonBlock;

- (instancetype)initWithNameString:(NSString*)name;

@end
