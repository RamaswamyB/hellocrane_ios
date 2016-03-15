//
//  ViewController.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHMainViewController.h"
#import "EHLoginViewController.h"
#import "EHConstant.h"
#import "SWRevealViewController.h"
#import "EHAboutUsViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EHRegisterViewController.h"
#import "EHTerm&ConditionViewController.h"

#define IMAGE_WIDTH 150.0
#define IMAGE_HEIGHT 114.0

#define BUTTON_WIDTH 150.0
#define BUTTON_HEIGHT 40.0

#define LABEL_WIDTH 150.0
#define LABEL_HEIGHT 40.0
#define CUSTOMER_CARE_NUMBER @"18001038392"

@interface EHMainViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIButton *aboutUsButton;
@property (nonatomic, strong) UILabel *callTollFreeLabel;
@property (nonatomic, strong) UIButton *callTollFreeButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *termAndCondition;
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *mainScrollView;
@property (nonatomic, strong) UIButton *userButton;

@end

@implementation EHMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotification:) name:NOTIFICATION_SHOW_RELOGIN object:nil];
   
    _mainScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectZero];
    
    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CompanyLogo.png"]];
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_mainScrollView addSubview:_logoImageView];
    
    _aboutUsButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_aboutUsButton setTitle:@"About us" forState:UIControlStateNormal];
    [_aboutUsButton setTitleColor:[UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1] forState:UIControlStateNormal];
    
    [self setButtonInteractionFor:_aboutUsButton];
    [_aboutUsButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_aboutUsButton];
    
    _callTollFreeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _callTollFreeLabel.text = @"Toll free";
    _callTollFreeLabel.textAlignment = NSTextAlignmentCenter;
    _callTollFreeLabel.font = [UIFont systemFontOfSize:14.0f];
    [_mainScrollView addSubview:_callTollFreeLabel];
    
    _callTollFreeButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_callTollFreeButton setTitle:CUSTOMER_CARE_NUMBER forState:UIControlStateNormal];
    [_callTollFreeButton setTitleColor:[UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1] forState:UIControlStateNormal];
    
    [self setButtonInteractionFor:_callTollFreeButton];
    [_callTollFreeButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_callTollFreeButton];
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [_mainScrollView addSubview:_loginButton];
    

    _userButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_userButton setTitle:@"New user?" forState:UIControlStateNormal];
    [_userButton setTitleColor:[UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1] forState:UIControlStateNormal];
    [_userButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self setButtonInteractionFor:_userButton];
    [_userButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_userButton];
    
    _termAndCondition = [[UIButton alloc] initWithFrame:CGRectZero];
    [_termAndCondition setTitle:@"Terms & Conditions" forState:UIControlStateNormal];
    [_termAndCondition setTitleColor:[UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1] forState:UIControlStateNormal];
    [_termAndCondition.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self setButtonInteractionFor:_termAndCondition];
    [_termAndCondition addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_mainScrollView addSubview:_termAndCondition];
    
    [self.view addSubview:_mainScrollView];
    
    // First check user mobile number and password already exits.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *usermobile = [userDefaults usermobile];
    NSString *password = [userDefaults password];
    
    if (usermobile.length > kNilOptions && password.length > kNilOptions) {
        [_loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setButtonInteractionFor:(UIButton *)button
{
    NSArray * objects = [[NSArray alloc] initWithObjects:button.titleLabel.textColor, [NSNumber numberWithInt:NSUnderlineStyleSingle], nil];
    NSArray * keys = [[NSArray alloc] initWithObjects:NSForegroundColorAttributeName, NSUnderlineStyleAttributeName, nil];
    NSDictionary * linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:button.titleLabel.text attributes:linkAttributes];
    [button.titleLabel setAttributedText:attributedString];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Set frames of UI
    CGRect frame = self.view.bounds;
    _mainScrollView.frame = frame;
    
    _logoImageView.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (IMAGE_WIDTH / 2),
        .origin.y = 40,
        .size.width = IMAGE_WIDTH,
        .size.height = IMAGE_HEIGHT,
    };

    _aboutUsButton.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - BUTTON_WIDTH) / 2,
        .origin.y = CGRectGetMaxY(_logoImageView.frame) + 10,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    
    _callTollFreeLabel.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - LABEL_WIDTH) / 2,
        .origin.y = CGRectGetMaxY(_aboutUsButton.frame) + 15,
        .size.width = LABEL_WIDTH,
        .size.height = LABEL_HEIGHT,
    };
    
    _callTollFreeButton.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - LABEL_WIDTH) / 2,
        .origin.y = CGRectGetMidY(_callTollFreeLabel.frame),
        .size.width = LABEL_WIDTH,
        .size.height = LABEL_HEIGHT,
    };
    
    _loginButton.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - BUTTON_WIDTH) / 2,
        .origin.y = CGRectGetMaxY(_callTollFreeButton.frame) + BUTTON_HEIGHT,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    _userButton.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - BUTTON_WIDTH) / 2,
        .origin.y = CGRectGetMaxY(_loginButton.frame) + 5,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    _termAndCondition.frame = (CGRect){
        .origin.x = (CGRectGetWidth(frame) - BUTTON_WIDTH) / 2,
        .origin.y = CGRectGetMaxY(_userButton.frame) ,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    
    _mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetMaxY(_termAndCondition.frame));
}
- (IBAction)buttonTouched:(id)sender
{
    if (sender == _aboutUsButton) {
        EHAboutUsViewController *abousUSController = [[EHAboutUsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:abousUSController];
        [self presentViewController:navController animated:YES completion:nil];
    }
    else if(sender == _callTollFreeButton)
    {
        NSString *contact = [NSString stringWithFormat:@"telprompt://%@",CUSTOMER_CARE_NUMBER];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:contact]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contact]];
        }
    }
    else if(sender == _termAndCondition){
        EHTerm_ConditionViewController *termViewController = [[EHTerm_ConditionViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:termViewController];
        [self presentViewController:navController animated:YES completion:nil];
    }
    else
    {
        EHRegisterViewController *registerController = [[EHRegisterViewController alloc] init];
        [self.navigationController pushViewController:registerController animated:YES];
    }
}
- (IBAction)loginButtonTouched:(id)sender
{
    EHLoginViewController *loginViewController = [[EHLoginViewController alloc] init];
    [self.navigationController pushViewController:loginViewController animated:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)loginNotification:(NSNotification *)notification
{
    [self.navigationController popViewControllerAnimated:NO];
    [_loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
