//
//  EHEHCustomerNotificationViewController.m
//  Easy Hire
//
//  Created by Prasanna on 12/12/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHEHCustomerNotificationViewController.h"
#import "SWRevealViewController.h"
#import "EHHTTPClient.h"
#import "EHParentTableViewCell.h"
#import "EHParentTableViewHeader.h"

NSString *EHNotificationSentURLForType(HTTPClientType type)
{
    switch (type) {
        case kHTTPClientTypeGetNotification:return MY_NOTIFICATION;
       // case kHTTPClientTypeRespondToNotification:return VEHICLE_GPS_LOCATION;
        default:return nil;
    }
}

@class EHCustomerNotifcationHeader;

@protocol EHCustomerNotifcationHeaderDelegate <NSObject>

- (void)expandableTableView:(EHCustomerNotifcationHeader *)expandableTableView sectionTapped:(NSInteger)section;

@end

@interface EHCustomerNotifcationHeader : EHParentTableViewHeader
@property (nonatomic, weak) id<EHCustomerNotifcationHeaderDelegate> delegate;
@property (nonatomic, assign) BOOL expand;
@property (nonatomic, strong) UIImageView *caratImageView;

@end

@implementation EHCustomerNotifcationHeader

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

@interface NotificationSent : NSObject

@property (nonatomic, copy) NSString *requiremntName;
@property (nonatomic, copy) NSString *requirementLocation;
@property (nonatomic, copy) NSString *requirementCpacity;
@property (nonatomic, copy) NSDate *requirementStartDate;
@property (nonatomic, copy) NSDate *requirementEndDate;
@property (nonatomic, assign) NSUInteger status;

@end
@implementation NotificationSent
@end

static NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *GMTDateFormat = nil;

@interface EHEHCustomerNotificationViewController () <EHCustomerNotifcationHeaderDelegate,UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *notificationTableView;

@end

@implementation EHEHCustomerNotificationViewController
{
    NSMutableArray *notificationArray;
    UIRefreshControl *refreshControl;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [self.view addSubview:_notificationTableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_notificationTableView addSubview:refreshControl];
    
    
    [self sendQueryForURL:EHNotificationSentURLForType(kHTTPClientTypeGetNotification) forType:kHTTPClientTypeGetNotification forClientMethod:@"GET"];
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
    
    [self sendQueryForURL:EHNotificationSentURLForType(kHTTPClientTypeGetNotification) forType:kHTTPClientTypeGetNotification forClientMethod:@"GET"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return notificationArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([expandedSections containsIndex:section]) {
        return 4;
    }
    else
        return 0;

}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) { // project location
        
        NotificationSent *model = notificationArray[indexPath.section];
        
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
    EHParentTableViewCell *cell = (EHParentTableViewCell *)[EHParentTableViewCell tableCellViewForTableView:tableView];
    
    NotificationSent *model = notificationArray[indexPath.section];
    switch (indexPath.row) {
        case 0:
        {
            NSString *startDateString = [dateFormatter stringFromDate:model.requirementStartDate];
            NSString *endDateString = [dateFormatter stringFromDate:model.requirementEndDate];
            cell.textLabel.text = @"Requirement date:";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ To %@",startDateString,endDateString];//model.requiremntName;
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"Requirement capacity:";
            cell.detailTextLabel.text = model.requirementCpacity;
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Requirement location:";
            cell.detailTextLabel.text = model.requirementLocation;
        }
            break;
        case 3:
        {
            NSMutableAttributedString *statusString = nil;
            
            switch (model.status) {
                case 0:
                {
                    statusString = [[NSMutableAttributedString alloc] initWithString:@"Pending"];
                    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, statusString.length)];
                }
                    break;
                case 1:
                {
                    
                    statusString = [[NSMutableAttributedString alloc] initWithString:@"Accepted"];
                    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:47/255.0 green:120/255.0 blue:49/255.0 alpha:1] range:NSMakeRange(0, statusString.length)];
                }
                    break;
                case 2:
                {
                    
                    statusString = [[NSMutableAttributedString alloc] initWithString:@"Rejected"];
                    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:148/255.0 green:35/255.0 blue:40/255.0 alpha:1] range:NSMakeRange(0, statusString.length)];
                }
                    break;
                case 3:
                {
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
- (void)updateTableView
{
    // [_requirementTableView beginUpdates];
    [_notificationTableView reloadData];
    // [_requirementTableView endUpdates];
    
}
- (void)expandableTableView:(EHCustomerNotifcationHeader *)expandableTableView sectionTapped:(NSInteger)section;
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    EHCustomerNotifcationHeader *headerView = (EHCustomerNotifcationHeader *)[EHCustomerNotifcationHeader headerCellViewForTableView:tableView];
    headerView.delegate = self;
    headerView.tag = section;
    headerView.expand = [expandedSections containsIndex:section];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(headerView.bounds) - 35, CGRectGetHeight(headerView.bounds))];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:17];
    label.adjustsFontSizeToFitWidth = YES;
    NotificationSent *model = notificationArray[section];
    
   // NSString *startDateString = [dateFormatter stringFromDate:model.requirementStartDate];
   // NSString *endDateString = [dateFormatter stringFromDate:model.requirementEndDate];
    
    label.text = model.requiremntName;//[NSString stringWithFormat:@"%@ To %@",startDateString,endDateString];
    [headerView addSubview:label];
    
    return headerView;
}
- (void)sendQueryForURL:(NSString *)url forType:(HTTPClientType)type forClientMethod:(NSString *)method
{
    weakify(self);
    
    EHHTTPClient *httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        // strongify(self);
        NSDictionary *param = nil;
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
            [self->notificationArray removeAllObjects];
            [self->expandedSections removeAllIndexes];
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                
                NSArray *array = dict[@"data"];
                NSMutableArray *resultArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *dict in array) {
                    NotificationSent *model = [[NotificationSent alloc] init];
                    
                    
                    
                    model.requirementCpacity = dict[@"capacity"];
                    model.requirementLocation = dict[@"location"];
                    model.requiremntName = dict[@"name"];
                    
                    NSDate *startDate = [GMTDateFormat dateFromString:dict[@"start_date"]];
                    // NSString *startDateString = [dateFormatter stringFromDate:startDate];
                    
                    NSDate *endDate = [GMTDateFormat dateFromString:dict[@"end_date"]];
                    //  NSString *endDateString = [dateFormatter stringFromDate:endDate];
                    
                    model.requirementStartDate = startDate;
                    model.requirementEndDate = endDate;
                    model.status = [dict[@"status"] integerValue];
                    [resultArray addObject:model];
                }
                
                if (resultArray.count > 1)
                {
                    // Sort based on start date
                    NSArray *sortedEventArray = [resultArray sortedArrayUsingComparator:^NSComparisonResult(NotificationSent *event1, NotificationSent *event2) {
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
@end
