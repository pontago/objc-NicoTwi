//
//  AddOnCell.m
//  TVJikkyoNow
//
//  Created by Pontago on 2012/12/03.
//
//

#import "AddOnCell.h"

@implementation AddOnCell

@synthesize priceLabel, titleLabel, descriptionTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
