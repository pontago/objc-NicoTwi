//
//  UIViewController+dismissCompletion.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/26.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "UIViewController+dismissCompletion.h"
#import <objc/runtime.h>

@implementation UIViewController (dismissCompletion)

- (void)setCompletionBlock:(dispatch_block_t)completionBlock {
    objc_setAssociatedObject(self, @selector(completionBlock:), 
      completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (dispatch_block_t)completionBlock {
    return objc_getAssociatedObject(self, @selector(completionBlock:));
}


- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated 
  completion:(void (^)(void))completion dismissCompletion:(dispatch_block_t)dismissCompletion {

    if ([viewController isKindOfClass:[UINavigationController class]]) {
      UIViewController *rootViewController = ((UINavigationController*)viewController).viewControllers[0];
      rootViewController.completionBlock = dismissCompletion;
    }
    else {
      self.completionBlock = dismissCompletion;
    }

    [self presentViewController:viewController animated:animated completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag {
    dispatch_block_t block = self.completionBlock;
    self.completionBlock = nil;

    [self dismissViewControllerAnimated:(BOOL)flag completion:block];
}

@end
