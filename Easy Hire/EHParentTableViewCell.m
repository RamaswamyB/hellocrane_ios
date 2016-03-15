//
//  EHParentTableViewCell.m
//  Easy Hire
//
//  Created by Prasanna on 15/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHParentTableViewCell.h"

@implementation EHParentTableViewCell

+ (NSString *)tableViewCellViewIdentifier
{
    return NSStringFromClass([self class]);
}
+ (UIView *)tableCellViewForTableView:(UITableView *)tableView
{
    static NSString *cellID = nil;
    cellID = [self tableViewCellViewIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[self alloc] initWithIdentifier:cellID];
        
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return cell;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
}

@end
