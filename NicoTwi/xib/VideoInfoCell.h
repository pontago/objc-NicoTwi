//
//  VideoInfoCell.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/16.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoInfoCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *videoInfo;

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth;
- (void)setupVideoInfo:(NSDictionary*)videoDetail;

@end
