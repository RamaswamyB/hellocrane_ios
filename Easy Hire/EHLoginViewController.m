//
//  EHLoginViewController.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHLoginViewController.h"
#import "EHServiceViewController.h"
#import "EHHTTPClient.h"
#import "EHConstant.h"
#import "EHSettingsViewController.h"
#import "SWRevealViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EHEquipmentOwnedListViewController.h"
#import "EHEHEquipmentOwnedMapViewController.h"
#import "EHForgotPasswordViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MSG_ENTER_USERNAME @"Please enter valid mobile number."
#define TITLE_ENTER_USERNAME @"Missing mobile number."

#define MSG_ENTER_PASSWORD @"Please enter valid password."
#define TITLE_ENTER_PASSWORD @"Missing Password"

#define TITLE_LOGIN_FAILED @"Login Failed."

#define TEXT_FIELD_WIDTH 300.0
#define TEXT_FIELD_HEIGHT 30.0

#define TEXT_VIEW_WIDTH 220.0
#define TEXT_VIEW_HEIGHT 90.0

#define BUTTON_WIDTH 220.0
#define BUTTON_HEIGHT 40.0f

#define TEXT_FIELD_PADDING 15.0

#define GROUP_WIDTH 200.0f
#define GROUP_HEIGHT 30.0f

#define IMAGE_WIDTH 150.0
#define IMAGE_HEIGHT 114.0

#define ACCEPTABLE_CHARECTERS_MOBILE_NUMBER @"0123456789"

@interface FormTextField : UITextField

@property (nonatomic, strong) CALayer *underlineLayer;

@end

@implementation FormTextField
@end

void underLineForTextField(FormTextField *textField)
{
    CALayer *layer = [CALayer layer];
    CGFloat borderWidth = 2;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderWidth = borderWidth;
    textField.underlineLayer = layer;
    [textField.layer addSublayer:textField.underlineLayer];
    textField.layer.masksToBounds = YES;
}

@interface EHLoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) FormTextField *usernameTextField;
@property (nonatomic, strong) FormTextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *forgotButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) EHHTTPClient *loginClient;
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *loginScrollView;

@end

