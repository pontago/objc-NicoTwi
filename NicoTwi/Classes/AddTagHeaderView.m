//
//  AddTagHeaderView.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/25.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "AddTagHeaderView.h"

NSUInteger const MAX_CLIP = 5;

@interface AddTagHeaderView ()

- (void)doCancel_;

@end

@implementation AddTagHeaderView

@synthesize textField, cancelButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor whiteColor];

      NSString *str = @"キャンセル";
      self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
      self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
      self.cancelButton.titleLabel.userInteractionEnabled = NO;
      self.cancelButton.hidden = YES;

      CGSize size = [str sizeWithFont:self.cancelButton.titleLabel.font];
      CGFloat w = size.width + 22.0f;
      self.cancelButton.frame = CGRectMake(frame.size.width - w - 4.0f, 4.0f, w, 32.0f);

      UIImage *backgroundImage = [[FlatUIUtils sharedInstance] createRoundedBackgroundImage:cancelButton.bounds 
        withColor:[FlatUIUtils sharedInstance].backgroundColor 
        borderStyle:FlatUIBorderAll borderColor:[FlatUIUtils sharedInstance].borderColor];
      UIImage *backgroundImage2 = [[FlatUIUtils sharedInstance] createRoundedBackgroundImage:cancelButton.bounds 
        withColor:[FlatUIUtils sharedInstance].highlightedColor
        borderStyle:FlatUIBorderAll borderColor:[FlatUIUtils sharedInstance].borderColor];

      [self.cancelButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
      [self.cancelButton setBackgroundImage:backgroundImage2 forState:UIControlStateHighlighted];
      [self.cancelButton addTarget:self action:@selector(doCancel_) forControlEvents:UIControlEventTouchUpInside];
      [self.cancelButton setTitleColor:[FlatUIUtils sharedInstance].textColor forState:UIControlStateNormal];
      [self.cancelButton setTitle:str forState:UIControlStateNormal];
      [self addSubview:self.cancelButton];


      CGRect frame;
      if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        frame = CGRectMake(5.0f, 0.0f, self.bounds.size.width - 5.0f, 40.0f);
      }
      else {
        frame = CGRectMake(5.0f, 10.0f, self.bounds.size.width - 5.0f, 40.0f);
      }
      self.textField = [[UITextField alloc] initWithFrame:frame];
      self.textField.placeholder = @"登録するタグを入力";
      self.textField.returnKeyType = UIReturnKeyDone;
      self.textField.textColor = HEXCOLOR(BAR_TEXT_COLOR);
      self.textField.font = [UIFont systemFontOfSize:15];
      self.textField.delegate = self;
      [self addSubview:self.textField];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *color = HEXCOLOR(0x999999);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);

    // Border
    CGContextMoveToPoint(context, 0, rect.size.height - 1.0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - 1.0);
    CGContextStrokePath(context);
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGRect frame = self.textField.frame;
    CGFloat w = self.cancelButton.bounds.size.width;

    frame.size.width = self.bounds.size.width - w - 10.0f;
    self.textField.frame = frame;
    self.cancelButton.hidden = NO;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    CGRect frame = self.textField.frame;
    frame.size.width = self.bounds.size.width - 5.0f;
    self.textField.frame = frame;
    self.cancelButton.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [[DataHelper sharedInstance] addClip:self.textField.text checkLimit:YES];

    self.textField.text = @"";
    [self.textField resignFirstResponder];

    return YES;
}

- (void)doCancel_ {
    self.textField.text = @"";
    [self.textField resignFirstResponder];
}

@end
