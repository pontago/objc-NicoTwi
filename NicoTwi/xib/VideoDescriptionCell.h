//
//  VideoDescriptionCell.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/16.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDescriptionCell : UITableViewCell <UIWebViewDelegate>

@property (strong, nonatomic) NSString *description;

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth;
- (void)setupDescription:(NSString*)text;

@end
