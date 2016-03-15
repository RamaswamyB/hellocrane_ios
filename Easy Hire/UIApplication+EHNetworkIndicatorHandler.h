//
//  UIApplication+EHNetworkIndicatorHandler.h
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (EHNetworkIndicatorHandler)

@property (nonatomic, assign, readonly) NSInteger networkActivityCount;

- (void)pushNetworkIndicator;
- (void)popNetworkIndicator;
- (void)resetNetworkIndicator;

@end
