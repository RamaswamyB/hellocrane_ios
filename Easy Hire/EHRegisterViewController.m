//
//  EHRegisterViewController.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHRegisterViewController.h"
#import "EHHTTPClient.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MIRadioButtonGroup.h"
#import "EHSettingsViewController.h"
#import "SWRevealViewController.h"
#import "EHServiceViewController.h"
#import "EHEquipmentOwnedListViewController.h"
#import "EHEHEquipmentOwnedMapViewController.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_FIELD_WIDTH 250.0
#define TEXT_FIELD_HEIGHT 30.0

#define LABEL_WIDTH 280.0
#define LABEL_HEIGHT 15.0

#define BUTTON_WIDTH 135.0//220.0
#define BUTTON_HEIGHT 40.0f

#define TEXT_LABEL_PADDING 30.0

#define GROUP_WIDTH 200.0f
#define GROUP_HEIGHT 30.0f

#define ACCEPTABLE_CHARECTERS_MOBILE_NUMBER @"0123456789"
#define ACCEPTABLE_CHARECTERS_OTP_NUMBER @"0123456789"
#define TITLE_REGISTRATION_FAILED @"Registration Failed."
#define PASSWORD_FIELD @" "
#define OTP_VIEW_HEIGHT 100.0f
UIKeyboardType keyboardTypeForTextFieldType(EHTextFieldType type)
{
    switch (type) {
        case kEHMobileNumberField:return UIKeyboardTypePhonePad;
        case kEHPasswordFiled: return UIKeyboardTypeNumbersAndPunctuation;
        default:return UIKeyboardTypeDefault;
    }
}
@interface RegistrationFormTextField : UITextField

@property (nonatomic, strong) CALayer *underlineLayer;

@end

@implementation RegistrationFormTextField
@end

void underLineForRegistrationTextField(RegistrationFormTextField *textField)
{
    CALayer *layer = [CALayer layer];
    CGFloat borderWidth = 2;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderWidth = borderWidth;
    textField.underlineLayer = layer;
    [textField.layer addSublayer:textField.underlineLayer];
    textField.layer.masksToBounds = YES;
}

const NSString *EHPlaceholderMessageForType(EHTextFieldType type)
{
    switch (type) {
        case kEHUserFirstNameField: return @"Enter your first name.";
        case kEHUserLastNameField: return @"Enter your last name.";
        case kEHCompanyNameField: return @"Enter your company name";
        case kEHMobileNumberField: return @"Enter your mobile number";
        case kEHPasswordFiled: return @"Enter your password";
        case kEHEmailField: return @"Enter your email";
    }
}
extern NSString *EHValidationMessageForType(EHTextFieldType type)
{
    switch (type) {
        case kEHUserFirstNameField: return @"First name should not be blank";
        case kEHUserLastNameField: return @"Last name should not be blank";
        case kEHCompanyNameField: return @"Company name should not be blank";
        case kEHMobileNumberField: return @"Enter valid mobile number";
        case kEHPasswordFiled: return @"Please ensure that you have entered at least six characters and also you can't insert more than 15 characters";
        case kEHEmailField: return @"Please enter valid email";
    }
}
NSString *EHUserRoleNameeForType(UserType type)
{
    switch (type) {
        case kUserTypeSupplier:return @"ROLE_PROVIDER";
        case kUserTypeCustomer: return @"ROLE_CUSTOMER";
        }
}


NSString *EHRegistrationURLForType(HTTPClientType type)
{
    switch (type) {
        case kHTTPClientTypeRegistration: return REGISTRATION_URL;
        case kHTTPClientTypeGetOTP: return GET_OTP_URL;
        case kHTTPClientTypeSendOTP: return SEND_OTP_URL;
        case kHTTPClientTypeReLogin: return RELOGIN_URL;
        default: return nil;
    }
}

typedef void (^OTPHandlerViewSubmitOTP)(NSString *);
typedef void (^OTPHandlerViewResendOTP)(void);
typedef void (^OTPHandlerViewCloseOTP)(void);

@interface OTPHandlerView : UIView

@property (nonatomic, copy) NSString *message;

@end

