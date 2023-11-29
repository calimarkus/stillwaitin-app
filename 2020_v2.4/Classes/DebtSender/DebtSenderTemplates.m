//
//  DebtSenderTemplates.m
//  StillWaitin
//
//

#import "DebtSenderTemplates.h"

NSString *const DebtSenderTemplatesUserDefaultsKey = @"DebtSenderTemplates00";

DebtSenderTemplates *OriginalDebtSenderTemplates(void) {
  DebtSenderTemplates *templates = [DebtSenderTemplates new];
  templates.otherSharingFormatOut = NSLocalizedString(@"keyShortTextSharingFormatOut", nil);
  templates.otherSharingFormatIn = NSLocalizedString(@"keyShortTextSharingFormatIn", nil);
  templates.emailFormatOut = NSLocalizedString(@"keyMailFormatOut", nil);
  templates.emailFormatIn = NSLocalizedString(@"keyMailFormatIn", nil);
  templates.emailFormatSummary = NSLocalizedString(@"keyMailFormatMulti", nil);
  return templates;
}

DebtSenderTemplates *CurrentDebtSenderTemplates(void) {
  NSData *const data = [[NSUserDefaults standardUserDefaults] objectForKey:DebtSenderTemplatesUserDefaultsKey];
  DebtSenderTemplates *const fetchedTemplates = [NSKeyedUnarchiver unarchivedObjectOfClass:[DebtSenderTemplates class] fromData:data error:nil];
  if (fetchedTemplates) {
    return fetchedTemplates;
  } else {
    DebtSenderTemplates *templates = OriginalDebtSenderTemplates();
    SetCurrentDebtSenderTemplates(templates);
    return templates;
  }
}

void SetCurrentDebtSenderTemplates(DebtSenderTemplates *templates) {
  if (templates) {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:templates requiringSecureCoding:NO error:nil]
                                              forKey:DebtSenderTemplatesUserDefaultsKey];
  } else {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DebtSenderTemplatesUserDefaultsKey];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@interface DebtSenderTemplates () <NSCoding>
@end

@implementation DebtSenderTemplates

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _otherSharingFormatIn = [aDecoder decodeObjectForKey:@"_smsFormatIn"]; // keep legacy keys
    _otherSharingFormatOut = [aDecoder decodeObjectForKey:@"_smsFormatOut"]; // keep legacy keys
    _emailFormatIn = [aDecoder decodeObjectForKey:@"_emailFormatIn"];
    _emailFormatOut = [aDecoder decodeObjectForKey:@"_emailFormatOut"];
    _emailFormatSummary = [aDecoder decodeObjectForKey:@"_emailFormatSummary"];
  }
  return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_otherSharingFormatIn forKey:@"_smsFormatIn"]; // keep legacy keys
  [aCoder encodeObject:_otherSharingFormatOut forKey:@"_smsFormatOut"]; // keep legacy keys
  [aCoder encodeObject:_emailFormatIn forKey:@"_emailFormatIn"];
  [aCoder encodeObject:_emailFormatOut forKey:@"_emailFormatOut"];
  [aCoder encodeObject:_emailFormatSummary forKey:@"_emailFormatSummary"];
}

@end
