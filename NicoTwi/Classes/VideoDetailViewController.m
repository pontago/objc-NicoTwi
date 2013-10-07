//
//  VideoDetailViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/16.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "VideoInfoCell.h"
#import "VideoCounterCell.h"
#import "VideoDescriptionCell.h"
#import "VideoTagCell.h"
#import "VideoRelatedTweetCell.h"
#import "RelatedVideoCell.h"

NSString * const URL_ALLEGATION = @"http://www.upload.nicovideo.jp/allegation/";

@interface VideoDetailViewController () {
    BOOL isRequested_, isRequest_, isVideoRelation_;
    NSDictionary *videoDict_;
    PSCollectionView *collectionView_;
    UITableView *tableView_;
    NSMutableArray *items_;
    NSString *nextPage_, *currentPage_;
    NSMutableDictionary *favorites_;

    ActionMenuTableViewController *actionMenuTableViewController_;
    AdBannerViewController *adBannerViewController_;
}

- (void)doWebRequest_;
- (void)requestRelatedVideo_;
- (void)reloadHeaderView_;
- (void)reloadFavorites_;
- (void)doAction_:(UIBarButtonItem*)sender;

- (void)postTweet:(NSDictionary*)params;
- (void)toggleFavorite;
- (void)openApplication:(NSDictionary*)params;
- (void)copyWatchUrl;
- (void)reload;
- (void)report;

@end

@implementation VideoDetailViewController

@synthesize videoDetail;

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME 
      subtitle:[self.videoDetail objectForKey:@"video_id"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
        [[UIImage imageNamed:ICON_ACTION] imageByShrinkingWithSize:CGSizeMake(22, 22)] 
        style:UIBarButtonItemStylePlain target:self action:@selector(doAction_:)];

    isRequested_ = NO;
    isRequest_ = NO;
    isVideoRelation_ = NO;
    items_ = [NSMutableArray array];
    favorites_ = [NSMutableDictionary dictionary];
    nextPage_ = currentPage_ = @"1";


    // tableview
    tableView_ = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView_.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.scrollsToTop = NO;

    // collection view
    collectionView_ = [[PSCollectionView alloc] initWithFrame:self.view.bounds];
    collectionView_.collectionViewDelegate = self;
    collectionView_.collectionViewDataSource = self;
    collectionView_.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    collectionView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    collectionView_.numColsPortrait = 2;
    collectionView_.numColsLandscape = 3;
    collectionView_.headerView = tableView_;
    collectionView_.footerView = [[LastFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.0f)];
    collectionView_.scrollsToTop = YES;
    [self.view addSubview:collectionView_];
    [collectionView_ reloadData];


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self doWebRequest_];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self reloadFavorites_];
    [collectionView_ reloadData];
    [self reloadHeaderView_];

    if (adBannerViewController_ && !adBannerViewController_.isFullScreen) {
      CGSize size = collectionView_.contentSize;
      size.height += 44.0f;
      collectionView_.contentSize = size;
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (!adBannerViewController_.isFullScreen) {
      [adBannerViewController_ removeAdBanner];
      [adBannerViewController_.view removeFromSuperview];
      adBannerViewController_ = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return isVideoRelation_ ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
      case 0: return isRequested_ ? 5 : 2;
      case 1: return 0;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *VideoInfoCellIdentifier = @"VideoInfoCell";
    static NSString *VideoCounterCellIdentifier = @"VideoCounterCell";
    static NSString *VideoDescriptionCellIdentifier = @"VideoDescriptionCell";
    static NSString *VideoTagCellIdentifier = @"VideoTagCell";
    static NSString *VideoRelatedTweetCellIdentifier = @"VideoRelatedTweetCell";

    if (indexPath.section == 0) {
      if (indexPath.row == 0) {
        VideoInfoCell *cell = (VideoInfoCell*)[tableView dequeueReusableCellWithIdentifier:VideoInfoCellIdentifier];
        if (cell == nil) {
          cell = [[VideoInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoInfoCellIdentifier];
          [cell setupVideoInfo:self.videoDetail];
        }
        return cell;
      }
      else if (indexPath.row == 1) {
        VideoCounterCell *cell = (VideoCounterCell*)[tableView dequeueReusableCellWithIdentifier:VideoCounterCellIdentifier];
        if (cell == nil) {
          cell = [[VideoCounterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoCounterCellIdentifier];
        }
        cell.videoInfo = self.videoDetail;
        return cell;
      }
      else if (indexPath.row == 2) {
        VideoDescriptionCell *cell = (VideoDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:VideoDescriptionCellIdentifier];
        if (cell == nil) {
          cell = [[VideoDescriptionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoDescriptionCellIdentifier];
        }
        NSDictionary *item = [videoDict_ objectForKey:@"video"];
        [cell setupDescription:[item objectForKey:@"description"]];
        return cell;
      }
      else if (indexPath.row == 3) {
        VideoTagCell *cell = (VideoTagCell*)[tableView dequeueReusableCellWithIdentifier:VideoTagCellIdentifier];
        if (cell == nil) {
          cell = [[VideoTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoTagCellIdentifier];
          cell.viewController = self;
        }
        [cell setupVideoTags:[videoDict_ objectForKey:@"tags"]];
        return cell;
      }
      else if (indexPath.row == 4) {
        VideoRelatedTweetCell *cell = (VideoRelatedTweetCell*)[tableView dequeueReusableCellWithIdentifier:VideoRelatedTweetCellIdentifier];
        if (cell == nil) {
          cell = [[VideoRelatedTweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoRelatedTweetCellIdentifier];
        }

        NSDictionary *tweet = [videoDict_ objectForKey:@"tweet"];
        if (tweet) {
          [cell.twitterView setupTwitterInfo:tweet isLazyLoad:NO];
        }
        cell.twitterView.videoId = [self.videoDetail objectForKey:@"id"];
        return cell;
      }
    }

    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
      if (indexPath.row == 0) {
        return [VideoInfoCell rowHeightForObject:nil inColumnWidth:tableView.frame.size.width];
      }
      else if (indexPath.row == 1) {
        return [VideoCounterCell rowHeightForObject:nil inColumnWidth:tableView.frame.size.width];
      }
      else if (indexPath.row == 2) {
        NSDictionary *item = [videoDict_ objectForKey:@"video"];
        return [VideoDescriptionCell rowHeightForObject:[item objectForKey:@"description"] 
          inColumnWidth:tableView.frame.size.width];
      }
      else if (indexPath.row == 3) {
        return [VideoTagCell rowHeightForObject:[videoDict_ objectForKey:@"tags"] 
          inColumnWidth:tableView.frame.size.width];
      }
      else if (indexPath.row == 4) {
        return [VideoRelatedTweetCell rowHeightForObject:videoDict_
          inColumnWidth:tableView.frame.size.width];
      }
    }

    return 0.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 1:
      return 22.0;
    }

    return 0.0;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 1:
      return @"関連動画";
    }

    return @"";
} 

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat sectionHeight = [self tableView:tableView heightForHeaderInSection:section];
    if (sectionHeight == 0.0) {
      return nil;
    }


    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, sectionHeight)];;
    headerView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.85];

    NSString *text  = [self tableView:tableView titleForHeaderInSection:section];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width - 5, 22)];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = HEXCOLOR(BARCOLOR);
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];

    return headerView;
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


    if (index == ([items_ count] - 1) && isRequest_ == NO && [currentPage_ isEqualToString:nextPage_] == NO) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestRelatedVideo_];
      });
    }

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

    [self.navigationController pushViewController:videoDetailViewController animated:YES];
}


- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    collectionView_.scrollsToTop = NO;
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    collectionView_.scrollsToTop = YES;
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
        CGSize size = [[UtilEx sharedInstance] applicationSize];
        CGRect rect = self.view.frame;
        rect.size.height = size.height - adView.frame.size.height;
        self.view.frame = rect;

        rect = adBannerViewController_.view.frame;
        rect.origin.y = self.navigationController.view.frame.size.height - adView.frame.size.height;
        adBannerViewController_.view.frame = rect;
      } completion:NULL];
}

- (void)didFailAdBanner:(UIView*)adView {
    [UIView animateWithDuration:0.3 delay:0
      options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
      animations:^{
        CGSize size = [[UtilEx sharedInstance] applicationSize];
        CGRect rect = self.view.frame;
        rect.size.height = size.height;
        self.view.frame = rect;

        rect = adBannerViewController_.view.frame;
        rect.origin.y = self.navigationController.view.frame.size.height;
        adBannerViewController_.view.frame = rect;
      } completion:NULL];
}


- (void)doWebRequest_ {
    @autoreleasepool {
      dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingBar sharedInstance] pushLoadingBar:self.view];
        [(LastFooterView*)collectionView_.footerView loading];
      });


      videoDict_ = [[WebRequest sharedInstance] videoDetail:[NSDictionary dictionaryWithObjectsAndKeys: 
          [self.videoDetail objectForKey:@"id"], @"videoId", 
        nil]];
      if (videoDict_) {
        NSString *status = [videoDict_ objectForKey:@"status"];
        if ([status isEqualToString:@"ok"]) {
          isRequested_ = YES;
        }
      }

      if (!isRequested_) {
        videoDict_ = [[WebRequest sharedInstance] getNicoThumbInfo:[NSDictionary dictionaryWithObjectsAndKeys: 
            [self.videoDetail objectForKey:@"video_id"], @"videoId", 
          nil]];
        if (videoDict_) {
          isRequested_ = YES;
        }
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        if (videoDict_) {
          [self reloadHeaderView_];
        }
        else {
          [SVProgressHUD showErrorWithStatus:@"取得失敗"];
          collectionView_.footerView.hidden = YES;
        }
      });

      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestRelatedVideo_];
      });
    }
}

