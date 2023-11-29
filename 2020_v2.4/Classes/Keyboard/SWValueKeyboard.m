//
//  SWValueKeyboard.m
//  StillWaitin
//
//

#import <QuartzCore/QuartzCore.h>

#import "SWColors.h"
#import "SWValueKeyboard.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

const NSTimeInterval SWValueKeyboardDeleteRepeatInterval = 0.15;

@interface SWValueKeyboard () <UIInputViewAudioFeedback>
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *allButtons;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *topButtons;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *mainButtons;
@property (weak, nonatomic) IBOutlet UIView *separatorButton;
@property (weak, nonatomic) IBOutlet UIView *backButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *gotIndicator;
@property (weak, nonatomic) IBOutlet UIView *gaveIndicator;
@property (weak, nonatomic) IBOutlet UILabel *gotLabel;
@property (weak, nonatomic) IBOutlet UILabel *gaveLabel;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;

// highlighting / touch handling
@property (nonatomic, weak) UIView *highlightedView;
@property (nonatomic, strong) UIColor *previousBackgroundColor;
@property (nonatomic, strong) NSTimer *deleteTimer;
@property (nonatomic, assign) BOOL deleteTimerDidFire;
@end

@implementation SWValueKeyboard

+ (instancetype)instanciateFromNibFile {
  UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
  return [[nib instantiateWithOwner:self options:nil] firstObject];
}

- (void)awakeFromNib {
  [super awakeFromNib];

  // style indicator views
  self.gotIndicator.backgroundColor = SWColorIndicatorGreen();
  self.gotIndicator.layer.cornerRadius = CGRectGetWidth(self.gotIndicator.frame)/2.0;
  self.gaveIndicator.backgroundColor = SWColorIndicatorRed();
  self.gaveIndicator.layer.cornerRadius = CGRectGetWidth(self.gaveIndicator.frame)/2.0;

  // localize buttons
  self.doneLabel.text = NSLocalizedString(@"keyDone", nil);
  self.gotLabel.text = NSLocalizedString(@"keyGave", nil);
  self.gaveLabel.text =   NSLocalizedString(@"keyGot", nil);

  // safe area adjustment
  CGFloat safeBottomMargin = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] safeAreaInsets].bottom;
  self.frameHeight += safeBottomMargin;

  // dark mode fixes
  self.backgroundColor = SWColorKeyboardBackground();
  self.backButton.tintColor = SWColorKeyboardTextColor();
  for (UIView *view in self.allButtons) {
    CGFloat brightness = 0;
    [view.backgroundColor getWhite:&brightness alpha:nil];
    view.backgroundColor = colorWithLightAndDarkVersion(view.backgroundColor,
                                                        [UIColor colorWithWhite:brightness*0.22 alpha:1.0]);

    [self labelForView:view].textColor = SWColorKeyboardTextColor();
  }
  self.doneLabel.textColor = SWColorKeyboardDoneButtonColor();
}

- (NSString *)doneButtonText {
  return self.doneLabel.text;
}

- (void)setDoneButtonText:(NSString *)doneButtonText {
  self.doneLabel.text = doneButtonText;
}

- (void)setHidesGotGave:(BOOL)hidesGotGave {
  _hidesGotGave = hidesGotGave;

  CGFloat alpha = hidesGotGave ? 0.33 : 1.0;
  self.gaveIndicator.alpha = alpha;
  self.gaveLabel.alpha = alpha;
  self.gotIndicator.alpha = alpha;
  self.gotLabel.alpha = alpha;
}

#pragma mark touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  UIView *button = [self viewForTouches:touches event:event];
  [self setHighlightedView:button];
  [self resetDeleteTimerForView:button];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  UIView *button = [self viewForTouches:touches event:event];
  [self setHighlightedView:button];
  [self resetDeleteTimerForView:button];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  [self setHighlightedView:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  UIView *button = [self viewForTouches:touches event:event];
  BOOL didRepeatDelete = (button == self.backButton && self.deleteTimerDidFire);
  if (!didRepeatDelete) [self handleTouchUpForButton:button];
  [self setHighlightedView:nil];
  [self cancelDeleteTimer];
}

#pragma mark actions

- (void)handleTouchUpForButton:(UIView*)sender {
  if (!self.didTouchKeyBlock || !sender) return;

  // play input sound
  [[UIDevice currentDevice] playInputClick];

  NSString *value = [self labelForView:sender].text;
  SWValueKeyboardKeyType type = SWValueKeyboardKeyTypeNumber;

  // delete
  if (sender == self.backButton) {
    type = SWValueKeyboardKeyTypeDelete;
  }

  // separator
  else if (sender == self.separatorButton) {
    type = SWValueKeyboardKeyTypeSeparator;
  }

  // top buttons
  else if (![self.mainButtons containsObject:sender]) {
    if (sender.tag == 0) {
      type = SWValueKeyboardKeyTypeGave;
    } else if (sender.tag == 1) {
      type = SWValueKeyboardKeyTypeGot;
    } else if (sender.tag == 2) {
      type = SWValueKeyboardKeyTypeDone;
    }
  }

  // call callback
  self.didTouchKeyBlock(type, value);
}

