//
//  EHChangePasswordViewController.h
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/14/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EHTextFieldType) {
    kEHCurrentPasswordField = 0,
    kEHNewPasswordField,
    kEHConfirmPasswordField,
};

extern NSString *EHPlaceholderMessageForPasswordType(EHTextFieldType type);

@interface EHChangePasswordViewController : UIViewController

@end
