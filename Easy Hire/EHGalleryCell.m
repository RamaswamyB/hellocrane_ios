//
//  EHGalleryCell.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHGalleryCell.h"
#import "EHEquipmentView.h"

@interface EHGalleryCell ()
@property (nonatomic, strong) EHEquipmentView *equipemntView;
@end

@implementation EHGalleryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _equipemntView = [[EHEquipmentView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_equipemntView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    _equipemntView.frame = self.bounds;
}

- (void)setEquipmentTitle:(NSString *)equipmentTitle
{
    _equipmentTitle = equipmentTitle;
    _equipemntView.title = equipmentTitle;
}
- (void)setEquipmentImageURL:(NSURL *)equipmentImageURL
{
    _equipmentImageURL = equipmentImageURL;
    _equipemntView.url = equipmentImageURL;
}

- (void)setCacheType:(EHCacheType)cacheType
{
    _cacheType = cacheType;
    _equipemntView.cacheType = cacheType;
}

@end
