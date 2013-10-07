//
//  ActionMenuTableViewController.m
//  TVJikkyoNow
//
//  Created by Pontago on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ActionMenuTableViewController.h"
#import "SNPopupView.h"
#import "SNPopupView+UsingPrivateMethod.h"

@interface ActionMenuTableViewController () {
//    UITableView *tableView_;
    SNPopupView *popupActionMenu_;
}

@end

@implementation ActionMenuTableViewController

@synthesize menuItems = menuItems_;
@synthesize delegate = delegate_;
@synthesize params;
@synthesize actionObject;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
      // Custom initialization
    }
    return self;
}

- (id)initWithMenuItems:(NSArray*)menuItems delegate:(id)delegate
{
//    self = [self init];
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
      menuItems_ = menuItems;
      delegate_ = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = HEXCOLOR(BACKGROUND_COLOR);

    // tableview
    self.tableView.backgroundColor = self.view.backgroundColor;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 38.0;
//    self.tableView.frame = CGRectMake(0, 0, 190, (34.0f * [menuItems_ count]) - 1);
//    self.tableView.frame = CGRectMake(0, 0, width, (34.0f * [menuItems_ count]) - 1);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuItems_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.textLabel.font = [UIFont systemFontOfSize:12];
      cell.textLabel.textColor = HEXCOLOR(BAR_TEXT_COLOR);
      cell.selectionStyle = UITableViewCellSelectionStyleGray;
      cell.backgroundColor = [UIColor clearColor];

      UIView *backgroundView = [[UIView alloc] init];
      [backgroundView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
      [cell setSelectedBackgroundView:backgroundView];
    }

    NSArray *item = [menuItems_ objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectAtIndex:0];

    if ([item count] > 2 && [[item objectAtIndex:2] isEqualToString:@"Check"]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
      cell.accessoryType = UITableViewCellAccessoryNone;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

    NSArray *item = [menuItems_ objectAtIndex:indexPath.row];
    NSString *actionStr = [item objectAtIndex:1];
    if (![actionStr isEqualToString:@""]) {
      SEL action = NSSelectorFromString(actionStr);

      id sender;
      if (self.delegate) {
        sender = self.delegate;
      }
      else {
        sender = self.actionObject;
      }

      if ([sender respondsToSelector:action]) {
        NSDictionary *dict = self.params;
        NSMethodSignature *methodSig = [[sender class] instanceMethodSignatureForSelector:action];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setSelector:action];
        [invocation setTarget:sender];
        if ([actionStr hasSuffix:@":"]) {
          [invocation setArgument:&dict atIndex:2];
        }
        [invocation invoke];
      }

      [popupActionMenu_ dismissModal];
      popupActionMenu_ = nil;
    }
}


- (void)presentModalFromBarButtonItem:(UIBarButtonItem*)sender inView:(UIView*)inView animated:(BOOL)animtaed {
    CGFloat width = 0.0f;
    CGSize strSize;
    NSString *str;
    for (NSArray *item in menuItems_) {
      str = item[0];
      strSize = [str sizeWithFont:[UIFont systemFontOfSize:13]
        constrainedToSize:CGSizeMake(300.0f, 2000) lineBreakMode:NSLineBreakByWordWrapping];
      if (strSize.width > width) {
        width = strSize.width;
      }
    }

    popupActionMenu_ = [[SNPopupView alloc] initWithContentView:self.view 
      contentSize:CGSizeMake(width + 50.0f, ((self.tableView.rowHeight - 1.0f) * [menuItems_ count]) - 1)];
    popupActionMenu_.borderColor = self.view.backgroundColor;
    [popupActionMenu_ presentModalFromBarButtonItem:sender inView:inView animated:animtaed];
}

- (void)presentModalAtPoint:(CGPoint)p inView:(UIView*)inView animated:(BOOL)animtaed {
    CGFloat width = 0.0f;
    CGSize strSize;
    NSString *str;
    for (NSArray *item in menuItems_) {
      str = item[0];
      strSize = [str sizeWithFont:[UIFont systemFontOfSize:13]
        constrainedToSize:CGSizeMake(300.0f, 2000) lineBreakMode:NSLineBreakByWordWrapping];
      if (strSize.width > width) {
        width = strSize.width;
      }
    }

    popupActionMenu_ = [[SNPopupView alloc] initWithContentView:self.view 
      contentSize:CGSizeMake(width + 50.0f, ((self.tableView.rowHeight - 1.0f) * [menuItems_ count]) - 1)];
//      contentSize:CGSizeMake(285.0f, ((self.tableView.rowHeight - 1.0f) * [menuItems_ count]) - 1)];
    popupActionMenu_.borderColor = self.view.backgroundColor;
    [popupActionMenu_ presentModalAtPoint:p inView:inView animated:animtaed];
}

@end
