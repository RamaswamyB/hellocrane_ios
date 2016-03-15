//
//  EHContactUsViewController.m
//  Easy Hire
//
//  Created by Prasanna on 04/10/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHEnquiryFormViewController.h"
#import "SWRevealViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "RMDateSelectionViewController.h"
#import "EHHTTPClient.h"
#import "FPPopoverController.h"
#import "ARCMacros.h"
#import "FPPopoverKeyboardResponsiveController.h"
#import <QuartzCore/QuartzCore.h>
#import "EHListViewController.h"

NSString *RequirementURLForType(HTTPClientType type)
{
    switch (type) {
        case kHTTPClientTypeGetProjectLocationAddress:return LOCATION_API;
        case kHTTPClientTypeGetProjectLocationCoordinate: return COORDINATE_API;
        case kEHClientTypeDeviceCapacity: return CAPACITY_URL;
        case kEHClientTypeDeviceBrand: return BRAND_URL;
        default:return nil;
    }
}
UIKeyboardType keyboardTypeForFormType(EHFormTextFieldType type)
{
    switch (type) {
        case kEHNumberOfEquipmentRequired:return UIKeyboardTypePhonePad;
        
        default:return UIKeyboardTypeDefault;
    }
}
UITextAutocapitalizationType capitalizationType(EHFormTextFieldType type)
{
    switch (type) {
        case kEHRequirementNameField: return UITextAutocapitalizationTypeWords;
        default: return UITextAutocapitalizationTypeNone;
            
    }
}
id rightViewForFormType(EHFormTextFieldType type,EHEnquiryFormViewController *self)
{
    switch (type) {
        case kEHCapacityField:
        case kEHBrandField:
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, 40, 40);
            button.tag = type;
            button.contentMode = UIViewContentModeScaleAspectFit;
            [button setImage:[UIImage imageNamed:@"rightarrow"] forState:UIControlStateNormal];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            
            [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
#pragma clang diagnostic pop
            
            [button sizeToFit];

            return button;
        }
            break;
            
        default:return nil;
            
    }
}

NSString *const apiKey = @"AIzaSyBTQPYb8fvHUwey8yp_uZ-jsn-NwWj9h4Q";


@implementation PlaceModel
@end

@protocol AutocompleteTableViewControllerDelegate <NSObject>

- (void)selectedTableRowWithModel:(PlaceModel *)model;

@end

@interface AutocompleteTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *placeArray;
@property (nonatomic, assign) id<AutocompleteTableViewControllerDelegate> delegate;

@end

@implementation AutocompleteTableViewController

- (void)setPlaceArray:(NSMutableArray *)placeArray
{
    _placeArray = placeArray;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _placeArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"aCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    
    PlaceModel *model = _placeArray[indexPath.row];
    
    cell.textLabel.text = model.placeName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(selectedTableRowWithModel:)]) {
        [self.delegate selectedTableRowWithModel:_placeArray[indexPath.row]];
    }
}


@end



#define TEXT_FIELD_WIDTH 280.0
#define TEXT_FIELD_HEIGHT 30.0

#define BUTTON_WIDTH 220.0
#define BUTTON_HEIGHT 40.0f

static NSDateFormatter *dateFormatter = nil;

NSString *EHPlaceholderMessageForEnquiryFormType(EHFormTextFieldType type)
{
    switch (type) {
        case kEHRequirementNameField: return @"Requirement name"; // mandatory             category = 1;
        case kEHCapacityField: return @"Capacity"; // mandatory
       // case kEHMakeField: return @"Make";
        case kEHBrandField: return @"Brand";
        case kEHAgeOfEquipmentField: return @"Year of manufacture";
        case kEHProjectLocationField:return @"Project location"; // mandatory
        case kEHNumberOfEquipmentRequired:return @"Number of equipments required";
        case kEHStartDate: return @"Start date";
        case kEHEndDate: return @"End date";
    }
}
NSString *EHErrorMessageForEmptyFieldForEnquiryFormType(EHFormTextFieldType type)
{
    switch (type) {
        case kEHRequirementNameField: return @"Enter requirement name";
        case kEHCapacityField: return @"Enter equipment capacity";
        case kEHBrandField: return @"Enter brand of equipment";
        case kEHAgeOfEquipmentField: return @"Enter equipment age";
        case kEHProjectLocationField:return @"Enter project location";
        case kEHNumberOfEquipmentRequired:return @"Enter number of equipment required";
        case kEHStartDate: return @"Enter start date";
        case kEHEndDate: return @"Enter end date";
    }
}

