//
//  AppDelegate.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

NSString* const URL_SCHEME      = @"nicotwi";
NSString* const URL_SCHEME_URL  = @"url";

NSUInteger const ALERT_REVIEW_COUNT   = 10;

@interface AppDelegate ()

- (void)setControlStyles_;
- (void)showReviewAlert_;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = HEXCOLOR(0xEDEDED);

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
      self.window.clipsToBounds = YES;
      self.window.frame = CGRectMake(0, 20.0f, self.window.frame.size.width, self.window.frame.size.height - 20.0f);
      self.window.bounds = CGRectMake(0, 20.0f, self.window.frame.size.width, self.window.frame.size.height);
    }

    // Override point for customization after application launch.

    // Initial methods
    [[UserConfig sharedInstance] createUserDefaults];
    [[UserConfig sharedInstance] updateIdleTimerDisabled];
    [self setControlStyles_];
    [NSURLProtocol registerClass:[SafeURLProtocol class]];

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];

//    [[CacheManager sharedCache] setCountLimit:30];
//    [[CacheManager sharedCache] setCountLimit:0];
//    [[CacheManager sharedCache] setTotalCostLimit:(2 * 1024 * 1024)];
//    [[CacheManager sharedCache] setTotalCostLimit:0];

    // Setup ViewControllers
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    MenuViewController *menuViewController = [[MenuViewController alloc] initWithStyle:UITableViewStylePlain];

    SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] initWithRootViewController:self.viewController];
    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:navigationController 
      leftViewController:menuViewController rightViewController:nil];
    deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    deckController.openSlideAnimationDuration = 0.25f;
    deckController.closeSlideAnimationDuration = 0.15f;
    deckController.delegateMode = IIViewDeckDelegateAndSubControllers;
    deckController.panningMode = IIViewDeckNavigationBarPanning;

    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];


    NSDate *initDate = [[UserConfig sharedInstance] getConfig:@"INIT_DATE"];
    if ([initDate isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0]]) {
      [[UserConfig sharedInstance] saveConfig:@"INIT_DATE" value:[NSDate date]];
    }
    [self showReviewAlert_];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication 
  annotation:(id)annotation {

    if ([url.scheme isEqualToString:URL_SCHEME] && [url.host isEqualToString:URL_SCHEME_URL]) {
      WebBrowserViewController *webBrowserViewController = [[WebBrowserViewController alloc] init];
      webBrowserViewController.requestUrl = [url.path substringFromIndex:1];

      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:webBrowserViewController];
      navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

      [self.window.rootViewController presentViewController:navigationController animated:YES completion:NULL];

      return YES;
    }

    return NO;
}


- (void)showMenuTableViewController {
    [(IIViewDeckController*)self.window.rootViewController toggleLeftView];
}


- (void)setControlStyles_ {
    UIColor *color = HEXCOLOR(BARCOLOR);
    UIColor *textColor = HEXCOLOR(BAR_TEXT_COLOR);
    UIColor *highlightedColor = HEXCOLOR(HIGHLIGHTED_BUTTON_COLOR);
    UIColor *borderColor = HEXCOLOR(BORDER_COLOR);

    FlatUIUtils *flatUIUtils = [FlatUIUtils sharedInstance];
    flatUIUtils.textColor = textColor;
    flatUIUtils.backgroundColor = color;
    flatUIUtils.highlightedColor = highlightedColor;
    flatUIUtils.borderColor = borderColor;


    // NavigationBar
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
      [[UINavigationBar appearance] setBackgroundImage:
          [flatUIUtils createBackgroundImage:44.0 withColor:color borderStyle:FlatUIBorderNone borderColor:borderColor] 
        forBarMetrics:UIBarMetricsDefault];
    }
    else {
      [[UINavigationBar appearance] setBarTintColor:color];
    }

    NSDictionary *barTitleTextAttributes;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0) {
      barTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: 
        [UIFont systemFontOfSize:17], UITextAttributeFont,
        [UIColor whiteColor], UITextAttributeTextShadowColor, nil];
    }
    else {
      barTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: 
        [UIFont systemFontOfSize:17], UITextAttributeFont,
        textColor, NSForegroundColorAttributeName, 
        [UIColor whiteColor], UITextAttributeTextShadowColor, nil];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:barTitleTextAttributes];
    // Toolbar 
    [[UIToolbar appearance] setBackgroundImage:
        [flatUIUtils createBackgroundImage:44.0 withColor:color borderStyle:FlatUIBorderTop borderColor:borderColor] 
      forToolbarPosition:UIToolbarPositionAny
      barMetrics:UIBarMetricsDefault];
    // BarButtonItem 
    [[UIBarButtonItem appearance] setBackgroundImage:
        [flatUIUtils createBackgroundImage:30.0 withColor:color borderStyle:FlatUIBorderNone borderColor:borderColor] 
      forState:UIControlStateNormal
      barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:
        [flatUIUtils createBackgroundImage:30.0 withColor:highlightedColor borderStyle:FlatUIBorderNone borderColor:borderColor] 
      forState:UIControlStateHighlighted
      barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:
        [flatUIUtils createBackgroundImage:30.0 withColor:color borderStyle:FlatUIBorderNone borderColor:borderColor] 
      forState:UIControlStateNormal
      barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:
        [flatUIUtils createBackgroundImage:30.0 withColor:highlightedColor borderStyle:FlatUIBorderNone borderColor:borderColor] 
      forState:UIControlStateHighlighted
      barMetrics:UIBarMetricsDefault];


    [WCAlertView setDefaultStyle:WCAlertViewStyleWhite];
    [WCAlertView setDefaultCustomiaztonBlock:^(WCAlertView *alertView) {
            alertView.labelTextColor = textColor;
            alertView.outerFrameLineWidth = 0;
            alertView.outerFrameColor = highlightedColor;
            alertView.buttonTextColor = textColor;
            alertView.buttonShadowColor = textColor;
            alertView.buttonShadowOffset = CGSizeMake(0, 0);
            alertView.buttonShadowBlur = 0;
            alertView.cornerRadius = 1.0;

            alertView.titleFont = [UIFont boldSystemFontOfSize:17];
            alertView.messageFont = [UIFont systemFontOfSize:13];
        }];
}

- (void)showReviewAlert_ {
    NSNumber *launchCount = [[UserConfig sharedInstance] getConfig:@"LAUNCH_COUNT"];
    NSInteger launchCountVal = [launchCount intValue];
    if (launchCountVal != -1) {
      [[UserConfig sharedInstance] saveConfig:@"LAUNCH_COUNT" value:[NSNumber numberWithInt:launchCountVal + 1]];
      if ((launchCountVal % ALERT_REVIEW_COUNT) == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
          [WCAlertView showAlertWithTitle:@"アプリの評価" 
            message:@"気に入っていただけましたか？\n評価レビューを書いていただけると作者のやる気も出ます。" 
            customizationBlock:^(WCAlertView *alertView) {
          } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
            if (buttonIndex == 0) {
              NSURL *url = [NSURL URLWithString:URL_APPSTORE];
              if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
              }
              [[UserConfig sharedInstance] saveConfig:@"LAUNCH_COUNT" value:[NSNumber numberWithInt:-1]];
            }
            else if (buttonIndex == 2) {
              [[UserConfig sharedInstance] saveConfig:@"LAUNCH_COUNT" value:[NSNumber numberWithInt:-1]];
            }
          } cancelButtonTitle:@"再度表示しない" otherButtonTitles:@"レビューを書く", @"またあとで", nil];
        });
      }
    }
}

@end
