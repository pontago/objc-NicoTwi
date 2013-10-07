//
//  AddTagHeaderView.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/25.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSUInteger const MAX_CLIP;

@interface AddTagHeaderView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *cancelButton;

@end
