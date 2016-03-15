//
//  EHEquipmentView.m
//  Easy Hire
//
//  Created by Prasanna on 10/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHEquipmentView.h"
#import "EHHTTPClient.h"

@interface EHEquipmentView ()

@property (nonatomic, strong) UILabel *equipmentTitleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *equipmentActivityView;
@property (nonatomic, strong) UIImageView *equipmentImageView;

@property (nonatomic, strong) EHHTTPClient *equipmentHttpClient;

@end

@implementation EHEquipmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _equipmentTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _equipmentTitleLabel.backgroundColor = [UIColor clearColor];
        _equipmentTitleLabel.contentMode = UIViewContentModeScaleToFill;
        _equipmentTitleLabel.font = [UIFont systemFontOfSize:15];
        [_equipmentTitleLabel sizeToFit];
        _equipmentTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _equipmentTitleLabel.numberOfLines = 2;
        _equipmentTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_equipmentTitleLabel];
        
        _equipmentActivityView = [[UIActivityIndicatorView alloc] init];
        _equipmentActivityView.hidesWhenStopped = YES;
        _equipmentActivityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:_equipmentActivityView];
        
        _equipmentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _equipmentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_equipmentImageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    _equipmentActivityView.center = self.center;
    
    _equipmentImageView.frame = (CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width = CGRectGetWidth(self.bounds),
        .size.height = CGRectGetHeight(self.bounds) - 30,
    };
    
    _equipmentTitleLabel.frame = (CGRect){
        .origin.x = 0,
        .origin.y = CGRectGetMaxY(_equipmentImageView.bounds),
        .size.width = CGRectGetWidth(self.bounds),
        .size.height = 30
    };
    
}

- (void)setUrl:(NSURL *)imageURL
{
    _url = imageURL;
    
    if (_equipmentHttpClient) {
        [_equipmentHttpClient stop];
        _equipmentHttpClient = nil;
    }
    
    [self displayImage:nil];// Clear image
    
    UIImage *cachedImage = [[EHCache sharedCacheInstance]cachedImageForKey:imageURL forCacheType:_cacheType];
    
    if (cachedImage != nil) {
        
        [self displayImage:cachedImage];
    }
    else
    {
        // No cache available. Download it.
        
        [_equipmentActivityView startAnimating];
        
        weakify(self);
        
        _equipmentHttpClient = [EHHTTPClient connectionWithImageURL:imageURL method:@"GET" paramBlock:^(void){
            
            NSDictionary *dictionary = nil;
            return dictionary;
            
        }failureBlock:^(NSError *error){
            //
        }completionBlock:^(NSData *data){
            
            strongify(self);
            if(self) {
                [self displayImage:[UIImage imageWithData:data]];
                [[EHCache sharedCacheInstance] cacheImage:data forKey:imageURL toCacheType:_cacheType];
                [self->_equipmentActivityView stopAnimating];

            }
            
        }];
        
        [_equipmentHttpClient start];
        
    }
}

- (void)setCacheType:(EHCacheType)cacheType
{
    _cacheType = cacheType;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _equipmentTitleLabel.text = title;
}

- (void)displayImage:(UIImage *)image
{
    [UIView animateWithDuration:0.5 animations:^(void){
        _equipmentImageView.image = image;
    }];
}


@end
