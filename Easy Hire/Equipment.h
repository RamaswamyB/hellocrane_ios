//
//  Equipment.h
//  Easy Hire
//
//  Created by Prasanna on 10/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Equipment : NSObject

@property (assign) NSInteger equipmentId;
@property (nonatomic, copy) NSURL *equipmentImageURL;
@property (nonatomic, copy) NSString *equipmentName;
@property (assign) NSUInteger equipmentParentId;
@property (assign) NSUInteger equipmentStatus;

@property (nonatomic, assign) NSUInteger userID;
@property (nonatomic, assign) NSUInteger categoryID;

@property (nonatomic, copy) NSString *equipmentCapacity;
@property (nonatomic, copy) NSString *equipmentStartDate;
@property (nonatomic, copy) NSString *equipmentEndDate;
@property (nonatomic, copy) NSString *requirementName;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, copy) NSString *yearOfManufacture;
@property (assign) int numberOfEquipmentRequiredCount;
@property (assign) int brandID;
@property (nonatomic,copy) NSString *capacityID;

@end
