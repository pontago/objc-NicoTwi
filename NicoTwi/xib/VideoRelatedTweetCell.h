//
//  VideoRelatedTweetCell.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/17.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoRelatedTweetCell : UITableViewCell

@property (strong, nonatomic) TwitterView *twitterView;

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth;

@end
