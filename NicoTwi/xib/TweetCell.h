//
//  TweetCell.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/15.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell

@property (strong, nonatomic) CALayer *profileImageLayer;
@property (strong, nonatomic) NSString *username, *text;
@property (strong, nonatomic) NSDate *createdAt;

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth accessoryType:(UITableViewCellAccessoryType)accessoryType;

@end
