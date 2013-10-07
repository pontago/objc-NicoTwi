//
//  CacheManager.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/08.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ImageResultBlock)(UIImage *image);

@interface CacheManager : NSCache

@property (unsafe_unretained, nonatomic) BOOL enableDiskCache;


+ (CacheManager*)sharedCache;

- (void)downloadImage:(NSString*)url block:(ImageResultBlock)block;
- (void)downloadImage:(NSString*)url resize:(CGSize)resize block:(ImageResultBlock)block;
- (void)downloadImage:(NSString*)url resize:(CGSize)resize cornerRadius:(CGFloat)cornerRadius block:(ImageResultBlock)block;

- (void)cancelRequestForUrls:(NSArray*)urls;
- (void)cancelAllRequest;

- (UIImage*)cacheImageWithUrl:(NSString*)url;
- (void)cacheImageWithUrl:(NSString*)url block:(ImageResultBlock)block;

@end
