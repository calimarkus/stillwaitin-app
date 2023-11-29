#import "FontSizeTextField.h"



@interface FontSizeTextField : UITextField
{
}

@property (nonatomic) CGFloat fontSize;

- (void) runFontSizeAnimation: (NSTimer*) timer;
- (void) animateFontSizeToSize: (CGFloat) size withDuration: (CGFloat) duration;
- (void) animateFontSizeToSize: (CGFloat) size withDuration: (CGFloat) duration andDelay: (CGFloat) delay;

@end