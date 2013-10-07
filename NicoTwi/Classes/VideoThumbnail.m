//
//  VideoThumbnail.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/11.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "VideoThumbnail.h"

@interface VideoThumbnail () {
    UIFont *fontSize10_;
    UIColor *starColor_, *whiteColor_;
    UIImage *starImage_;
}

@end

@implementation VideoThumbnail

@synthesize thumbnailImage, length;

- (id)init {
    self = [super init];
    if (self) {
      starColor_ = HEXCOLOR(0xFFC821);
      whiteColor_ = [UIColor whiteColor];
      fontSize10_ = [UIFont systemFontOfSize:10];

      starImage_ = [[UIImage imageNamed:@"28-star"] imageByShrinkingWithSize:CGSizeMake(10.0f, 10.0f)];
    }
    return self;
}

- (void)dealloc {
}

- (void)setImage:(UIImage*)image videoLength:(NSString*)videoLength {
    [self setImage:image videoLength:videoLength star:NO];
}

- (void)setImage:(UIImage*)image videoLength:(NSString*)videoLength star:(BOOL)star {
    self.thumbnailImage = image;
    self.length = videoLength;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // image
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [image drawInRect:rect];


    if (star) {
      CGContextSaveGState(context);

      // favorite background
      CGContextSetRGBFillColor(context, 0, 0, 0, 0.8);
      CGContextMoveToPoint(context, 0.0f, 0.0f);
      CGContextAddLineToPoint(context, 26.0f, 0.0f);
      CGContextAddLineToPoint(context, 0.0f, 26.0f);
      CGContextFillPath(context);

      // favorite icon
      rect = CGRectMake(3, -3, starImage_.size.width, starImage_.size.height);

      [starColor_ setFill];
      CGContextTranslateCTM(context, 0, starImage_.size.height);
      CGContextScaleCTM(context, 1.0, -1.0);
      CGContextClipToMask(context, rect, starImage_.CGImage);
      CGContextAddRect(context, rect);
      CGContextDrawPath(context, kCGPathFill);

      CGContextRestoreGState(context);
    }


    // video length
    CGSize strSize = [videoLength sizeWithFont:fontSize10_];
    CGRect drawRect = CGRectMake(self.bounds.size.width - strSize.width - 7, 
      self.bounds.size.height - strSize.height - 3, strSize.width + 4, strSize.height);

    CGContextSetRGBFillColor(context, 0, 0, 0, 0.8);
    CGContextFillRect(context, drawRect);

    CGContextSetFillColorWithColor(context, whiteColor_.CGColor);
    [videoLength drawInRect:drawRect withFont:fontSize10_ 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();

    self.contents = (__bridge id)imgRef;

    CGImageRelease(imgRef);
}

- (void)drawStar:(BOOL)draw {
    [self setImage:self.thumbnailImage videoLength:self.length star:draw];
}

@end
