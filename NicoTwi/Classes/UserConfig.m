//
//  UserConfig.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "UserConfig.h"

@implementation UserConfig

static UserConfig *sharedUserConfig = nil;

+ (UserConfig*)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedUserConfig = [[UserConfig alloc] init];
    });
    return sharedUserConfig;
}


- (void)createUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
        @YES, @"SLEEP_DISABLED", 
        @"", @"TWITTER_IDENTIFIER", 
        SORT_DESC, @"FAVORITE_SORT", 
        @YES, @"FAVORITE_CONFIRM_DELETE", 
        @YES, @"CLIP_CONFIRM_ADD", 
        OPEN_VIDEO_APP_OFFICIAL, @"OPEN_VIDEO_APP", 
        OPEN_VIDEO_APP_BUILTIN, @"OPEN_URL_APP", 
        @NO, @"INIT_HELP", 
        @1, @"LAUNCH_COUNT", 
        @NO, @"ADDON_ADBANNER_HIDDEN", 
        [NSDate dateWithTimeIntervalSince1970:0], @"INIT_DATE", 
        @NO, @"CHECK_TERMS",
      nil];

    [defaults registerDefaults:userDefaults];
}

- (id)getConfig:(NSString*)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

- (void)saveConfig:(NSString*)key value:(NSObject*)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}


- (void)updateIdleTimerDisabled {
    NSNumber *sleepDisabled = [self getConfig:@"SLEEP_DISABLED"];
    [UIApplication sharedApplication].idleTimerDisabled = [sleepDisabled boolValue];
}

@end
