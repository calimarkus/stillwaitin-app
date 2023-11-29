//
//  DebtSenderTemplates.h
//  StillWaitin
//
//

@class DebtSenderTemplates;

extern DebtSenderTemplates *OriginalDebtSenderTemplates(void);
extern DebtSenderTemplates *CurrentDebtSenderTemplates(void);
extern void SetCurrentDebtSenderTemplates(DebtSenderTemplates *templates);

@interface DebtSenderTemplates : NSObject
@property (nonatomic, strong) NSString *otherSharingFormatIn;
@property (nonatomic, strong) NSString *otherSharingFormatOut;
@property (nonatomic, strong) NSString *emailFormatIn;
@property (nonatomic, strong) NSString *emailFormatOut;
@property (nonatomic, strong) NSString *emailFormatSummary;
@end
