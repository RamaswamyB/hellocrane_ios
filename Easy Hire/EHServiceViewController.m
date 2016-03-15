//
//  EHServiceViewController.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHServiceViewController.h"
#import "EHGalleryCell.h"
#import "EHSettingsViewController.h"
#import "SWRevealViewController.h"
#import "EHEnquiryFormViewController.h"
#import "EHHTTPClient.h"
#import "Equipment.h"
#import "FPPopoverKeyboardResponsiveController.h"

#define EQUIPMENT_LIST_TITLE @"Failed to get equipment list"
#define CellSectionInset UIEdgeInsetsMake(0, 10, 0, 10)

#define CUSTOMER_CARE_NUMBER @"18001038392"


const  NSString * _Nullable EHPlaceholderMessageForButtonType(EHButtonType type)
{
    switch (type) {
        case kCallMeBack: return @"Call Me Back";
        case KTollFree: return @"Call Toll Free";
        case kFillUpEnquiryForm: return @"Fill Up Enquiry Form";
            
    }
}
NSString *ServiceURLForType(HTTPClientType type)
{
    switch (type) {
        case kHTTPClientTypeGetService:return EQUIPMENTS_LIST_URL;
        case kHTTPClientTypeCallTollFree: return CUSTOMER_CARE_SERVICE;
        case kHTTPClientTypeCallMeBack: return CUSTOMER_CARE_SERVICE;
            
        default:return nil;
    }
}
@protocol ContactTableViewControllerDelegate <NSObject>

- (void)selectedTableRowIndex:(NSInteger)index;

@end

@interface ContactTableViewController : UITableViewController

@property (nonatomic, assign) id<ContactTableViewControllerDelegate> delegate;

@end

@implementation ContactTableViewController

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
    static NSString *cellID = @"aCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {

        cell.textLabel.text = @"Call Me Back";
    }
    else
    {
        cell.textLabel.text = @"Call Toll Free";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(selectedTableRowIndex:)]) {
        [self.delegate selectedTableRowIndex:indexPath.row];
    }
}


@end


@interface EHServiceViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,ContactTableViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *serviceCollectionView;
@property (nonatomic, strong) NSMutableArray *serviceArray;
@property (nonatomic, strong) EHHTTPClient *serviceClient;
@property (nonatomic, strong)  FPPopoverKeyboardResponsiveController *popover;
@property (nonatomic, strong) ContactTableViewController *contactTableView;
@end

@implementation EHServiceViewController
{
    UIRefreshControl *refreshControl;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Post your requirement";
    SWRevealViewController *revealController = [self revealViewController];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];

    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];

    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (CGRect){0,0,30,30};
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(callButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    _serviceArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    // Collection view for grid.
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _serviceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _serviceCollectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _serviceCollectionView.dataSource = self;
    _serviceCollectionView.delegate = self;
    [_serviceCollectionView registerClass:[EHGalleryCell class] forCellWithReuseIdentifier:@"ReuseCell"];
    _serviceCollectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_serviceCollectionView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_serviceCollectionView addSubview:refreshControl];
    
    [self sendQueryForURL:CATEGORIES_LIST_URL forType:kHTTPClientTypeGetService forClientMethod:@"GET"];
    
  //  [[_serviceCollectionView delegate] collectionView:nil didSelectItemAtIndexPath:0];
    
    _contactTableView = [[ContactTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _contactTableView.tableView.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    _contactTableView.delegate = self;
    
    _popover = [[FPPopoverKeyboardResponsiveController alloc] initWithViewController:_contactTableView];
    _popover.tint = FPPopoverDefaultTint;
    _popover.contentSize = CGSizeMake(160, 125);
    
}
- (void)refreshView:(UIRefreshControl *)refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [refreshControl endRefreshing];
    
    // URL - /category - need to change
    [self sendQueryForURL:CATEGORIES_LIST_URL forType:kHTTPClientTypeGetService forClientMethod:@"GET"];
}
- (void)selectedTableRowIndex:(NSInteger)index
{
    [self.popover dismissPopoverAnimated:YES];
    
    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Info!" message:@"Do you want to continue?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Continue"]  completionBlock:^(EHAlertPromptHelper *actionSheet, NSUInteger buttonIndex){
        if (buttonIndex == 0) {
            //
        }
        else
        {
            if (index == 0) {
                [self sendQueryForURL:ServiceURLForType(kHTTPClientTypeCallMeBack) forType:kHTTPClientTypeCallMeBack forClientMethod:@"POST"];
            }
            else
            {
                [self sendQueryForURL:ServiceURLForType(kHTTPClientTypeCallTollFree) forType:kHTTPClientTypeCallTollFree forClientMethod:@"POST"];
            }
        }
    }];
    
}
- (IBAction)callButton:(id)sender
{
    [self.popover presentPopoverFromView:sender];
}
- (void)sendQueryForURL:(NSString *)url forType:(HTTPClientType)type forClientMethod:(NSString *)method
{
    weakify(self);
    
    _serviceClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        //  post method - mobile_number, contact_mode ---
        
        // 1 -> call me back,
        // 2 for toll free
       
        NSDictionary *dictionary = nil;
        if (type == kHTTPClientTypeCallMeBack) {
            
            dictionary = @{
                           @"mobile_number" : [[NSUserDefaults standardUserDefaults] usermobile],
                           @"contact_mode"  : @"1"
            };
        }
        else if (type == kHTTPClientTypeCallTollFree)
        {
            dictionary = @{
                           @"mobile_number" : [[NSUserDefaults standardUserDefaults] usermobile],
                           @"contact_mode"  : @"2"
                           };
        }
        else
        {
            //
        }
        return dictionary;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            if (type == kHTTPClientTypeCallTollFree) {
                
                NSString *contact = [NSString stringWithFormat:@"telprompt://%@",CUSTOMER_CARE_NUMBER];
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:contact]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contact]];
                }
            }
            else
            {
                [self showInvalidErrorMessage:[error localizedDescription] title:@"Message!"];
            }
        }
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            if (type == kHTTPClientTypeCallTollFree) {
                NSString *contact = [NSString stringWithFormat:@"telprompt://%@",CUSTOMER_CARE_NUMBER];
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:contact]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contact]];
                }
            }
            else if (type == kHTTPClientTypeCallMeBack)
            {
                [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"We shall get back to you shortly. Thank you" cancelButtonTitle:@"OK" otherButtonTitles:nil completionBlock:nil];
            }
            else
            {
                [self.serviceArray removeAllObjects];
                
                NSLog(@"Equipemnt %@",[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                    
                    NSArray *categoryList = dict[@"data"];
                    
                    for (int i = 0; i < categoryList.count; i++) {
                        NSDictionary *dictionary = categoryList[i];
                        
                        //equipmentId - id
                        //name - requirement name
                        // user_id - get through defaults
                        //categoryID -
                        
                        Equipment *equipment = [[Equipment alloc] init];
                        equipment.equipmentId = [dictionary[@"id"] integerValue];
                        equipment.equipmentImageURL = [NSURL URLWithString:dictionary[@"image"]];
                        equipment.equipmentName = dictionary[@"name"];
                        equipment.equipmentParentId = [dictionary[@"parentId"] integerValue];
                        //  equipment.userID =  [dictionary[@"user"][@"id"] integerValue];
                        //  equipment.categoryID =  [dictionary[@"category"] integerValue];
                        
                        [self.serviceArray addObject:equipment];
                    }
                }
                // Reload
                [_serviceCollectionView reloadData];
            }

        }
        
    }];
    [_serviceClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}
