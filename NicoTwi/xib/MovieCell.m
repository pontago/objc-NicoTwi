//
//  MovieCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "MovieCell.h"


@interface MovieCell () {
    UIFont *fontSize9_, *fontSize10_, *fontSize11_;
    UIColor *blackColor_, *whiteColor_, *darkGrayColor_;
    UIImage *viewCounterImage_, *commentNumImage_;
}

- (void)longPressGesture_:(UILongPressGestureRecognizer*)gestureRecognizer;
- (void)swipeGesture_:(UISwipeGestureRecognizer*)gestureRecognizer;

@end

@implementation MovieCell

@synthesize videoThumb, twitterView;
@synthesize videoInfo, videoTitle, videoLength;
@synthesize viewCounter, commentNum;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      UIColor *borderColor = HEXCOLOR(BORDER_COLOR);
      self.layer.cornerRadius = 1;
      self.clipsToBounds = YES;
      self.layer.borderColor = borderColor.CGColor;
      self.layer.borderWidth = 0.3;

      whiteColor_ = [UIColor whiteColor];
      blackColor_ = [UIColor blackColor];
      darkGrayColor_ = [UIColor darkGrayColor];
      self.backgroundColor = whiteColor_;

      fontSize9_ = [UIFont systemFontOfSize:9];
      fontSize10_ = [UIFont systemFontOfSize:10];
      fontSize11_ = [UIFont systemFontOfSize:11];

      viewCounterImage_ = [[UIImage imageNamed:@"285-facetime"] imageByShrinkingWithSize:CGSizeMake(15, 12)];
      commentNumImage_ = [[UIImage imageNamed:@"08-chat"] imageByShrinkingWithSize:CGSizeMake(12, 12)];

      self.videoThumb = [[VideoThumbnail alloc] init];
      self.videoThumb.frame = CGRectIntegral(CGRectMake(0, 0, frame.size.width, frame.size.width / 130 * 100));
      [self.layer addSublayer:self.videoThumb];

      self.twitterView = [[TwitterView alloc] initWithFrame:CGRectZero];
      [self addSubview:self.twitterView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *color = HEXCOLOR(0x999999);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);

    // Border
    CGContextMoveToPoint(context, 0, rect.size.height - 1.0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 1.0);
    CGContextStrokePath(context);


    // Video thumbnail border
    CGContextSetLineWidth(context, 0.3);
    CGContextMoveToPoint(context, 0, self.videoThumb.frame.size.height);
    CGContextAddLineToPoint(context, rect.size.width, self.videoThumb.frame.size.height);
    CGContextStrokePath(context);


    // video title label
    CGRect drawRect;
    CGSize strSize;
    if (self.videoTitle) {
      strSize = [self.videoTitle sizeWithFont:fontSize11_
        constrainedToSize:CGSizeMake(self.frame.size.width - 8, 2000)
        lineBreakMode:NSLineBreakByWordWrapping];
      drawRect = CGRectMake(4, self.videoThumb.bounds.size.height + 5, self.frame.size.width - 8, strSize.height);
      CGContextSetFillColorWithColor(context, blackColor_.CGColor);
      [self.videoTitle drawInRect:CGRectIntegral(drawRect) withFont:fontSize11_ 
        lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }

    // play count, comment count
    CGFloat y;
    if (self.viewCounter && self.commentNum) {
      y = drawRect.origin.y + drawRect.size.height + 3;
      strSize = [self.viewCounter sizeWithFont:fontSize10_
        constrainedToSize:CGSizeMake(self.frame.size.width - 8, 2000)
        lineBreakMode:NSLineBreakByWordWrapping];
      drawRect = CGRectMake(10 + viewCounterImage_.size.width, y, strSize.width, strSize.height);
      CGContextSetFillColorWithColor(context, darkGrayColor_.CGColor);

      CGRect imageRect = CGRectMake(7, y + 1, viewCounterImage_.size.width, viewCounterImage_.size.height);
      [viewCounterImage_ drawInRect:CGRectIntegral(imageRect)];
      [self.viewCounter drawInRect:CGRectIntegral(drawRect) withFont:fontSize10_ 
        lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];


      imageRect = CGRectMake(drawRect.origin.x + drawRect.size.width + 5, y + 2, 
        commentNumImage_.size.width, commentNumImage_.size.height);
      strSize = [self.commentNum sizeWithFont:fontSize10_
        constrainedToSize:CGSizeMake(self.frame.size.width - 8, 2000)
        lineBreakMode:NSLineBreakByWordWrapping];
      drawRect = CGRectMake(imageRect.origin.x + imageRect.size.width + 4 , y, strSize.width, strSize.height);
      [commentNumImage_ drawInRect:CGRectIntegral(imageRect)];
      [self.commentNum drawInRect:CGRectIntegral(drawRect) withFont:fontSize10_
        lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }


    // video title label border
    NSDictionary *tweet = self.twitterView.tweetInfo;
    if (tweet) {
      y = drawRect.origin.y + drawRect.size.height + 5;
      CGFloat popPos = 13.0;
      CGFloat popHeight = 4.0, popWidth = 6.0;
      CGContextMoveToPoint(context, 0, y);
      CGContextAddLineToPoint(context, popPos, y);
      CGContextAddLineToPoint(context, popPos + popWidth / 2, y + popHeight);
      CGContextAddLineToPoint(context, popPos + popWidth, y);
      CGContextAddLineToPoint(context, rect.size.width, y);
      CGContextStrokePath(context);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize strSize = [self.videoTitle sizeWithFont:fontSize11_
      constrainedToSize:CGSizeMake(self.frame.size.width - 8, 2000)
      lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat y = self.videoThumb.frame.size.height + 5 + strSize.height + 5 + 15;
    CGRect frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height - y - 1);
    self.twitterView.frame = CGRectIntegral(frame);
}

- (void)prepareForReuse {
    [super prepareForReuse];

    NSMutableArray *urls = [NSMutableArray array];
//    NSArray *tweets = [self.twitterView.tweetInfo objectForKey:@"list"];

    [urls addObject:[self.videoInfo objectForKey:@"thumbnail_url"]];
//    for (NSDictionary *tweet in tweets) {
//      [urls addObject:[tweet objectForKey:@"profile_image_url"]];
//    }
    [[CacheManager sharedCache] cancelRequestForUrls:urls];

    self.videoThumb.contents = nil;
    self.videoInfo = nil;
    self.videoTitle = nil;
    self.videoLength = nil;
    self.viewCounter = nil;
    self.commentNum = nil;

    [self.twitterView setupTwitterInfo:nil isLazyLoad:NO];
    self.twitterView.videoId = nil;
}

- (void)collectionView:(PSCollectionView *)collectionView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    [self performSelectorInBackground:@selector(downloadThumbnail_:) withObject:object];
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    NSString *title = [object objectForKey:@"title"];

    CGFloat twitterHeight = 0.0f;
    NSDictionary *tweet = [object objectForKey:@"tweet"];
    if (tweet) {
      NSArray *tweetList = [tweet objectForKey:@"list"];
      twitterHeight = [TwitterView heightForObject:tweetList rowImageCount:6];
    }

    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:11]
      constrainedToSize:CGSizeMake(columnWidth - 8, 2000)
      lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat height = (columnWidth / 130 * 100) + 5 + titleSize.height + twitterHeight + 15;

    return floorf(height + 10);
}

