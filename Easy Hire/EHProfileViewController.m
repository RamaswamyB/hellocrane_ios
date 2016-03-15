//
//  EHProfileViewController.m
//  Easy Hire
//
//  Created by Prasanna on 20/02/16.
//  Copyright © 2016 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHProfileViewController.h"
#import "SWRevealViewController.h"
#import "EHChangePasswordViewController.h"
#import "EHHTTPClient.h"

@interface EHProfileViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *profileTableView;

@end

@implementation EHProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"My Profile";
    
    SWRevealViewController *revealController = [self revealViewController];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    _profileTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _profileTableView.dataSource = self;
    _profileTableView.delegate = self;
    _profileTableView.scrollEnabled = NO;
    [self.view addSubview:_profileTableView];
}
- (void)viewWillLayoutSubviews
{
    _profileTableView.frame = self.view.bounds;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *aCell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:aCell];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = [[NSUserDefaults standardUserDefaults] usermobile];
            cell.imageView.image = [UIImage imageNamed:@"mobile.png"];
        }
        else
        {
            cell.textLabel.text = [[[NSUserDefaults standardUserDefaults] companyName] length] > 0 ?[[NSUserDefaults standardUserDefaults] companyName] : @"N/A";
            cell.imageView.image = [UIImage imageNamed:@"company.png"];
        }
    }
    else
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Change password";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.textLabel.text = @"Logout";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }
    
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    if (section == 0) {
        
        UIImage *image = [UIImage imageNamed:@"avatar.png"];
        UIImageView *profile = [[UIImageView alloc] initWithFrame:(CGRect){5,9,32,32}];
        profile.contentMode = UIViewContentModeScaleAspectFit;
        profile.image = image;
        [view addSubview:profile];
        
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){45,9,170,32}];
        label.font = [UIFont systemFontOfSize:14.0f];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *name = [NSString stringWithFormat:@"%@ %@",userDefault.firstName,userDefault.lastName];
        label.text = name;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
    }
    
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            EHChangePasswordViewController *changePasswordViewController = [[EHChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:changePasswordViewController animated:YES];
        }
        else
        {
         // logout
            [EHHTTPClient stopAllOperation];
            [[NSUserDefaults standardUserDefaults] remove];
            SWRevealViewController *revealController = self.revealViewController;
            [revealController.navigationController popToRootViewControllerAnimated:NO];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_LOGIN object:nil];
        }
    }
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
