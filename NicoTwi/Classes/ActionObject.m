//
//  ActionObject.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/30.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "ActionObject.h"

@implementation ActionObject

@synthesize viewController = viewController_;

- (id)initWithViewController:(UIViewController*)viewController
{
    self = [self init];
    if (self) {
      viewController_ = viewController;
    }
    return self;
}

- (void)postTweet:(NSDictionary*)params {
    TWTweetComposeViewController *twViewController = [[UtilEx sharedInstance] postTweet:[params objectForKey:@"title"] 
      videoId:[params objectForKey:@"video_id"]];
    [twViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
      [self.viewController dismissModalViewControllerAnimated:YES];
    }];
    [self.viewController presentModalViewController:twViewController animated:YES];
}

- (void)openApplication:(NSDictionary*)params {
    [[UtilEx sharedInstance] openVideo:[params objectForKey:@"video_id"]];
}


+ (NSArray*)swipeMenu {
    return @[
        @[@"ツイッター投稿", @"postTweet:"],
        @[@"アプリで開く", @"openApplication:"]
      ];
}

@end
