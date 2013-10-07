//
//  TweetViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/14.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetCell.h"

@interface TweetViewController () {
    LoadingIndicator *loadingIndicator_;

    NSMutableArray *items_;
    NSUInteger totalCount_;
    BOOL isRequest_;
}

- (void)doDone_:(id)sender;
- (void)doWebRequest_:(NSNumber*)refreshMode;

@end

@implementation TweetViewController

@synthesize videoId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"関連ツイート"];

    // Navigation Button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ICON_CLOSE]
      style:UIBarButtonItemStylePlain target:self action:@selector(doDone_:)];

    items_ = [NSMutableArray array];
    totalCount_ = 0;

    loadingIndicator_ = [[LoadingIndicator alloc] initWithFrame:self.view.frame];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self doWebRequest_:@NO];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    TweetCell *cell = (TweetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
      cell = [[TweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDictionary *item = [items_ objectAtIndex:indexPath.row];
    NSString *profileImageUrl = [item objectForKey:@"profile_image_url"];

    cell.profileImageLayer.contents = nil;
    [[CacheManager sharedCache] downloadImage:profileImageUrl block:^(UIImage *image) {
      cell.profileImageLayer.contents = (__bridge id)image.CGImage;
    }];

    cell.username = [item objectForKey:@"name"];
    cell.text = [item objectForKey:@"text"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];
    cell.createdAt = [formatter dateFromString:[item objectForKey:@"created_at"]];


    if (indexPath.row == ([items_ count] - 1) && isRequest_ == NO && totalCount_ > [items_ count]) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performSelectorInBackground:@selector(doWebRequest_:) withObject:@NO];
      });
    }

    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [items_ objectAtIndex:indexPath.row];
    [[UtilEx sharedInstance] openTwitterUser:[item objectForKey:@"screen_name"]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [items_ objectAtIndex:indexPath.row];
    return [TweetCell rowHeightForObject:item inColumnWidth:self.tableView.frame.size.width 
      accessoryType:UITableViewCellAccessoryDisclosureIndicator];
}


- (void)doDone_:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
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
            [[LoadingBar sharedInstance] pushLoadingBar:self.view.superview];
          }
          else {
            [self.view addSubview:loadingIndicator_];
          }
        });
      }
      else {
        offset = 0;
      }


      NSDictionary *results = [[WebRequest sharedInstance] relatedTweetFromVideo:[NSDictionary dictionaryWithObjectsAndKeys: 
          videoId, @"videoId", 
          [NSNumber numberWithInt:offset], @"offset", 
        nil]];

      if (results) {
        NSArray *tweets = [results objectForKey:@"tweets"];
        totalCount_ = [[results objectForKey:@"total_count"] intValue];

        if (isRefresh) {
          @synchronized(self) {
            items_ = [NSMutableArray arrayWithArray:tweets];
          }
        }
        else {
          @synchronized(self) {
            [items_ addObjectsFromArray:tweets];
          }
        }
      }


      dispatch_async(dispatch_get_main_queue(), ^{
        if (!modeLoadingBar) {
          [loadingIndicator_ removeFromSuperview];
        }

        if (results) {
          [self.tableView reloadData];
        }
        else {
          [SVProgressHUD showErrorWithStatus:@"取得失敗"];
        }
      });

      isRequest_ = NO;
    }
}

@end