@interface OTPHandlerView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *otpBackgroundView;
@property (nonatomic, strong) UILabel *otpTimerLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSTimer *otpTimer;
@property (nonatomic, strong) RegistrationFormTextField *otpTextField;
@property (nonatomic, strong) UIButton *otpSubmitButton;
@property (nonatomic, strong) UIButton *otpRetryButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, copy) OTPHandlerViewSubmitOTP submitOTPBlock;
@property (nonatomic, copy) OTPHandlerViewResendOTP resendOTPBlock;
@property (nonatomic, copy) OTPHandlerViewCloseOTP closeOTPBlock;


- (instancetype)initWithFrame:(CGRect)frame submitOTPBlock:(OTPHandlerViewSubmitOTP)submitBlock resendOTPBlock:(OTPHandlerViewResendOTP)resendBlock closeOTP:(OTPHandlerViewCloseOTP)closeOTP;

@end

@implementation OTPHandlerView
{
    int seconds;
}
- (instancetype)initWithFrame:(CGRect)frame submitOTPBlock:(OTPHandlerViewSubmitOTP)submitBlock resendOTPBlock:(OTPHandlerViewResendOTP)resendBlock closeOTP:(OTPHandlerViewCloseOTP)closeOTP
{
    if (self = [super initWithFrame:frame]) {
       
        _otpBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _otpBackgroundView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_otpBackgroundView];
        
        _otpTimerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _otpTimerLabel.textAlignment = NSTextAlignmentCenter;
        _otpTimerLabel.textColor = [UIColor blackColor];
        _otpTimerLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _otpTimerLabel.backgroundColor = [UIColor whiteColor];
        [_otpBackgroundView addSubview:_otpTimerLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor redColor];
        _messageLabel.font = [UIFont systemFontOfSize:15.0f];
        _messageLabel.backgroundColor = [UIColor whiteColor];
        [_otpBackgroundView addSubview:_messageLabel];
        
        _otpTextField = [[RegistrationFormTextField alloc] initWithFrame:CGRectZero];
        _otpTextField.placeholder = @"Enter OTP received";
        _otpTextField.borderStyle = UITextBorderStyleNone;
       // _otpTextField.backgroundColor = [UIColor lightGrayColor];
        _otpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _otpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _otpTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        _otpTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _otpTextField.returnKeyType = UIReturnKeyDone;
        _otpTextField.delegate = self;
        _otpTextField.keyboardType = UIKeyboardTypePhonePad;
        _otpTextField.font = [UIFont systemFontOfSize:15];
        underLineForRegistrationTextField(_otpTextField);
        [_otpBackgroundView addSubview:_otpTextField];
        
        _otpSubmitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_otpSubmitButton addTarget:self action:@selector(submitOPTButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_otpSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
        _otpSubmitButton.enabled = NO;
        [_otpBackgroundView addSubview:_otpSubmitButton];
        
        _otpRetryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_otpRetryButton addTarget:self action:@selector(resendOPTButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_otpRetryButton setTitle:@"Retry" forState:UIControlStateNormal];
        _otpRetryButton.enabled = NO;
        [_otpBackgroundView addSubview:_otpRetryButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:@"UIKeyboardWillShowNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:@"UIKeyboardDidHideNotification"
                                                   object:nil];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(closeButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.frame = CGRectMake(0, 0, 40, 40);
        [_closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [_otpBackgroundView addSubview:_closeButton];
        
        _submitOTPBlock = [submitBlock copy];
        _resendOTPBlock = [resendBlock copy];
        _closeOTPBlock = closeOTP;
        
        seconds = 120;
        [self startTimer];
        
    }
    return self;
    
}
- (void)setMessage:(NSString *)message
{
    _message = message;
    _messageLabel.text = message;
}
- (void)startTimer
{
    _otpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    [_otpTimer fire];
}

- (void)updateTimer:(NSTimer *)timer
{
    if(seconds > 0 && seconds <= 120)
    {
        seconds--;
        
        int min = (seconds / 60) % 60;
        int sec = seconds % 60;
        _otpTimerLabel.text = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    }
    else if(seconds == 0)
    {
        if(timer != nil)
        {
            [_otpTimer invalidate];
            _otpTimer = nil;
        }
        
        _otpRetryButton.enabled = YES;
       // [self showInvalidErrorMessage:@"Something went wrong.Please try again later" title:@"Message!"];
    }
}
- (IBAction)closeButtonEvent:(id)sender
{
    [_otpTimer invalidate];
    _otpTimer = nil;
    
    [_otpTextField resignFirstResponder];
    _closeOTPBlock();
    
}
- (IBAction)submitOPTButtonEvent:(id)sender
{
    [_otpTimer invalidate];
    _otpTimer = nil;
    [_otpTextField resignFirstResponder];
    _submitOTPBlock(_otpTextField.text);
    _submitOTPBlock = nil;
    
    
}
- (IBAction)resendOPTButtonEvent:(id)sender
{
    [_otpTimer invalidate];
    _otpTimer = nil;
    [_otpTextField resignFirstResponder];
    _resendOTPBlock();
    _resendOTPBlock = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    _otpBackgroundView.frame = (CGRect){
        .origin.x = 2,
        .origin.y = (CGRectGetHeight(bounds) - OTP_VIEW_HEIGHT)/2,
        .size.width = CGRectGetWidth(bounds) - 4,
        .size.height = OTP_VIEW_HEIGHT,
    };
    
    _otpTimerLabel.frame = (CGRect){
        .origin.x = 0,
        .origin.y = CGRectGetHeight(_otpBackgroundView.bounds) - 40,
        .size.width = 60,
        .size.height = 40,
    };
    
    _closeButton.frame = (CGRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = 40,
        .size.height = 40
    };

    
    _otpTextField.frame = (CGRect){
        .origin.x = CGRectGetWidth(_closeButton.bounds) + 5,
        .origin.y = 2,
        .size.width = TEXT_FIELD_WIDTH,
        .size.height = TEXT_FIELD_HEIGHT,
    };
    
    _otpTextField.underlineLayer.frame = CGRectMake(0, _otpTextField.bounds.size.height - 2, _otpTextField.bounds.size.width, 1);
    
    _otpSubmitButton.frame = (CGRect){
        .origin.x = CGRectGetMidX(_otpBackgroundView.bounds),
        .origin.y = CGRectGetHeight(_otpBackgroundView.bounds) - 40,
        .size.width = 60,
        .size.height = 40,
    };
    _otpRetryButton.frame = (CGRect){
        .origin.x = CGRectGetMidX(_otpBackgroundView.bounds) - 70,
        .origin.y = CGRectGetHeight(_otpBackgroundView.bounds) - 40,
        .size.width = 60,
        .size.height = 40,
    };
    
    _messageLabel.frame = (CGRect){
        .origin.x = 0,
        .origin.y = CGRectGetHeight(_otpTextField.frame) + 1,
        .size.width = CGRectGetWidth(_otpBackgroundView.bounds),
        .size.height = 25,
    };
}
//- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
//{
//    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:nil completionBlock:^(EHAlertPromptHelper *alert,NSUInteger index){
//
//        [self removeFromSuperview];
//    }];
//}
- (void)keyboardWillShow:(NSNotification *)note {
    
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float diff = CGRectGetHeight(self.bounds) - kbSize.height;
    diff = MAX(CGRectGetMaxY(_otpBackgroundView.frame) - diff, 0);
    // move the view up by 30 pts
    
    CGRect frame = _otpBackgroundView.frame;
    frame.origin.y -= diff;
    
    [UIView animateWithDuration:0.3 animations:^{
        _otpBackgroundView.frame = frame;
    }];
}
- (void)keyboardDidHide:(NSNotification *)note {
    
    // move the view back to the origin
    CGRect frame = _otpBackgroundView.frame;
    frame.origin.y += 30;
    
    [UIView animateWithDuration:0.3 animations:^{
        _otpBackgroundView.frame = (CGRect){
            .origin.x = 2,
            .origin.y = (CGRectGetHeight(self.bounds) - OTP_VIEW_HEIGHT)/2,
            .size.width = CGRectGetWidth(self.bounds) - 4,
            .size.height = OTP_VIEW_HEIGHT,
        };
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *resultString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_OTP_NUMBER] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL result = [string isEqualToString:filtered] && resultString.length <= 4;
    _otpSubmitButton.enabled = resultString.length >= 4;
    return result;

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end


@interface EHRegisterViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *formScrollView;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) EHHTTPClient *httpClient;
//@property (nonatomic, strong) MIRadioButtonGroup *userGroup;
@property (nonatomic, strong) OTPHandlerView *otpView;
@end

@implementation EHRegisterViewController
{
    RegistrationFormTextField *formTextField[6];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.title = @"Registration";
    // Set up tap gesture recognizer
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    

    _formScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_formScrollView];
    
    for (int i = 0; i<6; i++) {
       formTextField[i] = [self addFormTextFieldForIndex:i];
        [_formScrollView addSubview:formTextField[i]];
    }
    formTextField[4].secureTextEntry = YES;

//    NSArray *options =[[NSArray alloc]initWithObjects:@"Supplier",@"Customer",nil];
//    _userGroup = [[MIRadioButtonGroup alloc]initWithFrame:CGRectMake(0, 0, GROUP_WIDTH, GROUP_HEIGHT) andOptions:options andColumns:2];
//    [_userGroup setSelected:kUserTypeSupplier];
//    [_formScrollView addSubview:_userGroup];
    
    _registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_registerButton addTarget:self action:@selector(registerButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton setTitle:@"REGISTER" forState:UIControlStateNormal];
    [_formScrollView addSubview:_registerButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cancelButton addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    [_formScrollView addSubview:_cancelButton];

    
    [self.navigationController setNavigationBarHidden:NO];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // [self showOTPHandlerView:@"You have entered wrong OTP."];
}
- (RegistrationFormTextField *)addFormTextFieldForIndex:(NSUInteger)index
{
    RegistrationFormTextField *textField = [[RegistrationFormTextField alloc] initWithFrame:CGRectZero];
    textField.tag = index;
    textField.font = [UIFont systemFontOfSize:15];
    textField.borderStyle = UITextBorderStyleNone;
   // textField.backgroundColor = [UIColor lightGrayColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
   // textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
    textField.placeholder = EHPlaceholderMessageForType(index);
    underLineForRegistrationTextField(textField);
    textField.keyboardType = keyboardTypeForTextFieldType(index);
    return textField;
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.view.bounds;
    
    _formScrollView.frame = frame;
    
    for (int i = 0; i<6; i++) {
        
        RegistrationFormTextField *textField = formTextField[i];
        textField.frame = (CGRect){
            .origin.x = CGRectGetMidX(frame) - (TEXT_FIELD_WIDTH)/2,
            .origin.y = TEXT_FIELD_HEIGHT * i + TEXT_LABEL_PADDING * i + 20,
            .size.width = TEXT_FIELD_WIDTH,
            .size.height = TEXT_FIELD_HEIGHT,
        };
     
        textField.underlineLayer.frame = CGRectMake(0, textField.bounds.size.height - 2, textField.bounds.size.width, 1);
    }
    
//    _userGroup.frame = (CGRect){
//        .origin.x = CGRectGetMidX(frame) - (GROUP_WIDTH)/2,
//        .origin.y = CGRectGetMaxY(formTextField[5].frame) + 10,
//        .size.width = GROUP_WIDTH,
//        .size.height = GROUP_HEIGHT,
//    };
    
    _registerButton.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (BUTTON_WIDTH)/2,
        .origin.y = CGRectGetMaxY(formTextField[5].frame) + /*CGRectGetMidY(formTextField[4].bounds)*/+ 15,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    
//    _cancelButton.frame = (CGRect) {
//        .origin.x = CGRectGetMinX(formTextField[0].frame),
//        .origin.y = CGRectGetMaxY(formTextField[5].frame) + /*CGRectGetMidY(formTextField[4].bounds)*/+ 15,
//        .size.width = BUTTON_WIDTH,
//        .size.height = BUTTON_HEIGHT,
//        
//    };
    
    _registerButton.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - BUTTON_WIDTH) / 2,
        .origin.y = CGRectGetMaxY(formTextField[5].frame) + /*CGRectGetMidY(formTextField[4].bounds)*/+ 15,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    
//    _registerButton.frame = (CGRect) {
//        .origin.x = CGRectGetMinX(formTextField[5].frame),
//        .origin.y = CGRectGetMaxY(formTextField[5].frame) + /*CGRectGetMidY(formTextField[4].bounds)*/+ 15,
//        .size.width = BUTTON_WIDTH,
//        .size.height = BUTTON_HEIGHT,
//        
//    };
    
    _formScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetMaxY(_registerButton.frame));
}

- (void)viewTapped:(id)sender {
    
    // Dismiss keyboard
    [self dismissKeyboard];
}
- (void)dismissKeyboard
{
    for (int i = 0; i <=5; i++) {
        [formTextField[i] resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (int i = 0; i < 5; i++) {
        if (formTextField[i].tag == textField.tag + 1) {
            [self setFocusOnTextField:formTextField[i]];
        }
    }
    
    return YES;
}
- (void)setFocusOnTextField:(UITextField *)textField
{
    [textField becomeFirstResponder];
}

- (void)sendQueryForURL:(NSString *)url forClientType:(HTTPClientType)type forClientMethod:(NSString *)method
{
    weakify(self);
    _httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        strongify(self);
        _httpClient.tag = type;
        
        NSDictionary *registrationDict = nil;
        
        if (type == kHTTPClientTypeRegistration) {
            
            registrationDict = @{
                                 
                                 @"first_name"    : self->formTextField[0].text,
                                 @"last_name"     : self->formTextField[1].text,
                                 @"company_name"  : self->formTextField[2].text,
                                 @"mobile_number" : self->formTextField[3].text,
                                 @"password"      : self->formTextField[4].text,
                                 @"email"         : self->formTextField[5].text,
                                 @"role"          : EHUserRoleNameeForType(kUserTypeCustomer)
                                 };
        }
        else if (type == kHTTPClientTypeGetOTP)
        {
            registrationDict = nil;
        }
        else if (type == kHTTPClientTypeSendOTP)
        {
            registrationDict = @{
                                 @"otp" : _otpView.otpTextField.text,
                                 };
        }
        else if (type == kHTTPClientTypeLogin)
        {
            registrationDict = nil;// @{
              
//              @"mobile_number": formTextField[3].text,
//              @"password"     : formTextField[4].text
//              };
        }
        
        return registrationDict;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if(self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            if (type == kHTTPClientTypeGetOTP || type == kHTTPClientTypeSendOTP) {
                
                [self hideOTPHandlerView];
                [self showOTPHandlerView:@"Something went wrong.Try again."];
            }
            
            else
                [self showInvalidErrorMessage:[error localizedDescription] title:TITLE_REGISTRATION_FAILED];
        }
        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            NSDictionary *userProfileDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (type == kHTTPClientTypeRegistration) {
                
                if (userProfileDict[@"errors"] != nil) {
                    
                    [self showInvalidErrorMessage:([userProfileDict[@"errors"] firstObject] != nil) ? [userProfileDict[@"errors"] firstObject][@"message"] : @"Something went wrong.Please try again later." title:@"Message!"];
                }
                else
                {
                    
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    userDefault.usermobile = ObjectOrNullInstance(userProfileDict[@"mobile_number"]);
                    
                    /*
                     userDefault.password = formTextField[4].text;
                     userDefault.companyName = ObjectOrNullInstance(userProfileDict[@"company_name"]);
                     userDefault.userEmail = ObjectOrNullInstance(userProfileDict[@"email"]);
                     userDefault.firstName = ObjectOrNullInstance(userProfileDict[@"first_name"]);
                     userDefault.lastName = ObjectOrNullInstance(userProfileDict[@"last_name"]);
                     */
                    userDefault.userid = [userProfileDict[@"id"] integerValue];
                    // userDefault.userType = [_userGroup getSelectedIndex];
                    [userDefault save];
                    
                    
                    [self getOTPForUserID:[[NSUserDefaults standardUserDefaults] userid]];
                }
            }
            else if (type == kHTTPClientTypeGetOTP)
            {
                [self showOTPHandlerView:nil];
                
            }
            else if(type == kHTTPClientTypeSendOTP)
            {
                NSString *result = ObjectOrNullInstance(userProfileDict[@"status"]);
                if ([result isEqualToString:@"SUCCESS"]) {
                    
                    //OTP entered successfully
                    [self hideOTPHandlerView];
                    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                    userDefault.password = formTextField[4].text;
                    [userDefault save];
                    [self relogin];
                }
                else
                {
                    // Wrong otp entered
                    [self showOTPHandlerView:@"You have entered wrong OTP."];
                }
                
                
                
            }
            else if (type == kHTTPClientTypeLogin)
            {
                NSDictionary *userDetailsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if (![[EHValidateWrapper sharedInstance] isNullDictionary:userDetailsDict]) {
                    
                    NSUserDefaults *userDetailsDefaults = [NSUserDefaults standardUserDefaults];
                    userDetailsDefaults.userEmail = ObjectOrNullInstance(userDetailsDict[@"email"]);
                    userDetailsDefaults.usermobile = formTextField[3].text;
                    userDetailsDefaults.password = formTextField[4].text;
                    userDetailsDefaults.firstName = ObjectOrNullInstance(userDetailsDict[@"first_name"]);
                    userDetailsDefaults.userid =  [userDetailsDict[@"id"] integerValue];
                    userDetailsDefaults.lastName = ObjectOrNullInstance(userDetailsDict[@"last_name"]);
                    userDetailsDefaults.userType = [ObjectOrNullInstance(userDetailsDict[@"role"]) isEqualToString:@"ROLE_CUSTOMER"]? kUserTypeCustomer : kUserTypeSupplier;
                    [userDetailsDefaults save];
                    
                    
                    /*
                    UINavigationController *frontNavigationController = nil;
                    
                    if ([[NSUserDefaults standardUserDefaults] userType] == kUserTypeSupplier) {
                        EHEquipmentOwnedListViewController *listViewController = [[EHEquipmentOwnedListViewController alloc] init];
                        EHEHEquipmentOwnedMapViewController *mapViewController = [[EHEHEquipmentOwnedMapViewController alloc] init];
                        
                        UITabBarController *controller = [[UITabBarController alloc] init];
                        controller.viewControllers = @[listViewController,mapViewController];
                        controller.selectedIndex = 1;
                        controller.selectedIndex = 0;
                        
                        frontNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                        
                    }
                    else
                    {
                        EHServiceViewController *controller = [[EHServiceViewController alloc] init];
                        frontNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                    }
                    
                    EHSettingsViewController *settingsViewController = [[EHSettingsViewController alloc] init];
                    
                    
                    ;
                    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
                    
                    SWRevealViewController *mainRevealController = [[SWRevealViewController alloc]initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
                    
                    [self.navigationController pushViewController:mainRevealController animated:NO];
                    */
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_RELOGIN object:nil];
                }
                else
                {
                    [self showInvalidErrorMessage:@"Something went wrong.Please try again later" title:TITLE_REGISTRATION_FAILED];
                }
            }

        }
        
        
    }];
    [_httpClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}