@interface RequirementFormTextField : UITextField

@property (nonatomic, strong) CALayer *underlineLayer;

@end

@implementation RequirementFormTextField
@end

void underLineForRequirementTextField(RequirementFormTextField *textField)
{
    CALayer *layer = [CALayer layer];
    CGFloat borderWidth = 2;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderWidth = borderWidth;
    textField.underlineLayer = layer;
    [textField.layer addSublayer:textField.underlineLayer];
    textField.layer.masksToBounds = YES;
}

@interface EHEnquiryFormViewController ()<UITextFieldDelegate,AutocompleteTableViewControllerDelegate,EHListViewControllerDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *formScrollView;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) RMDateSelectionViewController *dateSelectionController;
@property (nonatomic, strong) EHHTTPClient *httpClient;
@property (nonatomic, strong)  FPPopoverKeyboardResponsiveController *popover;
@property (nonatomic, strong) AutocompleteTableViewController *tableController;
@property (nonatomic, strong) ListModel *capacityModel;
@property (nonatomic, strong) ListModel *brandModel;

@end

@implementation EHEnquiryFormViewController
{
    RequirementFormTextField *formTextField[8];
}

+ (void)initialize
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.title = @"Enquiry form";
    self.view.backgroundColor = [UIColor whiteColor];

    _formScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_formScrollView];
    
    
    for (int i = 0; i<8; i++) {
        formTextField[i] = [self addFormTextFieldForIndex:i];
        [_formScrollView addSubview:formTextField[i]];
        
    }
    
    _registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_registerButton addTarget:self action:@selector(registerButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton setTitle:@"POST" forState:UIControlStateNormal];
    [_formScrollView addSubview:_registerButton];
    
    RMActionControllerStyle style = RMActionControllerStyleBlack;
    RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController *controller) {
        NSLog(@"Successfully selected date: %@", ((UIDatePicker *)controller.contentView).date);
        
        if (controller.contentView.tag == kEHStartDate) {
            formTextField[6].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
        else
        {
            formTextField[7].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
    }];
    
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController *controller) {
        NSLog(@"Date selection was canceled");
    }];
    
    _dateSelectionController = [RMDateSelectionViewController actionControllerWithStyle:style];
    _dateSelectionController.title = @"";
    _dateSelectionController.message = @"Please choose a date and press 'Select' or 'Cancel'.";
    
    [_dateSelectionController addAction:selectAction];
    [_dateSelectionController addAction:cancelAction];
    
    
    RMAction *in30MinAction = [RMAction actionWithTitle:@"30 Min" style:RMActionStyleAdditional andHandler:^(RMActionController *controller) {
        ((UIDatePicker *)controller.contentView).date = [NSDate dateWithTimeIntervalSinceNow:30*60];
        NSLog(@"30 Min button tapped");
        
        if (controller.contentView.tag == kEHStartDate) {
            formTextField[6].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
        else
        {
            formTextField[7].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
    }];
    in30MinAction.dismissesActionController = NO;
    
    RMAction *in45MinAction = [RMAction actionWithTitle:@"45 Min" style:RMActionStyleAdditional andHandler:^(RMActionController *controller) {
        ((UIDatePicker *)controller.contentView).date = [NSDate dateWithTimeIntervalSinceNow:45*60];
        NSLog(@"45 Min button tapped");
        if (controller.contentView.tag == kEHStartDate) {
            formTextField[6].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
        else
        {
            formTextField[7].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
    }];
    in45MinAction.dismissesActionController = NO;
    
    RMAction *in60MinAction = [RMAction actionWithTitle:@"60 Min" style:RMActionStyleAdditional andHandler:^(RMActionController *controller) {
        ((UIDatePicker *)controller.contentView).date = [NSDate dateWithTimeIntervalSinceNow:60*60];
        NSLog(@"60 Min button tapped");
        if (controller.contentView.tag == kEHStartDate) {
            formTextField[6].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
        else
        {
            formTextField[7].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
    }];
    in60MinAction.dismissesActionController = NO;
    
    RMGroupedAction *groupedAction = [RMGroupedAction actionWithStyle:RMActionStyleAdditional andActions:@[ in30MinAction, in45MinAction, in60MinAction]];
    
    [_dateSelectionController addAction:groupedAction];
    
    RMAction *nowAction = [RMAction actionWithTitle:@"Now" style:RMActionStyleAdditional andHandler:^(RMActionController *controller) {
        ((UIDatePicker *)controller.contentView).date = [NSDate date];
        NSLog(@"Now button tapped");
        if (controller.contentView.tag == kEHStartDate) {
            formTextField[6].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
        else
        {
            formTextField[7].text = [dateFormatter stringFromDate:((UIDatePicker *)controller.contentView).date];
        }
    }];
    
    nowAction.dismissesActionController = NO;
    
    [_dateSelectionController addAction:nowAction];
    
    //You can enable or disable blur, bouncing and motion effects
    _dateSelectionController.disableBouncingEffects = NO;
    _dateSelectionController.disableMotionEffects = NO;
    _dateSelectionController.disableBlurEffects = YES;
    
    //You can access the actual UIDatePicker via the datePicker property
    _dateSelectionController.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _dateSelectionController.datePicker.minuteInterval = 5;
    _dateSelectionController.datePicker.date = [NSDate date];//[NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
//    kEHRequirementNameField = 0,
//    kEHCapacityField,
//    kEHMakeField,
//    kEHModelField,
//    kEHAgeOfEquipmentField,
//    kEHProjectLocationField,
//    kEHStartDate,
//    kEHEndDate
    
    if (_entryType == kNewFormType) {
     //
    }
    else
    {
        formTextField[kEHRequirementNameField].text = _equipment.requirementName;
        //formTextField[kEHCapacityField].text = _equipment.equipmentCapacity;
        formTextField[kEHProjectLocationField].text = _selectedModel.placeName;
        formTextField[kEHStartDate].text = _equipment.equipmentStartDate;
        formTextField[kEHEndDate].text = _equipment.equipmentEndDate;
        formTextField[kEHAgeOfEquipmentField].text = _equipment.yearOfManufacture;
        formTextField[kEHNumberOfEquipmentRequired].text = [NSString stringWithFormat:@"%d",_equipment.numberOfEquipmentRequiredCount];
        // Get capacity 
        [self sendQueryForURL:[NSString stringWithFormat:@"%@/%@",RequirementURLForType(kEHClientTypeDeviceCapacity),_equipment.capacityID] forType:kEHClientTypeDeviceCapacity forClientMethod:@"GET"];
//        ListModel *capacityModel = [[ListModel alloc] init];
//        capacityModel.listName = _equipment.capacityID;
//        capacityModel.listID = _equipment.capacityID;
//        _capacityModel = capacityModel;
//        formTextField[kEHCapacityField].text = _capacityModel.listName;
        
        
        // Get brand
        [self sendQueryForURL:[NSString stringWithFormat:@"%@/%d",RequirementURLForType(kEHClientTypeDeviceBrand),_equipment.brandID] forType:kEHClientTypeDeviceBrand forClientMethod:@"GET"];
    }
    
    _tableController = [[AutocompleteTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _tableController.delegate = self;
    _popover = [[FPPopoverKeyboardResponsiveController alloc] initWithViewController:_tableController];
    _popover.tint = FPPopoverDefaultTint;
    _popover.arrowDirection = FPPopoverArrowDirectionLeft;
    _popover.contentSize = CGSizeMake(300, 250);
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.view.bounds;
    _formScrollView.frame  = frame;
    
    
    for (int i = 0; i<8; i++) {
        
        RequirementFormTextField *textField = formTextField[i];
        
        textField.frame = (CGRect){
            .origin.x = CGRectGetMidX(frame) - (TEXT_FIELD_WIDTH)/2,
            .origin.y = TEXT_FIELD_HEIGHT * i + 20 * i + 20,
            .size.width = TEXT_FIELD_WIDTH,
            .size.height = TEXT_FIELD_HEIGHT,
        };
        
        textField.underlineLayer.frame = CGRectMake(0, textField.bounds.size.height - 2, textField.bounds.size.width, 1);
    }

   _registerButton.frame = (CGRect){
        .origin.x = CGRectGetMidX(frame) - (BUTTON_WIDTH)/2,
        .origin.y = CGRectGetMaxY(formTextField[7].frame) + 20,
        .size.width = BUTTON_WIDTH,
        .size.height = BUTTON_HEIGHT,
    };
    
    _formScrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), CGRectGetMaxY(_registerButton.frame));
    
//    _searchTableView.frame = CGRectMake(CGRectGetMinX(formTextField[kEHProjectLocationField].frame), CGRectGetMaxY(formTextField[kEHProjectLocationField].frame), CGRectGetWidth(formTextField[kEHProjectLocationField].frame), 120);
}
- (IBAction)startDateButtonTouched:(id)sender
{
    
}
- (IBAction)endDateButtonTouched:(id)sender
{
    
}
- (NSString *)trimmedStringForInput:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (IBAction)registerButtonTouched:(id)sender
{
    
    if ([self trimmedStringForInput:formTextField[kEHRequirementNameField].text].length <= kNilOptions) {
        [self showInvalidErrorMessage:EHErrorMessageForEmptyFieldForEnquiryFormType(kEHRequirementNameField) title:@"Message!"];
        [formTextField[kEHRequirementNameField] becomeFirstResponder];
        return;
    }
    else if ([self trimmedStringForInput:formTextField[kEHNumberOfEquipmentRequired].text].length <= kNilOptions)
    {
        [self showInvalidErrorMessage:EHErrorMessageForEmptyFieldForEnquiryFormType(kEHNumberOfEquipmentRequired) title:@"Message!"];
        [formTextField[kEHCapacityField] becomeFirstResponder];
        return;
    }
    else if ([self trimmedStringForInput:formTextField[kEHProjectLocationField].text].length <= kNilOptions)
    {
        [self showInvalidErrorMessage:EHErrorMessageForEmptyFieldForEnquiryFormType(kEHProjectLocationField) title:@"Message!"];
        [formTextField[kEHProjectLocationField] becomeFirstResponder];
        return;
    }
    else if ([self trimmedStringForInput:formTextField[kEHStartDate].text].length <= kNilOptions)
    {
        [self showInvalidErrorMessage:EHErrorMessageForEmptyFieldForEnquiryFormType(kEHStartDate) title:@"Message!"];
        [formTextField[kEHStartDate] becomeFirstResponder];
        return;
    }
    else if ([self trimmedStringForInput:formTextField[kEHEndDate].text].length <= kNilOptions)
    {
        [self showInvalidErrorMessage:EHErrorMessageForEmptyFieldForEnquiryFormType(kEHEndDate) title:@"Message!"];
        [formTextField[kEHEndDate] becomeFirstResponder];
        return;
    }
    else
    {
        NSString *startDateString = formTextField[kEHStartDate].text;
        NSString *endDateString = formTextField[kEHEndDate].text;
        NSDate *startDate = [dateFormatter dateFromString:startDateString];
        NSDate *endDate = [dateFormatter dateFromString:endDateString];
        
        switch ([startDate compare:endDate]) {
            case NSOrderedSame:
            {
                [self showInvalidErrorMessage:@"Start date & end date should not be same" title:@"Message!"];
                return;
            }
                break;
            case NSOrderedDescending:
            {
                [self showInvalidErrorMessage:@"Start date should not be greater than end date" title:@"Message!"];
                return;
            }
                
            default:
                break;
        }
    }
    
    if (self.selectedModel && [formTextField[kEHProjectLocationField].text isEqualToString:self.selectedModel.placeName]) {
        
        [self sendQueryForGoogleAPI:[NSString stringWithFormat:RequirementURLForType(kHTTPClientTypeGetProjectLocationCoordinate),self.selectedModel.placeID] forType:kHTTPClientTypeGetProjectLocationCoordinate method:@"GET"];
        return;
    }
    else
    {
        [self showInvalidErrorMessage:@"Please select the project location from the available location list" title:@"Message!"];
        return;
    }
}

- (void)sendQueryForURL:(NSString *)url forType:(int)type forClientMethod:(NSString *)method
{
    weakify(self);
    
    _httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        
        /*
         http://easyhire-api.connect2projects.com/requirements"
         
         name - Requirement name - textfiled value
         user_id
         category_id
         start_date
         end_date
         capacity
         location - google location
         status - default 0,
         
         
         equipment.equipmentId = [dictionary[@"id"] integerValue];
         equipment.equipmentImageURL = [NSURL URLWithString:dictionary[@"image"]];
         equipment.equipmentName = dictionary[@"name"];
         equipment.equipmentParentId = [dictionary[@"parentId"] integerValue];
         equipment.userID =  [dictionary[@"user"][@"id"] integerValue];
         equipment.categoryID =  [dictionary[@"category"] integerValue];
         
         */
        
        strongify(self);

//        NSDictionary *dict = @{
//                               @"id" : @(self.equipment.equipmentId),/* equipmentId*/
//                               @"name" : self->formTextField[kEHRequirementNameField].text,
//                               @"user_id" : @([[NSUserDefaults standardUserDefaults] userid]),
//                               @"category_id"   : [NSNumber numberWithInt:self.equipment.categoryID],
//                               @"start_date" : self->formTextField[6].text,
//                               @"end_date" : self->formTextField[7].text,
//                               @"capacity"  : self->formTextField[kEHCapacityField].text,
//                               @"location"  : self->formTextField[kEHProjectLocationField].text,
//                               @"lat"     : @(self.selectedModel.placeLocationCoordinate.latitude),
//                               @"lng"     : @(self.selectedModel.placeLocationCoordinate.longitude),
//                               @"status"    : @"0",
//                               @"assignee_id" : @(self.equipment.userID)
//                               };
        
        
        /*
         
         age_of_equipment - not mandatory
         number_of_equipment - mandatory - Integer only
         
         
         
         */
        NSDictionary *dict = nil;
        if (type == 0) {
            dict = @{
                     @"id" : @(self.equipment.categoryID),/* equipmentId*/
                     @"name" : self->formTextField[kEHRequirementNameField].text,
                     @"user_id" : @([[NSUserDefaults standardUserDefaults] userid]),
                     @"category_id"   : [NSNumber numberWithInteger:self.equipment.equipmentId],
                     @"start_date" : self->formTextField[6].text,
                     @"end_date" : self->formTextField[7].text,
                     @"capacity"  : _capacityModel.listID,//self->formTextField[kEHCapacityField].text,
                     @"brand"     : _brandModel.listID,
                     @"number_of_equipments" : self->formTextField[kEHNumberOfEquipmentRequired].text,
                     @"year_of_manufacture" : self->formTextField[kEHAgeOfEquipmentField].text,
                     @"location"  : self->formTextField[kEHProjectLocationField].text,
                     @"lat"     : @(self.selectedModel.placeLocationCoordinate.latitude),
                     @"lng"     : @(self.selectedModel.placeLocationCoordinate.longitude),
                     @"status"    : @"0",
                     @"assignee_id" : @(self.equipment.userID)
                     };
        }
        
        return dict;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if(self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:nil];
        }
        
        
    }completionBlock:^(NSData *data){
       
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            
            NSLog(@"Equipemnt %@",[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (type == 0) {
                if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                    
                    NSString *title = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"message"];
                    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:@"Add a new requirement?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] completionBlock:^(EHAlertPromptHelper *alert, NSUInteger index){
                        if (index == 0) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                        else{
                            for (int i = 0; i<8; i++) {
                                formTextField[i].text = @"";
                            }
                            _selectedModel = nil;
                        }
                    }];
                }
                else
                {
                    [self showInvalidErrorMessage:@"Something went wrong. Please try again." title:@"Message!"];
                }
            }
            else if (type == kEHClientTypeDeviceCapacity)
            {
                formTextField[kEHCapacityField].text = dict[@"capacity"];
                ListModel *capacityModel = [[ListModel alloc] init];
                capacityModel.listID = dict[@"capacity"];
                capacityModel.listName = dict[@"capacity"];
                
                _capacityModel = capacityModel;
            }
            else
            {
                formTextField[kEHBrandField].text = dict[@"name"];
                ListModel *brandModel = [[ListModel alloc] init];
                brandModel.listID = dict[@"id"];
                brandModel.listName = dict[@"name"];
                _brandModel = brandModel;
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
- (RequirementFormTextField *)addFormTextFieldForIndex:(NSUInteger)index
{
    RequirementFormTextField *textField = [[RequirementFormTextField alloc] initWithFrame:CGRectZero];
    textField.tag = index;
    textField.font = [UIFont systemFontOfSize:15];
    textField.borderStyle = UITextBorderStyleNone;
   // textField.backgroundColor = [UIColor lightGrayColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.returnKeyType = UIReturnKeyNext;
    textField.delegate = self;
    textField.placeholder = EHPlaceholderMessageForEnquiryFormType(index);
    textField.rightViewMode = UITextFieldViewModeAlways;
    textField.rightView = rightViewForFormType(index,self);
    textField.keyboardType = keyboardTypeForFormType(index);
    underLineForRequirementTextField(textField);
    textField.autocapitalizationType = capitalizationType(index);
    return textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == formTextField[kEHProjectLocationField]) {
        
        NSString *resultString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (resultString.length %2 == 0) {
            
            //[self placeAutocomplete:resultString];
            [self sendQueryForGoogleAPI:[NSString stringWithFormat:RequirementURLForType(kHTTPClientTypeGetProjectLocationAddress),resultString] forType:kHTTPClientTypeGetProjectLocationAddress method:@"GET"];
        }
        
        
    }
    else if(textField == formTextField[kEHNumberOfEquipmentRequired])
    {
        NSString *resultString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return resultString.length <= 2;
    }
    return YES;
}

- (void)sendQueryForGoogleAPI:(NSString *)url forType:(NSUInteger)type method:(NSString *)method {
    
    if (_httpClient != nil) {
        [_httpClient stop];
        _httpClient = nil;
    }
    
    weakify(self);
    
    _httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:@"GET" paramBlock:^(void){
        
        NSDictionary *dictionary = nil;
        return dictionary;
        
    }failureBlock:^(NSError *error){
        
      //  NSLog(@"%@",[error localizedDescription]);
        
        if (type == kHTTPClientTypeGetProjectLocationAddress) {
        
            [self.popover dismissPopoverAnimated:YES];
        }
        
        if (type == kHTTPClientTypeGetProjectLocationCoordinate) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
        }

        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (type == kHTTPClientTypeGetProjectLocationCoordinate) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
        }
        
        if (![[EHValidateWrapper sharedInstance]isNullDictionary:result]) {
            
            
            if (type == kHTTPClientTypeGetProjectLocationAddress) {
                
                self.selectedModel = nil;
                
                if ([[result[@"status"] lowercaseString] isEqualToString:@"ok"]) {
                    
                    NSArray *array = result[@"predictions"];
                    if (array.count > kNilOptions) {
                        
                        if (!self.popover.view.window) {
                            [self.popover presentPopoverFromView:formTextField[kEHProjectLocationField]];
                        }
                        
                        NSMutableArray *placeData = [[NSMutableArray alloc] initWithCapacity:0];
                        
                        for (NSDictionary *dict in array) {
                            
                            PlaceModel *model = [[PlaceModel alloc] init];
                            model.placeName = dict[@"description"];
                            model.placeID = dict[@"place_id"];
                            [placeData addObject:model];
                        }
                        _tableController.placeArray = placeData;
                    }
                    else
                    {
                        [self.popover dismissPopoverAnimated:YES];
                    }
                    
                    
                }
                else
                {
                    NSLog(@"%@",result[@"status"]);
                    [self.popover dismissPopoverAnimated:YES];
                }
            }
            else
            {
                // Got Coordinate. Crenate new requiremnt request
                
                NSDictionary *geometry = result[@"result"][@"geometry"];
                NSDictionary *location = geometry[@"location"];
                CGFloat latitude = [location[@"lat"] floatValue];
                CGFloat longitude = [location[@"lng"] floatValue];
                self.selectedModel.placeLocationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
                
                NSString *url = (_entryType == kNewFormType) ? REQUIREMENT_LIST_CREATE : [NSString stringWithFormat:REQUIREMENT_LIST_MODIFY,(unsigned long)_equipment.categoryID];//equipmentid
              //  NSLog(@"required id = %d",_equipment.equipmentId);
                
                NSString *method = @"POST";//(_entryType == kNewFormType) ? @"POST" : @"PUT";
                [self sendQueryForURL:url forType:0 forClientMethod:method];
            }
            
        }
        
    }];
    [_httpClient start];
    if (type == kHTTPClientTypeGetProjectLocationCoordinate) {
        [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
    }
}

- (void)selectedTableRowWithModel:(PlaceModel *)model
{
    self.selectedModel = model;
    formTextField[kEHProjectLocationField].text = model.placeName;
    [self.popover dismissPopoverAnimated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == formTextField[kEHStartDate] || textField == formTextField[kEHEndDate])
    {
        //Now just present the date selection controller using the standard iOS presentation method
        
        [self presentViewController:_dateSelectionController animated:YES completion:nil];
        _dateSelectionController.contentView.tag = (textField == formTextField[kEHStartDate]) ? kEHStartDate : kEHEndDate;
        return NO;
    }
    else
        return YES;
}
- (IBAction)buttonTouched:(id)sender
{
    if ([sender tag] == kEHCapacityField) {
        
        EHListViewController *listController = [[EHListViewController alloc] initWithListCode:kCapacity];
        listController.delegate = self;
        [self.navigationController pushViewController:listController animated:YES];
        
    }
    else
    {
        EHListViewController *listController = [[EHListViewController alloc] initWithListCode:kBrand];
        listController.delegate = self;
        [self.navigationController pushViewController:listController animated:YES];
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)selectedIndex:(int)listIndex forModel:(ListModel *)model
{
    if (listIndex == kCapacity) {
        _capacityModel = model;
        formTextField[kEHCapacityField].text = model.listName;
    }
    else
    {
        _brandModel = model;
        formTextField[kEHBrandField].text = model.listName;
    }
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
