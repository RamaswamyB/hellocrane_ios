//
//  UIApplication+EHNetworkIndicatorHandler.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "UIApplication+EHNetworkIndicatorHandler.h"

static NSUInteger kEHNetworkActivityCount;

@implementation UIApplication (EHNetworkIndicatorHandler)

+ (void)load
{
    kEHNetworkActivityCount = kNilOptions;
}

- (void)refreshNetworkActivityIndicator
{
    if (![NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^(void){
            typeof(weakSelf) strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf refreshNetworkActivityIndicator];
            }
            
        });
        
    }
    self.networkActivityIndicatorVisible = self.networkActivityCount > 0;
}

- (NSInteger)networkActivityCount
{
    @synchronized(self)
    {
        return kEHNetworkActivityCount;
    }
}

- (void)pushNetworkIndicator
{
    @synchronized(self)
    {
        kEHNetworkActivityCount += 1;
    }
    [self refreshNetworkActivityIndicator];
}
- (void)popNetworkIndicator
{
    @synchronized(self)
    {
        kEHNetworkActivityCount -= 1;
    }
    [self refreshNetworkActivityIndicator];
}
- (void)resetNetworkIndicator
{
    @synchronized(self)
    {
        kEHNetworkActivityCount = kNilOptions;
    }
    [self refreshNetworkActivityIndicator];
    NSLog(@"Unbalanced network request : %s",__PRETTY_FUNCTION__);
}

@end
