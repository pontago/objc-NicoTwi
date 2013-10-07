//
//  LastFooterView.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/23.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "LastFooterView.h"

@interface LastFooterView () {
    UIImageView *imageView_;
    UIImage *lastImage_, *loadingImage_;
}

@end

@implementation LastFooterView

@synthesize titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      self.hidden = YES;

      lastImage_ = [UIImage imageNamed:@"258-checkmark"];
      loadingImage_ = [UIImage imageNamed:@"368-code-sync"];
      imageView_ = [[UIImageView alloc] init];
      [self addSubview:imageView_];

//      self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, image.size.height, frame.size.width, 44.0f)];
      self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
      self.titleLabel.backgroundColor = [UIColor clearColor];
      self.titleLabel.textColor = HEXCOLOR(BAR_TEXT_COLOR);
      self.titleLabel.numberOfLines = 1;
      self.titleLabel.textAlignment = UITextAlignmentCenter;
      self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
      self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      [self addSubview:self.titleLabel];
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


- (void)loading {
    imageView_.image = loadingImage_;
    imageView_.frame = CGRectMake((self.frame.size.width / 2) - (loadingImage_.size.width / 2), 10.0f, 
      loadingImage_.size.width, loadingImage_.size.height);

    self.titleLabel.frame = CGRectMake(0, loadingImage_.size.height, self.frame.size.width, 44.0f);
    self.titleLabel.text = @"読み込み中";
    self.hidden = NO;
}

- (void)last {
    [self last:NO];
}

- (void)last:(BOOL)hidden {
    if (hidden == NO) {
      imageView_.image = lastImage_;
      imageView_.frame = CGRectMake((self.frame.size.width / 2) - (lastImage_.size.width / 2), 10.0f, 
        lastImage_.size.width, lastImage_.size.height);

      self.titleLabel.frame = CGRectMake(0, lastImage_.size.height, self.frame.size.width, 44.0f);
      self.titleLabel.text = @"これ以上ありません";
    }
    self.hidden = hidden;
}

@end
