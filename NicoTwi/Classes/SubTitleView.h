//
//  SubTitleView.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/14.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubTitleView : UIView

@property (strong, nonatomic) UILabel *titleLabel, *subTitleLabel;

- (void)setTitleAndSubTitle:(NSString*)title subtitle:(NSString*)subtitle;

@end
