//
//  EHSettingsViewController.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/6/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHSettingsViewController.h"
#import "EHConstant.h"
//#import "EHChangePasswordViewController.h"
#import "EHAboutUsViewController.h"
#import "SWRevealViewController.h"
#import "EHServiceViewController.h"
#import "EHEnquiryFormViewController.h"
#import "EHRequirementListViewController.h"
#import "EHEquipmentOwnedListViewController.h"
#import "EHEHEquipmentOwnedMapViewController.h"
#import "EHSupplierNotificationViewController.h"
#import "EHEHCustomerNotificationViewController.h"
#import "EHHTTPClient.h"
#import "EHProfileViewController.h"

enum EHTableSection {
    EHTableSectionProfile = 0,
    EHTableSectionFavourites,
    EHTableSectionSettings,
    EHTableNumSections,
};

// For supplier
enum EHSupplierFavouritesRow {
    EHSupplierNotificationRow = 0,
    EHSupplierEquipmentOwnedRow,
    EHSupplierFavouritesNumRows
};

enum EHSupplierSettingsRow {
   // EHSupplierChangePasswordRow = 0,
    EHSupplierAboutUdRow = 0,
//    EHSupplierLogoutRow,
    EHSupplierCaptionRow,
    EHSupplierSettingsNumRows
};
////////////

// For Customer
enum EHCustomerFavouritesRow {
    EHCustomerDashboardRow = 0,
    EHCustomerNotificationRow,
    EHCustomerFavouritesNumRows
};

enum EHCustomerSettingsRow {
    EHCustomerRequirementRow = 0,
   // EHCustomerChangePasswordRow,
    EHCustomerAboutUdRow,
   // EHCustomerLogoutRow,
    EHCustomerCaptionRow,
    EHCustomerSettingsNumRows
};
///////////////

NSString *const EHTitleForSection[] = {
    [EHTableSectionFavourites] = @"Favourites",
    [EHTableSectionSettings] = @"Settings"
};

NSString *const EHSupplierTitleForRow[EHTableNumSections][EHSupplierFavouritesNumRows + EHSupplierSettingsNumRows] = {
    
    [EHTableSectionFavourites][EHSupplierNotificationRow] = @"Notification",
    [EHTableSectionFavourites][EHSupplierEquipmentOwnedRow] = @"Equipment Owned",
    
  //  [EHTableSectionSettings][EHSupplierChangePasswordRow] = @"Change password",
    [EHTableSectionSettings][EHSupplierAboutUdRow] = @"About us",
   // [EHTableSectionSettings][EHSupplierLogoutRow] = @"Logout",
    [EHTableSectionSettings][EHSupplierCaptionRow] = @"Made with ❤️ in Bengaluru",
};

NSString *const EHCustomerTitleForRow[EHTableNumSections][EHCustomerFavouritesNumRows + EHCustomerSettingsNumRows] = {
    
    [EHTableSectionFavourites][EHCustomerDashboardRow] = @"Dashboard",
    [EHTableSectionFavourites][EHCustomerNotificationRow] = @"Notification",
    
    [EHTableSectionSettings][EHCustomerRequirementRow] = @"Requirement List",
   // [EHTableSectionSettings][EHCustomerChangePasswordRow] = @"Change password",
    [EHTableSectionSettings][EHCustomerAboutUdRow] = @"About us",
   // [EHTableSectionSettings][EHCustomerLogoutRow] = @"Logout",
    [EHTableSectionSettings][EHCustomerCaptionRow] = @"Made with ❤️ in Bengaluru",
};

@interface EHSettingsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *supplierOptionsTableView;
@property (nonatomic, strong) UITableView *customerOptionsTableView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *signOutButton;

@end

