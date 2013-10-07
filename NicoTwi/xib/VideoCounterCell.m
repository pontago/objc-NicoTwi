//
//  VideoCounterCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/16.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "VideoCounterCell.h"

@interface VideoCounterCell () {
//    UIImage *viewCounterImage_, *commentNumImage_, *mylistCounterImage_;
}

@end

@implementation VideoCounterCell

@synthesize videoInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      self.backgroundColor = [UIColor clearColor];

//      viewCounterImage_ = [[UIImage imageNamed:@"285-facetime"] imageByShrinkingWithSize:CGSizeMake(15, 12)];
//      commentNumImage_ = [[UIImage imageNamed:@"08-chat"] imageByShrinkingWithSize:CGSizeMake(15, 12)];
//      mylistCounterImage_ = [[UIImage imageNamed:@"180-stickynote"] imageByShrinkingWithSize:CGSizeMake(15, 12)];
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
    UIColor *darkGrayColor = [UIColor darkGrayColor];
    UIColor *countColor = HEXCOLOR(BAR_TEXT_COLOR);

    // view border
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, borderColor.CGColor);

    CGRect drawRect = CGRectMake(5, 0, rect.size.width - 10, rect.size.height - 5);
    CGContextFillRect(context, drawRect);

    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    drawRect = CGRectMake(5.5, 0.5, drawRect.size.width - 1, drawRect.size.height - 1);
    CGContextFillRect(context, drawRect);



    // view counter
    UIFont *fontSize12 = [UIFont boldSystemFontOfSize:12];
    UIFont *fontSize11 = [UIFont systemFontOfSize:11];
    CGFloat y = 7, x = 10;
    CGFloat colWidth = (rect.size.width - 20) / 3;

    CGContextSetFillColorWithColor(context, darkGrayColor.CGColor);
    drawRect = CGRectMake(x, y, colWidth, 10);
    [@"再生" drawInRect:CGRectIntegral(drawRect) withFont:fontSize11 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

    // comment num
    x += colWidth;
    drawRect = CGRectMake(x, y, colWidth, 10);
    [@"コメント" drawInRect:CGRectIntegral(drawRect) withFont:fontSize11 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

    // mylist counter
    x += colWidth;
    drawRect = CGRectMake(x, y, colWidth, 10);
    [@"マイリス" drawInRect:CGRectIntegral(drawRect) withFont:fontSize11 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];


    // view counter
    x = 10;
    y += 15;
    NSString *str = [self.videoInfo objectForKey:@"view_counter"];
    CGContextSetFillColorWithColor(context, countColor.CGColor);
    drawRect = CGRectMake(x, y, colWidth, 10);
    [str drawInRect:CGRectIntegral(drawRect) withFont:fontSize12 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

    // comment num
    x += colWidth;
    str = [self.videoInfo objectForKey:@"comment_num"];
    drawRect = CGRectMake(x, y, colWidth, 10);
    [str drawInRect:CGRectIntegral(drawRect) withFont:fontSize12 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];

    // mylist counter
    x += colWidth;
    str = [self.videoInfo objectForKey:@"mylist_counter"];
    drawRect = CGRectMake(x, y, colWidth, 10);
    [str drawInRect:CGRectIntegral(drawRect) withFont:fontSize12 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    return 47.0;
}

@end
