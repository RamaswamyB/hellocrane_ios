//
//  EHChangePasswordViewController.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/14/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHChangePasswordViewController.h"
#import "EHHTTPClient.h"
#import "SWRevealViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_FIELD_WIDTH 280.0
#define TEXT_FIELD_HEIGHT 30.0

#define LABEL_WIDTH 280.0
#define LABEL_HEIGHT 15.0

#define BUTTON_WIDTH 220.0
#define BUTTON_HEIGHT 40.0f

#define TEXT_LABEL_PADDING 30.0

@interface PasswordChangeFormTextField : UITextField

@property (nonatomic, strong) CALayer *underlineLayer;

@end

@implementation PasswordChangeFormTextField
@end

void underLineForPasswordChangeTextField(PasswordChangeFormTextField *textField)
{
    CALayer *layer = [CALayer layer];
    CGFloat borderWidth = 2;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderWidth = borderWidth;
    textField.underlineLayer = layer;
    [textField.layer addSublayer:textField.underlineLayer];
    textField.layer.masksToBounds = YES;
}

const NSString *EHPlaceholderMessageForPasswordType(EHTextFieldType type)
{
    switch (type) {
        case kEHCurrentPasswordField: return @"Enter current password.";
        case kEHNewPasswordField: return @"Enter new password.";
        case kEHConfirmPasswordField: return @"Confirm the password";
        
    }
}

@interface EHChangePasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *formScrollView;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) EHHTTPClient *searchUserNameClient;

@end

@implementation EHChangePasswordViewController
{
    PasswordChangeFormTextField *formTextField[3];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Change password";
    
    SWRevealViewController *revealController = [self revealViewController];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    // Set up tap gesture recognizer
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
//    // Listen for the keyboard.
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
    
    _formScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_formScrollView];
    
    for (int i = 0; i<3; i++) {
        formTextField[i] = [self addFormTextFieldForIndex:i];
        [_formScrollView addSubview:formTextField[i]];
        
       // formLabel[i] = [self addFormLabelForIndex:i];
       // [_formScrollView addSubview:formLabel[i]];
    }
    
    _registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_registerButton addTarget:self action:@selector(registerButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton setTitle:@"Update" forState:UIControlStateNormal];
    [_formScrollView addSubview:_registerButton];
    
    formTextField[0].text = [[NSUserDefaults standardUserDefaults] password];
    formTextField[0].enabled = NO;
}

- (PasswordChangeFormTextField *)addFormTextFieldForIndex:(NSUInteger)index
{
    PasswordChangeFormTextField *textField = [[PasswordChangeFormTextField alloc] initWithFrame:CGRectZero];
    textField.tag = index;
    textField.secureTextEntry = YES;
    textField.borderStyle = UITextBorderStyleNone;
   // textField.backgroundColor = [UIColor lightGrayColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
    textField.placeholder = EHPlaceholderMessageForPasswordType(index);
    underLineForPasswordChangeTextField(textField);
    textField.font = [UIFont systemFontOfSize:15];
    return textField;
}
//- (UILabel *)addFormLabelForIndex:(NSUInteger)index
//{
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:9.0f];
//    label.text = EHErrorMessageForEmptyFieldForPasswordType(index);
//    label.textColor = [UIColor redColor];
//    return label;
//}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.view.bounds;
    
    _formScrollView.frame = frame;
    
    for (int i = 0; i<3; i++) {
        
        PasswordChangeFormTextField *textField = formTextField[i];
      //  UILabel *label = formLabel[i];
        
        textField.frame = (CGRect){
            .origin.x = CGRectGetMidX(frame) - (TEXT_FIELD_WIDTH)/2,
            .origin.y = TEXT_FIELD_HEIGHT * i + TEXT_LABEL_PADDING * i + 20,
            .size.width = TEXT_FIELD_WIDTH,
            .size.height = TEXT_FIELD_HEIGHT,
        };
        textField.underlineLayer.frame = CGRectMake(0, textField.bounds.size.height - 2, textField.bounds.size.width, 1);
        
//        label.frame = (CGRect){
//            .origin.x = CGRectGetMidX(frame) - (TEXT_FIELD_WIDTH)/2,
//            .origin.y = CGRectGetMaxY(textField.frame) - 3,
//            .size.width = LABEL_WIDTH,
//            .size.height = LABEL_HEIGHT,
//        };
    }
    
    _registerButton.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (BUTTON_WIDTH)/2,
        .origin.y = CGRectGetMaxY(formTextField[2].frame) + CGRectGetMidY(formTextField[2].bounds) + 5,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    
    _formScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetMaxY(_registerButton.frame));
}

