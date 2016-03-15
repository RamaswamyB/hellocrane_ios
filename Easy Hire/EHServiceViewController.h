//
//  EHServiceViewController.h
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EHButtonType) {
    kCallMeBack = 2,
    KTollFree,
    kFillUpEnquiryForm,
};

const NSString *EHPlaceholderMessageForButtonType(EHButtonType type);

@interface EHServiceViewController : UIViewController

@end
