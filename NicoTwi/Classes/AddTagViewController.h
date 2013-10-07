//
//  AddTagViewController.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/25.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddTagViewController;
@protocol AddTagViewControllerDelegate;

@interface AddTagViewController : UITableViewController

@property (unsafe_unretained, nonatomic) BOOL isCategory;
@property (unsafe_unretained, nonatomic) id<AddTagViewControllerDelegate> delegate;

@end


#pragma mark - Delegate

@protocol AddTagViewControllerDelegate <NSObject>

@optional
- (NSDictionary*)addTagViewController:(AddTagViewController*)addTagViewController request:(BOOL)isRequest;
- (BOOL)addTagViewController:(AddTagViewController*)addTagViewController editingStyle:(UITableViewCellEditingStyle)editingStyle
  tagName:(NSString*)tagName;

@end
