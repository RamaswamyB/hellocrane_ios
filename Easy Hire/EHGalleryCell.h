//
//  EHGalleryCell.h
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHCache.h"

@interface EHGalleryCell : UICollectionViewCell

@property (nonatomic, copy) NSString *equipmentTitle;
@property (nonatomic, copy) NSURL *equipmentImageURL;
@property (nonatomic, assign) EHCacheType cacheType;

@end
