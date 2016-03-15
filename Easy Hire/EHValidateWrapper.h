//
//  EHValidateWrapper.h
//  Easy Hire
//
//  Created by Prasanna on 12/12/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHValidateWrapper : NSObject

+ (EHValidateWrapper*)sharedInstance;

- (BOOL)isNullArray:(NSArray *)inputArray;
- (BOOL)isNullDictionary:(NSDictionary *)inputDic;

@end
