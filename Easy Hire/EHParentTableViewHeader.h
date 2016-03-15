//
//  EHTableViewHeader.h
//  Easy Hire
//
//  Created by Prasanna on 15/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHParentTableViewHeader : UIView

+ (NSString *)headerCellViewIdentifier;
+ (UIView *)headerCellViewForTableView:(UITableView *)tableView;

@end
