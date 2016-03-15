//
//  EHTerm&ConditionViewController.m
//  Easy Hire
//
//  Created by Prasanna on 21/02/16.
//  Copyright © 2016 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHTerm&ConditionViewController.h"

@interface EHTerm_ConditionViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *termWebView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation EHTerm_ConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Terms & Conditions";
    self.navigationController.navigationBarHidden = NO;
    
    _termWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _termWebView.delegate = self;
    [_termWebView sizeToFit];
    [self.view addSubview:_termWebView];
    [_termWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"Term&Condition" ofType:@"html"]]]];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.hidesWhenStopped = YES;
    [self.view addSubview:_indicatorView];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _indicatorView.center = self.view.center;
    _termWebView.frame = self.view.bounds;
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
