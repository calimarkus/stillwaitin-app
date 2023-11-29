//
//  DebtSender.h
//  StillWaitin
//
//

@class RealmEntry;

@interface DebtSender : NSObject

- (instancetype)initWithEntry:(RealmEntry *)entry;

- (void)presentSelectionFromViewController:(UIViewController *)viewController
                                    sender:(UIView *)sender;

@end