- (void)hideOTPHandlerView
{
    if (_otpView) {
        
        [_otpView removeFromSuperview];
        _otpView = nil;
        
    }
}
- (void)showOTPHandlerView:(NSString *)message
{
    [self hideOTPHandlerView];
    
    _otpView = [[OTPHandlerView alloc] initWithFrame:self.view.bounds submitOTPBlock:^(NSString *otp){
        
        [self sendQueryForURL:[NSString stringWithFormat:EHRegistrationURLForType(kHTTPClientTypeSendOTP),[[NSUserDefaults standardUserDefaults] userid]] forClientType:kHTTPClientTypeSendOTP forClientMethod:@"POST"];
        
    }resendOTPBlock:^(void){
        
        [self getOTPForUserID:[[NSUserDefaults standardUserDefaults] userid]];
    }closeOTP:^(void){
        
        [self hideOTPHandlerView];
    }];
    _otpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _otpView.message = message;
    _otpView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:_otpView];
}
- (void)relogin
{
    [self sendQueryForURL:EHRegistrationURLForType(kHTTPClientTypeReLogin) forClientType:kHTTPClientTypeLogin forClientMethod:@"GET"];// POST
}

- (void)getOTPForUserID:(NSUInteger)userID
{
    [self sendQueryForURL:[NSString stringWithFormat:EHRegistrationURLForType(kHTTPClientTypeGetOTP),userID] forClientType:kHTTPClientTypeGetOTP forClientMethod:@"GET"];
}

