//
//  TwAccountViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "TwAccountViewController.h"

@interface TwAccountViewController () {
    ACAccountStore *accountStore_;
    NSArray *accounts_;
}

- (void)doDone_:(id)sender;

@end

@implementation TwAccountViewController

@synthesize selectedAccount;

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

    UserConfig *userConfig = [UserConfig sharedInstance];
    self.selectedAccount = [userConfig getConfig:@"TWITTER_IDENTIFIER"];
    accounts_ = [NSArray array];

    self.tableView.backgroundView = nil;
    self.view.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);
    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"Twitter連携の設定"];


    // Navigation Button
    self.navigationItem.rightBarButtonItem = [[FlatUIUtils sharedInstance] textBarButtonItem:@"保存" 
      target:self action:@selector(doDone_:)];


    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    accountStore_ = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore_ accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    void (^completion)(BOOL, NSError*) = ^(BOOL granted, NSError *error) {
      if (granted) {
        accounts_ = [accountStore_ accountsWithAccountType:accountType];
        [self.tableView reloadData];
      }
      else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
          [WCAlertView showAlertWithTitle:@"Twitter連携の設定" 
            message:@"Twitter連携を有効にする必要があります。\n「設定」の「Twitter」から本アプリを許可してください。" 
            customizationBlock:^(WCAlertView *alertView) {
          } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
          } cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        });
      }
    };

    if (version < 6.0) {
      [accountStore_ requestAccessToAccountsWithType:accountType withCompletionHandler:completion];
    }
    else {
      [accountStore_ requestAccessToAccountsWithType:accountType options:nil completion:completion];
    }
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
    return [accounts_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

      cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    ACAccount *account = [accounts_ objectAtIndex:indexPath.row];
    if ([self.selectedAccount isEqualToString:account.identifier]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"@%@", account.username];

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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (cell.accessoryType == UITableViewCellAccessoryNone) {
      ACAccount *account = [accounts_ objectAtIndex:indexPath.row];
      self.selectedAccount = account.identifier;

      [self.tableView reloadData];
    }
}


- (void)doDone_:(id)sender {
    [[UserConfig sharedInstance] saveConfig:@"TWITTER_IDENTIFIER" value:self.selectedAccount];

    if ([self.selectedAccount isEqualToString:@""]) {
      [WCAlertView showAlertWithTitle:@"Twitter連携の設定" 
        message:@"Twitter連携の設定をおこなわないと一部機能が利用できません。" 
        customizationBlock:^(WCAlertView *alertView) {
      } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
      } cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    }

    [self dismissViewControllerAnimated:YES];
}

@end
