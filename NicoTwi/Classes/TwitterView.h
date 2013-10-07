//
//  TwitterView.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/09.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterView;
@protocol TwitterViewDelegate;

@interface TwitterView : UIView

@property (strong, nonatomic) NSNumber *videoId;
@property (strong, nonatomic) NSDictionary *tweetInfo;
@property (unsafe_unretained, nonatomic) id<TwitterViewDelegate> delegate;
@property (unsafe_unretained, nonatomic) NSUInteger rowProfileImageCount;

- (void)setupTwitterInfo:(NSDictionary*)tweetDict isLazyLoad:(BOOL)isLazyLoad;
+ (CGFloat)heightForObject:(NSArray*)tweets rowImageCount:(NSUInteger)rowImageCount;
- (void)downloadMiniProfileImages;
- (void)showMiniProfileImages;

@end


#pragma mark - Delegate

@protocol TwitterViewDelegate <NSObject>

@optional
- (void)twitterView:(TwitterView*)twitterView didSelect:(UIGestureRecognizerState)state;

@end
