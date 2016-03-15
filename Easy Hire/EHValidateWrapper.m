//
//  EHValidateWrapper.m
//  Easy Hire
//
//  Created by Prasanna on 12/12/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "EHValidateWrapper.h"

@implementation EHValidateWrapper

static EHValidateWrapper *sharedInstance = nil;

+ (EHValidateWrapper*)sharedInstance
{
    if (!sharedInstance) {
        sharedInstance = [[EHValidateWrapper alloc] init];
    }
    return sharedInstance;
}
- (BOOL)isNullArray:(NSArray *)inputArray{
    
    if ([inputArray isKindOfClass:[NSNull class]]) {
        return YES;
    }
    else if ([inputArray count] == 0){
        return YES;
    }
    else if ([inputArray  isEqual: @"null"]){
        return YES;
    }
    else if ([inputArray isEqual: @"(null)"]){
        return YES;
    }
    
    //    else if (inputArray == nil){
    //        return YES;
    //    }
    else if (inputArray == 0){
        return YES;
    }
    else if ([inputArray isEqual:@""]){
        return YES;
    }
    else{
        return NO;
    }
    
    return NO;
    
    
    
    
}

/*Checking the Dictionary is null or not
 Input - NSDictioary
 Output - Bool (if yes, then the dictionary is empty)
 
 */
- (BOOL)isNullDictionary:(NSDictionary *)inputDic{
    
    if (inputDic == nil) {
        return YES;
    }
    else if ([inputDic isKindOfClass:[NSNull class]]){
        return YES;
    }
    else if ([inputDic  isEqual: @"null"]){
        return YES;
    }
    else if ([inputDic isEqual: @"(null)"]){
        return YES;
    }
    else if (inputDic == 0){
        return YES;
    }
    else if ([inputDic isEqual:@""]){
        return YES;
    }
    else if ([inputDic isEqual:@{}]){
        return YES;
    }
    else{
        
        return NO;
    }
    
    return NO;
}
@end
