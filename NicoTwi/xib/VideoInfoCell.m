//
//  VideoInfoCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/16.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "VideoInfoCell.h"

CGSize const VIDEO_THUMBNAIL_IMAGE_SIZE = {120, 100};

@interface VideoInfoCell () {
    VideoThumbnail *videoThumb_;
}

@end

@implementation VideoInfoCell

@synthesize videoInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      self.backgroundColor = [UIColor clearColor];

      videoThumb_ = [VideoThumbnail layer];
      videoThumb_.frame = CGRectMake(10, 10, VIDEO_THUMBNAIL_IMAGE_SIZE.width, VIDEO_THUMBNAIL_IMAGE_SIZE.height);
      [self.layer addSublayer:videoThumb_];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *borderColor = HEXCOLOR(BORDER_COLOR);
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *blackColor = [UIColor blackColor];
    UIColor *darkGrayColor = [UIColor darkGrayColor];

    // view border
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, borderColor.CGColor);

    CGRect drawRect = CGRectMake(5, 5, rect.size.width - 10, rect.size.height - 10);
    CGContextFillRect(context, drawRect);

    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    drawRect = CGRectMake(5.5, 5.5, drawRect.size.width - 1, drawRect.size.height - 1);
    CGContextFillRect(context, drawRect);


    // title
    CGFloat x = VIDEO_THUMBNAIL_IMAGE_SIZE.width + 20;
    CGFloat y = 18.0;
    CGContextSetFillColorWithColor(context, blackColor.CGColor);

    NSString *str = [self.videoInfo objectForKey:@"title"];
    drawRect = CGRectMake(x, y, rect.size.width - x - 12, rect.size.height - 10);
    [str drawInRect:CGRectIntegral(drawRect) withFont:[UIFont systemFontOfSize:12] 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];


    x = VIDEO_THUMBNAIL_IMAGE_SIZE.width + 30;
    y = VIDEO_THUMBNAIL_IMAGE_SIZE.height - 5;

    // first retrieve
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];

    NSDate *date;
    NSError *error;
    if (![formatter getObjectValue:&date forString:[self.videoInfo objectForKey:@"first_retrieve"] range:nil error:&error]) {
      LOG(@"Date '%@' could not be parsed: %@", [self.videoInfo objectForKey:@"first_retrieve"], error);
    }


    CGContextSetFillColorWithColor(context, darkGrayColor.CGColor);
    str = [NSString stringWithFormat:@"%@ に投稿",
      [[UtilEx sharedInstance] twDateString:date shortFormat:NO]];
    drawRect = CGRectMake(x, y, rect.size.width - x - 13, 10);
    [str drawInRect:CGRectIntegral(drawRect) withFont:[UIFont systemFontOfSize:11] 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];

    // center border
//    CGContextSetLineWidth(context, 0.5);
//    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
//    CGFloat x = VIDEO_THUMBNAIL_IMAGE_SIZE.width;
//    CGFloat popPos = VIDEO_THUMBNAIL_IMAGE_SIZE.height - 20;
//    CGFloat popHeight = 6.0, popWidth = 4.0;
//    CGContextMoveToPoint(context, x, 5);
//    CGContextAddLineToPoint(context, x, popPos);
//    CGContextAddLineToPoint(context, x - popWidth, popPos + popHeight / 2);
//    CGContextAddLineToPoint(context, x, popPos + popHeight);
//    CGContextAddLineToPoint(context, x, rect.size.height - 5);
//    CGContextStrokePath(context);
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    return 120.0;
}


- (void)setupVideoInfo:(NSDictionary*)videoDetail {
    self.videoInfo = videoDetail;

    BOOL isFavorite = [[DataHelper sharedInstance] isFavoriteWithVideoId:[self.videoInfo objectForKey:@"video_id"]];
    NSString *thumbnailUrl = [self.videoInfo objectForKey:@"thumbnail_url"];
    [[CacheManager sharedCache] cacheImageWithUrl:thumbnailUrl block:^(UIImage *image) {
      if (image) {
        [videoThumb_ setImage:image videoLength:[self.videoInfo objectForKey:@"length"] star:isFavorite];
      }
      else {
        [[CacheManager sharedCache] downloadImage:thumbnailUrl block:^(UIImage *image) {
          [videoThumb_ setImage:image videoLength:[self.videoInfo objectForKey:@"length"] star:isFavorite];
        }];
      }
    }];
}

@end