- (void)showThumbnailImage:(UIImage*)image star:(BOOL)star {
    [self.videoThumb removeAnimationForKey:@"changeOpacity"];
    self.videoThumb.contents = nil;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
      [self.videoThumb setImage:image videoLength:self.videoLength star:star];

      CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
      animation.delegate = self;
      animation.fromValue = [NSNumber numberWithFloat:0.0];
      animation.toValue = [NSNumber numberWithFloat:1.0];
      animation.duration = 0.3;
      animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      self.videoThumb.opacity = 1.0;
      [self.videoThumb addAnimation:animation forKey:@"changeOpacity"];
    });
}

- (void)showThumbnailImage:(UIImage*)image {
    [self showThumbnailImage:image star:NO];
}

- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer {
    [super addGestureRecognizer:gestureRecognizer];

    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
      UILongPressGestureRecognizer *longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
        action:@selector(longPressGesture_:)];
      longTapGestureRecognizer.minimumPressDuration = 0.5;
      [self addGestureRecognizer:longTapGestureRecognizer];

      UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self 
        action:@selector(swipeGesture_:)];
      swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
      [self addGestureRecognizer:swipeGestureRecognizer];
    }
}

- (void)longPressGesture_:(UILongPressGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
      self.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
      self.backgroundColor = whiteColor_;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didSelect:)]) {
      [self.delegate cell:self didSelect:gestureRecognizer.state];
    }
}

- (void)swipeGesture_:(UISwipeGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
      self.backgroundColor = whiteColor_;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didSwipe:)]) {
      [self.delegate cell:self didSwipe:gestureRecognizer];
    }
}

@end
