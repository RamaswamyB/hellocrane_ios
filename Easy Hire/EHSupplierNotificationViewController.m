//
//  EHNotificationViewController.m
//  Easy Hire
//
//  Created by Prasanna on 07/12/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHSupplierNotificationViewController.h"
#import "SWRevealViewController.h"
#import "EHHTTPClient.h"
#import "EHParentTableViewCell.h"
#import "EHParentTableViewHeader.h"
#import "EHParentTableViewFooter.h"

NSString *EHNotificationURLForType(HTTPClientType type)
{
    switch (type) {
        case kHTTPClientTypeGetNotification:return MY_NOTIFICATION;
        case kHTTPClientTypeAcceptNotification:return MY_NOTIFICATION_ACCEPT;
        case kHTTPClientTypeRejectNotification:return MY_NOTIFICATION_REJECT;
        default:return nil;
    }
}

@class EHSupplierNotifcationHeader;

@protocol EHSupplierNotifcationHeaderDelegate <NSObject>

- (void)expandableTableView:(EHSupplierNotifcationHeader *)expandableTableView sectionTapped:(NSInteger)section;

@end

@interface EHSupplierNotifcationHeader : EHParentTableViewHeader
@property (nonatomic, weak) id<EHSupplierNotifcationHeaderDelegate> delegate;
@property (nonatomic, assign) BOOL expand;
@property (nonatomic, strong) UIImageView *caratImageView;

@end

@implementation EHSupplierNotifcationHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOccurred:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        _caratImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _caratImageView.image = [UIImage imageNamed:@"arrow.png"];
        [self addSubview:_caratImageView];
    }
    return self;
}

#pragma mark UITapGestureRecognizer method
- (void)tapOccurred:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.expand = !self.expand;
        [self.delegate expandableTableView:self sectionTapped:self.tag];
    }
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
- (void)layoutSubviews
{
    CGRect frame = self.bounds;
    _caratImageView.frame = CGRectMake(CGRectGetWidth(frame) - 25, 12, 20, 20);
}
@end

@interface NotificationReceived : NSObject

@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, copy) NSString *requiremntName;
@property (nonatomic, copy) NSString *requirementLocation;
@property (nonatomic, copy) NSString *requirementCpacity;
@property (nonatomic, copy) NSDate *requirementStartDate;
@property (nonatomic, copy) NSDate *requirementEndDate;
@property (nonatomic, assign) NSUInteger requirementID;
@property (nonatomic, assign) NSUInteger requirementStatus;

@end
@implementation NotificationReceived
@end

static NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *GMTDateFormat = nil;

@interface EHSupplierNotificationViewController () <EHSupplierNotifcationHeaderDelegate,UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *notificationTableView;

@end

@implementation EHSupplierNotificationViewController
{
    NSMutableArray *notificationArray;
    UIRefreshControl *refreshControl;
    NSUInteger selectedNotification;
    NSMutableIndexSet *expandedSections;
}
+ (void)initialize
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    GMTDateFormat = [[NSDateFormatter alloc] init];
    [GMTDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Notification";
    SWRevealViewController *revealController = [self revealViewController];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    expandedSections = [[NSMutableIndexSet alloc] init];
    
    notificationArray = [[NSMutableArray alloc] initWithCapacity:kNilOptions];
    
    _notificationTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _notificationTableView.delegate = self;
    _notificationTableView.dataSource = self;
    _notificationTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _notificationTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_notificationTableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_notificationTableView addSubview:refreshControl];
    
    [self sendQueryForURL:EHNotificationURLForType(kHTTPClientTypeGetNotification) forType:kHTTPClientTypeGetNotification forClientMethod:@"GET" param:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.view.bounds;
    _notificationTableView.frame = frame;
    [_notificationTableView reloadData];
}
- (void)refreshView:(UIRefreshControl *)refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [refreshControl endRefreshing];
    
    [self sendQueryForURL:EHNotificationURLForType(kHTTPClientTypeGetNotification) forType:kHTTPClientTypeGetNotification forClientMethod:@"GET" param:nil];
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return notificationArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([expandedSections containsIndex:section]) {
        NotificationReceived *model = notificationArray[section];
        
        if (model.requirementStatus != 0) { // o is pending
            return 5;
        }
        return 4;
    }
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) { // project location
        
        NotificationReceived *model = notificationArray[indexPath.section];
        
        CGRect detaiLabelSizeRect = [model.requirementLocation boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}context:nil];
        
        CGRect titleLabelSizeRect = [@"Requirement location:" boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}context:nil];
        
        CGSize detailLabelSize = detaiLabelSizeRect.size;
        CGSize titleLabelSize = titleLabelSizeRect.size;
        
        return MAX(50, (detailLabelSize.height +titleLabelSize.height + 15));
    }
    return 50;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellID = @"aCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
