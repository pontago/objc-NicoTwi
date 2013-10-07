//
//  FavoriteViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/22.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "FavoriteViewController.h"

@interface FavoriteViewController () {
    PSCollectionView *collectionView_;
    LoadingIndicator *loadingIndicator_;
    NSFetchedResultsController *fetchedResultsController_;
    ActionMenuTableViewController *actionMenuTableViewController_;
    AdBannerViewController *adBannerViewController_;
}

- (NSFetchedResultsController*)getFetchedResultsController_;
- (void)fetchedData_;
- (void)doAction_:(UIBarButtonItem*)sender;

- (void)sortDesc;
- (void)sortAsc;
- (void)confirmDelete;

@end

@implementation FavoriteViewController

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

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"お気に入り"];
    self.navigationItem.leftBarButtonItems = [[FlatUIUtils sharedInstance] menuBarButtonItem:[UIImage imageNamed:ICON_MENU]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
        [[UIImage imageNamed:ICON_ACTION] imageByShrinkingWithSize:CGSizeMake(22, 22)] 
        style:UIBarButtonItemStylePlain target:self action:@selector(doAction_:)];

    // Add CollectionView
    collectionView_ = [[PSCollectionView alloc] initWithFrame:self.view.bounds];
    collectionView_.collectionViewDelegate = self;
    collectionView_.collectionViewDataSource = self;
    collectionView_.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    collectionView_.autoresizingMask = ~UIViewAutoresizingNone;
    collectionView_.numColsPortrait = 2;
    collectionView_.numColsLandscape = 3;
    collectionView_.footerView = [[LastFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.0f)];
    [self.view addSubview:collectionView_];

    loadingIndicator_ = [[LoadingIndicator alloc] initWithFrame:self.view.frame];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self fetchedData_];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
      self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark - PSCollectionView delegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [MovieCell class];
}

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView {
    if (fetchedResultsController_) {
      id<NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController_ sections] objectAtIndex:0]; 
      return [sectionInfo numberOfObjects];
    }

    return 0;
}

