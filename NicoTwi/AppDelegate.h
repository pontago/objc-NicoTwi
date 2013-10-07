//
//  AppDelegate.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const URL_SCHEME;
extern NSString* const URL_SCHEME_URL;

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

- (void)showMenuTableViewController;

@end