@implementation EHSettingsViewController
{
    NSInteger _presentedRow;
    NSInteger _presentedSection;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *parentRevealController = self.revealViewController;
    SWRevealViewController *grandParentRevealController = parentRevealController.revealViewController;
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:grandParentRevealController action:@selector(revealToggle:)];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UserType userType = [userDefaults userType];
    
    if (userType == kUserTypeSupplier) {
        _supplierOptionsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _supplierOptionsTableView.dataSource = self;
        _supplierOptionsTableView.delegate = self;
       // [_supplierOptionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"aCell"];
        _supplierOptionsTableView.backgroundColor = [UIColor blackColor];
        _supplierOptionsTableView.separatorColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        [self.view addSubview:_supplierOptionsTableView];
    }
    
    else
    {
        _customerOptionsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _customerOptionsTableView.dataSource = self;
        _customerOptionsTableView.delegate = self;
       // [_customerOptionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"aCell"];
        _customerOptionsTableView.backgroundColor = [UIColor blackColor];
        _customerOptionsTableView.separatorColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        [self.view addSubview:_customerOptionsTableView];
    }
    
    
    // if we have a reveal controller as a grand parent, this means we are are being added as a
    // child of a detail (child) reveal controller, so we add a gesture recognizer provided by our grand parent to our
    // navigation bar as well as a "reveal" button, we also set
    if ( grandParentRevealController )
    {
        // to present a title, we count the number of ancestor reveal controllers we have, this is of course
        // only a hack for demonstration purposes, on a real project you would have a model telling this.
        NSInteger level=0;
        UIViewController *controller = grandParentRevealController;
        while( nil != (controller = [controller revealViewController]) )
            level++;
        
        NSString *title = [NSString stringWithFormat:@"Detail Level %ld", (long)level];
        
        [self.navigationController.navigationBar addGestureRecognizer:grandParentRevealController.panGestureRecognizer];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
        self.navigationItem.title = title;
    }
    
    // otherwise, we are in the top reveal controller, so we just add a title
    else
    {
        self.navigationItem.title = @"HelloCrane";
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SWRevealViewController *grandParentRevealController = self.revealViewController.revealViewController;
    grandParentRevealController.bounceBackOnOverdraw = NO;
    
    _presentedRow = -1;
    _presentedSection = -1;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    SWRevealViewController *grandParentRevealController = self.revealViewController.revealViewController;
    grandParentRevealController.bounceBackOnOverdraw = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    _supplierOptionsTableView.frame = rect;
    _customerOptionsTableView.frame = rect;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return EHTableNumSections;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _supplierOptionsTableView) {
        switch (section) {
            case EHTableSectionFavourites:
                return EHSupplierFavouritesNumRows;
                break;
            case EHTableSectionSettings:
                return EHSupplierSettingsNumRows;
            default:
                return 0;
                break;
            }
    }
    else
    {
        switch (section) {
            case EHTableSectionFavourites:
                return EHCustomerFavouritesNumRows;
                break;
            case EHTableSectionSettings:
                return EHCustomerSettingsNumRows;
            default:
                return 0;
                break;
        }
        
    }
        
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section) {
//        case EHTableSectionFavourites:
//        {
//            return EHTitleForSection[EHTableSectionFavourites];
//        }
//            break;
//        case EHTableSectionSettings:
//        {
//            return EHTitleForSection[EHTableSectionSettings];
//        }
//            break;
//            
//        default:
//            return nil;
//            break;
//    }
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == EHTableSectionProfile) {
        return 40;
    }
    return 30.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (section == EHTableSectionProfile) {
     
        view.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
        UIImage *image = [UIImage imageNamed:@"avatar.png"];
        UIImageView *profile = [[UIImageView alloc] initWithFrame:(CGRect){5,4,32,32}];
        profile.contentMode = UIViewContentModeScaleAspectFit;
        profile.image = image;
        [view addSubview:profile];
        
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){45,4,170,32}];
        label.font = [UIFont systemFontOfSize:14.0f];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *name = [NSString stringWithFormat:@"%@ %@",userDefault.firstName,userDefault.lastName];
        label.text = name;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
        button.frame = (CGRect){215,1,40,38};
        [button addTarget:self action:@selector(profileSettingTapped:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0,0,100,30}];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        
        switch (section) {
            case EHTableSectionFavourites:
            {
                label.text = EHTitleForSection[EHTableSectionFavourites];
            }
                break;
            case EHTableSectionSettings:
            {
                label.text = EHTitleForSection[EHTableSectionSettings];
            }
                break;
            default:
                return nil;
                break;
        }
        
        [view addSubview:label];
        
        view.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    }
    
    return view;
}
- (IBAction)profileSettingTapped:(id)sender
{
    SWRevealViewController *revealController = self.revealViewController;
    UIViewController *newFrontController = nil;
    EHProfileViewController *profileViewController = [[EHProfileViewController alloc] init];
    newFrontController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    [revealController pushFrontViewController:newFrontController animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"aCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        
    }
    
    if (tableView == _supplierOptionsTableView) {
    
        cell.textLabel.text = EHSupplierTitleForRow[indexPath.section][indexPath.row];
        
        if (indexPath.section == EHTableSectionSettings && indexPath.row == EHSupplierCaptionRow) {
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.textLabel.font = [UIFont systemFontOfSize:18];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
    else
    {
        cell.textLabel.text = EHCustomerTitleForRow[indexPath.section][indexPath.row];
        
        if (indexPath.section == EHTableSectionSettings && indexPath.row == EHCustomerCaptionRow) {
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.textLabel.font = [UIFont systemFontOfSize:18];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    SWRevealViewController *revealController = self.revealViewController;

    // if we are trying to push the same row or perform an operation that does not imply frontViewController replacement
    // we'll just set position and return
    if ( indexPath.row == _presentedRow && indexPath.section == _presentedSection )
    {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
    
    UIViewController *newFrontController = nil;

    // Cancel all operations
  //  [EHHTTPClient stopAllOperation];
    
    if (tableView == _supplierOptionsTableView) {
      
        switch (indexPath.section) {
            case EHTableSectionFavourites:
            {
                switch (indexPath.row) {
                    case EHSupplierNotificationRow:
                    {
                        EHSupplierNotificationViewController *notificationViewController = [[EHSupplierNotificationViewController alloc] init];
                        newFrontController = [[UINavigationController alloc] initWithRootViewController:notificationViewController];
                    }
                        break;
                    case EHSupplierEquipmentOwnedRow:
                    {
                        UITabBarController *tabBarController = [[UITabBarController alloc] init];
                        
                        EHEquipmentOwnedListViewController *listViewController = [[EHEquipmentOwnedListViewController alloc] init];
                       
                        EHEHEquipmentOwnedMapViewController *mapViewController = [[EHEHEquipmentOwnedMapViewController alloc] init];
                        
                        
                        tabBarController.viewControllers = @[listViewController,mapViewController];
                        tabBarController.selectedIndex = 1;
                        tabBarController.selectedIndex = 0;
                        
                        newFrontController = [[UINavigationController alloc] initWithRootViewController:tabBarController];
                    }
                        break;

                }
            }
                break;
            case EHTableSectionSettings:
            {
                switch (indexPath.row) {
                    case EHSupplierAboutUdRow:
                    {
                        EHAboutUsViewController *aboutUsViewController = [[EHAboutUsViewController alloc] init];
                        newFrontController = [[UINavigationController alloc] initWithRootViewController:aboutUsViewController];
                    }
                        break;
                    case EHSupplierCaptionRow:
                    {
                        return;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                break;
        }
    }
    else
    {

        
        switch (indexPath.section) {
            case EHTableSectionFavourites:
            {
                switch (indexPath.row) {
                    case EHCustomerDashboardRow:
                    {
                        EHServiceViewController *serviceViewController = [[EHServiceViewController alloc] init];
                        newFrontController = [[UINavigationController alloc] initWithRootViewController:serviceViewController];
                    }
                        break;
                    case EHCustomerNotificationRow:
                    {
                        EHEHCustomerNotificationViewController *notificationViewController = [[EHEHCustomerNotificationViewController alloc] init];
                        newFrontController = [[UINavigationController alloc] initWithRootViewController:notificationViewController];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
            case EHTableSectionSettings:
            {
                switch (indexPath.row) {
                    case EHCustomerRequirementRow:
                    {
                        EHRequirementListViewController *requirementListViewController = [[EHRequirementListViewController alloc] init];
                        newFrontController = [[UINavigationController alloc] initWithRootViewController:requirementListViewController];
                    }
                        break;
                    
                    case EHCustomerAboutUdRow:
                    {
                        EHAboutUsViewController *aboutUsViewController = [[EHAboutUsViewController alloc] init];
                        newFrontController = [[UINavigationController alloc] initWithRootViewController:aboutUsViewController];
                    }
                        break;
                    
                    case EHCustomerCaptionRow:
                    {
                        return;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }

    }
    [revealController pushFrontViewController:newFrontController animated:YES];
    _presentedRow = indexPath.row;  // <- store the presented row
    _presentedSection = indexPath.section;
}

- (void)signOutButtonTouched:(id)sender
{
    [EHHTTPClient stopAllOperation];
    [[NSUserDefaults standardUserDefaults] remove];
    
    _presentedRow = -1;
    _presentedSection = -1;
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_LOGIN object:nil];
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
