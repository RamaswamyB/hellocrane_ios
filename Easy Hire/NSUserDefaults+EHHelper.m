//
//  NSUserDefaults+EHHelper.m
//  Easy Hire
//
//  Created by Prasanna on 05/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "NSUserDefaults+EHHelper.h"

static NSString *const kEHParentKey = @"key";

static NSString *const kEHAccessToken = @"accessToken";
static NSString *const kEHUsermobile = @"usermobile";
static NSString *const kEHPassword = @"password";
static NSString *const kEHUserType = @"userType";

static NSString *const kEHUserCompanyName = @"companyName";
static NSString *const kEHUserEmailID = @"userEmail";
static NSString *const kEHUserFirstName = @"firstName";
static NSString *const kEHUserLastName = @"lastName";
static NSString *const kEHUserID = @"userID";


id ObjectOrNullInstance(id object)
{
    if (object == nil || object == [NSNull class]) {
        return @"";
    }
    return object;
}

@implementation NSUserDefaults (EHHelper)

- (NSString *)parentKey
{
    // Returns static key
    return kEHParentKey;
}
- (NSString *)childKey
{
    // Returns mobile no as key
    return [self objectForKey:[self parentKey]];
}
- (NSMutableDictionary *)savedUserDetails
{
    NSString *parentKey = [self parentKey];
    NSString *childKey = [self objectForKey:parentKey];
    
   
//    NSMutableDictionary *userdetails = nil;
//    if ([[[self dictionaryRepresentation]allKeys] containsObject:parentKey]) {
//        
//        userdetails = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForKey:childKey]];
//        
//    }
//    else
//        userdetails = [NSMutableDictionary dictionary];
//    return userdetails;
    
    return [NSMutableDictionary dictionaryWithDictionary:(childKey)?[self dictionaryForKey:childKey]:nil];
    
}
- (void)setUsermobile:(NSString *)usermobile
{
    [self setObject:usermobile forKey:[self parentKey]];
}
- (void)setPassword:(NSString *)password
{
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:password forKey:kEHPassword];
    
    [self setObject:dict forKey:[self childKey]];
}
- (void)setAccessToken:(NSString *)accessToken
{
   
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:accessToken forKey:kEHAccessToken];
    [self setObject:dict forKey:[self childKey]];
}

- (void)setUserType:(UserType)userType
{
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:[NSNumber numberWithInt:userType] forKey:kEHUserType];
    [self setObject:dict forKey:[self childKey]];
   
    // [[self userDetails] setObject:([NSNumber numberWithInt:userType]) forKey:kEHUserType];
}

- (void)setCompanyName:(NSString *)companyName
{
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:companyName forKey:kEHUserCompanyName];
    [self setObject:dict forKey:[self childKey]];
}
- (void)setUserEmail:(NSString *)userEmail
{
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:userEmail forKey:kEHUserEmailID];
    [self setObject:dict forKey:[self childKey]];
}
- (void)setFirstName:(NSString *)firstName
{
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:firstName forKey:kEHUserFirstName];
    [self setObject:dict forKey:[self childKey]];
}
- (void)setLastName:(NSString *)lastName
{
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:lastName forKey:kEHUserLastName];
    [self setObject:dict forKey:[self childKey]];
}
- (void)setUserid:(NSUInteger)userid
{
    NSMutableDictionary *dict = [self savedUserDetails];
    [dict setObject:[NSNumber numberWithInteger:userid] forKey:kEHUserID];
    [self setObject:dict forKey:[self childKey]];
}
- (void)save
{
    [self synchronize];
}
- (void)remove
{
    NSString *childkey = [self childKey];
    NSString *parentkey = [self parentKey];
    
    if (childkey != nil) {
        [self removeObjectForKey:[self childKey]];
    }
    if (parentkey != nil) {
        [self removeObjectForKey:[self parentKey]];
    }
    
    [self synchronize];
}
- (NSString *)companyName
{
   return [[self savedUserDetails] objectForKey:kEHUserCompanyName];
}
- (NSString *)userEmail
{
   return [[self savedUserDetails] objectForKey:kEHUserEmailID];
}
- (NSString *)firstName
{
   return [[self savedUserDetails] objectForKey:kEHUserFirstName];
}
- (NSString *)lastName
{
    return [[self savedUserDetails] objectForKey:kEHUserLastName];
}
- (NSUInteger)userid
{
    return [[[self savedUserDetails] objectForKey:kEHUserID] integerValue];
}
- (NSString *)usermobile
{
    return [self objectForKey:[self parentKey]];//[[self savedUserDetails] objectForKey:kEHUsermobile];
}
- (NSString *)password
{
   return [[self savedUserDetails] objectForKey:kEHPassword];
}
- (NSString *)accessToken
{
    return [[self savedUserDetails] objectForKey:kEHAccessToken];
}
- (UserType)userType
{
   return [[[self savedUserDetails] objectForKey:kEHUserType] integerValue];
}

@end
