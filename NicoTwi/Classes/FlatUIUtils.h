//
//  FlatUIUtils.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  FlatUIBorderNone    = 0,
  FlatUIBorderTop     = 1,
  FlatUIBorderBottom  = 2,
  FlatUIBorderLeft    = 4,
  FlatUIBorderRight   = 8,
  FlatUIBorderAll = FlatUIBorderTop | FlatUIBorderBottom | FlatUIBorderLeft | FlatUIBorderRight
};

@interface FlatUIUtils : NSObject {
    UIColor *textColor, *borderColor, *highlightedColor, *backgroundColor;
}

@property (strong, nonatomic) UIColor *textColor, *borderColor, *highlightedColor, *backgroundColor;


+ (FlatUIUtils*)sharedInstance;

- (UIImage*)createRoundedBackgroundImage:(CGRect)rect withColor:(UIColor*)color borderStyle:(NSInteger)border borderColor:(UIColor*)bColor;
- (UIImage*)createBackgroundImage:(CGFloat)height withColor:(UIColor*)color borderStyle:(NSInteger)border borderColor:(UIColor*)bColor;
- (NSArray*)menuBarButtonItem:(UIImage*)image;
- (UIBarButtonItem*)customBarButtonItem:(UIImage*)image withColor:(UIColor*)color target:(id)target action:(SEL)action;
- (UIBarButtonItem*)textBarButtonItem:(NSString*)text target:(id)target action:(SEL)action;
- (UIBarButtonItem*)textBarButtonItem:(NSString*)text backgroundColor:(UIColor*)color target:(id)target action:(SEL)action;

- (UIButton*)flatButton:(NSString*)text target:(id)target action:(SEL)action;

@end
