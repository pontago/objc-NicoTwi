//
//  TermsViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/07/11.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "TermsViewController.h"

NSString * const URL_TERMS = @"http://www.nicotwi.com/pages/terms";
//NSString * const URL_TERMS = @"http://localhost:3000/pages/terms";

@interface TermsViewController ()

- (void)doAgree_:(id)sender;
- (void)doDisagree_:(id)sender;

@end

@implementation TermsViewController

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

    self.view.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"同意の確認"];


    UIWebView *webView = [[UIWebView alloc] initWithFrame:
      CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100.0f)];
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL_TERMS]];
    [webView loadRequest:request];


    UIButton *agreeButton = [[FlatUIUtils sharedInstance] flatButton:@" 同意する " 
      target:self action:@selector(doAgree_:)];
    CGRect frame = agreeButton.frame;
    frame.origin.x = 60.0f;
    frame.origin.y = self.view.frame.size.height - 90.0f;
    agreeButton.frame = frame;
    [self.view addSubview:agreeButton];

    UIButton *disagreeButton = [[FlatUIUtils sharedInstance] flatButton:@"同意しない" 
      target:self action:@selector(doDisagree_:)];
    frame = disagreeButton.frame;
    frame.origin.x = self.view.frame.size.width - frame.size.width - 60.0f;
    frame.origin.y = self.view.frame.size.height - 90.0f;
    disagreeButton.frame = frame;
    [self.view addSubview:disagreeButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
      navigationType:(UIWebViewNavigationType)navigationType {

    NSString* scheme = [[request URL] scheme];
    if ([scheme compare:@"about"] == NSOrderedSame) {
      return YES;
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
      if ([scheme compare:@"http"] == NSOrderedSame || [scheme compare:@"https"] == NSOrderedSame) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
      }
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)doAgree_:(id)sender {
    [[UserConfig sharedInstance] saveConfig:@"CHECK_TERMS" value:@YES];

    [self dismissViewControllerAnimated:YES];
}

- (void)doDisagree_:(id)sender {
    [WCAlertView showAlertWithTitle:@"同意の確認" 
      message:@"同意できない場合、本アプリを利用することはできません。" 
      customizationBlock:^(WCAlertView *alertView) {
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
    } cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
}

@end
