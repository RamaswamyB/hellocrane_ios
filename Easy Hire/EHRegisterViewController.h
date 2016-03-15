//
//  EHRegisterViewController.h
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EHTextFieldType) {
    kEHUserFirstNameField = 0,
    kEHUserLastNameField,
    kEHCompanyNameField,
    kEHMobileNumberField,
    kEHPasswordFiled,
    kEHEmailField
};

extern NSString *EHPlaceholderMessageForType(EHTextFieldType type);
extern NSString *EHValidationMessageForType(EHTextFieldType type);
extern NSString *EHUserRoleNameeForType(UserType type);

@interface EHRegisterViewController : UIViewController

@end