- (void)viewTapped:(id)sender {
    
    // Dismiss keyboard
    [self dismissKeyboard];
}
- (void)dismissKeyboard
{
    for (int i =0; i < 3; i++) {
        [formTextField[i] resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (int i = 0; i < 3; i++) {
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

- (IBAction)registerButtonTouched:(id)sender
{
    [self dismissKeyboard];
    
    if ([self trimmedStringForInput:formTextField[1].text].length < kNilOptions ) {
        [self showInvalidErrorMessage:EHPlaceholderMessageForPasswordType(kEHNewPasswordField) title:@"Message!"];
        [formTextField[1] becomeFirstResponder];
        return;
    }
    else if([self trimmedStringForInput:formTextField[2].text].length < kNilOptions)
    {
        [self showInvalidErrorMessage:EHPlaceholderMessageForPasswordType(kEHConfirmPasswordField) title:@"Message"];
        [formTextField[2] becomeFirstResponder];
        return;
    }
    else
    {
        if (![self validatePassword:formTextField[1].text]) {
            
            [self showInvalidErrorMessage:@"Please ensure that you have entered at least six characters and also you can't insert more than 15 characters" title:@"Message!"];
            [formTextField[1] becomeFirstResponder];
            return;
        }
        else
        {
            if ([[self trimmedStringForInput:formTextField[1].text] isEqualToString:[self trimmedStringForInput:formTextField[2].text]]) {
                
                if (![formTextField[0].text isEqualToString:[self trimmedStringForInput:formTextField[1].text]]) {
                  
                    // Change the password here
                    [self updatePassword];
                }
                else
                {
                    [self showInvalidErrorMessage:@"New password should not be similar to old password" title:@"Message!"];
                }
                
            }
            else
            {
                [self showInvalidErrorMessage:@"New password and confirmed password didn't match" title:@"Message!"];
                [formTextField[2] becomeFirstResponder];
                return;
            }

        }
        
        // URL - users/change-password - POSt method - argument name - password: ""
    }
}

- (void)updatePassword
{
    [self sendQueryForURL:CHANGE_PASSWORD forClientMethod:@"POST"];
}
- (void)sendQueryForURL:(NSString *)url forClientMethod:(NSString *)method
{
    weakify(self);
    
    EHHTTPClient *httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        // strongify(self);
        NSDictionary *param = @ {
            @"password" : self->formTextField[1].text
        };
        return param;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
       
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:@"Message!"];
        }
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                
                [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"Password changed." cancelButtonTitle:@"Ok" otherButtonTitles:nil completionBlock:nil];
            }
            else
            {
                [self showInvalidErrorMessage:@"Something went wrong. Please try again." title:@"Message!"];
            }
 
        }
        
    }];
    [httpClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}

- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //[textField resignFirstResponder];
    [self dismissKeyboard];
    
    
}
- (NSString *)trimmedStringForInput:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
   // NSString *resultString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return YES;
}
- (BOOL)validatePassword:(NSString *)password {
    
//    NSCharacterSet *upperCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLKMNOPQRSTUVWXYZ"];
//    NSCharacterSet *lowerCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
//    
    if ([[self trimmedStringForInput:password] length]<6 || [[self trimmedStringForInput:password] length]>15 )
        return NO;  // too long or too short
    return YES;
//    NSRange rang;
//    rang = [password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
//    if (!rang.length )
//        return NO;  // no letter
//    rang = [password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
//    if (!rang.length )
//        return NO;  // no number;
//    rang = [password rangeOfCharacterFromSet:upperCaseChars];
//    if (!rang.length )
//        return NO;  // no uppercase letter;
//    rang = [password rangeOfCharacterFromSet:lowerCaseChars];
//    if (!rang.length )
//        return NO;  // no lowerCase Chars;
//    return YES;
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
