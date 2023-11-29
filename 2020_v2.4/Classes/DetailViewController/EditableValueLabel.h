//
//  EditableValueLabel.h
//  StillWaitin
//
//

#import <UIKit/UIKit.h>

@class EditableValueLabel;

typedef void(^EditableValueLabelTextDidChangeBlock)(EditableValueLabel *label);
typedef void(^EditableValueLabelBecameActiveBlock)(EditableValueLabel *label);

@interface EditableValueLabel : UITextField

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) NSNumber *value;

@property (nonatomic, copy) EditableValueLabelTextDidChangeBlock textDidChangeBlock;
@property (nonatomic, copy) EditableValueLabelBecameActiveBlock becameActiveBlock;

- (void)handleCustomKeyboardInput:(NSString*)string;

@end

@interface EditableValueLabelDelegateHandler : NSObject <UITextFieldDelegate>
@end