- (void)viewDidLayoutSubviews
{
    CGRect frame = self.view.frame;
    
    _serviceCollectionView.frame = frame;
    
    [_serviceCollectionView.collectionViewLayout invalidateLayout];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _serviceArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = _serviceCollectionView.bounds.size.width;
    
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) // For portrait show 2 columns
    {
        width /= 2.0;
    }
    else // For landscape show 4 columns
    {
        width /= 4.0;
    }
    
    width -= (CellSectionInset.left + CellSectionInset.right); // Inset
    
    CGSize cellSize = CGSizeMake(width,100);
    
    return cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return CellSectionInset;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EHGalleryCell *cell = (EHGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReuseCell" forIndexPath:indexPath];
    
    Equipment *equipment = _serviceArray[indexPath.row];
    
//    cell.serviceTitle.text = name;
//    cell.serviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.%@",name,@"png"]];
//
    cell.equipmentTitle = equipment.equipmentName;
    cell.cacheType = kCacheTypeMemory;
    cell.equipmentImageURL = equipment.equipmentImageURL;
    NSLog(@"Image url =%@",equipment.equipmentImageURL);
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [EHAlertPromptHelper showActionSheetIn:self withTitle:@"Info!" message:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[EHPlaceholderMessageForButtonType(kCallMeBack),EHPlaceholderMessageForButtonType(KTollFree),EHPlaceholderMessageForButtonType(kFillUpEnquiryForm)]  completionBlock:^(EHAlertPromptHelper *actionSheet, NSUInteger buttonIndex){
//        
//        switch (buttonIndex) {
//            case kCallMeBack:
//            {
//               [self sendQueryForURL:ServiceURLForType(kHTTPClientTypeCallMeBack) forType:kHTTPClientTypeCallMeBack forClientMethod:@"POST"];
//            }
//                
//                break;
//            case KTollFree:
//            {
//                [self sendQueryForURL:ServiceURLForType(kHTTPClientTypeCallTollFree) forType:kHTTPClientTypeCallTollFree forClientMethod:@"POST"];
//                
//                
//            }
//                break;
//            case kFillUpEnquiryForm:
//            {
        EHEnquiryFormViewController *enquiryFormViewController = [[EHEnquiryFormViewController alloc] init];
        enquiryFormViewController.entryType = kNewFormType;
        enquiryFormViewController.equipment = _serviceArray[indexPath.row];
        [self.navigationController pushViewController:enquiryFormViewController animated:YES];
//            }
//                break;
//                
//            default:
//                break;
//        }
//    }];
    
}
- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
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
