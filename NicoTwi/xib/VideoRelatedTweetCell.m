//
//  VideoRelatedTweetCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/17.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "VideoRelatedTweetCell.h"

@implementation VideoRelatedTweetCell

@synthesize twitterView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      self.backgroundColor = [UIColor clearColor];

      self.twitterView = [[TwitterView alloc] initWithFrame:CGRectZero];
      self.userInteractionEnabled = NO;
      self.twitterView.rowProfileImageCount = 12;
      [self addSubview:self.twitterView];
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

    // view border
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, borderColor.CGColor);

    CGRect drawRect = CGRectMake(5, 0, rect.size.width - 10, rect.size.height - 6);
    CGContextFillRect(context, drawRect);

    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    drawRect = CGRectMake(5.5, 0.5, drawRect.size.width - 1, drawRect.size.height - 1);
    CGContextFillRect(context, drawRect);


    // label
    CGFloat x = 15.0f;
    CGFloat y = 5.0f;
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);

    NSInteger tweetCount = [[self.twitterView.tweetInfo objectForKey:@"tweet_count"] intValue];
    NSString *str = [NSString stringWithFormat:@"%d ツイート", tweetCount];
    drawRect = CGRectMake(x, y, rect.size.width - x - 10.0f, 12.0f);
    [str drawInRect:CGRectIntegral(drawRect) withFont:[UIFont systemFontOfSize:12.0f] 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = CGRectMake(15.0f, 16.0f, self.bounds.size.width, self.bounds.size.height);
    self.twitterView.frame = CGRectIntegral(frame);
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat twitterHeight = 15.0;
    NSDictionary *tweet = [object objectForKey:@"tweet"];
    if (tweet) {
      NSArray *tweetList = [tweet objectForKey:@"list"];
      twitterHeight = [TwitterView heightForObject:tweetList rowImageCount:12];
    }

    return twitterHeight + 25.0f;
}

@end
