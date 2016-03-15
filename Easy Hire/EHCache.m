//
//  FDCache.m
//  Flicker Feed Demo
//
//  Created by Prasanna Ramachandra Aithal on 4/30/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHCache.h"

static const NSTimeInterval kCacheExpiryTimeInterval = 7200; // 2 hours cache
static const NSInteger kMaxAllowedURLCache = 100; // 100 URL limit
static const NSInteger kMaxAllowedDataCache = 10 * 1024 * 1024; // 10 MB limit
static char kPNGBytesSignature[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static NSData *kPNGDataSignature = nil;

FOUNDATION_STATIC_INLINE NSString * EHCacheKeyFromURL(NSURL *url){
   return [url absoluteString];
}

FOUNDATION_STATIC_INLINE NSString *EHCacheFileName(NSString *fileName){
    return [fileName lastPathComponent];
}

// Check png or jpeg
BOOL isImageDataHasPNGPreffix(NSData *data) {
    
    NSUInteger pngDataSignatureLength = [kPNGDataSignature length];
   
    if ([data length] >= pngDataSignatureLength) {
        if ([[data subdataWithRange:NSMakeRange(0, pngDataSignatureLength)] isEqualToData:kPNGDataSignature]) {
           
            return YES;
        }
    }
    
    return NO;
}

// Stringification
#define ImageCacheForKey(imageCache) @#imageCache
#define ImageCacheCreatedDateForKey(imageCacheCreatedDate) @#imageCacheCreatedDate

@interface FDMemoryCache : NSObject <NSCoding>

/**
 * Imgae cache
 *
 * @param imageCache The image cache
 */
@property (nonatomic, strong) NSData *imageCache;

/**
 * The cache created date
 *
 * @param imageCacheCreatedDate The cache created date
 */
@property (nonatomic, strong) NSDate *imageCacheCreatedDate;

@end

@implementation FDMemoryCache

#pragma mark - Init
- (instancetype)init __attribute__((objc_requires_super))
{
    return [super init];
}

#pragma mark - Encode/Decode
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        // Check keys are allowed
        if ([aDecoder allowsKeyedCoding]) {
            
            _imageCache = [aDecoder decodeObjectForKey:ImageCacheForKey(_imageCache)];
            _imageCacheCreatedDate = [aDecoder decodeObjectForKey:ImageCacheCreatedDateForKey(_imageCacheCreatedDate)];
        }
        else
        {
            _imageCache = [aDecoder decodeObject];
            _imageCacheCreatedDate = [aDecoder decodeObject];
        }
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if ([aCoder allowsKeyedCoding]) { 
        [aCoder encodeObject:_imageCache forKey:ImageCacheForKey(_imageCache)];
        [aCoder encodeObject:_imageCacheCreatedDate forKey:ImageCacheCreatedDateForKey(_imageCacheCreatedDate)];
    }
    else
    {
        // Maintain stack order as key is not allowed here
        [aCoder encodeObject:_imageCache];
        [aCoder encodeObject:_imageCacheCreatedDate];
    }
}

@end

@interface EHCache ()

/**
 * The in-memory cache handler
 *
 * @param cacheHandler The cache handler
 */
@property (nonatomic, copy) NSCache *cacheHandler;

/**
 * The disk cache file handler
 *
 * @param fileHandler The file handler
 */
@property (nonatomic, strong) NSFileManager *fileHandler;

@end

@implementation EHCache

#pragma mark - Single Instance
+ (EHCache *)sharedCacheInstance
{
    static EHCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void){
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}
#pragma mark - Init
- (instancetype)init
{
    if (self = [super init]) {
        
        _cacheHandler = [NSCache new];
        _cacheHandler.countLimit = kMaxAllowedURLCache; // Set max URL limit
        _cacheHandler.totalCostLimit = kMaxAllowedDataCache; // Set max cache limit
        
        // Remove all cached object during memory warning.
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *__unused notification){
            [_cacheHandler removeAllObjects];
        }];
        
        _fileHandler = [NSFileManager new];
        
        kPNGDataSignature = [NSData dataWithBytes:kPNGBytesSignature length:8];
    }
    return self;
}
#pragma mark - Directory/File path
- (NSString *)diskCacheDirectoryPath
{
    // Return directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return paths[0];
}

