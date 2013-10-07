//
//  VideoTagCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/17.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "VideoTagCell.h"

NSString* const TAG_DELIMITER = @"   ";

@interface VideoTagCell () {
    UIWebView *webView_;
}

@end

@implementation VideoTagCell

@synthesize videoTags;
@synthesize viewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      self.backgroundColor = [UIColor clearColor];

      webView_ = [[UIWebView alloc] initWithFrame:CGRectZero];
      webView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      webView_.delegate = self;
      webView_.dataDetectorTypes = UIDataDetectorTypeNone;
      webView_.backgroundColor = [UIColor clearColor];
      webView_.opaque = NO;
      webView_.scrollView.scrollsToTop = NO;
      webView_.scrollView.scrollEnabled = NO;
      [self addSubview:webView_];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    self.viewController = nil;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *borderColor = HEXCOLOR(BORDER_COLOR);
    UIColor *whiteColor = [UIColor whiteColor];

    // view border
    CGContextSetLineWidth(context, 0.5f);
    CGContextSetFillColorWithColor(context, borderColor.CGColor);

    CGRect drawRect = CGRectMake(5.0f, 5.0f, rect.size.width - 10.0f, rect.size.height - 10.0f);
    CGContextFillRect(context, drawRect);

    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    drawRect = CGRectMake(5.5f, 5.5f, drawRect.size.width - 1.0f, drawRect.size.height - 1.0f);
    CGContextFillRect(context, drawRect);


    // tag label
    CGFloat x = 15.0f;
    CGFloat y = 10.0f;
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);

    NSString *str = [NSString stringWithFormat:@"%d タグ", [self.videoTags count]];
    drawRect = CGRectMake(x, y, rect.size.width - x - 10.0f, 11.0f);
    [str drawInRect:CGRectIntegral(drawRect) withFont:[UIFont systemFontOfSize:12.0f] 
      lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    NSArray *tags = object;
    NSString *strVideoTag = [tags componentsJoinedByString:TAG_DELIMITER];
    CGSize size = [strVideoTag sizeWithFont:[UIFont systemFontOfSize:12.0f]
      constrainedToSize:CGSizeMake(columnWidth - 18.0f, 2000.0f)
      lineBreakMode:NSLineBreakByWordWrapping];

    return size.height + 42.0f;
}

- (void)setupVideoTags:(NSArray*)tags {
    self.videoTags = tags; 

    webView_.frame = CGRectMake(5.0f, 20.0f, self.bounds.size.width - 10.0f, 
//      [VideoTagCell rowHeightForObject:tags inColumnWidth:self.bounds.size.width]);
      [VideoTagCell rowHeightForObject:tags inColumnWidth:self.bounds.size.width] - 25);

    NSString *body = [NSString stringWithFormat:@"%@<div style='font-family:Helvetica NeueUI;font-size:12px;word-break:break-word;white-space:pre-wrap;line-height:15px;'>%@</div>",
      WEBVIEW_CSS,
      [[UtilEx sharedInstance] replaceUrlTagFromText:tags delimiter:TAG_DELIMITER]];
    [webView_ loadHTMLString:body baseURL:nil];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
      navigationType:(UIWebViewNavigationType)navigationType {

    NSString* scheme = [[request URL] scheme];
    if ([scheme compare:@"about"] == NSOrderedSame) {
      return YES;
    }

    if ([scheme compare:@"http"] == NSOrderedSame || [scheme compare:@"https"] == NSOrderedSame) {
      NSString *tagName = [[request URL] lastPathComponent];

      NSUInteger clipCount = [[DataHelper sharedInstance] clipCount];
      if (clipCount < MAX_CLIP) {
        NSNumber *clipConfirmAdd = [[UserConfig sharedInstance] getConfig:@"CLIP_CONFIRM_ADD"];

        if ([clipConfirmAdd boolValue]) {
          [WCAlertView showAlertWithTitle:@"確認" 
            message:@"クリップに登録しますか？" 
            customizationBlock:^(WCAlertView *alertView) {
          } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
              if ([[DataHelper sharedInstance] addClip:tagName checkLimit:NO]) {
                [SVProgressHUD showSuccessWithStatus:@"登録しました"];
              }
            }
          } cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
        }
        else{
          if ([[DataHelper sharedInstance] addClip:tagName checkLimit:NO]) {
            [SVProgressHUD showSuccessWithStatus:@"登録しました"];
          }
        }
      }
      else {
        [WCAlertView showAlertWithTitle:@"確認" 
          message:@"これ以上登録できません。\nクリップ一覧を開きますか？" 
          customizationBlock:^(WCAlertView *alertView) {
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
          if (buttonIndex == 0) {
            EditClipViewController *editClipViewController = [[EditClipViewController alloc] initWithStyle:UITableViewStylePlain];

            SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
              initWithRootViewController:editClipViewController];
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

            [self.viewController presentViewController:navigationController animated:YES completion:NULL];
          }
        } cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
      }
    }

    return NO;
}

@end
