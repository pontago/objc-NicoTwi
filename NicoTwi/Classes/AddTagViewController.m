//
//  AddTagViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/25.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "AddTagViewController.h"

@interface AddTagViewController () {
    LoadingIndicator *loadingIndicator_;
    NSMutableArray *items_;
    NSMutableArray *clipTags_;

    ISRefreshControl *refreshControl_;
}

- (void)doWebRequest_:(NSNumber*)refreshMode;
- (void)refresh_;

@end

@implementation AddTagViewController

@synthesize isCategory, delegate;

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

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:self.navigationItem.title];


    items_ = [NSMutableArray array];
    clipTags_ = (NSMutableArray*)[[DataHelper sharedInstance] clipTags];


    // Add refresh control
    refreshControl_ = [[ISRefreshControl alloc] init];
    refreshControl_.tintColor = HEXCOLOR(BAR_TEXT_COLOR);
    if (!isCategory) {
      [self.tableView addSubview:refreshControl_];
      [refreshControl_ addTarget:self action:@selector(refresh_) 
        forControlEvents:UIControlEventValueChanged];
    }

    loadingIndicator_ = [[LoadingIndicator alloc] initWithFrame:self.view.frame];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
      cell.textLabel.font = [UIFont systemFontOfSize:14];
      cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
      cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    NSDictionary *item = items_[indexPath.row];
    NSString *tagName = item[@"name"];
    cell.textLabel.text = tagName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@動画に含まれる", item[@"count"]];

    if ([clipTags_ containsObject:tagName]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = items_[indexPath.row];
    NSString *tagName = item[@"name"];

    if ([clipTags_ containsObject:tagName]) {
      return YES;
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      NSDictionary *item = items_[indexPath.row];
      NSString *tagName = item[@"name"];

      [self.delegate addTagViewController:self editingStyle:UITableViewCellEditingStyleDelete tagName:tagName];
      [clipTags_ removeObject:tagName];
      [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

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

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"削除";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = items_[indexPath.row];
    NSString *tagName = item[@"name"];

    if ([clipTags_ containsObject:tagName]) {
      [WCAlertView showAlertWithTitle:@"確認" 
        message:@"このタグをクリップから解除しますか？" 
        customizationBlock:^(WCAlertView *alertView) {
      } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
          BOOL flag = [self.delegate addTagViewController:self editingStyle:UITableViewCellEditingStyleDelete tagName:tagName];
          if (flag) {
            [clipTags_ removeObject:tagName];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
          }
        }
      } cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    }
    else {
      [WCAlertView showAlertWithTitle:@"確認" 
        message:@"このタグをクリップに追加しますか？" 
        customizationBlock:^(WCAlertView *alertView) {
      } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 0) {
          BOOL flag = [self.delegate addTagViewController:self editingStyle:UITableViewCellEditingStyleInsert tagName:tagName];
          if (flag) {
            [clipTags_ addObject:tagName];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
          }
        }
      } cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    }
}


- (void)doWebRequest_:(NSNumber*)refreshMode {
    @autoreleasepool {
      BOOL isRefresh = [refreshMode boolValue];

      dispatch_async(dispatch_get_main_queue(), ^{
        if (!isRefresh) {
          self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
          [self.view addSubview:loadingIndicator_];
        }
      });


      NSDictionary *results = [self.delegate addTagViewController:self request:YES];
      if (results) {
        NSArray *tags = [results objectForKey:@"tags"];

        @synchronized(self) {
          items_ = [NSMutableArray arrayWithArray:tags];
        }
      }


      dispatch_async(dispatch_get_main_queue(), ^{
        if (isRefresh) {
          [refreshControl_ endRefreshing];
        }
        else {
          self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
          [loadingIndicator_ removeFromSuperview];
        }

        if (results) {
          [self.tableView reloadData];
        }
        else {
          [SVProgressHUD showErrorWithStatus:@"取得失敗"];
        }
      });
    }
}

- (void)refresh_ {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self doWebRequest_:@YES];
    });
}

@end
