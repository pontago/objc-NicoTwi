//
//  WebBrowserViewController.h
//  TVJikkyoNow
//
//  Created by Pontago on 12/07/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *requestUrl;

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIBarButtonItem *backBarButtonItem, *forwardBarButtonItem, 
  *loadBarButtonItem, *indicatorBarButtonItem;

- (void)doLoad:(id)sender;

@end
