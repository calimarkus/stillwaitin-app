//
//  PasswordViewController.m
//  StillWaitin
//

#import "PasswordViewController.h"
#import "SWColors.h"
#import "SWValueKeyboard.h"

#import <LocalAuthentication/LocalAuthentication.h>
#import <SAMKeychain/SAMKeychain.h>
#import <SimpleUIKit/UIAlertController+SimpleUIKit.h>
#import <SimpleUIKit/UIView+SimplePositioning.h>

NSString *const SWPasswordKeychainAccount = @"SWPasswordKeychainAccount";
NSString *const SWPasswordKeychainService = @"SWPasswordKeychainKey";

NSString *const SWLastEnteredUserDefaultsKey = @"kKEY_USERDEFAULTS_PW_LAST_ENTERED";
NSString *const SWSilenceTimeIntervalUserDefaultsKey = @"kKEY_USERDEFAULTS_SILENCE_TIME_INTERVAL";

NSTimeInterval const SWDefaultSilenceTimeInterval = 60.0 * 2;

@interface PasswordViewController () <UITextFieldDelegate>
@end

@implementation PasswordViewController {
  UIImageView *_logo;
  UITextField *_textField;
  NSString *_password;

  LAContext *_localAuthContext;
  UIButton *_localAuthButton;

  BOOL _isEvaluating;
  BOOL _dontEvaluateOnBecomeActive;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    _password = [PasswordViewController _storedPassword];

    _localAuthContext = [[LAContext alloc] init];

    [[NSUserDefaults standardUserDefaults] registerDefaults:
     @{SWSilenceTimeIntervalUserDefaultsKey:@(SWDefaultSilenceTimeInterval)}];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidBecomeActive:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResignActive:)
     name:UIApplicationWillResignActiveNotification
     object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = SWColorGreenMain();

  // sw logo "S"
  _logo = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"splash_logo"]];
  _logo.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  _logo.frameX = floor(self.view.frameWidth/2.0-_logo.frameWidth/2.0);
  _logo.frameY = -110;
  _logo.transform = CGAffineTransformMakeScale(0.75, 0.75);
  [self.view addSubview: _logo];

  // password field
  _textField = [[UITextField alloc] init];
  _textField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  _textField.secureTextEntry = YES;
  _textField.autocorrectionType = UITextAutocorrectionTypeNo;
  _textField.frame = CGRectMake((self.view.frameWidth-220)/2.0, 180, 220, 30);
  _textField.borderStyle = UITextBorderStyleRoundedRect;
  _textField.textAlignment = NSTextAlignmentCenter;
  _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  _textField.text = @"";
  _textField.delegate = self;
  [self.view addSubview:_textField];

  // add TouchID button, if device has touchID
  if (!self.editing && [_localAuthContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
    switch (_localAuthContext.biometryType) {
      case LABiometryTypeTouchID: {
        _localAuthButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _localAuthButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_localAuthButton.titleLabel setTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
        [_localAuthButton setTitle:NSLocalizedString(@"keyTouchIDButtonTitle", nil) forState:UIControlStateNormal];
        [_localAuthButton addTarget:self action:@selector(_evaluateLocalAuthOrBecomeFirstResponder) forControlEvents:UIControlEventTouchUpInside];
        _localAuthButton.frame = CGRectOffset(_textField.frame, 0, _textField.frameHeight + 20);
        [self.view addSubview:_localAuthButton];
      }
      case LABiometryTypeFaceID:
      case LABiometryTypeOpticID:
      case LABiometryTypeNone:
        break;
    }
  }

  // keyboard
  [self setupKeyboard];
  if (self.editing) {
    [_textField becomeFirstResponder];
  } else if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
    [self _evaluateLocalAuthOrBecomeFirstResponder];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateKeyboardWidth];

  if (!self.editing
      && _shouldEvaluateOnWillAppear
      && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
    [self _evaluateLocalAuthOrBecomeFirstResponder];
  }
}

#pragma mark class methods

+ (BOOL)shouldEnterPassword {
  // check, if a password is set
  if (![self _storedPassword]) {
    return NO;
  } else {
    // check, when the pw was entered the last time
    NSTimeInterval lastEntered = [[[NSUserDefaults standardUserDefaults] objectForKey:SWLastEnteredUserDefaultsKey] doubleValue];
    NSTimeInterval timeSinceLastEntered = [[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:lastEntered]];
    NSTimeInterval noPasswordDuration = [[NSUserDefaults standardUserDefaults] doubleForKey:SWSilenceTimeIntervalUserDefaultsKey];
    if(timeSinceLastEntered < noPasswordDuration) {
      return NO;
    }

    return YES;
  }
}

#pragma mark - ValueKeyboard

- (void)setupKeyboard {
  if (!_textField.inputView)
  {
    SWValueKeyboard *valueKeyboard = [SWValueKeyboard instanciateFromNibFile];
    if (self.isEditing) {
      valueKeyboard.doneButtonText = NSLocalizedString(@"keySave", nil);
    }
    valueKeyboard.separatorString = @"";
    valueKeyboard.hidesGotGave = YES;

    __weak typeof(self) weakSelf = self;
    __weak typeof(_textField) weakTextField = _textField;
    valueKeyboard.didTouchKeyBlock = ^(SWValueKeyboardKeyType type, NSString *value){
      if (type == SWValueKeyboardKeyTypeNumber) {
        weakTextField.text = [weakTextField.text stringByAppendingString:value];
      } else if (type == SWValueKeyboardKeyTypeDelete) {
        if (weakTextField.text.length > 0) {
          weakTextField.text = [weakTextField.text substringToIndex:weakTextField.text.length-1];
        }
      } else if (type == SWValueKeyboardKeyTypeDone) {
        if (weakSelf.editing) {
          [weakSelf savePassword];
        } else {
          [weakSelf checkPassword];
        }
      }
    };

    _textField.inputView = valueKeyboard;
  }
}

