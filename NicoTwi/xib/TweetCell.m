//
//  TweetCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/15.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "TweetCell.h"

CGSize const      CELL_PROFILE_IMAGE_SIZE        = {32, 32};
CGFloat const     CELL_DETAIL_DISCLOSURE_MARGIN  = 30.0f;

@interface TweetCell () {
    UIFont *fontSize9_, *fontSize10_, *fontSize11_, *fontSizeBold11_;
    UIColor *blackColor_, *darkGrayColor_, *whiteColor_, *borderColor_;
}

@end

@implementation TweetCell

@synthesize profileImageLayer, username, text, createdAt;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      self.backgroundColor = [UIColor clearColor];

      fontSize10_ = [UIFont systemFontOfSize:10];
      fontSize11_ = [UIFont systemFontOfSize:11];
      fontSizeBold11_ = [UIFont boldSystemFontOfSize:11];
      blackColor_ = [UIColor blackColor];
      darkGrayColor_ = [UIColor darkGrayColor];
      whiteColor_ = [UIColor whiteColor];

      borderColor_ = HEXCOLOR(BORDER_COLOR);

      UIColor *backgroundColor = HEXCOLOR(0xF8F7F8);
      self.profileImageLayer = [CALayer layer];
      self.profileImageLayer.backgroundColor = backgroundColor.CGColor;
      self.profileImageLayer.frame = CGRectMake(10, 10, CELL_PROFILE_IMAGE_SIZE.width, CELL_PROFILE_IMAGE_SIZE.height);
      [self.layer addSublayer:self.profileImageLayer];
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

    // border
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, borderColor_.CGColor);
    CGContextFillRect(context, CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 1));

    CGContextSetFillColorWithColor(context, whiteColor_.CGColor);
    CGContextFillRect(context, CGRectMake(5.5, 5.5, self.bounds.size.width - 11, self.bounds.size.height - 6.5));

    // user name label
    CGRect drawRect;
    CGFloat w;
    if (self.username) {
      w = self.bounds.size.width - self.profileImageLayer.bounds.size.width - 80;
      if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        w -= CELL_DETAIL_DISCLOSURE_MARGIN;
      }

      drawRect = CGRectMake(self.profileImageLayer.bounds.size.width + 15, 12, w, 11);
      CGContextSetFillColorWithColor(context, blackColor_.CGColor);
      [self.username drawInRect:drawRect withFont:fontSizeBold11_ 
        lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    }

    // time label
    if (self.createdAt) {
      CGFloat x = self.bounds.size.width - 80;
      if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        x -= CELL_DETAIL_DISCLOSURE_MARGIN;
      }

      NSString *str = [[UtilEx sharedInstance] twDateString:self.createdAt shortFormat:YES];
      drawRect = CGRectMake(x, 12, 70, 11);
      CGContextSetFillColorWithColor(context, darkGrayColor_.CGColor);
      [str drawInRect:drawRect withFont:fontSize11_ 
        lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentRight];
    }

    // text label
    if (self.text) {
      w = self.bounds.size.width - self.profileImageLayer.bounds.size.width - 25;
      if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        w -= CELL_DETAIL_DISCLOSURE_MARGIN;
      }

      drawRect = CGRectMake(self.profileImageLayer.bounds.size.width + 15, 27, w, 2000);
      CGContextSetFillColorWithColor(context, blackColor_.CGColor);
      [text drawInRect:drawRect withFont:fontSize11_ 
        lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth accessoryType:(UITableViewCellAccessoryType)accessoryType {
    CGFloat w = columnWidth - CELL_PROFILE_IMAGE_SIZE.width - 25;
    NSString *text = [object objectForKey:@"text"];

    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
      w -= CELL_DETAIL_DISCLOSURE_MARGIN;
    }
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:11]
      constrainedToSize:CGSizeMake(w, 2000)
      lineBreakMode:NSLineBreakByWordWrapping];

    CGFloat minHeight = CELL_PROFILE_IMAGE_SIZE.height + 20;
    CGFloat height = 30 + textSize.height;

    return (minHeight > height ? minHeight : height) + 5;
}

@end
