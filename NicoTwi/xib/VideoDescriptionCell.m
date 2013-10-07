//
//  VideoDescriptionCell.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/16.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "VideoDescriptionCell.h"

@interface VideoDescriptionCell () {
    UIWebView *webView_;
}

@end

@implementation VideoDescriptionCell

@synthesize description;

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

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *borderColor = HEXCOLOR(BORDER_COLOR);
    UIColor *whiteColor = [UIColor whiteColor];

    // view border
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, borderColor.CGColor);

    CGRect drawRect = CGRectMake(5, 0, rect.size.width - 10, rect.size.height - 1);
    CGContextFillRect(context, drawRect);

    CGContextSetFillColorWithColor(context, whiteColor.CGColor);
    drawRect = CGRectMake(5.5, 0.5, drawRect.size.width - 1, drawRect.size.height - 1);
    CGContextFillRect(context, drawRect);
}

+ (CGFloat)rowHeightForObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    NSString *description = object;
    CGSize size = [description sizeWithFont:[UIFont systemFontOfSize:12]
      constrainedToSize:CGSizeMake(columnWidth - 25, 2000)
      lineBreakMode:NSLineBreakByCharWrapping];

    return size.height + 20;
}


- (void)setupDescription:(NSString*)text {
    self.description = text;

    webView_.frame = CGRectMake(5, 0, 
      self.bounds.size.width - 10, [VideoDescriptionCell rowHeightForObject:text inColumnWidth:self.bounds.size.width]);

    NSString *body = [NSString stringWithFormat:@"%@<div style='font-family:Helvetica NeueUI;font-size:12px;word-break:break-all;white-space:pre-wrap;line-height:15px;'>%@</div>",
      WEBVIEW_CSS,
      [[UtilEx sharedInstance] replaceUrlAndMovieIdFromText:text]];
    [webView_ loadHTMLString:body baseURL:nil];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
      navigationType:(UIWebViewNavigationType)navigationType {

    NSString* scheme = [[request URL] scheme];
    if ([scheme compare:@"about"] == NSOrderedSame) {
      return YES;
    }
    if ([scheme compare:@"http"] == NSOrderedSame || [scheme compare:@"https"] == NSOrderedSame) {
      [[UtilEx sharedInstance] openNicoUrl:[request URL]];
    }

    return NO;
}

@end
