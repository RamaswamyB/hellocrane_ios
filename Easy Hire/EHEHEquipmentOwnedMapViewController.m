//
//  EHEHEquipmentOwnedMapViewController.m
//  Easy Hire
//
//  Created by Prasanna on 21/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHEHEquipmentOwnedMapViewController.h"
#import "SWRevealViewController.h"
#import "JPSThumbnailAnnotation.h"
#import "EHHTTPClient.h"

NSString *EHGetMapDetailURLForType(HTTPClientType type)
{
    switch (type) {
        case kHTTPClientTypeMapEquipemntOwned:return EQUIPMENT_OWNED_URL;
        case kHTTPClientTypeGetLocation:return VEHICLE_GPS_LOCATION;
        default:return nil;
        }
}


@interface EHEHEquipmentOwnedMapViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) EHHTTPClient *httpClient;

@end

@implementation EHEHEquipmentOwnedMapViewController
{
    NSMutableArray *vehicleArray;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tabBarItem.title = @"Map View";
    self.view.backgroundColor = [UIColor whiteColor];
    
    SWRevealViewController *revealController = [self revealViewController];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    
    self.tabBarController.navigationItem.leftBarButtonItem = revealButtonItem;
    
    
    if ([[UIImage imageNamed:@"mapview.png"] respondsToSelector:@selector(imageWithRenderingMode:)]) {
        self.tabBarItem.image =  [[UIImage imageNamed:@"mapview.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        // iOS 6 fallback: insert code to convert imaged if needed
        self.tabBarItem.image = [UIImage imageNamed:@"mapview.png"];
    }
    
    
    
    vehicleArray = [[NSMutableArray alloc] initWithCapacity:kNilOptions];
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.mapType = MKMapTypeHybrid;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"Map View";
    
    [vehicleArray removeAllObjects];
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getVehicleGPSLocation)];
    self.tabBarController.navigationItem.rightBarButtonItem =rightButton;
    self.tabBarController.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    [self sendQueryForURL:[NSString stringWithFormat:EHGetMapDetailURLForType(kHTTPClientTypeMapEquipemntOwned),[[NSUserDefaults standardUserDefaults]userid]] forClientType:kHTTPClientTypeMapEquipemntOwned forClientMethod:@"GET"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect frame = self.view.bounds;
    _mapView.frame = frame;

}

- (void)sendQueryForURL:(NSString *)url forClientType:(HTTPClientType)type forClientMethod:(NSString *)method
{
    weakify(self);
    
//    if (_httpClient != nil) {
//        [_httpClient stop];
//        _httpClient = nil;
//    }
    
    EHHTTPClient *httpClient = [EHHTTPClient connectionWithDataURL:[NSURL URLWithString:url] method:method paramBlock:^(void){
        //UserId=landmaster&Password=welcome&vehicleno=KA-51-M-8454
        // strongify(self);
        NSDictionary *equipmentDict = nil;
        return equipmentDict;
        
    }failureBlock:^(NSError *error){
        
        strongify(self);
        if (self) {
            [[EHProgressLoader sharedLoaderInstance] hideLoader];
            [self showInvalidErrorMessage:[error localizedDescription] title:nil];
        }
        
        
    }completionBlock:^(NSData *data){
        
        strongify(self);
        if (self) {
            if(type == kHTTPClientTypeMapEquipemntOwned)
            {
                [[EHProgressLoader sharedLoaderInstance] hideLoader];
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                    
                    NSLog(@"Dict = %@",dict);
                    
                    NSArray *array = dict[@"data"];
                    for (int i = 0; i < array.count; i++) {
                        
                        NSDictionary *vehicleDictionary = array[i];
                        
                        JPSThumbnail *model = [[JPSThumbnail alloc] init];
                        model.vehicleNumber = vehicleDictionary[@"vehicle_number"];//[vehicleDictionary[@"vehicle_number"] stringByReplacingOccurrencesOfString:@" " withString:@"-"];//vehicleDictionary[@"vehicle_number"];
                        model.vehicleCapacity = vehicleDictionary[@"capacity"];
                        model.vehicleImageURL = @"http://easyhire-api.connect2projects.com/images/app/logo.png";//vehicleDictionary[@"image"];
                        model.title = [NSString stringWithFormat:@"%@ %@",vehicleDictionary[@"name"],model.vehicleNumber];
                        [vehicleArray addObject:model];
                    }
                    
                    [self getVehicleGPSLocation];
                    self.tabBarController.navigationItem.rightBarButtonItem.enabled = YES;
                }
                else
                {
                    // Error
                }
                
            }
            else{
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if (![[EHValidateWrapper sharedInstance]isNullDictionary:dict]) {
                    
                    NSString *status = [dict[@"status"] lowercaseString];
                    if ([status isEqualToString:@"failure"]) {
                        
                        [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"Unable to get equipment location.Please contact customer care at 18001038392" cancelButtonTitle:@"Ok" otherButtonTitles:nil completionBlock:nil];
                        
                        return;
                    }
                    
                    
                    NSDictionary *data = [dict[@"data"] firstObject];
                    NSString* filter = @"%K CONTAINS[cd] %@";
                    NSString *vehicleNumber = data[@"VehicleNo"];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:filter,@"vehicleNumber",vehicleNumber];
                    JPSThumbnail *model = [[vehicleArray filteredArrayUsingPredicate:predicate] firstObject];
                    if (model != nil) {
                        
                        NSUInteger index = [vehicleArray indexOfObject:model];
                        model.subtitle =  data[@"Location"];
                        model.coordinate = CLLocationCoordinate2DMake([data[@"Lat"] floatValue],[data[@"Lon"] floatValue]);
                        [vehicleArray replaceObjectAtIndex:index withObject:model];
                        
                        __weak typeof(model) weakModel = model;
                        
                        model.disclosureBlock = ^{
                            
                            typeof(weakModel) strongModel = weakModel;
                            
                            [EHAlertPromptHelper showActionSheetIn:self withTitle:@"Info!" message:[NSString stringWithFormat:@"%@\n Capacity - %@\n%@",strongModel.title, strongModel.vehicleCapacity,strongModel.subtitle] cancelButtonTitle:@"I Know" destructiveButtonTitle:nil otherButtonTitles:nil completionBlock:nil];
                            
                        };
                        
                        NSArray *array = _mapView.annotations;
                        for (JPSThumbnailAnnotation *annotation in array) {
                            
                            if ([annotation.thumbnail.vehicleNumber isEqualToString:model.vehicleNumber]) {
                                [_mapView removeAnnotation:annotation];
                                break;
                            }
                        }
                        
                        [_mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:model]];
                        [_mapView showAnnotations:[_mapView annotations] animated:YES];
                    }
                }
                else{
                    // Error
                    
                    [EHAlertPromptHelper showAlertViewIn:self withTitle:@"Message!" message:@"Unable to get equipment location.Please contact customer care at 18001038392" cancelButtonTitle:@"Ok" otherButtonTitles:nil completionBlock:nil];
                    
                }
            }

        }
        
    }];
    [httpClient start];
    
    if(type == kHTTPClientTypeMapEquipemntOwned)
        [[EHProgressLoader sharedLoaderInstance] showLoaderIn:self.view];
}

- (void)getVehicleGPSLocation
{
   for (JPSThumbnail *model in vehicleArray) {
        [self sendQueryForURL:[NSString stringWithFormat:EHGetMapDetailURLForType(kHTTPClientTypeGetLocation),model.vehicleNumber]forClientType:kHTTPClientTypeGetLocation forClientMethod:@"GET"];
    }
}

- (void)showInvalidErrorMessage:(NSString *)message title:(NSString *)title
{
    [EHAlertPromptHelper showAlertViewIn:self withTitle:title message:message cancelButtonTitle:@"I Know" otherButtonTitles:nil completionBlock:nil];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}
@end
