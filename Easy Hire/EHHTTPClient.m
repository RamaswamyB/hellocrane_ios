//
//  EHHTTPClient.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHHTTPClient.h"
#import "UIApplication+EHNetworkIndicatorHandler.h"

typedef NS_ENUM(NSUInteger, EHClientType) {
    kClientTypeJson = 0,
    kClientTypeImage,

};

@interface EHHTTPClient ()

@property (nonatomic, copy) NSURL *requestURL;

@property (nonatomic, copy) EHHttpClientDownloadCompletionBlock downloadCompletionBlock;
@property (nonatomic, copy) EHHttpClientDownloadFailureBlock downloadFailureBlock;
@property (nonatomic, copy) EHHttpClientParameterBlock paramBlock;

@property (nonatomic, assign) EHClientType clientType;

@property (nonatomic, strong) NSURLSessionDataTask *downloadDataTask;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadImageTask;
@property (nonatomic, copy) NSString *method;

- (instancetype)initWithImageDownloadURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result));
- (instancetype)initWithDataDownloadURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result));

@end

static NSURLSession *sEHDownloadTaskSession = nil;

@implementation EHHTTPClient

+ (void)initialize
{
    NSURLSessionConfiguration *sEHSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sEHSessionConfiguration.timeoutIntervalForRequest = 30.0f;
    sEHSessionConfiguration.timeoutIntervalForResource = 30.0f;
    sEHSessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/json"};
    sEHDownloadTaskSession = [NSURLSession sessionWithConfiguration:sEHSessionConfiguration];
}


+ (instancetype)connectionWithImageURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result));
{
    return [[self alloc] initWithImageDownloadURL:requestURL method:method paramBlock:param failureBlock:failureBlock completionBlock:completionBlock];
}
+ (instancetype)connectionWithDataURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result))
{
    return [[self alloc] initWithDataDownloadURL:requestURL method:method paramBlock:param failureBlock:failureBlock completionBlock:completionBlock];
}

- (instancetype)initWithImageDownloadURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result))
{
    if((self = [super init]))
    {
        _requestURL = requestURL;
        _downloadCompletionBlock = [completionBlock copy];
        _downloadFailureBlock = [failureBlock copy];
        _paramBlock = [param copy];
        _clientType = kClientTypeImage;
        _method = method;
        
    }
    return self;
}

- (instancetype)initWithDataDownloadURL:(NSURL *)requestURL method:(NSString *)method paramBlock:(EHHttpClientParameterBlock)param failureBlock:(EHHttpClientDownloadFailureBlock)failureBlock completionBlock:(EHHttpClientDownloadCompletionBlock)completionBlock __attribute__((warn_unused_result))
{
    if((self = [super init]))
    {
        _requestURL = requestURL;
        _downloadCompletionBlock = [completionBlock copy];
        _downloadFailureBlock = [failureBlock copy];
        _paramBlock = [param copy];
        _clientType = kClientTypeJson;
        _method = method;
        
    }
    return self;
}
- (void)start
{
   NSDictionary *param = _paramBlock();
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_requestURL];
    request.HTTPMethod = _method;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefault usermobile];
    NSString *password = [userDefault password];
  
    if (username && password) {
        
        NSString *token = [userDefault accessToken];
        if (token) {
            NSString *authValue = [NSString stringWithFormat:@"Bearer %@",token];
            [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        }
        else
        {
            [self getRevisedAccessToken];
            return;
        }
    }
   
    [[UIApplication sharedApplication] pushNetworkIndicator];
    
    if (param != nil) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        [request setHTTPBody:jsonData];
    }
    
    
    if (_clientType == kClientTypeJson) {
      
        _downloadDataTask = [sEHDownloadTaskSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            GET_ASYNC_MAIN_QUEUE({
                
                if (error != nil) {
                    [self connectionDidFailWithError:error];
                }
                else
                {
                    [self connectionDidFinishLoading:data];
                }
            });

        }];

        [_downloadDataTask resume];
    }
    else
    {
        _downloadImageTask = [sEHDownloadTaskSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error){
            
            GET_ASYNC_MAIN_QUEUE({
               
                if (error != nil) {
                    [self connectionDidFailWithError:error];
                }
                else
                {
                    [self connectionDidFinishLoading:[NSData dataWithContentsOfURL:location]];
                    [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
                }
            });
          
        }];

        [_downloadImageTask resume];
    }
    
}

