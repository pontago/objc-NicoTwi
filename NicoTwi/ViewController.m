//
//  ViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "ViewController.h"
#import "TweetViewController.h"
#import "TermsViewController.h"

@interface ViewController () {
    PSCollectionView *collectionView_;
    NSString *lastUpdatedId_;
    NSMutableArray *items_;
    NSMutableDictionary *favorites_;
    LoadingIndicator *loadingIndicator_;
    ISRefreshControl *refreshControl_;
    ActionMenuTableViewController *actionMenuTableViewController_;
    AdBannerViewController *adBannerViewController_;

    NSDate *lastUpdatedTime_;
    NSUInteger totalCount_;
    BOOL isRequest_;
}

- (void)doWebRequest_:(NSNumber*)refreshMode;
- (void)refresh_;
- (void)reloadFavorites_;
- (void)reloadVisibleCells_;
- (void)loadViews_;

- (void)doEditClip_:(id)sender;
@end

@implementation ViewController

@synthesize tagName;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItems = [[FlatUIUtils sharedInstance] menuBarButtonItem:[UIImage imageNamed:ICON_MENU]];

    if (self.isClipMode) {
      [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"クリップ"];
      self.navigationItem.rightBarButtonItem = [[FlatUIUtils sharedInstance] textBarButtonItem:@"編集" 
        target:self action:@selector(doEditClip_:)];
    }
    else {
      [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:self.tagName];
    }


    items_ = [NSMutableArray array];
    favorites_ = [NSMutableDictionary dictionary];
    totalCount_ = 0;
    lastUpdatedTime_ = nil;
    isRequest_ = NO;

    // Add CollectionView
    collectionView_ = [[PSCollectionView alloc] initWithFrame:self.view.bounds];
    collectionView_.delegate = self;
    collectionView_.collectionViewDelegate = self;
    collectionView_.collectionViewDataSource = self;
    collectionView_.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    collectionView_.autoresizingMask = ~UIViewAutoresizingNone;
    collectionView_.numColsPortrait = 2;
    collectionView_.numColsLandscape = 3;
    collectionView_.footerView = [[LastFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.0f)];
    [self.view addSubview:collectionView_];

    // Add refresh control
    refreshControl_ = [[ISRefreshControl alloc] init];
    refreshControl_.tintColor = HEXCOLOR(BAR_TEXT_COLOR);
    [collectionView_ addSubview:refreshControl_];
    [refreshControl_ addTarget:self action:@selector(refresh_) 
      forControlEvents:UIControlEventValueChanged];

    loadingIndicator_ = [[LoadingIndicator alloc] initWithFrame:self.view.frame];


    // Check terms
    NSNumber *checkTerms = [[UserConfig sharedInstance] getConfig:@"CHECK_TERMS"];

    if (![checkTerms boolValue]) {
      TermsViewController *termsViewController = [[TermsViewController alloc] init];
      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:termsViewController];
      navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

      [self presentViewController:navigationController animated:YES completion:NULL dismissCompletion:^{
        [self loadViews_];
      }];
    }
    else {
      [self loadViews_];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
LOG(@"viewcon - dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([items_ count] > 0) {
      [self reloadFavorites_];
      [collectionView_ reloadData];
      [self reloadVisibleCells_];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!adBannerViewController_ || !adBannerViewController_.isFullScreen) {
      adBannerViewController_ = [[AdBannerViewController alloc] init];
      adBannerViewController_.view.frame = CGRectMake(0, self.navigationController.view.frame.size.height, 
        self.navigationController.view.frame.size.width, AD_BANNER_HEIGHT);
      adBannerViewController_.delegate = self;
      adBannerViewController_.rootViewController = self.navigationController;
      [self.navigationController.view addSubview:adBannerViewController_.view];
      [adBannerViewController_ showAdBanner];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (!adBannerViewController_.isFullScreen) {
      [adBannerViewController_ removeAdBanner];
      [adBannerViewController_.view removeFromSuperview];
      adBannerViewController_ = nil;
      collectionView_.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

#pragma mark - PSCollectionView delegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [MovieCell class];
}

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView {
    return [items_ count];
}

- (PSCollectionViewCell*)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index {
    MovieCell *cell = (MovieCell*)[collectionView dequeueReusableViewForClass:[MovieCell class]];

    if (cell == nil) {
      cell = [[MovieCell alloc] initWithFrame:CGRectMake(0, 0, collectionView.colWidth, 0)];
      cell.delegate = self;
      cell.twitterView.delegate = self;
    }

    NSDictionary *item = [items_ objectAtIndex:index];
    NSString *thumbnailUrl = [item objectForKey:@"thumbnail_url"];

    cell.videoInfo = item;
    cell.videoTitle = [item objectForKey:@"title"];
    cell.videoLength = [item objectForKey:@"length"];
    cell.viewCounter = [item objectForKey:@"view_counter"];
    cell.commentNum = [item objectForKey:@"comment_num"];

    NSNumber *isFavorite = [favorites_ objectForKey:[item objectForKey:@"video_id"]];
    [[CacheManager sharedCache] cacheImageWithUrl:thumbnailUrl block:^(UIImage *image) {
      if (image) {
        [cell.videoThumb setImage:image videoLength:cell.videoLength star:[isFavorite boolValue]];
      }
      else {
        [[CacheManager sharedCache] downloadImage:thumbnailUrl block:^(UIImage *image) {
          [cell showThumbnailImage:image star:[isFavorite boolValue]];
        }];
      }
    }];

    NSDictionary *tweet = [item objectForKey:@"tweet"];
    [cell.twitterView setupTwitterInfo:tweet isLazyLoad:YES];
    cell.twitterView.videoId = [item objectForKey:@"id"];
//    if (tweet) {
//      NSArray *tweetList = [tweet objectForKey:@"list"];
//      if ([tweetList count] > 0) {
//        [cell.twitterView setupTwitterInfo:tweet isLazyLoad:YES];
//        cell.twitterView.videoId = [item objectForKey:@"id"];
//      }
//    }


    if (index == ([items_ count] - 1) && isRequest_ == NO && totalCount_ > [items_ count]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doWebRequest_:@NO];
      });
    }

    [cell.twitterView setNeedsDisplay];
    [cell setNeedsDisplay];
    return cell;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index {
    NSDictionary *item = [items_ objectAtIndex:index];
    return [MovieCell rowHeightForObject:item inColumnWidth:collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index {
    NSDictionary *item = [items_ objectAtIndex:index];

    VideoDetailViewController *videoDetailViewController = [[VideoDetailViewController alloc] init];
    videoDetailViewController.videoDetail = item;

    [[CacheManager sharedCache] cancelAllRequest];

    [self.navigationController pushViewController:videoDetailViewController animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
      [self reloadVisibleCells_];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadVisibleCells_];
}


- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    collectionView_.scrollsToTop = NO;
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    collectionView_.scrollsToTop = YES;
}

- (void)twitterView:(TwitterView*)twitterView didSelect:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateEnded) {
      TweetViewController *tweetViewController = [[TweetViewController alloc] initWithStyle:UITableViewStylePlain];
      tweetViewController.videoId = twitterView.videoId;
      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:tweetViewController];
      navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
      [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

- (void)cell:(MovieCell*)cell didSelect:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateBegan) {
      NSString *videoId = [cell.videoInfo objectForKey:@"video_id"];
      NSNumber *isFavorite = [favorites_ objectForKey:videoId];
      [[DataHelper sharedInstance] toggleFavorite:cell.videoInfo];
      [favorites_ setObject:@(![isFavorite boolValue]) forKey:videoId];

      [cell.videoThumb drawStar:![isFavorite boolValue]];
    }
}

