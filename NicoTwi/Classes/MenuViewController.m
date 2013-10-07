//
//  MenuViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "MenuViewController.h"
#import "ViewController.h"
#import "SettingViewController.h"
#import "FixedTableViewCell.h"
#import "AppDelegate.h"

NSString * const URL_INFORMATION = @"http://nicotwiapp.blogspot.jp/";

@interface MenuViewController () {
    NSArray *menuItems_;
}

- (void)showTimeline_:(NSString*)tagName;
- (void)showInformation_;
- (void)showHelp_;
- (void)buildViewController_:(NSString*)className;
- (void)buildSettingViewController_;

@end

@implementation MenuViewController

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

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
      UIEdgeInsets insets = self.tableView.contentInset;
      insets.top += 20.0f;
      self.tableView.contentInset = insets;
    }

    self.tableView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    self.tableView.separatorColor = [UIColor darkGrayColor];

    NSArray *nicoCategories = [[UtilEx sharedInstance] nicoCategories];
    NSString *categoryImageName = @"15-tags";

    NSMutableArray *categories = [NSMutableArray array];
    for (NSString *item in nicoCategories) {
      [categories addObject:@[item, categoryImageName, @"Category"]];
    }

    menuItems_ = [NSArray arrayWithObjects:
      [NSArray arrayWithObjects:
        [NSArray arrayWithObjects:@"ホーム", @"390-coverflow", @"ViewController", nil], 
        [NSArray arrayWithObjects:@"お気に入り", @"28-star", @"FavoriteViewController", nil], 
        [NSArray arrayWithObjects:@"クリップ", @"68-paperclip", @"Clip", nil], 
        [NSArray arrayWithObjects:@"お知らせ", @"275-broadcast", @"Info", nil], 
        [NSArray arrayWithObjects:@"設定", @"20-gear-2", @"Setting", nil], 
        [NSArray arrayWithObjects:@"ヘルプ", @"441-help-symbol1", @"Help", nil], 
        nil],
      categories, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [menuItems_ count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = [menuItems_ objectAtIndex:section];
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FixedTableViewCell *cell = (FixedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[FixedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
      cell.textLabel.textColor = [UIColor whiteColor];

      UIView *backgroundView = [[UIView alloc] init];
      [backgroundView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
      [cell setSelectedBackgroundView:backgroundView];

      cell.imageWidth = 25.0f;
    }

    NSArray *items = [menuItems_ objectAtIndex:indexPath.section];
    NSArray *item = [items objectAtIndex:indexPath.row];

    cell.textLabel.text = [item objectAtIndex:0];
    cell.imageView.image = [[UIImage imageNamed:[item objectAtIndex:1]] 
      imageByShrinkingWithSize:CGSizeMake(20, 22)];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [menuItems_ objectAtIndex:indexPath.section];
    NSArray *item = [items objectAtIndex:indexPath.row];

    if (indexPath.section == 0) {
      if (indexPath.row == 0) {
        [self showTimeline_:nil];
      }
      else {
        if ([[item objectAtIndex:2] isEqualToString:@"Setting"]) {
          [self buildSettingViewController_];
        }
        else if ([[item objectAtIndex:2] isEqualToString:@"Clip"]) {
          [self showTimeline_:@"Clip"];
        }
        else if ([[item objectAtIndex:2] isEqualToString:@"Info"]) {
          [self showInformation_];
        }
        else if ([[item objectAtIndex:2] isEqualToString:@"Help"]) {
          [self showHelp_];
        }
        else {
          [self buildViewController_:[item objectAtIndex:2]];
        }
      }
    }
    else if (indexPath.section == 1) {
      [self showTimeline_:[item objectAtIndex:0]];
    }
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
      return @"カテゴリ";
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
}


- (void)showTimeline_:(NSString*)tagName {
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
      ViewController *viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
      if ([tagName isEqualToString:@"Clip"]) {
        viewController.isClipMode = YES;
      }
      else {
        viewController.tagName = tagName;
      }

      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:viewController];

      self.viewDeckController.centerController = navigationController;
    }];
}

- (void)showInformation_ {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@", URL_SCHEME, URL_SCHEME_URL, 
      URL_INFORMATION]];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
      [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)showHelp_ {
    HelpViewController *helpViewController = [[HelpViewController alloc] init];

    SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
      initWithRootViewController:helpViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.viewDeckController presentViewController:navigationController animated:YES completion:NULL];
}

- (void)buildViewController_:(NSString*)className {
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
      Class klass = NSClassFromString(className);
      UIViewController *viewController = [[klass alloc] init];
      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:viewController];

      self.viewDeckController.centerController = navigationController;
    }];
}

- (void)buildSettingViewController_ {
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
      SettingViewController *settingViewController = (SettingViewController*)[[SettingViewController alloc] init];
      [settingViewController buildSettingData];
      SubTitleNavigationController *navigationController = [[SubTitleNavigationController alloc] 
        initWithRootViewController:settingViewController];

      self.viewDeckController.centerController = navigationController;
    }];
}

@end
