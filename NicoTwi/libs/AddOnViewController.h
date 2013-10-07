//
//  AddOnViewController.h
//  TVJikkyoNow
//
//  Created by Pontago on 2012/12/02.
//
//

#import <UIKit/UIKit.h>

@interface AddOnViewController : UITableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver, 
  UIActionSheetDelegate> {

    NSMutableArray *addOnItems_;
    NSArray *productIds_;
}

- (void)doWebRequest;

@end