- (void)requestRelatedVideo_ {
    @autoreleasepool {
      isRequest_ = YES;

      dispatch_async(dispatch_get_main_queue(), ^{
        [[LoadingBar sharedInstance] pushLoadingBar:self.view];
        [(LastFooterView*)collectionView_.footerView loading];
      });


      NSDictionary *results = [[WebRequest sharedInstance] relatedVideo:[NSDictionary dictionaryWithObjectsAndKeys: 
          [self.videoDetail objectForKey:@"video_id"], @"videoId", 
          nextPage_, @"page", 
        nil]];
      if (results) {
        NSArray *videos = [results objectForKey:@"items"];
        currentPage_ = nextPage_;
        nextPage_ = [results objectForKey:@"nextPage"];

        @synchronized(self) {
          [items_ addObjectsFromArray:videos];
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


      dispatch_async(dispatch_get_main_queue(), ^{
        if (results) {
          NSString *totalCount = [results objectForKey:@"totalCount"];
          if ([totalCount intValue] > 0) {
            if (!isVideoRelation_) {
              isVideoRelation_ = YES;
              [self reloadHeaderView_];
            }

            if ([currentPage_ isEqualToString:nextPage_]) {
              [(LastFooterView*)collectionView_.footerView last];
            }

            [collectionView_ reloadDataEx];
          }
          else {
            [(LastFooterView*)collectionView_.footerView last];
          }
        }
        else {
          [SVProgressHUD showErrorWithStatus:@"取得失敗"];
          collectionView_.footerView.hidden = YES;
        }
      });

      isRequest_ = NO;
    }
}

- (void)reloadHeaderView_ {
    [tableView_ reloadData];

    CGRect frame = tableView_.frame;
    if (isVideoRelation_) {
      frame.size.height = tableView_.contentSize.height + 5.0f;
      tableView_.frame = frame;
    }
    else {
      frame.size.height = tableView_.contentSize.height + 5.0f;
      tableView_.frame = frame;
      collectionView_.contentSize = CGSizeMake(0, tableView_.contentSize.height + 5.0f);

      if (tableView_.frame.size.height > collectionView_.frame.size.height) {
        frame = collectionView_.footerView.frame;
        frame.origin.y = tableView_.frame.size.height;
        collectionView_.footerView.frame = frame;
      }
    }
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

- (void)doAction_:(UIBarButtonItem*)sender {
    NSString *videoId = [self.videoDetail objectForKey:@"video_id"];
    BOOL isFavorite = [[DataHelper sharedInstance] isFavoriteWithVideoId:videoId];
    NSString *toggleFavoriteTitle;

    if (isFavorite) {
      toggleFavoriteTitle = @"お気に入り解除";
    }
    else {
      toggleFavoriteTitle = @"お気に入り登録";
    }

    NSArray *menus = @[
        @[@"ツイッター投稿", @"postTweet:"],
        @[toggleFavoriteTitle, @"toggleFavorite"],
        @[@"アプリで開く", @"openApplication:"],
        @[@"動画URLをコピー", @"copyWatchUrl"],
        @[@"再読み込み", @"reload"],
        @[@"不適切な動画の報告", @"report"]
      ];

    actionMenuTableViewController_ = [[ActionMenuTableViewController alloc] 
      initWithMenuItems:menus delegate:self];
    actionMenuTableViewController_.params = self.videoDetail;
    [actionMenuTableViewController_ presentModalFromBarButtonItem:sender inView:self.view animated:YES];
}


#pragma mark - Action methods

- (void)postTweet:(NSDictionary*)params {
    TWTweetComposeViewController *twViewController = [[UtilEx sharedInstance] postTweet:[params objectForKey:@"title"] 
      videoId:[params objectForKey:@"video_id"]];
    [twViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
      [self dismissModalViewControllerAnimated:YES];
    }];
    [self presentModalViewController:twViewController animated:YES];
}

- (void)toggleFavorite {
    [[DataHelper sharedInstance] toggleFavorite:self.videoDetail];

    [tableView_ reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] 
      withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)openApplication:(NSDictionary*)params {
    [[UtilEx sharedInstance] openVideo:[params objectForKey:@"video_id"]];
}

- (void)copyWatchUrl {
    [[UIPasteboard generalPasteboard] 
      setValue:[URL_NICO_WATCH stringByAppendingString:[self.videoDetail objectForKey:@"video_id"]] 
      forPasteboardType:@"public.utf8-plain-text"];
    [SVProgressHUD showSuccessWithStatus:@"コピーしました"];
}

- (void)reload {
    items_ = [NSMutableArray array];
    favorites_ = [NSMutableDictionary dictionary];
    isRequested_ = NO;
    isRequest_ = NO;
    isVideoRelation_ = NO;
    nextPage_ = currentPage_ = @"1";
    collectionView_.footerView.hidden = YES;

    [collectionView_ reloadData];
    [tableView_ reloadData];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self doWebRequest_];
    });
}

- (void)report {
    NSString *url = [NSString stringWithFormat:@"%@%@", 
      URL_ALLEGATION, [[UtilEx sharedInstance] parseNumNicoVideoId:[self.videoDetail objectForKey:@"video_id"]]];

    [WCAlertView showAlertWithTitle:@"不適切な動画の報告" 
      message:@"この動画を不適切な動画として報告しようとしています。" 
      customizationBlock:^(WCAlertView *alertView) {
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
      if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
      }
    } cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
}

@end
