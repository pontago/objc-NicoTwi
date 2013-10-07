//
//  FixedTableViewCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/25.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "FixedTableViewCell.h"

@implementation FixedTableViewCell

@synthesize imageWidth;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      imageWidth = 32.0f;
      self.imageView.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = self.imageView.frame.size.width;
    CGFloat diff;

    CGRect frame = self.imageView.frame;
    frame.size.width = self.imageWidth;
    self.imageView.frame = frame;

    if (width > self.imageWidth) {
      diff = width - self.imageWidth;

      frame = self.textLabel.frame;
      frame.origin.x -= diff;
      frame.size.width += diff;
      self.textLabel.frame = frame;

      frame = self.detailTextLabel.frame;
      frame.origin.x -= diff;
      frame.size.width += diff;
      self.detailTextLabel.frame = frame;
    }
    else {
      diff = self.imageWidth - width;

      frame = self.textLabel.frame;
      frame.origin.x += diff;
      frame.size.width -= diff;
      self.textLabel.frame = frame;

      frame = self.detailTextLabel.frame;
      frame.origin.x += diff;
      frame.size.width -= diff;
      self.detailTextLabel.frame = frame;
    }
}

@end
