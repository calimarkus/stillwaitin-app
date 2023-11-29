//
//  CurrencyManager.h
//  StillWaitin
//
//

#import <Foundation/Foundation.h>

extern NSString *const CurrencyManagerDidChangeCurrencyNotification;

@interface CurrencyManager : NSObject

+ (void)setCurrentCurrencyLocaleIdentifier:(NSString *)localeIdentifier;

+ (NSNumberFormatter *)currencyNumberFormatter;

@end