- (void)cell:(MovieCell*)cell didSwipe:(UISwipeGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded &&
        gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {

      ActionObject *actionObject = [[ActionObject alloc] initWithViewController:self];
      actionMenuTableViewController_ = [[ActionMenuTableViewController alloc] 
        initWithMenuItems:[ActionObject swipeMenu] delegate:nil];
      actionMenuTableViewController_.params = cell.videoInfo;
      actionMenuTableViewController_.actionObject = actionObject;
      [actionMenuTableViewController_ presentModalAtPoint:[gestureRecognizer locationInView:self.view]
        inView:self.view animated:YES];
    }
}

- (void)didLoadAdBanner:(UIView*)adView {
    [UIView animateWithDuration:0.3 delay:0
      options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
      animations:^{
        CGRect rect = collectionView_.frame;
        rect.size.height = self.view.frame.size.height - adView.frame.size.height;
        collectionView_.frame = rect;

        rect = adBannerViewController_.view.frame;
        rect.origin.y = self.navigationController.view.frame.size.height - adView.frame.size.height;
        adBannerViewController_.view.frame = rect;
      } completion:NULL];
}

- (void)didFailAdBanner:(UIView*)adView {
    [UIView animateWithDuration:0.3 delay:0
      options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
      animations:^{
        CGRect rect = collectionView_.frame;
        rect.size.height = self.view.frame.size.height;
        collectionView_.frame = rect;

        rect = adBannerViewController_.view.frame;
        rect.origin.y = self.navigationController.view.frame.size.height;
        adBannerViewController_.view.frame = rect;
      } completion:NULL];
}


