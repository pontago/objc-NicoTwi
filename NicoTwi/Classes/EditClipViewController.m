//
//  EditClipViewController.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/25.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "EditClipViewController.h"
#import "FixedTableViewCell.h"

@interface EditClipViewController () {
    NSFetchedResultsController *fetchedResultsController_;
}

- (NSFetchedResultsController*)getFetchedResultsController_;
- (void)doClose_:(id)sender;

@end

@implementation EditClipViewController

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

    [(SubTitleView*)self.navigationItem.titleView setTitleAndSubTitle:APP_NAME subtitle:@"クリップの編集"];

    // Navigation Button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:ICON_CLOSE]
      style:UIBarButtonItemStylePlain target:self action:@selector(doClose_:)];

    // tableview header view
    self.tableView.tableHeaderView = [[AddTagHeaderView alloc] initWithFrame:CGRectMake(0, 0, 
      self.view.bounds.size.width, 40.0f)];

    [self getFetchedResultsController_];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
      return 2;
    }
    else if (section == 1) {
      if (fetchedResultsController_) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController_ sections] objectAtIndex:0]; 
        return [sectionInfo numberOfObjects];
      }
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FixedTableViewCell *cell = (FixedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
      cell = [[FixedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    if (indexPath.section == 0) {
      UIColor *imageColor = HEXCOLOR(0xFF5C5C);
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.textLabel.font = [UIFont systemFontOfSize:15];
      cell.textLabel.textColor = [UIColor darkGrayColor];
      cell.imageWidth = 20.0f;

      if (indexPath.row == 0) {
        cell.textLabel.text = @"リストから選択する";
        cell.imageView.image = [[UIImage imageNamed:@"436-plus" withColor:imageColor] imageByShrinkingWithSize:CGSizeMake(20, 22)];
      }
      else if (indexPath.row == 1) {
        cell.textLabel.text = @"カテゴリ一覧から選択する";
        cell.imageView.image = [[UIImage imageNamed:@"15-tags" withColor:imageColor] imageByShrinkingWithSize:CGSizeMake(20, 22)];
      }
    }
    else if (indexPath.section == 1) {
      Clip *moClip = [fetchedResultsController_ objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.textLabel.font = [UIFont systemFontOfSize:15];
      cell.textLabel.textColor = [UIColor darkGrayColor];
      cell.textLabel.text = moClip.tagName;
      cell.imageWidth = 0.0f;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
      return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Clip *moClip = [fetchedResultsController_ objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self addTagViewController:nil editingStyle:UITableViewCellEditingStyleDelete tagName:moClip.tagName];
        [self.tableView reloadData];
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
    if (indexPath.section == 0) {
      AddTagViewController *addTagViewController = [[AddTagViewController alloc] initWithStyle:UITableViewStylePlain];
      addTagViewController.delegate = self;
      if (indexPath.row == 0) {
        addTagViewController.navigationItem.title = @"リストから選択";
        [self.navigationController pushViewController:addTagViewController animated:YES];
      }
      else if (indexPath.row == 1) {
        addTagViewController.navigationItem.title = @"カテゴリ一覧から選択";
        addTagViewController.isCategory = YES;
        [self.navigationController pushViewController:addTagViewController animated:YES];
      }
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
    if (section == 1) {
      return [NSString stringWithFormat:@"選択中のタグ - %d/%d個", 
        [[DataHelper sharedInstance] clipCount], MAX_CLIP];
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

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
//  atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//
//    switch(type) {
//      case NSFetchedResultsChangeInsert:
//        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//          withRowAnimation:UITableViewRowAnimationFade];
//        break;
//      case NSFetchedResultsChangeDelete:
//        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//          withRowAnimation:UITableViewRowAnimationFade];
//        break;
//    }
//}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
  atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
  newIndexPath:(NSIndexPath *)newIndexPath {

    [self.tableView reloadData];
//    switch(type) {
//      case NSFetchedResultsChangeInsert:
//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//          withRowAnimation:UITableViewRowAnimationFade];
//        break;
//      case NSFetchedResultsChangeDelete:
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//          withRowAnimation:UITableViewRowAnimationFade];
//        break;
//      case NSFetchedResultsChangeUpdate:
////        [self updateCell:[self.tableView cellForRowAtIndexPath:indexPath] IndexPath:indexPath];
//        break;
//      case NSFetchedResultsChangeMove:
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//          withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//          withRowAnimation:UITableViewRowAnimationFade];
//        break;
//    }
}


- (NSFetchedResultsController*)getFetchedResultsController_ {
    if (fetchedResultsController_ != nil) {
      return fetchedResultsController_;
    }

    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_CLIP];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:MODEL_CLIP
      inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
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

- (void)doClose_:(id)sender {
    [self dismissViewControllerAnimated:YES];
}


- (NSDictionary*)addTagViewController:(AddTagViewController*)addTagViewController request:(BOOL)isRequest {
    NSDictionary *results;

    if (addTagViewController.isCategory) {
      results = [[WebRequest sharedInstance] tagCount:[NSDictionary dictionaryWithObjectsAndKeys: 
          [[UtilEx sharedInstance] nicoCategories], @"tags", 
        nil]];
    }
    else {
      results = [[WebRequest sharedInstance] tagList:nil];
    }

    return results;
}

- (BOOL)addTagViewController:(AddTagViewController*)addTagViewController editingStyle:(UITableViewCellEditingStyle)editingStyle 
  tagName:(NSString*)tagName {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
      return [[DataHelper sharedInstance] deleteClip:tagName];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
      return [[DataHelper sharedInstance] addClip:tagName checkLimit:YES];
    }

    return NO;
}

@end
