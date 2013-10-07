//
//  ActionMenuTableViewController.h
//  TVJikkyoNow
//
//  Created by Pontago on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionMenuTableViewController : UITableViewController {
}

@property (strong, nonatomic) NSArray *menuItems;
@property (unsafe_unretained, nonatomic) id delegate;
@property (strong, nonatomic) NSDictionary *params;
@property (strong, nonatomic) NSObject *actionObject;

- (id)initWithMenuItems:(NSArray*)menuItems delegate:(id)delegate;
- (void)presentModalFromBarButtonItem:(UIBarButtonItem*)sender inView:(UIView*)inView animated:(BOOL)animtaed;
- (void)presentModalAtPoint:(CGPoint)p inView:(UIView*)inView animated:(BOOL)animtaed;

@end
