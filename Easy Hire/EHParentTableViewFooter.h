//
//  EHParentTableViewFooter.h
//  Easy Hire
//
//  Created by Prasanna on 21/12/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHParentTableViewFooter : UIView

+ (NSString *)footerCellViewIdentifier;
+ (UIView *)footerCellViewForTableView:(UITableView *)tableView;

@end