@implementation EHLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    // Set up tap gesture recognizer
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    _loginScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectZero];
    
    _usernameTextField = [[FormTextField alloc] init];
    _usernameTextField.font = [UIFont boldSystemFontOfSize:15];
    _usernameTextField.borderStyle = UITextBorderStyleNone;
    //_usernameTextField.backgroundColor = [UIColor lightGrayColor];
    _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _usernameTextField.placeholder = @"Enter mobile number";
    _usernameTextField.keyboardType = UIKeyboardTypePhonePad;
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.delegate = self;
    _usernameTextField.contentMode = UIViewContentModeBottom;
    underLineForTextField(_usernameTextField);
    [_loginScrollView addSubview:_usernameTextField];
    
    _passwordTextField = [[FormTextField alloc] init];
    _passwordTextField.font = [UIFont boldSystemFontOfSize:15];
    _passwordTextField.borderStyle = UITextBorderStyleNone;
   // _passwordTextField.backgroundColor = [UIColor lightGrayColor];
    _passwordTextField.placeholder = @"Password";
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.returnKeyType = UIReturnKeyGo;
    _passwordTextField.delegate = self;
    _passwordTextField.contentMode = UIViewContentModeBottom;
    underLineForTextField(_passwordTextField);
    [_loginScrollView addSubview:_passwordTextField];
    
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [_loginScrollView addSubview:_loginButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_cancelButton addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    [_loginScrollView addSubview:_cancelButton];
    
    _forgotButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_forgotButton setTitle:@"Forgot password?" forState:UIControlStateNormal];
    [_forgotButton setTitleColor:[UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1] forState:UIControlStateNormal];
    [_forgotButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self setButtonInteractionFor:_forgotButton];
    [_forgotButton addTarget:self action:@selector(forgotPasswordButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_loginScrollView addSubview:_forgotButton];
    
    
    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CompanyLogo.png"]];
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_loginScrollView addSubview:_logoImageView];
    
    [self.view addSubview:_loginScrollView];
    
    // First check user mobile number and password already exits.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *usermobile = [userDefaults usermobile];
    NSString *password = [userDefaults password];
    
    if (usermobile.length > kNilOptions && password.length > kNilOptions) {
        
        // Use LOGIN_URL
        _usernameTextField.text = usermobile;
        _passwordTextField.text = password;
       [_loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        // TEST
//        _usernameTextField.text = @"9886678849";//@"7045020592";
//        _passwordTextField.text = @"admin123";//@"test123";
      
    }
 // for hirer 9591510257 admin123
    // vendor 7045020592 test123
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Set frames of UI
    CGRect frame = self.view.frame;
   _loginScrollView.frame = frame;
    
    
    _passwordTextField.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (TEXT_FIELD_WIDTH)/2,
        .origin.y = CGRectGetMidY(frame) - TEXT_FIELD_PADDING,
        .size.width = TEXT_FIELD_WIDTH,
        .size.height = TEXT_FIELD_HEIGHT,
    };
    
    _usernameTextField.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (TEXT_FIELD_WIDTH)/2,
        .origin.y = CGRectGetMinY(_passwordTextField.frame) - TEXT_FIELD_HEIGHT - TEXT_FIELD_PADDING,
        .size.width = TEXT_FIELD_WIDTH,
        .size.height = TEXT_FIELD_HEIGHT,
    };
    
    
    _cancelButton.frame = (CGRect){
        .origin.x = 10,
        .origin.y = CGRectGetMaxY(_passwordTextField.frame) + 10 + TEXT_FIELD_PADDING,
        .size.width = CGRectGetMidX(_usernameTextField.frame) - 10,
        .size.height = BUTTON_HEIGHT,
    };
    
    _loginButton.frame = (CGRect){
        .origin.x = CGRectGetMaxX(_cancelButton.frame) + 10,
        .origin.y = CGRectGetMaxY(_passwordTextField.frame) + 10 + TEXT_FIELD_PADDING,
        .size.width = CGRectGetMidX(_usernameTextField.frame) - 20,
        .size.height = BUTTON_HEIGHT,
    };
    
    _forgotButton.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - BUTTON_WIDTH)/2,
        .origin.y = CGRectGetMaxY(_loginButton.frame) + 5,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    
    _logoImageView.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (IMAGE_WIDTH / 2),
        .origin.y = CGRectGetMinY(_usernameTextField.frame) - IMAGE_HEIGHT - 10,
        .size.width = IMAGE_WIDTH,
        .size.height = IMAGE_HEIGHT,
    };
    
    _usernameTextField.underlineLayer.frame = CGRectMake(0, _usernameTextField.bounds.size.height - 2, _usernameTextField.bounds.size.width, 1);
    _passwordTextField.underlineLayer.frame = CGRectMake(0, _passwordTextField.bounds.size.height - 2, _passwordTextField.bounds.size.width, 1);

}
- (void)setButtonInteractionFor:(UIButton *)button
{
    NSArray * objects = [[NSArray alloc] initWithObjects:button.titleLabel.textColor, [NSNumber numberWithInt:NSUnderlineStyleSingle], nil];
    NSArray * keys = [[NSArray alloc] initWithObjects:NSForegroundColorAttributeName, NSUnderlineStyleAttributeName, nil];
    NSDictionary * linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:button.titleLabel.text attributes:linkAttributes];
    [button.titleLabel setAttributedText:attributedString];
}
- (IBAction)cancelButtonTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewTapped:(id)sender {
    
    // Dismiss keyboard
    [self dismissKeyboard];
}
- (void)dismissKeyboard
{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    (textField == _usernameTextField) ? [self setFocusOnTextField:_passwordTextField] : [self loginButtonTouched:nil];
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _usernameTextField)
    {
        NSString *resultString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_MOBILE_NUMBER] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered] && resultString.length <= 10;
    }
    return YES;
}
- (void)setFocusOnTextField:(UITextField *)textField
{
    [textField becomeFirstResponder];
}
#pragma mark - Check empty filed
- (NSString *)trimmedStringForInput:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (BOOL)checkIfEmptyField
{
    BOOL isEmpty = NO;
    if([[self trimmedStringForInput:_usernameTextField.text] length] == 0 || [[self trimmedStringForInput:_usernameTextField.text] length] < 10)
    {
        [self showInvalidErrorMessage:MSG_ENTER_USERNAME title:TITLE_ENTER_USERNAME];
        [self setFocusOnTextField:_usernameTextField];
        isEmpty = YES;
    }
    else if([[self trimmedStringForInput:_passwordTextField.text] length] < 6 || [[self trimmedStringForInput:_passwordTextField.text] length] > 15)
    {
        [self showInvalidErrorMessage:MSG_ENTER_PASSWORD title:TITLE_ENTER_PASSWORD];
        [self setFocusOnTextField:_passwordTextField];
        isEmpty = YES;
    }
    
    return isEmpty;
    
}
- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^[1-9][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}
#pragma mark - Pop up message
- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
   [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
}
- (void)sendQueryForURL:(NSString *)url forClientMethod:(NSString *)method
{
    weakify(self);
    
    _loginClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        strongify(self);
        
        NSDictionary *loginDict = nil;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        userDefault.usermobile = self.usernameTextField.text;
        userDefault.password = self.passwordTextField.text;
        [userDefault save];
        
        return loginDict;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if(self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:TITLE_LOGIN_FAILED];
        }
        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            NSDictionary *userDetailsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (![[EHValidateWrapper sharedInstance]isNullDictionary:userDetailsDict]) {
                
                NSUserDefaults *userDetailsDefaults = [NSUserDefaults standardUserDefaults];
                userDetailsDefaults.userEmail = ObjectOrNullInstance(userDetailsDict[@"email"]);
                userDetailsDefaults.usermobile = _usernameTextField.text;
                userDetailsDefaults.password = _passwordTextField.text;
                userDetailsDefaults.firstName = ObjectOrNullInstance(userDetailsDict[@"first_name"]);
                userDetailsDefaults.userid =  [userDetailsDict[@"id"] integerValue];
                userDetailsDefaults.lastName = ObjectOrNullInstance(userDetailsDict[@"last_name"]);
                userDetailsDefaults.userType = [ObjectOrNullInstance(userDetailsDict[@"role"]) isEqualToString:@"ROLE_CUSTOMER"]? kUserTypeCustomer : kUserTypeSupplier;
                [userDetailsDefaults save];
                
                
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
                
                // self.passwordTextField.text = @"";
                self.usernameTextField.text = @"";
            }
            else
            {
                [self showInvalidErrorMessage:@"Something went wrong. Please try again." title:TITLE_LOGIN_FAILED];
            }
        }
        
    }];
    [_loginClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}
- (IBAction)loginButtonTouched:(id)sender
{
    // Check for empty fileds
    if ([self checkIfEmptyField])
    {
        return;
    }
    
    [self dismissKeyboard];
    
    [self sendQueryForURL:RELOGIN_URL forClientMethod:@"GET"];
}
- (IBAction)forgotPasswordButtonEvent:(id)sender
{
    EHForgotPasswordViewController *forgotPasswordController = [[EHForgotPasswordViewController alloc] init];
    [self.navigationController pushViewController:forgotPasswordController animated:1];
}

- (BOOL)shouldAutorotate
{
    return YES;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
#else

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
    
}
#endif
@end
