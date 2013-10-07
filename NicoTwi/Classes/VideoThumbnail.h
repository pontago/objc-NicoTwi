//
//  VideoThumbnail.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/11.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface VideoThumbnail : CALayer

@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) NSString *length;

- (void)setImage:(UIImage*)image videoLength:(NSString*)videoLength;
- (void)setImage:(UIImage*)image videoLength:(NSString*)videoLength star:(BOOL)star;
- (void)drawStar:(BOOL)draw;

@end
