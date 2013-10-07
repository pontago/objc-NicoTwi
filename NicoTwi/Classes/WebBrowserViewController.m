//
//  WebBrowserViewController.m
//  TVJikkyoNow
//
//  Created by Pontago on 12/07/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebBrowserViewController.h"

@interface WebBrowserViewController () {
    UIImage *reloadImage_, *cancelImage_;
    NSString *webTitle_;
}

- (void)doClose_:(id)sender;

@end

@implementation WebBrowserViewController

@synthesize requestUrl;
@synthesize webView, toolbar;
@synthesize backBarButtonItem, forwardBarButtonItem, loadBarButtonItem, indicatorBarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"ブラウザ"];

    // Navigation Button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ICON_CLOSE]
      style:UIBarButtonItemStylePlain target:self action:@selector(doClose_:)];


    UIColor *color = HEXCOLOR(BAR_TEXT_COLOR);
    reloadImage_ = [[UIImage imageNamed:@"reload" withColor:color] imageByShrinkingWithSize:CGSizeMake(20, 20)];
    cancelImage_ = [[UIImage imageNamed:@"cancel" withColor:color] imageByShrinkingWithSize:CGSizeMake(20, 20)];

    webTitle_ = nil;

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 
      self.view.frame.size.width, self.view.frame.size.height - 44.0)];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.webView];
    [self.webView sizeToFit];

    self.toolbar = [[UIToolbar alloc] 
      initWithFrame:CGRectMake(0, self.view.frame.size.height - 44.0, self.view.frame.size.width, 44.0)];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;


    self.backBarButtonItem = [[FlatUIUtils sharedInstance] customBarButtonItem:
        [[UIImage imageNamed:@"arrow_left" withColor:color] imageByShrinkingWithSize:CGSizeMake(22, 22)]
      withColor:color target:self.webView action:@selector(goBack)];
    self.backBarButtonItem.enabled = NO;
    self.forwardBarButtonItem = [[FlatUIUtils sharedInstance] customBarButtonItem:
        [[UIImage imageNamed:@"arrow_right" withColor:color] imageByShrinkingWithSize:CGSizeMake(22, 22)]
      withColor:color target:self.webView action:@selector(goForward)];
    self.forwardBarButtonItem.enabled = NO;
    self.loadBarButtonItem = [[FlatUIUtils sharedInstance] customBarButtonItem:reloadImage_
      withColor:color target:self action:@selector(doLoad:)];
    UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpaceButton = [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceButton.width = 20.0;

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    self.indicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];

    [self.toolbar setItems:[NSArray arrayWithObjects:fixedSpaceButton, self.backBarButtonItem, 
      fixedSpaceButton, self.forwardBarButtonItem, fixedSpaceButton, self.loadBarButtonItem, 
      flexibleSpaceButton, self.indicatorBarButtonItem, fixedSpaceButton, nil]];
    [self.view addSubview:self.toolbar];


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


- (void)webViewDidStartLoad:(UIWebView*)webView {
    self.indicatorBarButtonItem.customView.hidden = NO;

    UIButton *button = (UIButton*)self.loadBarButtonItem.customView;
    [button setImage:cancelImage_ forState:UIControlStateNormal];
    [button setImage:cancelImage_ forState:UIControlStateHighlighted];

    webTitle_ = nil;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    self.indicatorBarButtonItem.customView.hidden = YES;

    UIButton *button = (UIButton*)self.loadBarButtonItem.customView;
    [button setImage:reloadImage_ forState:UIControlStateNormal];
    [button setImage:reloadImage_ forState:UIControlStateHighlighted];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    self.indicatorBarButtonItem.customView.hidden = YES;

    self.backBarButtonItem.enabled = self.webView.canGoBack;
    self.forwardBarButtonItem.enabled = self.webView.canGoForward;

    UIButton *button = (UIButton*)self.loadBarButtonItem.customView;
    [button setImage:reloadImage_ forState:UIControlStateNormal];
    [button setImage:reloadImage_ forState:UIControlStateHighlighted];

    if (!webTitle_) {
      webTitle_ = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
      [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:webTitle_];
    }
}


- (void)doLoad:(id)sender {
    if (self.webView.loading) {
      [self.webView stopLoading];
    }
    else {
      [self.webView reload];
    }
}

- (void)doClose_:(id)sender {
    [self dismissViewControllerAnimated:YES];
}

@end
