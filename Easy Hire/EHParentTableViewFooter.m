//
//  EHParentTableViewFooter.m
//  Easy Hire
//
//  Created by Prasanna on 21/12/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHParentTableViewFooter.h"

@implementation EHParentTableViewFooter

+ (NSString *)footerCellViewIdentifier
{
    return NSStringFromClass([self class]);
}
+ (UIView *)footerCellViewForTableView:(UITableView *)tableView
{
    static NSString *viewIdentifier = nil;
    viewIdentifier = [self footerCellViewIdentifier];
    UIView *reusedView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:viewIdentifier];
    if (reusedView == nil) {
        reusedView = [[self alloc] initWithFrame:(CGRect){0,0,CGRectGetWidth([[UIScreen mainScreen]bounds]),35.0f}];
        reusedView.opaque = YES;
        reusedView.backgroundColor = [UIColor whiteColor];
        
    }
    return reusedView;
}

@end