- (NSString *)diskCacheFilePath:(NSString *)fileName
{
    // Return file path
    return [[self diskCacheDirectoryPath] stringByAppendingPathComponent:EHCacheFileName(fileName)];
}
#pragma mark - Cache image or return cached image
- (void)cacheImage:(NSData *)imageData forKey:(NSURL *)key toCacheType:(EHCacheType)cacheType
{
    if (cacheType == kCacheTypeMemory) {
       
        FDMemoryCache *memoryCache = [[FDMemoryCache alloc] init];
        memoryCache.imageCache = imageData;
        memoryCache.imageCacheCreatedDate = [NSDate date];
        
        NSPurgeableData *data = [NSPurgeableData dataWithData:[NSKeyedArchiver archivedDataWithRootObject:memoryCache]];
        
        [_cacheHandler setObject:data forKey:EHCacheKeyFromURL(key) cost:data.length];
    }
    else
    {
        // Get image type (png or jpeg). Dont overide imge type
        NSData *data = nil;
        BOOL isPNGImage = YES;
      
        if ([imageData length] > [kPNGDataSignature length]) {
            isPNGImage = isImageDataHasPNGPreffix(imageData);
        }
        
        data = isPNGImage ? UIImagePNGRepresentation([UIImage imageWithData:imageData]) : UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1);
        
        if ([data length] > kNilOptions) {
            
            NSString *diskCachePath = [self diskCacheFilePath:EHCacheKeyFromURL(key)];
          
            if(![_fileHandler fileExistsAtPath:diskCachePath])
            {
                [_fileHandler createFileAtPath:diskCachePath contents:data attributes:nil];
            }
        }
    }
    
}

- (UIImage *)cachedImageForKey:(NSURL *)key forCacheType:(EHCacheType)cacheType
{
    UIImage *cachedImage = nil;
    NSDate *cacheCreatedDate = nil;
    
    if (cacheType == kCacheTypeMemory) {
        
        NSPurgeableData *cachedData = [_cacheHandler objectForKey:EHCacheKeyFromURL(key)];
        
        if (cachedData) {
            // Stop data purge. As i am going to access that
            [cachedData beginContentAccess];
            
            FDMemoryCache *memoryCache = (FDMemoryCache *)[NSKeyedUnarchiver unarchiveObjectWithData:cachedData];
            cachedImage = [UIImage imageWithData:memoryCache.imageCache];
            cacheCreatedDate = memoryCache.imageCacheCreatedDate;
            
            [cachedData endContentAccess];
        }
    }
    else
    {
        NSString *diskCachePath = [self diskCacheFilePath:EHCacheKeyFromURL(key)];
        cachedImage = [UIImage imageWithContentsOfFile:diskCachePath];
        cacheCreatedDate = [_fileHandler attributesOfItemAtPath:[self diskCacheFilePath:EHCacheKeyFromURL(key)] error:NULL][NSFileCreationDate];
    }

    return [self hasCacheExpiredForDate:cacheCreatedDate] ? nil : cachedImage;
}

- (BOOL)hasCacheExpiredForDate:(NSDate *)cacheExpiryDate
{
    NSTimeInterval timeSinceCache = fabs([cacheExpiryDate timeIntervalSinceNow]);
    return (timeSinceCache > kCacheExpiryTimeInterval);
}

#pragma mark - Clear in-memory/disk cache
- (void)clearMemoryCacheForKey:(NSURL *)key
{
    [_cacheHandler removeObjectForKey:EHCacheKeyFromURL(key)];
}

- (void)clearDiskCacheForKey:(NSURL *)key
{
    [_fileHandler removeItemAtURL:key error:NULL];
}

#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