#pragma mark UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
  return YES;
}

#pragma mark helper

- (UIView*)viewForTouches:(NSSet*)touches event:(UIEvent*)event {
  CGPoint location = [[touches anyObject] locationInView:self];

  // find view
  UIView *view = nil;
  for (UIView *button in self.allButtons) {
    CGRect rect = [self convertRect:button.frame fromView:button.superview];
    if (CGRectContainsPoint(rect, location)) {
      view = button;
      break;
    }
  }

  return view;
}

- (UILabel*)labelForView:(UIView*)view {
  for (UIView* subview in view.subviews) {
    if ([subview isKindOfClass:[UILabel class]]) {
      return (id)subview;
    }
  }
  return nil;
}

- (void)setHighlightedView:(UIView *)highlightedView {
  if (highlightedView == self.highlightedView) return;

  // reset previous view state
  self.highlightedView.backgroundColor = self.previousBackgroundColor;

  // remember current view + color
  _highlightedView = highlightedView;
  self.previousBackgroundColor = highlightedView.backgroundColor;

  // build highlighted color
  CGFloat hue=0, sat=0, bright=0;
  [highlightedView.backgroundColor getHue:&hue saturation:&sat brightness:&bright alpha:nil];
  UIColor *highlightedColor = colorWithLightAndDarkVersionForTraitCollection(self.traitCollection,
                                                                             [UIColor colorWithHue:hue saturation:sat*1.25 brightness:bright*0.88 alpha:1.0],
                                                                             [UIColor colorWithHue:hue saturation:sat*1.33 brightness:bright*0.7 alpha:1.0]);

  // update view state
  highlightedView.backgroundColor = highlightedColor;
}

#pragma mark separator value

- (NSString *)separatorString {
  return [[self labelForView:self.separatorButton] text];
}

- (void)setSeparatorString:(NSString *)separatorString {
  [[self labelForView:self.separatorButton] setText:separatorString];
}

#pragma mark Delete timer

- (void)resetDeleteTimerForView:(UIView*)view {
  if (view == self.backButton) {
    [self resetDeleteTimer];
  } else {
    [self cancelDeleteTimer];
  }
}

- (void)resetDeleteTimer {
  [self cancelDeleteTimer];
  self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:SWValueKeyboardDeleteRepeatInterval
                                                      target:self
                                                    selector:@selector(handleDeleteTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)cancelDeleteTimer {
  self.deleteTimerDidFire = NO;
  [self.deleteTimer invalidate];
  self.deleteTimer = nil;
}

- (void)handleDeleteTimer:(NSTimer*)timer {
  self.deleteTimerDidFire = YES;
  [self handleTouchUpForButton:self.backButton];
}

#pragma mark adaptive layout

- (void)setKeyboardWidth:(CGFloat)keyboardWidth {
  if (self.containerView.frameWidth != keyboardWidth) {
    self.containerView.frameWidth = keyboardWidth;
    self.containerView.frameX = floor((self.frameWidth-keyboardWidth)/2.0);
    [self setNeedsLayout];
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat buttonWidth = floor((self.containerView.frameWidth-2)/3.0);
  CGFloat buttonWidthCenter = ceil((self.containerView.frameWidth-2)/3.0);

  // reposition buttons for width
  for (NSInteger i=0; i<self.allButtons.count; i+=3) {
    UIView *left = self.allButtons[i];
    left.frameX = 0;
    left.frameWidth = buttonWidth;

    UIView *middle = self.allButtons[i+1];
    middle.frameX = left.frameRight+1;
    middle.frameWidth = buttonWidthCenter;

    UIView *right = self.allButtons[i+2];
    right.frameWidth = buttonWidth;
    right.frameX = middle.frameRight+1;
  }

  // resize labels
  [self.gotLabel sizeToFit];
  [self.gaveLabel sizeToFit];

  // center indicators & labels within button
  CGFloat indicatorOffset = 8.0;
  UIView *gotButton = self.topButtons[0];
  CGFloat gotOffset = (gotButton.frameWidth-self.gotLabel.frameWidth-indicatorOffset-self.gotIndicator.frameWidth)/2.0;
  self.gotIndicator.frameX = gotOffset;
  self.gotLabel.frameX = self.gotIndicator.frameRight + indicatorOffset;
  self.gotLabel.frameY = 0;
  self.gotLabel.frameHeight = gotButton.frameHeight;
  UIView *gaveButton = self.topButtons[1];
  CGFloat gaveOffset = (gaveButton.frameWidth-self.gaveLabel.frameWidth-indicatorOffset-self.gaveIndicator.frameWidth)/2.0;
  self.gaveIndicator.frameX = gaveOffset;
  self.gaveLabel.frameX = self.gaveIndicator.frameRight + indicatorOffset;
  self.gaveLabel.frameY = 0;
  self.gaveLabel.frameHeight = gaveButton.frameHeight;
}

@end
