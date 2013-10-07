//
//  LoadingBar.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/10.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const LOADING_BAR_HEIGHT;

@interface LoadingBar : UIView

@property (strong, nonatomic) UILabel *loadingLabel;
@property (unsafe_unretained, nonatomic) CGFloat delay;
@property (unsafe_unretained, nonatomic) CGPoint offset;

+ (LoadingBar*)sharedInstance; 
- (void)popLoadingBar;
- (void)pushLoadingBar:(UIView*)view;
- (void)pushLoadingBar:(UIView*)view delay:(CGFloat)delayPop offset:(CGPoint)offsetPush;

@end
