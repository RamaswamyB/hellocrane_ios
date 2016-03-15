//
//  EHRequirementListViewController.m
//  Easy Hire
//
//  Created by Prasanna on 17/10/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHRequirementListViewController.h"
#import "SWRevealViewController.h"
#import "EHHTTPClient.h"
#import "EHParentTableViewHeader.h"
#import "EHParentTableViewCell.h"
#import "Equipment.h"
#import "EHEnquiryFormViewController.h"

static NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *GMTDateFormat = nil;

@class EHRequirementTableViewHeader;

@protocol EHRequirementTableViewHeaderDelegate <NSObject>

- (void)expandableTableView:(EHRequirementTableViewHeader *)expandableTableView didEditRequirementAtIndexPath:(NSInteger)section;
- (void)expandableTableView:(EHRequirementTableViewHeader *)expandableTableView didDeleteRequirementAtIndexPath:(NSInteger)section;

- (void)expandableTableView:(EHRequirementTableViewHeader *)expandableTableView sectionTapped:(NSInteger)section;

@end

@interface EHRequirementTableViewHeader : EHParentTableViewHeader

@property (nonatomic, copy) NSString *requirementTitle;
//@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) id<EHRequirementTableViewHeaderDelegate> delegate;

@property (nonatomic, assign, getter=isButtonVisible) BOOL buttonVisible;

@end


@interface EHRequirementTableViewHeader ()

@property (nonatomic, strong) UILabel *requirementLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *caratImageView;
@property (nonatomic, assign) BOOL expand;

@end

@implementation EHRequirementTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor grayColor];
        
        _requirementLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _requirementLabel.textColor = [UIColor whiteColor];
        //_requirementLabel.backgroundColor = [UIColor colorWithRed:223/255.0f green:47/255.0f blue:51/255.0f alpha:1.0];
        _requirementLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:_requirementLabel];
        
        _editButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [_editButton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_editButton];
        
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [_deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
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
    
    _requirementLabel.frame = CGRectMake(10, 0, CGRectGetWidth(frame) - 125, CGRectGetHeight(frame));
    _deleteButton.frame = CGRectMake(CGRectGetWidth(frame) - 65, 4.5, 35, 35);
    _editButton.frame = CGRectMake(CGRectGetMinX(_deleteButton.frame) - 45, 4.5, 35, 35);
    _caratImageView.frame = CGRectMake(CGRectGetWidth(frame) - 25, 12, 20, 20);
}
- (IBAction)editButtonTouched:(id)sender
{
    [self.delegate expandableTableView:self didEditRequirementAtIndexPath:self.tag];
}
- (IBAction)deleteButtonTouched:(id)sender
{
    [self.delegate expandableTableView:self didDeleteRequirementAtIndexPath:self.tag];
}
- (void)setButtonVisible:(BOOL)buttonVisible
{
    _buttonVisible = buttonVisible;
    _editButton.hidden = buttonVisible;
    _deleteButton.hidden = buttonVisible;
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

- (void)setRequirementTitle:(NSString *)requirementTitle
{
    _requirementTitle = requirementTitle;
    _requirementLabel.text = _requirementTitle;
}

@end

@interface EHRequirementListViewController ()<UITableViewDataSource,UITableViewDelegate,EHRequirementTableViewHeaderDelegate>

@property (nonatomic , strong) EHHTTPClient *httpClient;
@property (nonatomic, strong) UITableView *requirementTableView;

@end

NSString *EHRequirementURLForType(HTTPClientType type)
{
    switch (type) {
            
        case kHTTPClientTypeRequirementList: return EQUIPMENT_OWNED_URL;
        case kHTTPClientTypeRequirementDelete: return EQUIPMENT_OWNED_URL;
        default: return nil;
    }
}

@implementation EHRequirementListViewController
{
    NSMutableArray *requirementArray;
    NSMutableIndexSet *expandedSections;
    NSUInteger selectedRequirementIndex;
    UIRefreshControl *refreshControl;
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
    
    self.title = @"Requirement List";
    self.view.backgroundColor = [UIColor whiteColor];
    
    SWRevealViewController *revealController = [self revealViewController];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    
    requirementArray = [[NSMutableArray alloc] initWithCapacity:0];
    expandedSections = [[NSMutableIndexSet alloc] init];
    
    _requirementTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _requirementTableView.dataSource = self;
    _requirementTableView.delegate = self;
    _requirementTableView.allowsMultipleSelection = YES;
    _requirementTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _requirementTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_requirementTableView];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_requirementTableView addSubview:refreshControl];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendQueryForURL:REQUIREMENT_LIST forClientType:kHTTPClientTypeRequirementList forClientMethod:@"GET"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
     CGRect frame = self.view.bounds;
    _requirementTableView.frame = frame;
    [_requirementTableView reloadData];
}
- (void)refreshView:(UIRefreshControl *)refresh {
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [refreshControl endRefreshing];
    
    [self sendQueryForURL:REQUIREMENT_LIST forClientType:kHTTPClientTypeRequirementList forClientMethod:@"GET"];
}


