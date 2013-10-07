//
//  UIViewController+dismissCompletion.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/26.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (dismissCompletion)

@property (nonatomic, copy) dispatch_block_t completionBlock;

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated 
  completion:(void (^)(void))completion dismissCompletion:(dispatch_block_t)dismissCompletion;
- (void)dismissViewControllerAnimated:(BOOL)flag;

@end
