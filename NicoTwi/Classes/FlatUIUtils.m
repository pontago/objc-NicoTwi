//
//  FlatUIUtils.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "FlatUIUtils.h"

@interface FlatUIUtils () {
}

- (CGMutablePathRef)createRoundedRectForRect_:(CGRect)rect radius:(CGFloat)radius;

@end

@implementation FlatUIUtils

@synthesize textColor, borderColor, highlightedColor, backgroundColor;

static FlatUIUtils *sharedFlatUIUtils = nil;

+ (FlatUIUtils*)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedFlatUIUtils = [[FlatUIUtils alloc] init];

        sharedFlatUIUtils.textColor = [UIColor blackColor];
        sharedFlatUIUtils.borderColor = [UIColor blackColor];
        sharedFlatUIUtils.highlightedColor = [UIColor darkGrayColor];
        sharedFlatUIUtils.backgroundColor = [UIColor whiteColor];
    });
    return sharedFlatUIUtils;
}

- (CGMutablePathRef)createRoundedRectForRect_:(CGRect)rect radius:(CGFloat)radius {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), 
        CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), 
        CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), 
        CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), 
        CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    return path;
}

- (UIImage*)createRoundedBackgroundImage:(CGRect)rect withColor:(UIColor*)color borderStyle:(NSInteger)border borderColor:(UIColor*)bColor {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, bColor.CGColor);
    CGMutablePathRef path = [self createRoundedRectForRect_:rect radius:4.0f];
    CGContextAddPath(context, path);
    CGContextFillPath(context);

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGRect rect2 = rect;
    rect2.origin.x += 1.0f;
    rect2.origin.y += 1.0f;
    rect2.size.width -= 2.0f;
    rect2.size.height -= 2.0f;
    path = [self createRoundedRectForRect_:rect2 radius:4.0f];
    CGContextAddPath(context, path);
    CGContextFillPath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage*)createBackgroundImage:(CGFloat)height withColor:(UIColor*)color borderStyle:(NSInteger)border borderColor:(UIColor*)bColor {
    NSInteger width = 3;
    CGFloat top = border & FlatUIBorderTop ? 1 : 0;
    CGFloat bottom = border & FlatUIBorderBottom ? (height - top - 1) : (height - top);
    CGFloat left = border & FlatUIBorderLeft ? 1 : 0;
    CGFloat right = border & FlatUIBorderRight ? (width - left - 1) : (width - left);

    CGSize size = CGSizeMake(3, height);
    CGRect fillRect = CGRectMake(left, top, right, bottom);
    CGRect borderRect = CGRectMake(0, 0, width, height);

//    UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, bColor.CGColor);
    CGContextFillRect(context, borderRect);

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, fillRect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 1.0, 0.0, 1.0)];
}

- (NSArray*)menuBarButtonItem:(UIImage*)image {
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image 
      style:UIBarButtonItemStylePlain target:[[UIApplication sharedApplication] delegate]
      action:@selector(showMenuTableViewController)];

    UIBarButtonItem *marginButtonItem = [[UIBarButtonItem alloc] initWithCustomView:
      [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 1)]];

    return [NSArray arrayWithObjects:barButtonItem, marginButtonItem, nil];
}

- (UIBarButtonItem*)customBarButtonItem:(UIImage*)image withColor:(UIColor*)color 
  target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    button.layer.cornerRadius = 5;
//    button.clipsToBounds = YES;
    button.frame = CGRectMake(0, 0, 32.0, 32.0);
//    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);

    UIImage *backgroundImage = [self createBackgroundImage:image.size.height withColor:self.backgroundColor 
      borderStyle:FlatUIBorderNone borderColor:self.borderColor];
    UIImage *backgroundImage2 = [self createBackgroundImage:image.size.height withColor:self.highlightedColor 
      borderStyle:FlatUIBorderNone borderColor:self.borderColor];

    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImage2 forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (UIBarButtonItem*)textBarButtonItem:(NSString*)text target:(id)target action:(SEL)action {
    return [self textBarButtonItem:text backgroundColor:self.backgroundColor target:target action:action];
}

- (UIBarButtonItem*)textBarButtonItem:(NSString*)text backgroundColor:(UIColor*)color target:(id)target action:(SEL)action {
    NSInteger borderStyle = FlatUIBorderAll;
    if (![color isEqual:self.backgroundColor]) {
      borderStyle = FlatUIBorderNone;
    }

    UIButton *barButtonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    barButtonItem.titleLabel.font = [UIFont systemFontOfSize:13];
    barButtonItem.titleLabel.userInteractionEnabled = NO;

    CGSize size = [text sizeWithFont:barButtonItem.titleLabel.font];
    barButtonItem.frame = CGRectMake(0, 0, size.width + 22, 32);

    UIImage *backgroundImage = [self createRoundedBackgroundImage:barButtonItem.frame withColor:color 
      borderStyle:borderStyle borderColor:self.borderColor];
    UIImage *backgroundImage2 = [self createRoundedBackgroundImage:barButtonItem.frame withColor:self.highlightedColor
      borderStyle:borderStyle borderColor:self.borderColor];


    [barButtonItem setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [barButtonItem setBackgroundImage:backgroundImage2 forState:UIControlStateHighlighted];
    [barButtonItem addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [barButtonItem setTitleColor:self.textColor forState:UIControlStateNormal];
    [barButtonItem setTitle:text forState:UIControlStateNormal];

//    barButtonItem.layer.cornerRadius = 1;
//    barButtonItem.clipsToBounds = YES;


    return [[UIBarButtonItem alloc] initWithCustomView:barButtonItem];
}

- (UIButton*)flatButton:(NSString*)text target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.titleLabel.userInteractionEnabled = NO;

    CGSize size = [text sizeWithFont:button.titleLabel.font];
    CGFloat w = size.width + 22.0f;
    button.frame = CGRectMake(0, 0, w, 32.0f);

    UIImage *backgroundImage = [self createRoundedBackgroundImage:button.bounds 
      withColor:self.backgroundColor 
      borderStyle:FlatUIBorderAll borderColor:self.borderColor];
    UIImage *backgroundImage2 = [self createRoundedBackgroundImage:button.bounds 
      withColor:self.highlightedColor
      borderStyle:FlatUIBorderAll borderColor:self.borderColor];

    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImage2 forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];

    return button;
}

@end
