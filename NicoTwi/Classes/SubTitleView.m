//
//  SubTitleView.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/14.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "SubTitleView.h"

@implementation SubTitleView

@synthesize titleLabel, subTitleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-105, 0, 210, 44)];
      self.titleLabel.backgroundColor = [UIColor clearColor];
      self.titleLabel.textColor = HEXCOLOR(BAR_TEXT_COLOR);
      self.titleLabel.numberOfLines = 1;
      self.titleLabel.textAlignment = UITextAlignmentCenter;
      self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
      self.titleLabel.font = [UIFont systemFontOfSize:17];
      [self addSubview:self.titleLabel];

      self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-105, 22, 210, 22)];
      self.subTitleLabel.backgroundColor = [UIColor clearColor];
      self.subTitleLabel.textColor = [UIColor darkGrayColor];
      self.subTitleLabel.numberOfLines = 1;
      self.subTitleLabel.textAlignment = UITextAlignmentCenter;
      self.subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
      self.subTitleLabel.font = [UIFont systemFontOfSize:13];
      self.subTitleLabel.hidden = YES;
      [self addSubview:self.subTitleLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setTitleAndSubTitle:(NSString*)title subtitle:(NSString*)subtitle {
    self.titleLabel.text = title;
    self.subTitleLabel.text = subtitle;

    if (subtitle && [subtitle length] > 0) {
      self.subTitleLabel.alpha = 0.0;
      self.subTitleLabel.hidden = NO;

      [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          self.subTitleLabel.alpha = 1.0;
          CGRect frame = self.titleLabel.frame;
          frame.origin.y = 3;
          frame.size.height = 22;
          self.titleLabel.frame = frame;
        }
        completion:^(BOOL finished){
        }];
    }
}

@end
