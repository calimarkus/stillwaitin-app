//
//  ChooseRegionViewController.h
//  StillWaitin
//
//

@interface ChooseRegionViewController : UIViewController

- (instancetype)initWithCurrencyDescription:(NSString *)currencyDescription
                                    locales:(NSArray<NSLocale *> *)locales;

- (void)showConfirmationAlertForLocale:(NSLocale *)locale
                    fromViewController:(UIViewController *)viewController;

@end