- (void)stop
{
    if (_clientType == kClientTypeJson) {
        if (_downloadDataTask && _downloadDataTask.state == NSURLSessionTaskStateRunning) {
            [_downloadDataTask cancel];
            
        }
    }
    else
    {
        if (_downloadImageTask && _downloadImageTask.state == NSURLSessionTaskStateRunning) {
            [_downloadImageTask cancel];

        }
    }
    
    [self cancelAndInvalidate];
    
    
}
- (void)cancelAndInvalidate
{
    _downloadDataTask = nil;
    _downloadImageTask = nil;
    _requestURL = nil;
    _downloadCompletionBlock = nil;
    _downloadFailureBlock = nil;
    _paramBlock = nil;
    
    [[UIApplication sharedApplication] popNetworkIndicator];
}

- (void)connectionDidFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] popNetworkIndicator];
    
    if (error.code == 401) {
    
        [self getRevisedAccessToken];
        return;
    }
  
    if (_downloadFailureBlock) {
        _downloadFailureBlock(error);
        _downloadFailureBlock = nil;
    }
}
- (void)connectionDidFinishLoading:(NSData *)data
{
   // [sProgressLoader hide:NO];
    [[UIApplication sharedApplication] popNetworkIndicator];
   
    //if (data.length > kNilOptions) {
        if (_downloadCompletionBlock) {
            _downloadCompletionBlock(data);
            _downloadCompletionBlock = nil;
            
        }
//    }
//    else
//    {
//        NSError *error = [[NSError alloc] initWithDomain:@"Easy Hire" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Unknown error occured"}];
//        [self connectionDidFailWithError:error];
//    }
    
}

- (NSString *)getAccessToken
{
    return [[NSUserDefaults standardUserDefaults] accessToken];
}
- (void)setAccessToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setAccessToken:token];
}
- (void)getRevisedAccessToken
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *param = @{
                            
                            @"mobile_number": [userDefault usermobile],
                            @"password"     : [userDefault password]
                            };

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LOGIN_URL]];
    request.HTTPMethod = @"POST";
    
    if (param != nil) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        [request setHTTPBody:jsonData];
    }
    
    _downloadDataTask = [sEHDownloadTaskSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        GET_ASYNC_MAIN_QUEUE({
            
            if (error != nil) {
                [self connectionDidFailWithError:error];
                
                // Remove all user detials *IF ANY*
                [userDefault remove];
            }
            else
            {
                NSDictionary *tokenDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *token = ObjectOrNullInstance(tokenDict[@"token"]);
                
                if (token.length > kNilOptions) {
                    
                    [[UIApplication sharedApplication] popNetworkIndicator];
                    
                    [userDefault setAccessToken:token];
                    [userDefault save];
                    
                    [self start];
                }
                else
                {
                    NSError *error = [[NSError alloc] initWithDomain:@"Easy Hire" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Incorrect mobile number/password"}];
                    [self connectionDidFailWithError:error];
                }
            }
        });
    }];
    
    [[UIApplication sharedApplication] pushNetworkIndicator];
    [_downloadDataTask resume];
    
    
}

+ (void)stopAllOperation
{
    [sEHDownloadTaskSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        for (NSURLSessionDataTask *dataTask in dataTasks) {
            if (dataTask && dataTask.state == NSURLSessionTaskStateRunning) {
                [dataTask cancel];
                [[UIApplication sharedApplication] popNetworkIndicator];
            }
        }
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            if (downloadTask && downloadTask.state == NSURLSessionTaskStateRunning) {
                [downloadTask cancel];
                [[UIApplication sharedApplication] popNetworkIndicator];
            }
        }
        
    }];
     
}

@end
