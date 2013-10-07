//
//  TwitterView.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/09.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "TwitterView.h"

CGPoint const     PROFILE_IMAGE_MARGIN      = {5, 8};
CGPoint const     PROFILE_IMAGE_PADDING     = {6, 5};
CGSize const      PROFILE_IMAGE_SIZE        = {24, 24};
CGSize const      PROFILE_IMAGE_MIN_SIZE    = {18, 18};
NSUInteger const  MAX_PROFILE_IMAGE         = 12;
NSUInteger const  ROW_PROFILE_IMAGE_COUNT   = 6;

@interface TwitterView () {
    UIFont *fontSize9_, *fontSize10_, *fontSizeBold10_;
    UIColor *blackColor_, *darkGrayColor_;
    CGRect profileRect_;
    CGFloat profileLabelX_;
    CGPoint moreCountPoint_;
}

- (void)longPressGesture_:(UILongPressGestureRecognizer*)gestureRecognizer;

@end

@implementation TwitterView

@synthesize videoId, tweetInfo, delegate, rowProfileImageCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//      self.backgroundColor = [UIColor whiteColor];
      self.backgroundColor = [UIColor clearColor];

      fontSize9_ = [UIFont systemFontOfSize:9];
      fontSize10_ = [UIFont systemFontOfSize:10];
      fontSizeBold10_ = [UIFont boldSystemFontOfSize:10];
      darkGrayColor_ = [UIColor darkGrayColor];
      blackColor_ = [UIColor blackColor];

      self.rowProfileImageCount = ROW_PROFILE_IMAGE_COUNT;

      profileRect_ = CGRectMake(PROFILE_IMAGE_MARGIN.x, PROFILE_IMAGE_MARGIN.y,
        PROFILE_IMAGE_SIZE.width, PROFILE_IMAGE_SIZE.height);
      profileLabelX_ = profileRect_.origin.x + profileRect_.size.width + PROFILE_IMAGE_MARGIN.x;

      UILongPressGestureRecognizer *longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
        action:@selector(longPressGesture_:)];
      longTapGestureRecognizer.minimumPressDuration = 0.5;
      [self addGestureRecognizer:longTapGestureRecognizer];
    }
    return self;
}

