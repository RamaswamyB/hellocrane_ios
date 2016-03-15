//
//  EHEquipmentOwnedViewController.m
//  Easy Hire
//
//  Created by Prasanna on 15/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHEquipmentOwnedListViewController.h"
#import "SWRevealViewController.h"
#import "EHHTTPClient.h"
#import "EHParentTableViewHeader.h"
#import "EHParentTableViewCell.h"
#import "FPPopoverKeyboardResponsiveController.h"

#define EQUIPMENT_LIST_TITLE @"Failed to get equipment"
#define CUSTOMER_CARE_NUMBER @"18001038392"

NSString *ServiceURLForSupplierType(HTTPClientType type)
{
    switch (type) {
        case kHTTPClientTypeCallTollFree: return CUSTOMER_CARE_SERVICE;
        case kHTTPClientTypeCallMeBack: return CUSTOMER_CARE_SERVICE;
            
        default:return nil;
    }
}

@protocol ContactTableViewControllerSupplierDelegate <NSObject>

- (void)selectedTableRowIndex:(NSInteger)index;

@end

@interface ContactTableViewControllerSupplier : UITableViewController

@property (nonatomic, assign) id<ContactTableViewControllerSupplierDelegate> delegate;

@end

@implementation ContactTableViewControllerSupplier

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

@class ListViewHeader;

@protocol ListViewHeaderDelegate <NSObject>

- (void)expandableTableView:(ListViewHeader *)expandableTableView sectionTapped:(NSInteger)section;

@end

@interface ListViewHeader : EHParentTableViewHeader

@property (nonatomic, copy) NSString *equipmentTitle;
@property (nonatomic, assign,getter = isExpanded) BOOL expand;
@property (nonatomic, assign) id<ListViewHeaderDelegate> delegate;

@end

@interface ListViewHeader ()

@property (nonatomic, strong) UILabel *equipmentNameLabel;
@property (nonatomic, strong) UIImageView *caratImageView;

@end

@implementation ListViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor grayColor];
        
        _equipmentNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _equipmentNameLabel.textColor = [UIColor whiteColor];
        //_requirementLabel.backgroundColor = [UIColor colorWithRed:223/255.0f green:47/255.0f blue:51/255.0f alpha:1.0];
        _equipmentNameLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:_equipmentNameLabel];
        
        _caratImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _caratImageView.image = [UIImage imageNamed:@"arrow.png"];
        [self addSubview:_caratImageView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOccurred:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    
    _equipmentNameLabel.frame = CGRectMake(10, 0, CGRectGetWidth(frame) - 110, CGRectGetHeight(frame));
    _caratImageView.frame = CGRectMake(CGRectGetWidth(frame) - 25, 12, 20, 20);
}

#pragma mark UITapGestureRecognizer method
- (void)tapOccurred:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.delegate expandableTableView:self sectionTapped:self.tag];
        self.expand = !self.expand;
    }
}
- (void)setEquipmentTitle:(NSString *)equipmentTitle
{
    _equipmentTitle = equipmentTitle;
    _equipmentNameLabel.text = equipmentTitle;
}
- (void)setExpand:(BOOL)expand
{
    _expand = expand;
    
    CGAffineTransform transform;
    if (expand) {
        
        transform = CGAffineTransformMakeRotation(M_PI/2);
        
    }
    else
    {
        transform = CGAffineTransformMakeRotation(0);
    }
    _caratImageView.transform = transform;
    [UIView animateWithDuration:0.25 animations:^{
        _caratImageView.transform = transform;
    }];
}

@end

@interface EquipmentModel : NSObject

@property (nonatomic, copy) NSString *equipmentName;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic,assign) NSUInteger status;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *capacity;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *vehicleNumber;

@end

@implementation EquipmentModel
@end

@interface EHEquipmentOwnedListViewController () <ListViewHeaderDelegate,UITableViewDataSource, UITableViewDelegate,ContactTableViewControllerSupplierDelegate>

@property (nonatomic , strong) EHHTTPClient *httpClient;
@property (nonatomic, strong) UITableView *equipmentOwnedTableView;
@property (nonatomic, strong) NSMutableArray *equipmentArray;
@property (nonatomic, strong)  FPPopoverKeyboardResponsiveController *popover;
@property (nonatomic, strong) ContactTableViewControllerSupplier *contactTableView;

@end

static NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *GMTDateFormat = nil;
static NSDateComponents* comps = nil;
static NSCalendar* calendar = nil;

