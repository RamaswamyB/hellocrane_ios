//
//  EHAboutUsViewController.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/14/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHAboutUsViewController.h"
#import "EHConstant.h"
#import "UIApplication+EHNetworkIndicatorHandler.h"
#import "SWRevealViewController.h"

@interface EHAboutUsViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *aboutUsWebView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation EHAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"About us";
    self.view.backgroundColor = [UIColor whiteColor];
    
    SWRevealViewController *revealController = [self revealViewController];
    
    if (revealController) {
        [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                             style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
        
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    else
    {
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton:)];
        
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _aboutUsWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _aboutUsWebView.delegate = self;
    [_aboutUsWebView sizeToFit];
    [self.view addSubview:_aboutUsWebView];
    [_aboutUsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"AboutUs" ofType:@"html"]]]];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_indicatorView];
    
    
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _indicatorView.center = self.view.center;
    _aboutUsWebView.frame = self.view.bounds;
}
- (IBAction)doneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_indicatorView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicatorView stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_indicatorView stopAnimating];
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
