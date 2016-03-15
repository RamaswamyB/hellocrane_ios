//
//  EHProgressLoader.m
//  Easy Hire
//
//  Created by Prasanna on 07/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHProgressLoader.h"

static MBProgressHUD *progressIndicator = nil;
static EHProgressLoader *progressLoader = nil;

@interface EHProgressLoader ()
@end

@implementation EHProgressLoader

+ (EHProgressLoader *)sharedLoaderInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        progressLoader = [[EHProgressLoader alloc] init];
    });
    return progressLoader;
}

- (instancetype)init
{
    if (self = [super init]) {
        progressIndicator = [[MBProgressHUD alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
        progressIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        progressIndicator.dimBackground = NO;
      
    }
    return self;
}

- (void)showLoaderIn:(id)controller
{
    [controller addSubview:progressIndicator];
    [progressIndicator show:NO];
}
- (void)hideLoader
{
    [progressIndicator hide:NO];
}

@end
