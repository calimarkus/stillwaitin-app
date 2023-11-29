//
//  SWValueKeyboard.h
//  StillWaitin
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SWValueKeyboardKeyType) {
    SWValueKeyboardKeyTypeNumber,
    SWValueKeyboardKeyTypeSeparator,
    SWValueKeyboardKeyTypeGot,
    SWValueKeyboardKeyTypeGave,
    SWValueKeyboardKeyTypeDone,
    SWValueKeyboardKeyTypeDelete
};

typedef void(^SWValueKeyboardDidTouchKeyBlock)(SWValueKeyboardKeyType keyType, NSString *value);

@interface SWValueKeyboard : UIView

+ (instancetype)instanciateFromNibFile;

@property (nonatomic, assign) BOOL hidesGotGave;
@property (nonatomic, strong) NSString *doneButtonText;
@property (nonatomic, strong) NSString *separatorString;
@property (nonatomic, copy) SWValueKeyboardDidTouchKeyBlock didTouchKeyBlock;

- (void)setKeyboardWidth:(CGFloat)keyboardWidth;

@end