//        
//        cell.textLabel.font = [UIFont systemFontOfSize:13];
//        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
//        cell.detailTextLabel.numberOfLines = 0;
//        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
//
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
    
    EHParentTableViewCell *cell = (EHParentTableViewCell *)[EHParentTableViewCell tableCellViewForTableView:tableView];
    
    NotificationReceived *model = notificationArray[indexPath.section];
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Customer name:";
            cell.detailTextLabel.text = model.customerName;
        }
            break;
        case 1:
        {
            NSString *startDateString = [dateFormatter stringFromDate:model.requirementStartDate];
            NSString *endDateString = [dateFormatter stringFromDate:model.requirementEndDate];
            
            cell.textLabel.text = @"Requirement date:";//@"Requirement name:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ To %@",startDateString,endDateString];//model.requiremntName;
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Requirement capacity:";
            cell.detailTextLabel.text = model.requirementCpacity;
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"Requirement location:";
            cell.detailTextLabel.text = model.requirementLocation;
        }
            break;
        case 4:
        {
            NSMutableAttributedString *statusString = nil;
            
            switch (model.requirementStatus) {
                case 1:
                { // accepted
                    statusString = [[NSMutableAttributedString alloc] initWithString:@"Accepted"];
                    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:47/255.0 green:120/255.0 blue:49/255.0 alpha:1] range:NSMakeRange(0, statusString.length)];
                }
                    break;
                case 2:
                { // rejected
                    statusString = [[NSMutableAttributedString alloc] initWithString:@"Rejected"];
                    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:148/255.0 green:35/255.0 blue:40/255.0 alpha:1] range:NSMakeRange(0, statusString.length)];
                }
                    break;
                case 3:
                { // deleted
                    statusString = [[NSMutableAttributedString alloc] initWithString:@"Deleted"];
                    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:148/255.0 green:35/255.0 blue:40/255.0 alpha:1] range:NSMakeRange(0, statusString.length)];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.textLabel.text = @"Status:";
            cell.detailTextLabel.attributedText = statusString;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NotificationReceived *model = notificationArray[section];
    
    if (model.requirementStatus == 0) { // 0 is pending status
        return 35;
    }
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NotificationReceived *model = notificationArray[section];
    
    EHSupplierNotifcationHeader *headerView = (EHSupplierNotifcationHeader *)[EHSupplierNotifcationHeader headerCellViewForTableView:tableView];
    headerView.delegate = self;
    headerView.tag = section;
    headerView.expand = [expandedSections containsIndex:section];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(headerView.bounds) - 35, CGRectGetHeight(headerView.bounds))];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:17];
    label.adjustsFontSizeToFitWidth = YES;
    
  //  NSString *startDateString = [dateFormatter stringFromDate:model.requirementStartDate];
  //  NSString *endDateString = [dateFormatter stringFromDate:model.requirementEndDate];
    
    label.text = model.requiremntName;//[NSString stringWithFormat:@"%@ To %@",startDateString,endDateString];
    [headerView addSubview:label];
    
    return headerView;
}
- (void)updateTableView
{
    // [_requirementTableView beginUpdates];
    [_notificationTableView reloadData];
    // [_requirementTableView endUpdates];
    
}
- (void)expandableTableView:(EHSupplierNotifcationHeader *)expandableTableView sectionTapped:(NSInteger)section;
{
    BOOL currentlyExpanded = [expandedSections containsIndex:section];
    
    // NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    
    if (currentlyExpanded) {
        [expandedSections removeIndex:section];
        // [_requirementTableView deselectRowAtIndexPath:indexPath animated:NO];
        // [[_requirementTableView delegate] tableView:_requirementTableView didDeselectRowAtIndexPath:indexPath];
    }
    else
    {
        [expandedSections addIndex:section];
        // [_requirementTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        // [[_requirementTableView delegate] tableView:_requirementTableView didSelectRowAtIndexPath:indexPath];
    }
    
    [self updateTableView];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NotificationReceived *model = notificationArray[section];
    if (model.requirementStatus != 0) { // 0 is pending status
        return nil;
    }
    
    EHParentTableViewFooter *footerView = (EHParentTableViewFooter *)[EHParentTableViewFooter footerCellViewForTableView:tableView];
   // footerView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    
    UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptButton.frame = CGRectMake(10, 1, CGRectGetWidth(tableView.bounds) /2 - 15, 30);
    
    acceptButton.tag = section;
    [acceptButton setTitle:@"Accept Proposal" forState:UIControlStateNormal];
    acceptButton.titleLabel.font = [UIFont systemFontOfSize:14];
    acceptButton.backgroundColor = [UIColor colorWithRed:47/255.0 green:120/255.0 blue:49/255.0 alpha:1];
    [acceptButton addTarget:self action:@selector(buttonAcceptTouched:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:acceptButton];
    
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rejectButton.tag = section;
    rejectButton.frame = CGRectMake(CGRectGetMaxX(acceptButton.frame) + 10, 1, CGRectGetWidth(tableView.bounds) /2 - 15, 30);
    rejectButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [rejectButton setTitle:@"Reject Proposal" forState:UIControlStateNormal];
    rejectButton.backgroundColor = [UIColor colorWithRed:148/255.0 green:35/255.0 blue:40/255.0 alpha:1];
    [rejectButton addTarget:self action:@selector(buttonRejectTouched:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:rejectButton];
    
    return footerView;
}
- (IBAction)buttonAcceptTouched:(id)sender
{
    selectedNotification = [sender tag];
    
    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Info!" message:@"Do you want to continue?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Continue"]  completionBlock:^(EHAlertPromptHelper *actionSheet, NSUInteger buttonIndex){
        if (buttonIndex == 0) {
            //
        }
        else
        {
            NotificationReceived *model = notificationArray[[sender tag]];
            
            NSDictionary *param = @{
                                    @"status" : @"1"
                                    };
            [self sendQueryForURL:[NSString stringWithFormat:EHNotificationURLForType(kHTTPClientTypeAcceptNotification),model.requirementID] forType:kHTTPClientTypeAcceptNotification forClientMethod:@"POST" param:param];
        }
    }];
    
}
- (IBAction)buttonRejectTouched:(id)sender
{
    selectedNotification = [sender tag];
    
    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Info!" message:@"Do you want to continue?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Continue"]  completionBlock:^(EHAlertPromptHelper *actionSheet, NSUInteger buttonIndex){
        if (buttonIndex == 0) {
            //
        }
        else
        {
            NotificationReceived *model = notificationArray[[sender tag]];
            
            NSDictionary *param = @{
                                    
                                    @"status" : @"2"
                                    };
            [self sendQueryForURL:[NSString stringWithFormat:EHNotificationURLForType(kHTTPClientTypeRejectNotification),model.requirementID] forType:kHTTPClientTypeRejectNotification forClientMethod:@"POST" param:param];
        }
    }];
}

