//
//  QWAlertPromptHelper.h
//  QikWell
//
//  Created by Prasanna on 08/10/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 
 This class handles all type of user prompt inside the app
 
 */

@class EHAlertPromptHelper;

typedef void (^EHAlertPromptCompletionBlock)(EHAlertPromptHelper *alert, NSUInteger buttonIndex);

@interface EHAlertPromptHelper : NSObject

+ (instancetype)showAlertViewIn:(id)instance withTitle:(NSString *)title
                        message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
              otherButtonTitles:(NSArray *)otherButtonTitles completionBlock:(EHAlertPromptCompletionBlock)completionBlock;

+ (instancetype)showActionSheetIn:(id)instance withTitle:(NSString *)title
                          message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle
                otherButtonTitles:(NSArray *)otherButtonTitles completionBlock:(EHAlertPromptCompletionBlock)completionBlock;

@end
