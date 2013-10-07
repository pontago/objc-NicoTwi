//
//  LoadingIndicator.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/22.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "LoadingIndicator.h"

@implementation LoadingIndicator

@synthesize indicatorView, loadingLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor clearColor];

      self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      [self addSubview:self.indicatorView];

      self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      self.loadingLabel.backgroundColor = [UIColor clearColor];
      self.loadingLabel.font = [UIFont systemFontOfSize:13];
      self.loadingLabel.textColor = HEXCOLOR(BAR_TEXT_COLOR);
      self.loadingLabel.textAlignment = UITextAlignmentCenter;
      self.loadingLabel.text = @"読み込み中";
      [self addSubview:self.loadingLabel];
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

- (void)layoutSubviews {
    [super layoutSubviews];

    self.indicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 3);
    self.indicatorView.frame = CGRectIntegral(self.indicatorView.frame);

    [self.loadingLabel sizeToFit];
    self.loadingLabel.center = CGPointMake(self.frame.size.width / 2, 
      (self.frame.size.height / 3) + self.indicatorView.frame.size.height);
    self.loadingLabel.frame = CGRectIntegral(self.loadingLabel.frame);
}

- (void)didMoveToSuperview {
    [self.indicatorView startAnimating];
}

@end