- (NSString *)trimmedStringForInput:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (IBAction)cancelButtonTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)registerButtonTouched:(id)sender
{
    
    [[NSUserDefaults standardUserDefaults] remove];
    
   if ([self trimmedStringForInput:formTextField[0].text].length <= kNilOptions) {
        [self showInvalidErrorMessage:EHValidationMessageForType(0) title:@"Message!"];
        [formTextField[0] becomeFirstResponder];
        return;
    }
    /*
   else if ([self trimmedStringForInput:formTextField[1].text].length <= kNilOptions)
    {
        [self showInvalidErrorMessage:EHValidationMessageForType(1) title:@"Message!"];
        [formTextField[1] becomeFirstResponder];
        return;
    } */
    /*
    else if ([self trimmedStringForInput:formTextField[2].text].length <= kNilOptions)
    {
        [self showInvalidErrorMessage:EHValidationMessageForType(2) title:@"Message!"];
        [formTextField[2] becomeFirstResponder];
        return;
    }
    */
    else if (![self validatePhone:formTextField[3].text])
    {
        [self showInvalidErrorMessage:EHValidationMessageForType(3) title:@"Message!"];
        [formTextField[3] becomeFirstResponder];
        return;
    }
    
    else if (![self validatePassword:formTextField[4].text])
    {
        [self showInvalidErrorMessage:EHValidationMessageForType(4) title:@"Message!"];
        [formTextField[4] becomeFirstResponder];
        return;
    }
    
    else if ([self trimmedStringForInput:formTextField[5].text].length > 0)//![self validEmail:formTextField[5].text]
    {
        if (![self validEmail:formTextField[5].text]) {
            [self showInvalidErrorMessage:EHValidationMessageForType(5) title:@"Message!"];
            [formTextField[5] becomeFirstResponder];
            return;
        }
    }
    
    [self dismissKeyboard];
    
    [self sendQueryForURL:EHRegistrationURLForType(kHTTPClientTypeRegistration) forClientType:kHTTPClientTypeRegistration forClientMethod:@"POST"];
}

- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^[1-9][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}
- (BOOL) validEmail:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    NSLog(@"%lu", (unsigned long)regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}
- (BOOL)validatePassword:(NSString *)password {
    
   // NSCharacterSet *upperCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLKMNOPQRSTUVWXYZ"];
  //  NSCharacterSet *lowerCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
    
    if ( [[self trimmedStringForInput:password] length]<6 || [[self trimmedStringForInput:password] length]>15 )
        return NO;  // too long or too short
    return YES;
    /*
    NSRange rang;
    rang = [password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    if ( !rang.length )
        return NO;  // no letter
    rang = [password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    if ( !rang.length )
        return NO;  // no number;
    rang = [password rangeOfCharacterFromSet:upperCaseChars];
    if ( !rang.length )
        return NO;  // no uppercase letter;
    rang = [password rangeOfCharacterFromSet:lowerCaseChars];
    if ( !rang.length )
        return NO;  // no lowerCase Chars;
    return YES;
    */
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[textField resignFirstResponder];
    [self dismissKeyboard];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    NSString *resultString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    switch (textField.tag) {

        case kEHMobileNumberField:
        {
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_MOBILE_NUMBER] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            return [string isEqualToString:filtered] && resultString.length <= 10;
        }
            break;
        case kEHPasswordFiled:
        {
            if ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
                return NO;
            }
            return YES;
        }
            break;
        default:
            break;
    }
    return YES;
}
- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
