//
//  NSUserDefaults+EHHelper.h
//  Easy Hire
//
//  Created by Prasanna on 05/11/15.
//  Copyright © 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UserType)
{
    kUserTypeSupplier = 0,
    kUserTypeCustomer
};

extern id ObjectOrNullInstance(id object);

@interface NSUserDefaults (EHHelper)

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *usermobile;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *userEmail;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, assign) NSUInteger userid;
@property (assign) UserType userType;

- (void)save;
- (void)remove;

@end
