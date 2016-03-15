//
//  EHContactUsViewController.h
//  Easy Hire
//
//  Created by Prasanna on 04/10/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Equipment.h"
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, EntryFormType){
    kNewFormType = 0,
    kEditFormType
};

typedef NS_ENUM(NSUInteger, EHFormTextFieldType) {
    kEHRequirementNameField = 0,
    kEHCapacityField,
   // kEHMakeField,
   // kEHModelField,
    kEHBrandField,
    kEHAgeOfEquipmentField,
    kEHProjectLocationField,
    kEHNumberOfEquipmentRequired,
    kEHStartDate,
    kEHEndDate
};

extern NSString *EHPlaceholderMessageForEnquiryFormType(EHFormTextFieldType type);
extern NSString *EHErrorMessageForEmptyFieldForEnquiryFormType(EHFormTextFieldType type);

@interface PlaceModel : NSObject

@property(nonatomic, copy) NSString *placeName;
@property (nonatomic, copy) NSString *placeID;
@property (assign) CLLocationCoordinate2D placeLocationCoordinate;

@end

@interface EHEnquiryFormViewController : UIViewController

@property (nonatomic, strong) Equipment *equipment;
@property (nonatomic, assign) EntryFormType entryType;
@property (nonatomic, strong) PlaceModel *selectedModel;

@end