- (EHParentTableViewHeader *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Equipment *model = requirementArray[section];
    EHRequirementTableViewHeader *headerView = (EHRequirementTableViewHeader *)[EHRequirementTableViewHeader headerCellViewForTableView:tableView];
    headerView.requirementTitle = model.requirementName;
    headerView.tag = section;
    headerView.delegate = self;
    headerView.expand = [expandedSections containsIndex:section];
    headerView.buttonVisible = model.equipmentStatus > 0 ? : NO;
    
    return headerView;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self updateTableView];
//}
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self updateTableView];
//    
//}
- (void)updateTableView
{
   // [_requirementTableView beginUpdates];
    [_requirementTableView reloadData];
   // [_requirementTableView endUpdates];
    
}
- (void)expandableTableView:(EHRequirementTableViewHeader *)expandableTableView sectionTapped:(NSInteger)section
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
- (void)expandableTableView:(EHRequirementTableViewHeader *)expandableTableView didEditRequirementAtIndexPath:(NSInteger)section
{
    EHEnquiryFormViewController *enquiryFormViewController = [[EHEnquiryFormViewController alloc] init];
    enquiryFormViewController.entryType = kEditFormType;
    enquiryFormViewController.equipment = requirementArray[section];

    Equipment *model = requirementArray[section];
    PlaceModel *placeModel = [[PlaceModel alloc] init];
    placeModel.placeName = model.location;
    placeModel.placeLocationCoordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
    
    enquiryFormViewController.selectedModel = placeModel;
    [self.navigationController pushViewController:enquiryFormViewController animated:YES];
    
}
- (void)expandableTableView:(EHRequirementTableViewHeader *)expandableTableView didDeleteRequirementAtIndexPath:(NSInteger)section
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"Do you want to delete the requirement?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Continue"] completionBlock:^(EHAlertPromptHelper *alert, NSUInteger buttonIndex){
        if (buttonIndex == 2) {
            
            selectedRequirementIndex = section;
            Equipment *model = requirementArray[section];
            
            [self sendQueryForURL:[NSString stringWithFormat:REQUIREMENT_LIST_DELETE,(unsigned long)model.categoryID] forClientType:kHTTPClientTypeRequirementDelete forClientMethod:@"DELETE"];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return requirementArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([expandedSections containsIndex:section]) {
        return 4;
    }
    else
        return 0;
    
//    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) { // project location
        
        Equipment *model = requirementArray[indexPath.section];
        
        CGRect detaiLabelSizeRect = [model.location boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}context:nil];
        
        CGRect titleLabelSizeRect = [@"Project location:" boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 1000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}context:nil];
        
        CGSize detailLabelSize = detaiLabelSizeRect.size;
        CGSize titleLabelSize = titleLabelSizeRect.size;
        
        return MAX(40, (detailLabelSize.height +titleLabelSize.height + 15));
    }
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
    EHParentTableViewCell *cell = (EHParentTableViewCell *)[EHParentTableViewCell tableCellViewForTableView:tableView];
    
    Equipment *model = requirementArray[indexPath.section];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Start date:";
            cell.detailTextLabel.text = model.equipmentStartDate;
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"End date:";
            cell.detailTextLabel.text = model.equipmentEndDate;
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Project location:";
            cell.detailTextLabel.text = model.location;
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"Status:";
            NSMutableAttributedString *statusString = nil;
            
            switch (model.equipmentStatus) {
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
                    statusString = [[NSMutableAttributedString alloc] initWithString:@"Status: Deleted"];
                    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:148/255.0 green:35/255.0 blue:40/255.0 alpha:1] range:NSMakeRange(0, statusString.length)];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.detailTextLabel.attributedText = statusString;
        }
            break;

            
        default:
            break;
    }
    //[cell layoutIfNeeded];
    return cell;
}
- (void)sendQueryForURL:(NSString *)url forClientType:(HTTPClientType)type forClientMethod:(NSString *)method
{
    weakify(self);
    
    _httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        // strongify(self);
        NSDictionary *equipmentDict = nil;
        return equipmentDict;
        
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
            
            if ([[EHValidateWrapper sharedInstance] isNullDictionary:dict]) {
                
                [self showInvalidErrorMessage:@"Something went wrong.Please try again." title:@"Message"];
                return;
            }
            
            [expandedSections removeAllIndexes];
            
            if (type == kHTTPClientTypeRequirementDelete) {
                
                [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:dict[@"message"] cancelButtonTitle:@"Ok" otherButtonTitles:nil completionBlock:^(EHAlertPromptHelper *alert, NSUInteger buttonIndex){
                    
                    if (selectedRequirementIndex < self->requirementArray.count) {
                        
                        // Equipment *model = self->requirementArray[selectedRequirementIndex];
                        // model.equipmentStatus = 3;//Deleted
                        
                        [self->requirementArray removeObjectAtIndex:selectedRequirementIndex];
                        // [self->requirementArray replaceObjectAtIndex:selectedRequirementIndex withObject:model];
                        
                        [self.requirementTableView reloadData];
                    }
                    
                }];
            }
            else
            {
                [requirementArray removeAllObjects];
                
                
                NSArray *array = dict[@"data"];
                for (int i = 0; i < array.count; i++) {
                    
                    NSDictionary *dict = array[i];
                    
                    Equipment *model = [[Equipment alloc] init];
                    model.requirementName = dict[@"name"];
                    
                    NSString *startDateString = dict[@"start_date"];
                    NSString *endDateString = dict[@"end_date"];
                    
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
                    model.equipmentStartDate = startDateString;
                    model.equipmentEndDate = endDateString;
                    
                    
                    model.equipmentId = [dict[@"category_id"] integerValue];
                    model.categoryID =  [dict[@"id"] integerValue];
                    model.location = dict[@"location"];
                    model.equipmentStatus = [dict[@"status"] integerValue];
                    model.latitude = [dict[@"lat"] floatValue];
                    model.longitude = [dict[@"lng"] floatValue];
                    model.equipmentCapacity = dict[@"capacity"];
                    
                    //   @property (assign) int numberOfEquipmentRequired;
                    //   @property (assign) int brand;
                    
                    model.numberOfEquipmentRequiredCount = [dict[@"number_of_equipments"] intValue];
                    model.yearOfManufacture = dict[@"year_of_manufacture"];
                    model.brandID = [dict[@"brand"] intValue];
                    model.capacityID = dict[@"capacity"];
                    [requirementArray addObject:model];
                }
                [_requirementTableView reloadData];
                
                NSLog(@"requirementArray %lu",(unsigned long)requirementArray.count);
                
                if (requirementArray.count <= kNilOptions) {
                    
                    // Show no notification alert
                    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"No Requirements Found" cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
                }
                
            }
        }
       
        
    }];
    [_httpClient start];
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
