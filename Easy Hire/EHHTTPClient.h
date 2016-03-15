//
//  EHHTTPClient.h
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * This class acts as a network request handler.
 * Downloads data and do parse if required.
*/


typedef NS_ENUM(NSUInteger, HTTPClientType){
    
    kHTTPClientTypeRegistration = 0,
    kHTTPClientTypeLogin,
    kHTTPClientTypeReLogin,
    kHTTPClientTypeGetOTP,
    kHTTPClientTypeSendOTP,
    kHTTPClientTypeListEquipemntOwned,
    kHTTPClientTypeMapEquipemntOwned,
    kHTTPClientTypeRequirementList,
    kHTTPClientTypeRequirementDelete,
    kHTTPClientTypeGetLocation,
    kHTTPClientTypeGetNotification,
    kHTTPClientTypeAcceptNotification,
    kHTTPClientTypeRejectNotification,
    kHTTPClientTypeGetProjectLocationAddress,
    kHTTPClientTypeGetProjectLocationCoordinate,
    kHTTPClientTypeGetService,
    kHTTPClientTypeCallTollFree,
    kHTTPClientTypeCallMeBack,
    kEHClientTypeDeviceCapacity,
    kEHClientTypeDeviceBrand,
};

@class EHHTTPClient;

typedef void (^EHHttpClientDownloadCompletionBlock)(NSData *data);
typedef void (^EHHttpClientDownloadFailureBlock)(NSError *error);
typedef NSDictionary *(^EHHttpClientParameterBlock)(void);

@interface EHHTTPClient : NSObject

+ (instancetype)connectionWithImageURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result));
+ (instancetype)connectionWithDataURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result));

@property (nonatomic, assign) HTTPClientType tag;

- (void)start;
- (void)stop;
+ (void)stopAllOperation;

@end
