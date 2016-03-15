//
//  EHEquipmentView.h
//  Easy Hire
//
//  Created by Prasanna on 10/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHCache.h"

@interface EHEquipmentView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) EHCacheType cacheType;

@end
