//
//  UtilEx.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/21.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const URL_NICO_WATCH;

@interface UtilEx : NSObject

+ (UtilEx*)sharedInstance;

- (NSString*)documentDirectory;
- (NSString*)cachesDirectory;
- (NSString*)stringByURLEncoding:(NSString*)string;

- (NSArray*)parseNicoMovieIds:(NSString*)text;
- (NSArray*)parseMovieIdFromTweet:(NSString*)text urls:(NSArray*)urls;
- (NSArray*)nicoCategories;
- (NSString*)parseNumNicoVideoId:(NSString*)videoId;

- (UIImage*)roundCornersOfImage:(UIImage*)image cornerRadius:(CGFloat)cornerRadius;

- (NSString*)twDateString:(NSDate*)date shortFormat:(BOOL)shortFormat;
- (NSString*)numberFormatFromString:(NSString*)string;
- (NSString*)timeFormatFromNumber:(NSNumber*)num;

- (NSString*)replaceUrlAndMovieIdFromText:(NSString*)body;
- (NSString*)replaceUrlTagFromText:(NSArray*)tags delimiter:(NSString*)delimiter;
- (NSString*)replaceTwitterProfileImageMini:(NSString*)url;

- (void)openVideo:(NSString*)videoId;
- (void)openNicoUrl:(NSURL*)url;
- (void)openTweet:(NSString*)statusId;
- (void)openTwitterUser:(NSString*)screenName;

- (TWTweetComposeViewController*)postTweet:(NSString*)title videoId:(NSString*)videoId;

- (CGSize)applicationSize;

@end
