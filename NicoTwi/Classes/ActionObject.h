//
//  ActionObject.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/30.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionObject : NSObject

@property (unsafe_unretained, nonatomic) UIViewController *viewController;

- (id)initWithViewController:(UIViewController*)viewController;

- (void)postTweet:(NSDictionary*)params;
- (void)openApplication:(NSDictionary*)params;

+ (NSArray*)swipeMenu;

@end
