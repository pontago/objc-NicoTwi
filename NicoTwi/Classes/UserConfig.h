//
//  UserConfig.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserConfig : NSObject

+ (UserConfig*)sharedInstance;

- (void)createUserDefaults;
- (id)getConfig:(NSString*)key;
- (void)saveConfig:(NSString*)key value:(NSObject*)value;

- (void)updateIdleTimerDisabled;
@end