@implementation EHEquipmentOwnedListViewController
{
    NSMutableIndexSet *expandedSections;
    UIRefreshControl *refreshControl;
}
+ (void)initialize
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    GMTDateFormat = [[NSDateFormatter alloc] init];
    [GMTDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    comps = [[NSDateComponents alloc]init];
    comps.day = 1;
    calendar = [NSCalendar currentCalendar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tabBarItem.title = @"List View";
    self.view.backgroundColor = [UIColor whiteColor];

    SWRevealViewController *revealController = [self revealViewController];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.tabBarController.navigationItem.leftBarButtonItem = revealButtonItem;
    
    if ([[UIImage imageNamed:@"listview.png"] respondsToSelector:@selector(imageWithRenderingMode:)]) {
        self.tabBarItem.image =  [[UIImage imageNamed:@"listview.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        // iOS 6 fallback: insert code to convert imaged if needed
        self.tabBarItem.image = [UIImage imageNamed:@"listview.png"];
    }
    
    
    
    _equipmentArray = [[NSMutableArray alloc] initWithCapacity:0];
    expandedSections = [[NSMutableIndexSet alloc] init];
    
    _equipmentOwnedTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _equipmentOwnedTableView.dataSource = self;
    _equipmentOwnedTableView.delegate = self;
    _equipmentOwnedTableView.rowHeight = 0.0f;
    _equipmentOwnedTableView.allowsMultipleSelection = YES;
    _equipmentOwnedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _equipmentOwnedTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_equipmentOwnedTableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_equipmentOwnedTableView addSubview:refreshControl];
    
    [self sendQueryForURL:[NSString stringWithFormat:EQUIPMENT_OWNED_URL,(unsigned long)[[NSUserDefaults standardUserDefaults]userid]] forClientMethod:@"GET"];
    
    
    
    _contactTableView = [[ContactTableViewControllerSupplier alloc] initWithStyle:UITableViewStylePlain];
    _contactTableView.tableView.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    _contactTableView.delegate = self;
    
    _popover = [[FPPopoverKeyboardResponsiveController alloc] initWithViewController:_contactTableView];
    _popover.tint = FPPopoverDefaultTint;
    _popover.contentSize = CGSizeMake(160, 125);

    
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
                [self sendQueryForURL:ServiceURLForSupplierType(kHTTPClientTypeCallMeBack) forType:kHTTPClientTypeCallMeBack forClientMethod:@"POST"];
            }
            else
            {
                [self sendQueryForURL:ServiceURLForSupplierType(kHTTPClientTypeCallTollFree) forType:kHTTPClientTypeCallTollFree forClientMethod:@"POST"];
            }
        }
    }];
    
}
- (void)sendQueryForURL:(NSString *)url forType:(HTTPClientType)type forClientMethod:(NSString *)method
{
    weakify(self);
    
    EHHTTPClient *serviceClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
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
        if(self) {
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
        }
        
        
    }];
    [serviceClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}
