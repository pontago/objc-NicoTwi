//
//  LoadingBar.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/10.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "LoadingBar.h"

CGFloat const LOADING_BAR_HEIGHT = 20.0;

@implementation LoadingBar

@synthesize loadingLabel, delay, offset;

static LoadingBar *sharedLoadingBar = nil;

+ (LoadingBar*)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedLoadingBar = [[LoadingBar alloc] initWithFrame:CGRectZero];
    });
    return sharedLoadingBar;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.delay = 0.3;
      self.offset = CGPointZero;

      self.backgroundColor = HEXCOLOR(0x00BFBC);

      self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      self.loadingLabel.backgroundColor = [UIColor clearColor];
      self.loadingLabel.font = [UIFont boldSystemFontOfSize:12];
      self.loadingLabel.textColor = [UIColor whiteColor];
      self.loadingLabel.textAlignment = UITextAlignmentCenter;
      self.loadingLabel.text = @"読み込み中...";
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

- (void)popLoadingBar {
    self.alpha = 1.0;

    [UIView animateWithDuration:0.4 delay:self.delay
      options:UIViewAnimationOptionCurveEaseInOut
      animations:^{
        CGRect frame = self.superview.frame;
        frame = self.frame;
        frame.origin.y += LOADING_BAR_HEIGHT;
        self.frame = frame;
        self.alpha = 0.0;
      } completion:^(BOOL finished) {
        [self removeFromSuperview];
      }];
}

- (void)pushLoadingBar:(UIView*)view {
    [self pushLoadingBar:view delay:0.3 offset:CGPointZero];
}

- (void)pushLoadingBar:(UIView*)view delay:(CGFloat)delayPop offset:(CGPoint)offsetPush {
    self.delay = delayPop;
    self.offset = offsetPush;

    [view addSubview:self];
}

- (void)didMoveToSuperview {
    __block CGRect frame = self.superview.frame;

    CGRect rect = CGRectMake(0, frame.size.height, frame.size.width, LOADING_BAR_HEIGHT);
    if (self.offset.y > 0.0f) {
      rect.origin.y = self.offset.y;
    }
    self.frame = rect;
    self.alpha = 0.0;

    self.loadingLabel.frame = CGRectMake(0, 0, frame.size.width, LOADING_BAR_HEIGHT);

    [UIView animateWithDuration:0.3 delay:0.0
      options:UIViewAnimationOptionCurveEaseInOut
      animations:^{
        self.frame = CGRectMake(0, rect.origin.y - LOADING_BAR_HEIGHT, frame.size.width, LOADING_BAR_HEIGHT);
        self.alpha = 1.0;
      } completion:^(BOOL finished) {
        [self popLoadingBar];
      }];
}

@end
