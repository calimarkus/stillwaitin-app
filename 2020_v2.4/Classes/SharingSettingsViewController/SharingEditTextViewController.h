//
//  SharingEditTextViewController.h
//  StillWaitin
//
//

typedef void(^SharingEditTextViewControllerDidSaveBlock)(NSString *newText);

@interface SharingEditTextViewController : UIViewController

@property (nonatomic, copy) SharingEditTextViewControllerDidSaveBlock didSaveBlock;

- (instancetype)initWithText:(NSString *)text
                    keywords:(NSArray<NSString *> *)keywords;

@end
