//
//  VideoTagCell.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/17.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoTagCell : UITableViewCell <UIWebViewDelegate>

@property (strong, nonatomic) NSArray *videoTags;
@property (strong, nonatomic) UIViewController *viewController;

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth;

- (void)setupVideoTags:(NSArray*)tags;

@end