- (void)dealloc {
    LOG(@"tv - dealloc");
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (self.tweetInfo) {
      NSArray *tweets = [self.tweetInfo objectForKey:@"list"];
      NSDictionary *tweet = [tweets objectAtIndex:0];

      // name label
      NSString *str = [tweet objectForKey:@"name"];
      CGRect drawRect = CGRectMake(profileLabelX_, profileRect_.origin.y + 1, 
        self.frame.size.width - profileLabelX_ - PROFILE_IMAGE_MARGIN.x, 12);
      CGContextSetFillColorWithColor(context, blackColor_.CGColor);
      [str drawInRect:CGRectIntegral(drawRect) withFont:fontSize10_ 
        lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];

      // screen name label
      str = [NSString stringWithFormat:@"@%@", [tweet objectForKey:@"screen_name"]];
      drawRect = CGRectMake(profileLabelX_, profileRect_.origin.y + 13, 
        self.frame.size.width - profileLabelX_ - PROFILE_IMAGE_MARGIN.x, 12);
      CGContextSetFillColorWithColor(context, darkGrayColor_.CGColor);
      [str drawInRect:CGRectIntegral(drawRect) withFont:fontSize9_ 
        lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];

      // tweet plus label
      NSUInteger max = [[self.tweetInfo objectForKey:@"tweet_count"] intValue];
      if ([tweets count] >= (self.rowProfileImageCount * 2)) {
        NSUInteger moreCount = max - (self.rowProfileImageCount * 2);
        if (moreCount > 99) moreCount = 99;

        str = [NSString stringWithFormat:@"%d+", moreCount];
        drawRect = CGRectMake(moreCountPoint_.x, moreCountPoint_.y + 3, 
          PROFILE_IMAGE_MIN_SIZE.width, PROFILE_IMAGE_MIN_SIZE.height);
        CGContextSetFillColorWithColor(context, blackColor_.CGColor);
        [str drawInRect:CGRectIntegral(drawRect) withFont:fontSizeBold10_ 
          lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
      }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}


- (void)setupTwitterInfo:(NSDictionary*)tweetDict isLazyLoad:(BOOL)isLazyLoad {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.layer.sublayers = nil;

    self.tweetInfo = tweetDict;
    if (!tweetDict) return;


    NSArray *tweets = [self.tweetInfo objectForKey:@"list"];
    CALayer *videoThumb;
    UIColor *videoThumbColor = HEXCOLOR(0xF8F7F8);
    NSString *profileImageUrl;
    NSInteger i = 0, max = [tweets count];
    CGFloat x = PROFILE_IMAGE_MARGIN.x, y = PROFILE_IMAGE_MARGIN.y;
    CGFloat w = PROFILE_IMAGE_SIZE.width, h = PROFILE_IMAGE_SIZE.height;

    for (i = 0; i < max; i++) {
      NSDictionary *tweet = [tweets objectAtIndex:i];

      if (i == 1) {
        w = PROFILE_IMAGE_MIN_SIZE.width;
        h = PROFILE_IMAGE_MIN_SIZE.height;
      }
      else if (i >= (self.rowProfileImageCount * 2)) {
        moreCountPoint_ = CGPointMake(x, y);
        break;
      }

      videoThumb = [CALayer layer];
      videoThumb.frame = CGRectIntegral(CGRectMake(x, y, w, h));
      videoThumb.backgroundColor = videoThumbColor.CGColor;
      [self.layer addSublayer:videoThumb];


      profileImageUrl = [tweet objectForKey:@"profile_image_url"];
      if (i == 0) {
        [[CacheManager sharedCache] downloadImage:profileImageUrl resize:PROFILE_IMAGE_SIZE cornerRadius:2.0 block:^(UIImage *image) {
            videoThumb.contents = (__bridge id)(image.CGImage);
        }];
      }
      else {
        NSString *miniProfileImageUrl = [[UtilEx sharedInstance] replaceTwitterProfileImageMini:profileImageUrl];
        [[CacheManager sharedCache] cacheImageWithUrl:miniProfileImageUrl block:^(UIImage *image) {
            videoThumb.contents = (__bridge id)(image.CGImage);
        }];

        videoThumb.name = miniProfileImageUrl;
      }


      if (i > 0) {
        if ((i % self.rowProfileImageCount) > 0) {
          x += w + PROFILE_IMAGE_PADDING.x;
        }
        else {
          x = PROFILE_IMAGE_MARGIN.x;
          y += h + PROFILE_IMAGE_PADDING.y;
        }
      }
      else {
        y += h + PROFILE_IMAGE_PADDING.y;
      }
    }


    if (!isLazyLoad) {
      [self downloadMiniProfileImages];
    }
}

+ (CGFloat)heightForObject:(NSArray*)tweets rowImageCount:(NSUInteger)rowImageCount {
    NSUInteger tweetCount = [tweets count];
    if (tweetCount > 0) {
      CGFloat height = PROFILE_IMAGE_MARGIN.y + PROFILE_IMAGE_SIZE.height;

      if (tweetCount > 1) {
        height += PROFILE_IMAGE_PADDING.y + PROFILE_IMAGE_MIN_SIZE.height;
        if (tweetCount > rowImageCount + 1) {
          height += PROFILE_IMAGE_PADDING.y + PROFILE_IMAGE_MIN_SIZE.height;
        }
      }

      return height + 2.0f;
    }
    else {
      return 15.0;
    }
}


- (void)longPressGesture_:(UILongPressGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
      self.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
      self.backgroundColor = [UIColor clearColor];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(twitterView:didSelect:)]) {
      [self.delegate twitterView:self didSelect:gestureRecognizer.state];
    }
}

- (void)downloadMiniProfileImages {
    for (VideoThumbnail *videoThumb in self.layer.sublayers) {
      if (videoThumb.name && [videoThumb.name length] > 0) {
        [[CacheManager sharedCache] downloadImage:videoThumb.name resize:PROFILE_IMAGE_SIZE cornerRadius:2.0 block:^(UIImage *image) {
          videoThumb.contents = (__bridge id)(image.CGImage);
//            [self showMiniProfileImages];
        }];
      }
    }
}

- (void)showMiniProfileImages {
    for (VideoThumbnail *videoThumb in self.layer.sublayers) {
      if (videoThumb.name && [videoThumb.name length] > 0 && videoThumb.contents == nil) {
        [[CacheManager sharedCache] cacheImageWithUrl:videoThumb.name block:^(UIImage *image) {
          videoThumb.contents = (__bridge id)(image.CGImage);
        }];
      }
    }
}

@end
