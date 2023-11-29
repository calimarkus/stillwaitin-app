//
//  SharingEditTextViewController.m
//  StillWaitin
//
//

#import "SharingEditTextViewController.h"

#import "SWColors.h"
#import <SimpleUIKit/UIView+SimplePositioning.h>

@interface SharingEditTextViewController () <UITextViewDelegate>
@end

@implementation SharingEditTextViewController {
  NSString *_originalText;
  NSArray<NSString *> *_keywords;
  UITextView *_textView;
}

- (instancetype)initWithText:(NSString *)text
                    keywords:(NSArray<NSString *> *)keywords {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _originalText = text;
    _keywords = keywords;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _textView = [[UITextView alloc] initWithFrame:CGRectOffset(CGRectInset(self.view.bounds, 12, 0), 12, 0)];
  _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _textView.text = _originalText;
  _textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  _textView.delegate = self;
  [self.view addSubview:_textView];

  self.view.backgroundColor = _textView.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  _textView.inputAccessoryView = [self _createInputAccessoryView];
  [_textView becomeFirstResponder];
}

#pragma mark - Custom Keyboard Accessory View

- (UIView *)_createInputAccessoryView {
  if (_keywords.count > 0) {
    const double buttonMargin = 18;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = SWColorGrayWash();
    scrollView.frameHeight = 40.0;
    scrollView.contentSize = CGSizeMake(buttonMargin, scrollView.frameHeight);

    for (NSString *keyword in _keywords) {
      UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
      button.tintColor = SWColorGreenContrastTintColor();
      [button setTitle:keyword forState:UIControlStateNormal];
      [button addTarget:self action:@selector(keywordTapped:) forControlEvents:UIControlEventTouchUpInside];
      [button sizeToFit];
      button.frameHeight = scrollView.frameHeight;
      button.frameX = scrollView.contentSize.width;
      [scrollView addSubview:button];
      scrollView.contentSize = CGSizeMake(button.frameRight + buttonMargin, scrollView.frameHeight);
    }

    return scrollView;
  } else {
    return nil;
  }
}

#pragma mark - Keyboard Notifications

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
  CGRect rawKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  const CGRect textViewFrameInWindowCoordinates = [_textView convertRect:_textView.bounds toView:_textView.window];
  const CGRect intersectionRect = CGRectIntersection(textViewFrameInWindowCoordinates, rawKeyboardFrame);
  _textView.contentInset = (UIEdgeInsets){ .bottom = CGRectGetHeight(intersectionRect) };
  _textView.scrollIndicatorInsets = _textView.contentInset;
}

#pragma mark - Interaction

- (void)textViewDidChange:(UITextView *)textView {
  if ([textView.text isEqualToString:_originalText]) {
    [self.navigationItem setLeftBarButtonItems:nil animated:YES];
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
  } else {
    if (self.navigationItem.rightBarButtonItem == nil) {
      [self.navigationItem setLeftBarButtonItems:@[[[UIBarButtonItem alloc]
                                                    initWithTitle:NSLocalizedString(@"keyReset", nil)
                                                    style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(resetButtonTouched:)]]
                                        animated:YES];
      [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc]
                                                     initWithTitle:NSLocalizedString(@"keySave", nil)
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(saveButtonTouched:)]]
                                         animated:YES];
    }
  }
}

- (void)keywordTapped:(UIButton *)button {
  [_textView replaceRange:_textView.selectedTextRange withText:[button titleForState:UIControlStateNormal]];
  [self textViewDidChange:_textView];
}

- (void)resetButtonTouched:(id)sender {
  _textView.text = _originalText;
  [self.navigationItem setLeftBarButtonItems:nil animated:YES];
  [self.navigationItem setRightBarButtonItems:nil animated:YES];
}

- (void)saveButtonTouched:(id)sender {
  if (_didSaveBlock) {
    _didSaveBlock(_textView.text);
  }
}

@end
