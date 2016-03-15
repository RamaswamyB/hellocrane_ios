//
//  EHForgotPasswordViewController.m
//  Easy Hire
//
//  Created by Prasanna on 16/02/16.
//  Copyright © 2016 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHForgotPasswordViewController.h"
#import "EHHTTPClient.h"

#define BUTTON_WIDTH 220.0
#define BUTTON_HEIGHT 40.0f

#define TEXT_FIELD_WIDTH 300.0
#define TEXT_FIELD_HEIGHT 30.0

#define ACCEPTABLE_CHARECTERS_MOBILE_NUMBER @"0123456789"
#define FORGOT_PASSWORD_FAILED @"Failed"
@interface ForgotFormTextField : UITextField

@property (nonatomic, strong) CALayer *underlineLayer;

@end

@implementation ForgotFormTextField
@end

void underLineForForgotTextField(ForgotFormTextField *textField)
{
    CALayer *layer = [CALayer layer];
    CGFloat borderWidth = 2;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderWidth = borderWidth;
    textField.underlineLayer = layer;
    [textField.layer addSublayer:textField.underlineLayer];
    textField.layer.masksToBounds = YES;
}

@interface EHForgotPasswordViewController ()

@property (nonatomic, strong) ForgotFormTextField *forgotTextField;
@property (nonatomic, strong) UIButton *submitButton;

@end

@implementation EHForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Forgot Password";
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    _forgotTextField = [[ForgotFormTextField alloc] init];
    _forgotTextField.font = [UIFont boldSystemFontOfSize:15];
    _forgotTextField.borderStyle = UITextBorderStyleNone;
    _forgotTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _forgotTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _forgotTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    _forgotTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _forgotTextField.placeholder = @"Enter mobile number";
    _forgotTextField.keyboardType = UIKeyboardTypePhonePad;
    _forgotTextField.returnKeyType = UIReturnKeyNext;
    _forgotTextField.contentMode = UIViewContentModeBottom;
    underLineForForgotTextField(_forgotTextField);
    [self.view addSubview:_forgotTextField];
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_submitButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _submitButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [self.view addSubview:_submitButton];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Set frames of UI
    CGRect frame = self.view.frame;
    
    _forgotTextField.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (TEXT_FIELD_WIDTH)/2,
        .origin.y =  20,
        .size.width = TEXT_FIELD_WIDTH,
        .size.height = TEXT_FIELD_HEIGHT,
    };
    _forgotTextField.underlineLayer.frame = CGRectMake(0, _forgotTextField.bounds.size.height - 2, _forgotTextField.bounds.size.width, 1);
    
    _submitButton.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (BUTTON_WIDTH)/2,
        .origin.y = CGRectGetMaxY(_forgotTextField.frame) + CGRectGetMidY(_forgotTextField.bounds) + 5,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
}
- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"^[1-9][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}
- (NSString *)trimmedStringForInput:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (IBAction)buttonTouched:(id)sender
{
    [_forgotTextField resignFirstResponder];
    
    if([[self trimmedStringForInput:_forgotTextField.text] length] == 0 || [[self trimmedStringForInput:_forgotTextField.text] length] < 10)
    {
        [self showInvalidErrorMessage:@"Please enter valid mobile number" title:@"Message!"];

    }
    else
    {
        [self sendQueryForURL:FORGOT_PASSWORD forClientMethod:@"POST"];
    }
    
}
- (void)sendQueryForURL:(NSString *)url forClientMethod:(NSString *)method
{
    weakify(self);
    
    EHHTTPClient *loginClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        strongify(self);
        
        NSDictionary *dict = @{
                                    @"mobile_number" : self.forgotTextField.text
                                    };
        return dict;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if(self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:FORGOT_PASSWORD_FAILED];
        }
        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                
                [EHAlertPromptHelper showAlertViewIn:self withTitle:[dict valueForKey:@"status"] message:@"You will get password through SMS." cancelButtonTitle:@"Ok" otherButtonTitles:nil completionBlock:^(EHAlertPromptHelper *alert,NSUInteger index){
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
        
        
    }];
    
    [loginClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
    
}
- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
   NSString *resultString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_MOBILE_NUMBER] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered] && resultString.length <= 10;
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
