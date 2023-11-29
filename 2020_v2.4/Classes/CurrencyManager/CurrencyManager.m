//
//  CurrencyManager.m
//  StillWaitin
//
//

#import "CurrencyManager.h"

NSString *const CurrencyManagerLocaleIdentifierKey = @"CurrencyManagerLocaleIdentifierKey";
NSString *const CurrencyManagerDidChangeCurrencyNotification = @"CurrencyManagerDidChangeCurrencyNotification";

@implementation CurrencyManager

+ (NSLocale*)currentCurrencyLocale {
  NSString *savedLocaleIdentifier = [[NSUserDefaults standardUserDefaults]
                                     objectForKey:CurrencyManagerLocaleIdentifierKey];
  if (savedLocaleIdentifier) {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:savedLocaleIdentifier];
    if (locale) return locale;
  }

  return [NSLocale currentLocale];
}

+ (void)setCurrentCurrencyLocaleIdentifier:(NSString *)localeIdentifier {
  if (localeIdentifier.length == 0) return;

  // save identifier
  [[NSUserDefaults standardUserDefaults] setObject:localeIdentifier forKey:CurrencyManagerLocaleIdentifierKey];
  [[NSUserDefaults standardUserDefaults] synchronize];

  // send change notification
  [[NSNotificationCenter defaultCenter] postNotificationName:CurrencyManagerDidChangeCurrencyNotification
                                                      object:nil];

  // update numberFormatter
  [[self currencyNumberFormatter] setLocale:[self currentCurrencyLocale]];
}


+ (NSNumberFormatter*)currencyNumberFormatter {
  static NSNumberFormatter *numberFormatter = nil;
  if (!numberFormatter) {
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
  }

  // update with current locale
  [numberFormatter setLocale:[self currentCurrencyLocale]];

  return numberFormatter;
}

@end
