//
//  EditableValueLabel.m
//  StillWaitin
//
//

#import "CurrencyManager.h"

#import "EditableValueLabel.h"
#import "SWColors.h"

const CGFloat EditableValueLabelInset = 6.0;
const CGFloat EditableValueCornerRadius = 5.0;
const NSInteger EditableValueLabelTextMaxLength = 16;

@interface EditableValueLabel ()
@property (nonatomic, assign) NSTextAlignment originalAlignment;
@property (nonatomic, strong) EditableValueLabelDelegateHandler *delegateHandler;

@property (nonatomic, assign) BOOL editingDecimalFraction;
@property (nonatomic, assign) BOOL leadingFractionZero;
@property (nonatomic, assign) BOOL active;
@end

@implementation EditableValueLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.delegateHandler = [[EditableValueLabelDelegateHandler alloc] init];
    self.delegate = self.delegateHandler;
  }
  return self;
}

#pragma mark UIResponder

- (BOOL)becomeFirstResponder {
  self.active = YES;
  self.editingDecimalFraction = NO;
  self.leadingFractionZero = NO;

  // enable fraction editing, if given
  double value = [[self value] doubleValue];
  if (value-floor(value) > 0) {
    self.editingDecimalFraction = YES;
  }

  // return, if already first responder
  if([self isFirstResponder]) return YES;

  return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
  self.active = NO;
  return [super resignFirstResponder];
}

#pragma mark UITextField

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, EditableValueLabelInset, EditableValueLabelInset);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
  return CGRectZero;
}

- (void)setText:(NSString *)text {
  [super setText:text];

  if (self.textDidChangeBlock) {
    self.textDidChangeBlock(self);
  }
}

#pragma mark Custom Keyboard Input

- (void)handleCustomKeyboardInput:(NSString*)string {
  [self.delegateHandler textField:self
    shouldChangeCharactersInRange:NSMakeRange(0, 0)
                replacementString:string];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];

  // draw active background
  if (self.enabled) {
    CGFloat lineWidth = 1.0;
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, lineWidth, lineWidth)
                                                             cornerRadius:EditableValueCornerRadius];
    if ([UIScreen mainScreen].scale > 1.0) lineWidth = 0.5;
    rectanglePath.lineWidth = lineWidth;
    [SWColorValueLabelBackground() setFill];
    [rectanglePath fill];
  }
}

#pragma mark value transformation

- (NSNumber *)value {
  return [[CurrencyManager currencyNumberFormatter] numberFromString:self.text];
}

- (void)setValue:(NSNumber *)value {
  [self setText:[[CurrencyManager currencyNumberFormatter] stringFromNumber:value]];
}

#pragma mark Active state

- (void)setEnabled:(BOOL)enabled {
  if (super.enabled == enabled) return;
  super.enabled = enabled;

  if (enabled) {
    self.originalAlignment = self.textAlignment;
    self.textAlignment = NSTextAlignmentCenter;
  } else {
    self.textAlignment = self.originalAlignment;
  }
  [self setNeedsDisplay];
}

- (void)setActive:(BOOL)active {
  if (_active == active) return;
  _active = active;

  if (active && self.becameActiveBlock) {
    self.becameActiveBlock(self);
  }
}

@end

@implementation EditableValueLabelDelegateHandler

- (BOOL)textField:(EditableValueLabel*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  // get current value
  NSString *valueText = [NSString stringWithFormat:@"%.0f", [[textField value] doubleValue]*100];
  if ([valueText isEqualToString:@"0"]) valueText = @"000";
  NSString *fraction = [valueText substringFromIndex:valueText.length-2];
  NSString *lastFraction = [valueText substringFromIndex:valueText.length-1];

  // apply deletion
  if (string.length == 0 && valueText.length > 0) {
    // disable fraction editing, when no fraction is given anymore
    if ([fraction isEqualToString:@"00"] && textField.leadingFractionZero) textField.leadingFractionZero = NO;
    else if ([fraction isEqualToString:@"00"]) textField.editingDecimalFraction = NO;

    if (textField.editingDecimalFraction) {
      if ([lastFraction isEqualToString:@"0"]) {
        valueText = [valueText stringByReplacingCharactersInRange:NSMakeRange(valueText.length-2, 1)
                                                       withString:@"0"];
      } else {
        valueText = [valueText stringByReplacingCharactersInRange:NSMakeRange(valueText.length-1, 1)
                                                       withString:@"0"];
      }
    } else {
      valueText = [valueText stringByReplacingCharactersInRange:NSMakeRange(valueText.length-3, 1)
                                                     withString:@""];
    }
  }

  // apply number characters
  else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
    if ([valueText isEqualToString:@"000"]) {
      if (textField.editingDecimalFraction) {
        valueText = [NSString stringWithFormat:@"0%@0", string];
      } else {
        valueText = [NSString stringWithFormat:@"%@00", string];
      }
    } else {
      if (textField.editingDecimalFraction) {
        if ([fraction isEqualToString:@"00"]) {
          if ([string isEqualToString:@"0"]) {
            textField.leadingFractionZero = YES;
          } else {
            NSInteger offset = (textField.leadingFractionZero ? 1 : 2);
            valueText = [valueText
                         stringByReplacingCharactersInRange:
                         NSMakeRange(valueText.length-offset, 1)
                         withString:string];
          }
        } else if ([lastFraction isEqualToString:@"0"]) {
          valueText = [valueText
                       stringByReplacingCharactersInRange:
                       NSMakeRange(valueText.length-1, 1)
                       withString:string];
        }
      } else {
        valueText = [valueText
                     stringByReplacingCharactersInRange:
                     NSMakeRange(valueText.length-2, 0)
                     withString:string];
      }
    }
  }

  // apply separator
  else {
    textField.editingDecimalFraction = YES;
  }

  // trim to maximum length
  if (valueText.length >= EditableValueLabelTextMaxLength) return NO;

  // create & set formatted text
  CGFloat value = [valueText longLongValue]/100.0;
  [textField setValue:@(value)];

  return NO;
}

@end
