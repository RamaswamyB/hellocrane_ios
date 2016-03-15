//
//  EHParentTableViewCell.h
//  Easy Hire
//
//  Created by Prasanna on 15/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHParentTableViewCell : UITableViewCell

+ (NSString *)tableViewCellViewIdentifier;
+ (UIView *)tableCellViewForTableView:(UITableView *)tableView;

- (instancetype)initWithIdentifier:(NSString *)identifier;

@end
