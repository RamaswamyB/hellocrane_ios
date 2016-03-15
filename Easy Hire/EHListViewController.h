//
//  EHListViewController.h
//  Easy Hire
//
//  Created by Prasanna on 24/02/16.
//  Copyright © 2016 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    kCapacity = 0,
    kBrand
};

@interface ListModel : NSObject

@property (nonatomic, copy) NSString *listID;
@property (nonatomic, copy) NSString *listName;

@end

@protocol EHListViewControllerDelegate <NSObject>

- (void)selectedIndex:(int)listIndex forModel:(ListModel *)model;

@end


@interface EHListViewController : UIViewController

@property (nonatomic, weak) id<EHListViewControllerDelegate> delegate;

- (instancetype)initWithListCode:(int)listCode;

@end