- (void)doWebRequest_:(NSNumber*)refreshMode {
    @autoreleasepool {
      isRequest_ = YES;
      NSInteger offset = [items_ count];
      BOOL modeLoadingBar = [items_ count] > 0 ? YES : NO;
      BOOL isRefresh = [refreshMode boolValue];

      if (!isRefresh) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (modeLoadingBar) {
            [[LoadingBar sharedInstance] pushLoadingBar:self.view delay:1.0 offset:CGPointMake(0.0f, collectionView_.frame.size.height)];
            [(LastFooterView*)collectionView_.footerView loading];
          }
          else {
            [self.view addSubview:loadingIndicator_];
          }
        });
      }
      else {
        offset = 0;
      }


      if (!lastUpdatedTime_) lastUpdatedTime_ = [NSDate date];

      NSDictionary *results = @{};
      NSMutableArray *tags = [NSMutableArray array];
      if (self.isClipMode) {
        tags = (NSMutableArray*)[[DataHelper sharedInstance] clipTags];
      }
      else {
        if (self.tagName) [tags addObject:self.tagName];
      }


      if (!self.isClipMode || (self.isClipMode && [tags count] > 0)) {
        NSDictionary *params = @{ @"ts":lastUpdatedTime_, 
          @"offset":[NSNumber numberWithInt:offset], @"tags":tags };
        results = [[WebRequest sharedInstance] searchVideo:params];

        if (results) {
          NSArray *videos = [results objectForKey:@"videos"];
          totalCount_ = [[results objectForKey:@"total_count"] intValue];

          if (isRefresh) {
            @synchronized(self) {
              items_ = [NSMutableArray arrayWithArray:videos];
              favorites_ = [NSMutableDictionary dictionary];
            }
          }
          else {
            @synchronized(self) {
              [items_ addObjectsFromArray:videos];
            }
          }


          if ([videos count] > 0) {
            NSMutableArray *videoIds = [NSMutableArray array];
            for (NSDictionary *video in videos) {
              [videoIds addObject:[video objectForKey:@"video_id"]];
            }
            NSDictionary *favorites = [[DataHelper sharedInstance] favoriteVideosWithVideoIds:videoIds];
            @synchronized(self) {
              [favorites_ addEntriesFromDictionary:favorites];
            }
          }
        }
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        if (!modeLoadingBar) {
          [loadingIndicator_ removeFromSuperview];
        }

        if (results) {
          if (isRefresh) {
            [collectionView_ reloadData];
          }
          else {
            [collectionView_ reloadDataEx];
          }

          if ([items_ count] == totalCount_) {
            [(LastFooterView*)collectionView_.footerView last:(collectionView_.frame.size.height >= collectionView_.contentSize.height)];
          }

          if (offset == 0) {
            [self reloadVisibleCells_];
          }
        }
        else {
          [SVProgressHUD showErrorWithStatus:@"取得失敗"];
          collectionView_.footerView.hidden = YES;
        }

        [refreshControl_ endRefreshing];
      });

      isRequest_ = NO;
    }
}

- (void)refresh_ {
    lastUpdatedTime_ = [NSDate date];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self doWebRequest_:@YES];
    });
}

- (void)reloadFavorites_ {
    NSMutableArray *videoIds = [NSMutableArray array];
    for (NSDictionary *video in items_) {
      [videoIds addObject:[video objectForKey:@"video_id"]];
    }
    NSDictionary *favorites = [[DataHelper sharedInstance] favoriteVideosWithVideoIds:videoIds];
    @synchronized(self) {
      favorites_ = [NSMutableDictionary dictionaryWithDictionary:favorites];
    }
}

- (void)reloadVisibleCells_ {
    NSArray *visibleCells = collectionView_.currentVisibleViews;
    for (MovieCell *cell in visibleCells) {
      [cell.twitterView downloadMiniProfileImages];
    }
}

- (void)loadViews_ {
    // Check twitter account
    NSNumber *initHelp = [[UserConfig sharedInstance] getConfig:@"INIT_HELP"];

    if (![initHelp boolValue]) {
      TwAccountViewController *twAccountViewController = 
        [[TwAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];

      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:twAccountViewController];
      navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

      [self presentViewController:navigationController animated:YES completion:NULL dismissCompletion:^{
        HelpViewController *helpViewController = [[HelpViewController alloc] init];
        helpViewController.howToMode = YES;
        SubTitleNavigationController *navigationController2 = [[SubTitleNavigationController alloc] 
          initWithRootViewController:helpViewController];
        navigationController2.modalPresentationStyle = UIModalPresentationFormSheet;

        [self presentViewController:navigationController2 animated:YES completion:NULL dismissCompletion:^{
          [[UserConfig sharedInstance] saveConfig:@"INIT_HELP" value:@YES];

          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self doWebRequest_:@NO];
          });
        }];
      }];
    }
    else {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doWebRequest_:@NO];
      });
    }
}


- (void)doEditClip_:(id)sender {
    EditClipViewController *editClipViewController = [[EditClipViewController alloc] initWithStyle:UITableViewStylePlain];

    SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
      initWithRootViewController:editClipViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    NSArray *tags = [[DataHelper sharedInstance] clipTags];
    [self presentViewController:navigationController animated:YES completion:NULL dismissCompletion:^{
      NSArray *newTags = [[DataHelper sharedInstance] clipTags];

      if ([tags isEqualToArray:newTags] == NO) {
        items_ = [NSMutableArray array];
        favorites_ = [NSMutableDictionary dictionary];
        totalCount_ = 0;
        lastUpdatedTime_ = [NSDate date];
        [collectionView_ reloadData];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [self doWebRequest_:@NO];
        });
      }
    }];
}

@end