- (void)updateKeyboardWidth {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    SWValueKeyboard *valueKeyboard = (SWValueKeyboard*)_textField.inputView;
    [valueKeyboard setKeyboardWidth:self.view.frameWidth];
  }
}

#pragma mark - Notifications

- (void)applicationDidBecomeActive:(NSNotification*)notification {
  if (!_dontEvaluateOnBecomeActive && !_isEvaluating) {
    [self _evaluateLocalAuthOrBecomeFirstResponder];
  }
}

- (void)applicationWillResignActive:(NSNotification*)notification {
  _dontEvaluateOnBecomeActive = NO;
}

#pragma mark - Evaluation

- (void)_evaluateLocalAuthOrBecomeFirstResponder {
  if(!_isEvaluating && [_localAuthContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
    _isEvaluating = YES;
    __weak typeof(self) weakSelf = self;
    [_localAuthContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:NSLocalizedString(@"keyTouchIDFaceIDPrompt", nil)
                              reply:^(BOOL success, NSError * _Nullable error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
          [weakSelf loggedInSuccessfully];
        } else {
          __strong __typeof(weakSelf) strongSelf = weakSelf;
          if (strongSelf) {
            strongSelf->_dontEvaluateOnBecomeActive = YES;
            strongSelf->_isEvaluating = NO;
            [strongSelf->_textField becomeFirstResponder];
          }
        }
      });
    }];
  } else {
    [_textField becomeFirstResponder];
  }
}

- (void)checkPassword {
  if ([_textField.text isEqualToString:_password]) {
    [self loggedInSuccessfully];
  } else {
    [self loginFailed];
  }
}

- (void)loginFailed {
  CGPoint currentCenter = [_textField center];
  CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  shakeAnimation.duration = 0.2;
  shakeAnimation.repeatCount = 2;
  shakeAnimation.values = @[[NSValue valueWithCGPoint:CGPointMake(currentCenter.x,
                                                                  currentCenter.y)],
                            [NSValue valueWithCGPoint:CGPointMake(currentCenter.x - 10.0f,
                                                                  currentCenter.y)],
                            [NSValue valueWithCGPoint:CGPointMake(currentCenter.x + 10.0f,
                                                                  currentCenter.y)],
                            [NSValue valueWithCGPoint:CGPointMake(currentCenter.x,
                                                                  currentCenter.y)]];
  [_textField.layer addAnimation:shakeAnimation forKey:@"position"];
}

- (void)loggedInSuccessfully {
  // save last entered date
  [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970])
                                            forKey:SWLastEnteredUserDefaultsKey];
  [[NSUserDefaults standardUserDefaults] synchronize];

  [_textField resignFirstResponder];
  [self _dismiss];
}

#pragma mark - Dismissal

- (void)_dismiss {
  if (_shouldDismissBlock != nil) {
    _shouldDismissBlock(self);
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self _dismiss];
  return YES;
}

#pragma mark - Editing

- (void)savePassword {
  if ([self _isEnteredTextEqualToPassword]) {
     // no change, just dismiss
    [_textField resignFirstResponder];
    [self _dismiss];
  } else {
    // save changed pw
    const BOOL didSetPassword = ([_textField.text length] > 0);
    if (!didSetPassword) {
      [PasswordViewController _storePassword:nil];
    } else {
      [PasswordViewController _storePassword:_textField.text];
    }

    // delete last entered date
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SWLastEnteredUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [_textField resignFirstResponder];

    __weak typeof(self) weakSelf = self;
    [UIAlertController presentAlertFromViewController:self
                                            withTitle:(didSetPassword ?
                                                       NSLocalizedString(@"keyPasswordSet", nil) :
                                                       NSLocalizedString(@"keyPasswordUnset", nil))
                                              message:nil
                                              buttons:@[[SimpleAlertButton defaultButtonWithTitle:NSLocalizedString(@"keyOk", nil)]]
                                        buttonHandler:^(UIAlertAction *action) {
      [weakSelf _dismiss];
    }];
  }
}

- (BOOL)_isEnteredTextEqualToPassword {
  return [_password ?: @"" isEqualToString:_textField.text ?: @""];
}

#pragma mark - Persistence

+ (NSString *)_storedPassword {
  NSError *error;
  NSString *password = [SAMKeychain passwordForService:SWPasswordKeychainService
                                               account:SWPasswordKeychainAccount
                                                 error:&error];
  if (error) {
    NSLog(@"Problem when reading PW: %@", error);
  }
  return password;
}

+ (void)_storePassword:(NSString *)password {
  NSError *error;
  if (password.length > 0) {
    [SAMKeychain setPassword:password
                  forService:SWPasswordKeychainService
                     account:SWPasswordKeychainAccount
                       error:&error];
  } else {
    [SAMKeychain deletePasswordForService:SWPasswordKeychainService
                                  account:SWPasswordKeychainAccount
                                    error:&error];
  }

  if (error) {
    NSLog(@"Problem when saving PW: %@", error);
  }
}

@end