- (PSCollectionViewCell*)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index {
    MovieCell *cell = (MovieCell*)[collectionView dequeueReusableViewForClass:[MovieCell class]];

    if (cell == nil) {
      cell = [[MovieCell alloc] initWithFrame:CGRectMake(0, 0, collectionView.colWidth, 0)];
      cell.delegate = self;
//      cell.twitterView.delegate = self;
    }

    Favorite *moFavorite = [fetchedResultsController_ objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSError *error;
    NSData *data = [moFavorite.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSString *thumbnailUrl = [item objectForKey:@"thumbnail_url"];

    cell.videoInfo = item;
    cell.videoTitle = [item objectForKey:@"title"];
    cell.videoLength = [item objectForKey:@"length"];
    cell.viewCounter = [item objectForKey:@"view_counter"];
    cell.commentNum = [item objectForKey:@"comment_num"];

    [[CacheManager sharedCache] cacheImageWithUrl:thumbnailUrl block:^(UIImage *image) {
      if (image) {
        [cell.videoThumb setImage:image videoLength:cell.videoLength star:YES];
      }
      else {
        [[CacheManager sharedCache] downloadImage:thumbnailUrl block:^(UIImage *image) {
          [cell showThumbnailImage:image star:YES];
        }];
      }
    }];

//    NSDictionary *tweet = [item objectForKey:@"tweet"];
//    if (tweet) {
//      NSArray *tweetList = [tweet objectForKey:@"list"];
//      if ([tweetList count] > 0) {
//        [cell.twitterView setupTwitterInfo:tweet];
//        cell.twitterView.videoId = [item objectForKey:@"id"];
//      }
//    }


//    if (index == ([items_ count] - 1) && isRequest_ == NO && totalCount_ > [items_ count]) {
//      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self doWebRequest_:@NO];
//      });
//    }

//    [cell.twitterView setNeedsDisplay];
    [cell setNeedsDisplay];
    return cell;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index {
    Favorite *moFavorite = [fetchedResultsController_ objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSError *error;
    NSData *data = [moFavorite.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return [MovieCell rowHeightForObject:item inColumnWidth:collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index {
    Favorite *moFavorite = [fetchedResultsController_ objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSError *error;
    NSData *data = [moFavorite.data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

    VideoDetailViewController *videoDetailViewController = [[VideoDetailViewController alloc] init];
    videoDetailViewController.videoDetail = item;

    [self.navigationController pushViewController:videoDetailViewController animated:YES];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
  atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    [collectionView_ reloadData];
    [(LastFooterView*)collectionView_.footerView last:(collectionView_.frame.size.height >= collectionView_.contentSize.height)];
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    collectionView_.scrollsToTop = NO;
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    collectionView_.scrollsToTop = YES;
}

- (void)cell:(MovieCell*)cell didSelect:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateBegan) {
      NSNumber *confirmDelete = [[UserConfig sharedInstance] getConfig:@"FAVORITE_CONFIRM_DELETE"];

      if ([confirmDelete boolValue]) {
        [WCAlertView showAlertWithTitle:@"お気に入り" 
          message:@"この動画をお気に入りから解除しますか？" 
          customizationBlock:^(WCAlertView *alertView) {
        } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
          if (buttonIndex == 0) {
            [[DataHelper sharedInstance] toggleFavorite:cell.videoInfo];
          }
        } cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
      }
      else {
        [[DataHelper sharedInstance] toggleFavorite:cell.videoInfo];
      }
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


- (NSFetchedResultsController*)getFetchedResultsController_ {
//    if (fetchedResultsController_ != nil) {
//      return fetchedResultsController_;
//    }

    NSString *favoriteSort = [[UserConfig sharedInstance] getConfig:@"FAVORITE_SORT"];

    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_FAVORITE];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:MODEL_FAVORITE
      inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" 
      ascending:[favoriteSort isEqualToString:SORT_ASC]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    fetchedResultsController_ = [[NSFetchedResultsController alloc] 
      initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext 
      sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController_.delegate = self;

    NSError *error;
    if (![fetchedResultsController_ performFetch:&error]) {
      LOG(@"Unresolved error %@, %@", error, [error userInfo]);
      return nil;
    }

    return fetchedResultsController_;
}

- (void)fetchedData_ {
    @autoreleasepool {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:loadingIndicator_];
      });


      [self getFetchedResultsController_];


      dispatch_async(dispatch_get_main_queue(), ^{
        [loadingIndicator_ removeFromSuperview];
        [collectionView_ reloadData];

        [(LastFooterView*)collectionView_.footerView last:(collectionView_.frame.size.height >= collectionView_.contentSize.height)];
      });
    }
}

- (void)doAction_:(UIBarButtonItem*)sender {
    NSString *favoriteSort = [[UserConfig sharedInstance] getConfig:@"FAVORITE_SORT"];
    NSNumber *confirmDelete = [[UserConfig sharedInstance] getConfig:@"FAVORITE_CONFIRM_DELETE"];
    NSString *sortDescCheck = [favoriteSort isEqualToString:SORT_DESC] ? @"Check" : @"";
    NSString *sortAscCheck = [favoriteSort isEqualToString:SORT_ASC] ? @"Check" : @"";

    NSArray *menus = @[
        @[@"登録が新しい順番に表示", @"sortDesc", sortDescCheck],
        @[@"登録が古い順番に表示", @"sortAsc", sortAscCheck],
        @[@"お気に入り解除の確認を表示", @"confirmDelete", [confirmDelete boolValue] == YES ? @"Check" : @""]
      ];

    actionMenuTableViewController_ = [[ActionMenuTableViewController alloc] 
      initWithMenuItems:menus delegate:self];
    [actionMenuTableViewController_ presentModalFromBarButtonItem:sender inView:self.view animated:YES];
}

#pragma mark - Action methods

- (void)sortDesc {
    [[UserConfig sharedInstance] saveConfig:@"FAVORITE_SORT" value:SORT_DESC];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self fetchedData_];
    });
}

- (void)sortAsc {
    [[UserConfig sharedInstance] saveConfig:@"FAVORITE_SORT" value:SORT_ASC];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self fetchedData_];
    });
}

- (void)confirmDelete {
    NSNumber *confirmDelete = [[UserConfig sharedInstance] getConfig:@"FAVORITE_CONFIRM_DELETE"];

    [[UserConfig sharedInstance] saveConfig:@"FAVORITE_CONFIRM_DELETE" 
      value:@(![confirmDelete boolValue])];
}

@end
