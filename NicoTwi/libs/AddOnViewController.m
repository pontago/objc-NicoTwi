//
//  AddOnViewController.m
//  TVJikkyoNow
//
//  Created by Pontago on 2012/12/02.
//
//

#import "AddOnViewController.h"
#import "AddOnCell.h"


NSString* const ADDON_ADBANNER_HIDDEN = @"AdBannerHidden";

@interface AddOnViewController ()

@end

@implementation AddOnViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    addOnItems_ = [NSMutableArray array];
    self.navigationItem.title = @"アドオンの購入";


    if ([SKPaymentQueue canMakePayments]) {
//      addOnItems_ = [NSArray arrayWithObjects:
//        [NSArray arrayWithObjects:@"広告非表示アドオン", 
//          @"アプリ内に表示されている広告を非表示にできます。", 
//          @"AdBannerHidden", nil], 
//        nil];
      productIds_ = [NSArray arrayWithObjects:ADDON_ADBANNER_HIDDEN, 
        nil];

      [self performSelectorInBackground:@selector(doWebRequest) withObject:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
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
    return [addOnItems_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddOnCell";
    AddOnCell *cell = (AddOnCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
      UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
      NSArray *array = [nib instantiateWithOwner:nil options:nil];
      cell = [array objectAtIndex:0];

      cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
      cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
      cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:10];
    }

    SKProduct *product = [addOnItems_ objectAtIndex:indexPath.row];
    cell.titleLabel.text = product.localizedTitle;
    cell.descriptionTextLabel.text = product.localizedDescription;

    NSNumber *addOnAdBannerHidden = [[UserConfig sharedInstance] getConfig:@"ADDON_ADBANNER_HIDDEN"];
    if (![addOnAdBannerHidden boolValue]) {
      NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
      [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
      [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
      [formatter setLocale:product.priceLocale];
      cell.priceLabel.text = [formatter stringFromNumber:product.price];
    }
    else {
      cell.priceLabel.text = @"購入済み";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
        initWithTitle:@"アドオン購入の確認"
        delegate:self cancelButtonTitle:@"キャンセル" 
        destructiveButtonTitle:nil otherButtonTitles:@"購入", @"リストア", nil];
    actionSheet.tag = indexPath.row;
    [actionSheet showInView:tableView];

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
      CGRect frame = actionSheet.frame;
      frame.origin.y -= 40.0f;
      actionSheet.frame = frame;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
      SKProduct *product = [addOnItems_ objectAtIndex:actionSheet.tag];
      SKPayment *payment = [SKPayment paymentWithProduct:product];
      [[SKPaymentQueue defaultQueue] addPayment:payment];
      [SVProgressHUD showWithStatus:@"購入処理中"];
    }
    else if (buttonIndex == 1) {
      [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
      [SVProgressHUD showWithStatus:@"リストア処理中"];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if ([response.products count] > 0) {
      for (SKProduct *product in response.products) {
        [addOnItems_ addObject:product];
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.tableView reloadData];

        [SVProgressHUD dismiss];
      });
    }
    else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"取得失敗"];
      });
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
      switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchasing:
    LOG(@"SKPaymentTransactionStatePurchasing");
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"購入処理中"];
          });
          break;
        case SKPaymentTransactionStatePurchased:
          [[UserConfig sharedInstance] saveConfig:@"ADDON_ADBANNER_HIDDEN" value:[NSNumber numberWithBool:YES]];

          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"購入成功"];
          });
    LOG(@"SKPaymentTransactionStatePurchased");

          [queue finishTransaction:transaction];
          break;
        case SKPaymentTransactionStateFailed:
    LOG(@"SKPaymentTransactionStateFailed");
          if (transaction.error.code != SKErrorPaymentCancelled) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [SVProgressHUD showErrorWithStatus:@"購入失敗"];
            });
          }
          else {
            [SVProgressHUD dismiss];
          }

          [queue finishTransaction:transaction];
          break;
        case SKPaymentTransactionStateRestored:
    LOG(@"SKPaymentTransactionStateRestored");
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"リストア処理中"];
          });
          [queue finishTransaction:transaction];
          break;
      }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
      [SVProgressHUD showErrorWithStatus:@"リストア失敗"];
    });
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    LOG(@"paymentQueueRestoreCompletedTransactionsFinished");

    BOOL restored = NO;

    for (SKPaymentTransaction *transaction in queue.transactions) {
      if ([transaction.payment.productIdentifier hasSuffix:ADDON_ADBANNER_HIDDEN]) {
        [[UserConfig sharedInstance] saveConfig:@"ADDON_ADBANNER_HIDDEN" value:[NSNumber numberWithBool:YES]];
        restored = YES;
        break;
      }
    }

    if (restored) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:@"リストア成功"];
      });
    }
    else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:@"未購入のため失敗"];
      });
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    LOG(@"removedTransactions");
    [self.tableView reloadData];
}


- (void)doWebRequest {
    @autoreleasepool {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"通信中"];
      });


      NSString *identifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
      NSMutableArray *productIds = [NSMutableArray array];
      for (NSString *item in productIds_) {
        [productIds addObject:[identifier stringByAppendingFormat:@".%@", item]];
      }

      SKProductsRequest *request= [[SKProductsRequest alloc] 
        initWithProductIdentifiers:[NSSet setWithArray:productIds]];
      request.delegate = self;
      [request start];
    }
}

@end
