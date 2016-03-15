//
//  EHProgressLoader.h
//  Easy Hire
//
//  Created by Prasanna on 07/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHProgressLoader : NSObject

+ (EHProgressLoader *)sharedLoaderInstance;

- (void)showLoaderIn:(id)controller;
- (void)hideLoader;

@end
