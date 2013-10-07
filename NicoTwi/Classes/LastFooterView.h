//
//  LastFooterView.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/23.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastFooterView : UIView

@property (strong, nonatomic) UILabel *titleLabel;

- (void)loading;
- (void)last;
- (void)last:(BOOL)hidden;

@end
