//
//  AdBannerViewController.m
//  TVJikkyoNow
//
//  Created by Pontago on 2012/10/02.
//
//

#import "AdBannerViewController.h"

NSString * const ADMOB_UNIT_ID      = @"a1506b0d8ac8f57";
NSString * const NEND_API_KEY_DEBUG = @"a6eca9dd074372c898dd1df549301f277c53f2b9";
NSString * const NEND_SPOT_ID_DEBUG = @"3172";
NSString * const NEND_API_KEY       = @"a6eca9dd074372c898dd1df549301f277c53f2b9";
NSString * const NEND_SPOT_ID       = @"3172";

CGFloat const AD_BANNER_HEIGHT        = 50.0f;
NSInteger const TAG_AD_BANNER         = 111;
//NSTimeInterval const AD_SHOW_PERIOD   = 604800.0f;
NSTimeInterval const AD_SHOW_PERIOD   = 0.0f;

@interface AdBannerViewController () {
    ADBannerView *adBannerView_;
//    GADBannerView *gAdBannerView_;
    NADView *nadBannerView_;

    CGRect oldFrame_, oldRootViewFrame_;
    CGSize statusBarSize_;
}

- (void)createAdBannerView;
//- (void)createAdMobBannerView;
- (void)createNadBannerView;
- (void)setFullScreen:(BOOL)fullscreen;

@end

@implementation AdBannerViewController

@synthesize delegate;
@synthesize isAdBanner, isFullScreen;
@synthesize rootViewController;

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
	// Do any additional setup after loading the view.

    self.view.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;

    self.isAdBanner = NO;
    self.isFullScreen = NO;
    self.view.tag = TAG_AD_BANNER;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeAdBanner];
}


- (void)showAdBanner {
    [self removeAdBanner];

    NSDate *initDate = [[UserConfig sharedInstance] getConfig:@"INIT_DATE"];
    NSDate *nowDate = [NSDate date];
    if ([nowDate compare:[initDate dateByAddingTimeInterval:AD_SHOW_PERIOD]] == NSOrderedDescending) {
      NSNumber *addOnAdBannerHidden = [[UserConfig sharedInstance] getConfig:@"ADDON_ADBANNER_HIDDEN"];
      if (![addOnAdBannerHidden boolValue]) {
//    [self createAdBannerView];
//    [self createAdMobBannerView];
        [self createNadBannerView];
      }
    }
}

- (void)removeAdBanner {
    [adBannerView_ removeFromSuperview];
    adBannerView_.delegate = nil;
    adBannerView_ = nil;

//    [gAdBannerView_ removeFromSuperview];
//    gAdBannerView_.delegate = nil;
//    gAdBannerView_ = nil;

    [nadBannerView_ removeFromSuperview];
    nadBannerView_.delegate = nil;
    nadBannerView_ = nil;

    self.isAdBanner = NO;
}

- (void)createAdBannerView {
    adBannerView_ = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adBannerView_.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    adBannerView_.delegate = self;
    adBannerView_.hidden = YES;
    [self.view addSubview:adBannerView_];
}

//- (void)createAdMobBannerView {
//    gAdBannerView_ = [[GADBannerView alloc] initWithFrame:
//      CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
//    gAdBannerView_.adUnitID = ADMOB_UNIT_ID;
//    gAdBannerView_.rootViewController = self.rootViewController;
//    gAdBannerView_.delegate = self;
//    gAdBannerView_.hidden = YES;
//    [self.view addSubview:gAdBannerView_];
//
//    GADRequest *request = [GADRequest request];
//#ifdef DEBUG
//    request.testing = YES;
//#endif
//    [gAdBannerView_ loadRequest:request];
//}

- (void)createNadBannerView {
    nadBannerView_ = [[NADView alloc] initWithFrame:
      CGRectMake(0, 0, NAD_ADVIEW_SIZE_320x50.width, NAD_ADVIEW_SIZE_320x50.height)];
    nadBannerView_.delegate = self;
    nadBannerView_.hidden = YES;

#ifdef DEBUG
    [nadBannerView_ setNendID:NEND_API_KEY_DEBUG spotID:NEND_SPOT_ID_DEBUG];
#else
    [nadBannerView_ setNendID:NEND_API_KEY spotID:NEND_SPOT_ID];
#endif

    [self.view addSubview:nadBannerView_];
    [nadBannerView_ load];
}


- (void)setFullScreen:(BOOL)fullscreen {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];

    if (fullscreen) {
      CGRect rect = window.rootViewController.view.frame;
      oldRootViewFrame_ = rect;
      statusBarSize_ = [UIApplication sharedApplication].statusBarFrame.size;

      rect.origin.y = 0;
      rect.size.height += statusBarSize_.height;
      window.rootViewController.view.frame = rect;
    }
    else {
      CGRect rect = self.rootViewController.view.frame;
      rect.size.height = oldRootViewFrame_.size.height;
      self.rootViewController.view.frame = rect;

      window.rootViewController.view.frame = oldRootViewFrame_;
    }
}


- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    self.isAdBanner = YES;

    adBannerView_.bounds = CGRectMake(0, 0, banner.bounds.size.width, banner.bounds.size.height);
    adBannerView_.hidden = NO;

    [self.delegate didLoadAdBanner:banner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    LOG(@"iad error - %@", error);

    [self.delegate didFailAdBanner:banner];

//    dispatch_async(dispatch_get_main_queue(), ^{
//      [self createAdMobBannerView];
//    });
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    oldFrame_ = self.view.frame;
    self.view.hidden = YES;
    self.isFullScreen = YES;

    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGRect rect = window.rootViewController.view.frame;
    statusBarSize_ = [UIApplication sharedApplication].statusBarFrame.size;
    rect.origin.y = 0;
    window.rootViewController.view.frame = rect;

    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    self.view.frame = oldFrame_;
    self.view.hidden = NO;
    self.isFullScreen = NO;

    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGRect rect = window.rootViewController.view.frame;
    rect.origin.y = statusBarSize_.height;
    window.rootViewController.view.frame = rect;
}


//- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
//    self.isAdBanner = YES;
//
//    gAdBannerView_.hidden = NO;
//
//    [self.delegate didLoadAdBanner:bannerView];
//}
//
//- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
//    LOG(@"admob error - %@", error);
//
//    [self.delegate didFailAdBanner:bannerView];
//}


- (void)nadViewDidFinishLoad:(NADView *)adView {
}

- (void)nadViewDidReceiveAd:(NADView *)adView {
    self.isAdBanner = YES;
    nadBannerView_.hidden = NO;

    [self.delegate didLoadAdBanner:adView];
}

- (void)nadViewDidFailToReceiveAd:(NADView *)adView {
    LOG(@"nend error");

//    [self.delegate didFailAdBanner:adView];

    dispatch_async(dispatch_get_main_queue(), ^{
      [self createAdBannerView];
    });
}


//- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
//    self.isFullScreen = YES;
//    [self setFullScreen:YES];
//}
//
//- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
//    [self setFullScreen:NO];
//}
//
//- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
//    self.isFullScreen = NO;
//}

@end