- (IBAction)callButton:(id)sender
{
    [self.popover presentPopoverFromView:sender];
}
- (void)viewDidLayoutSubviews
{
    CGRect frame = self.view.bounds;
    
    frame.size.height -= CGRectGetHeight(self.tabBarController.tabBar.bounds);
    _equipmentOwnedTableView.frame = frame;
    [_equipmentOwnedTableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"List View";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (CGRect){0,0,30,30};
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(callButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}
- (void)refreshView:(UIRefreshControl *)refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [refreshControl endRefreshing];
    
    [self sendQueryForURL:[NSString stringWithFormat:EQUIPMENT_OWNED_URL,(unsigned long)[[NSUserDefaults standardUserDefaults]userid]] forClientMethod:@"GET"];
}

- (ListViewHeader *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ListViewHeader *headerView = (ListViewHeader *)[ListViewHeader headerCellViewForTableView:tableView];
    
    EquipmentModel *model = _equipmentArray[section];
    headerView.equipmentTitle = model.equipmentName;
    headerView.tag = section;
    headerView.delegate = self;
    headerView.expand = [expandedSections containsIndex:section];
    return headerView;
}
- (void)updateTableView
{
    //[_equipmentOwnedTableView beginUpdates];
   // [_equipmentOwnedTableView endUpdates];
    [_equipmentOwnedTableView reloadData];
}
- (void)expandableTableView:(ListViewHeader *)expandableTableView sectionTapped:(NSInteger)section
{
    BOOL currentlyExpanded = [expandedSections containsIndex:section];

    if (currentlyExpanded) {
        [expandedSections removeIndex:section];
       
    }
    else
    {
        [expandedSections addIndex:section];
       
    }
    
    [self updateTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _equipmentArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([expandedSections containsIndex:section]) {
        return 6;
    }
    else
        return 0;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    EHEquipmentTableViewCell *cell = (EHEquipmentTableViewCell *)[EHEquipmentTableViewCell tableCellViewForTableView:tableView];
//    
//    EquipmentModel *model = _equipmentArray[indexPath.section];
//    cell.startDateString = model.startDate;
//    cell.endDateString = model.endDate;
//   
//    if (model.status == 1) {
//        //available
//        cell.statusString = @"Available";
//    }
//    else
//    {
//        // Not available
//        cell.statusString = @"Not Available";
//    }
//    
//    cell.statusBlock = ^(StatusChangeType inputType, NSString *input)
//    {
//        
//    };
    
    EHParentTableViewCell *cell = (EHParentTableViewCell *)[EHParentTableViewCell tableCellViewForTableView:tableView];
    
    EquipmentModel *model = _equipmentArray[indexPath.section];
    
    switch (indexPath.row) {
        case 0: // model
        {
            cell.textLabel.text = @"Vehicle model:";
            cell.detailTextLabel.text = model.modelName;
        }
            break;
        case 1: // year
        {
            cell.textLabel.text = @"Vehicle manufacture year:";
            cell.detailTextLabel.text = model.year;
            
        }
            break;
        case 2: // capacity
        {
            cell.textLabel.text = @"Vehicle capacity:";
            cell.detailTextLabel.text = model.capacity;
        }
            break;
        case 3: // start date
        {
            cell.textLabel.text = @"Start date:";
            cell.detailTextLabel.text = model.startDate;
        }
            break;
        case 4: // end date
        {
            cell.textLabel.text = @"End date:";
            cell.detailTextLabel.text = model.endDate;
        }
            break;
        case 5: // status
        {
            cell.textLabel.text = @"Available on:";
            
            if (![model.endDate isEqualToString:@"Not Available"] && model.endDate != nil) {
                NSDate* tomorrow = [calendar dateByAddingComponents:comps toDate:[dateFormatter dateFromString:model.endDate] options:0];
                cell.detailTextLabel.text = [dateFormatter stringFromDate:tomorrow];
            }
            else
            {
                cell.detailTextLabel.text = @"";
            }
            
        }
            break;
        default:
            break;
    }
   
    return cell;
}

- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
}
- (void)sendQueryForURL:(NSString *)url forClientMethod:(NSString *)method
{
    weakify(self);
    
    _httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
       // strongify(self);
        NSDictionary *equipmentDict = nil;
        return equipmentDict;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:EQUIPMENT_LIST_TITLE];
        }
        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self.equipmentArray removeAllObjects];
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                
                NSArray *equipmentDetails = dict[@"data"];
                
                for (int i = 0; i < equipmentDetails.count; i++) {
                    EquipmentModel *model = [[EquipmentModel alloc] init];
                    NSDictionary *equipment = equipmentDetails[i];
                    
                    model.equipmentName = ([equipment[@"name"] length] > 0) ? equipment[@"name"] : @"Not Available";
                    
                    model.status = [equipment[@"status"] integerValue];
                    
                    model.modelName =  ([equipment[@"model"] length] > 0) ? equipment[@"model"] : @"Not Available";
                    
                    model.vehicleNumber =  ([equipment[@"vehicle_number"] length] > 0) ? equipment[@"vehicle_number"] : @"Not Available";
                    
                    model.capacity = ([equipment[@"capacity"] length] > 0) ? equipment[@"capacity"] : @"Not Available";
                    
                    NSInteger year = [equipment[@"year"] integerValue];
                    if (year > 0) {
                        model.year = [NSString stringWithFormat:@"%d",[equipment[@"year"] intValue]];
                    }
                    else
                    {
                        model.year = @"Not Available";
                    }
                    
                    
                    NSString *startDateString = equipment[@"start_date"];
                    NSString *endDateString = equipment[@"end_date"];
                    
                    if (startDateString.length <= 0) {
                        startDateString = @"Not Available";
                    }
                    else
                    {
                        NSDate *startDate = [GMTDateFormat dateFromString:startDateString];
                        startDateString = [dateFormatter stringFromDate:startDate];
                    }
                    
                    if (endDateString.length <= 0) {
                        endDateString = @"Not Available";
                    }
                    else
                    {
                        NSDate *endDate = [GMTDateFormat dateFromString:endDateString];
                        endDateString = [dateFormatter stringFromDate:endDate];
                    }
                    
                    model.startDate = startDateString;
                    model.endDate = endDateString;
                    
                    [_equipmentArray addObject:model];
                }
                
                [expandedSections removeAllIndexes];
                [_equipmentOwnedTableView reloadData];
                
            }
            else
            {
                [self showInvalidErrorMessage:@"Something went wrong. Please try again." title:EQUIPMENT_LIST_TITLE];
            }

        }
        
    }];
    [_httpClient start];
    [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}
@end
