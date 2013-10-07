//
//  RelatedVideoCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/18.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "RelatedVideoCell.h"

@interface RelatedVideoCell () {
}

@end

@implementation RelatedVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    return 0.0f;
}

@end