- (void)sendQueryForURL:(NSString *)url forType:(HTTPClientType)type forClientMethod:(NSString *)method param:(NSDictionary *)param
{
    weakify(self);
    
    EHHTTPClient *httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        // strongify(self);
        return param;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if(self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:@"Message!"];
        }
        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                
                
                if (type == kHTTPClientTypeGetNotification) {
                    
                    [self->notificationArray removeAllObjects];
                    [self->expandedSections removeAllIndexes];
                    
                    NSArray *array = dict[@"data"];
                    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *dict in array) {
                        NotificationReceived *model = [[NotificationReceived alloc] init];
                        
                        model.customerName = [NSString stringWithFormat:@"%@ %@",dict[@"user"][@"first_name"],dict[@"user"][@"last_name"]];
                        //   model.customerEmail = dict[@"user"][@"email"];
                        //   model.customerMobileNumber = dict[@"user"][@"mobile_number"];
                        
                        model.requirementCpacity = dict[@"capacity"];
                        model.requirementLocation = dict[@"location"];
                        model.requiremntName = dict[@"name"];
                        model.requirementID = [dict[@"id"] integerValue];
                        model.requirementStatus = [dict[@"status"] integerValue];
                        
                        NSDate *startDate = [GMTDateFormat dateFromString:dict[@"start_date"]];
                        // NSString *startDateString = [dateFormatter stringFromDate:startDate];
                        
                        NSDate *endDate = [GMTDateFormat dateFromString:dict[@"end_date"]];
                        //  NSString *endDateString = [dateFormatter stringFromDate:endDate];
                        
                        model.requirementStartDate = startDate;
                        model.requirementEndDate = endDate;
                        
                        [resultArray addObject:model];
                    }
                    
                    if (resultArray.count > 1)
                    {
                        // Sort based on start date
                        NSArray *sortedEventArray = [resultArray sortedArrayUsingComparator:^NSComparisonResult(NotificationReceived *event1, NotificationReceived *event2) {
                            return [event1.requirementStartDate compare:event2.requirementStartDate];
                        }];
                        
                        [notificationArray addObjectsFromArray:sortedEventArray];
                        
                    }
                    else {
                        [notificationArray addObjectsFromArray:resultArray];
                    }
                    [_notificationTableView reloadData];
                    
                    if (notificationArray.count <= kNilOptions) {
                        // Show no notification alert
                        [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"No Notifications Available" cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
                    }
                    
                    
                }
                else
                {
                    //  if (selectedNotification < notificationArray.count) {
                    //    [notificationArray removeObjectAtIndex:selectedNotification];
                    //  [_notificationTableView reloadData];
                    //}
                    
                    // Refresh
                    [self sendQueryForURL:EHNotificationURLForType(kHTTPClientTypeGetNotification) forType:kHTTPClientTypeGetNotification forClientMethod:@"GET" param:nil];
                    
                    // Accept/Reject
                    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:dict[@"status"] cancelButtonTitle:@"OK" otherButtonTitles:nil completionBlock:nil];
                }
                
                
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
