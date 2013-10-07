//
//  AdBannerViewController.h
//  TVJikkyoNow
//
//  Created by Pontago on 2012/10/02.
//
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
//#import "GADBannerView.h"
#import "NADView.h"

extern CGFloat const AD_BANNER_HEIGHT;
extern NSInteger const TAG_AD_BANNER;

@protocol AdBannerDelegate <NSObject>

- (void)didLoadAdBanner:(UIView*)adView;
- (void)didFailAdBanner:(UIView*)adView;

@end

@interface AdBannerViewController : UIViewController <ADBannerViewDelegate, /*GADBannerViewDelegate,*/ NADViewDelegate>

@property (unsafe_unretained, nonatomic) id<AdBannerDelegate> delegate;
@property (unsafe_unretained, nonatomic) BOOL isAdBanner;
@property (unsafe_unretained, nonatomic) BOOL isFullScreen;
@property (strong, nonatomic) UIViewController *rootViewController;

- (void)showAdBanner;
- (void)removeAdBanner;

@end
