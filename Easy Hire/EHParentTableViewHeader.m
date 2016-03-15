//
//  EHTableViewHeader.m
//  Easy Hire
//
//  Created by Prasanna on 15/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHParentTableViewHeader.h"

@interface EHParentTableViewHeader ()

@end

@implementation EHParentTableViewHeader

+ (NSString *)headerCellViewIdentifier
{
    return NSStringFromClass([self class]);
}
+ (UIView *)headerCellViewForTableView:(UITableView *)tableView
{
    static NSString *viewIdentifier = nil;
    viewIdentifier = [self headerCellViewIdentifier];
    UIView *reusedView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:viewIdentifier];
    if (reusedView == nil) {
        reusedView = [[self alloc] initWithFrame:(CGRect){0,0,CGRectGetWidth([[UIScreen mainScreen]bounds]),44.0f}];
        reusedView.opaque = YES;
        reusedView.backgroundColor = [UIColor colorWithRed:35/255.0 green:138/255.0 blue:211/255.0 alpha:1];
        
    }
    return reusedView;
}

@end
