//
//  FDCache.h
//  Flicker Feed Demo
//
//  Created by Prasanna Ramachandra Aithal on 4/30/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * This class acts as a cache handler
 */

typedef NS_ENUM(NSInteger, EHCacheType)
{
    kCacheTypeMemory = 0,
    kCacheTypeDisk
};

@interface EHCache : NSObject

/**
 * Return shared cache instance
 *
 * @return sharedCacheInstance The global cache instance
 */
+ (EHCache *)sharedCacheInstance __attribute__((const));

/**
 * Cache image based on cache type
 *
 * @param image The image which will be cached
 * @param key The key for image cache
 * @param cacheType The cache type
 */
- (void)cacheImage:(NSData *)image forKey:(NSURL *)key toCacheType:(EHCacheType)cacheType;

/**
 * Returns cached image for key
 *
 * @param key The key for cached image
 * @param cacheType The cache type
 * @return UIImage Returns cached cached image
 */
- (bycopy UIImage *)cachedImageForKey:(NSURL *)key forCacheType:(EHCacheType)cacheType;

@end
