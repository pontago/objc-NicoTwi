//
//  SubTitleNavigationController.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/14.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "SubTitleNavigationController.h"

@interface SubTitleNavigationController ()

- (void)willEnterForeground_:(NSNotification *)notification;
- (void)popViewControllerAnimated_;

@end

@implementation SubTitleNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
//      rootViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] 
//        initWithImage:[UIImage imageNamed:ICON_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
//      rootViewController.navigationItem.titleView = [[SubTitleView alloc] 
//        initWithFrame:CGRectMake(0, 0, 0, 44)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CALayer *layer = self.navigationBar.layer;
    layer.masksToBounds = NO;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0.0, 0.0);
    layer.shadowRadius = 1.0;
    layer.shadowOpacity = 0.5;

    self.navigationBar.translucent = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground_:) 
      name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willEnterForeground_:(NSNotification *)notification {
    [self.visibleViewController viewWillAppear:YES];
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.viewControllers count] > 0) {
      viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
        initWithImage:[UIImage imageNamed:ICON_BACK] style:UIBarButtonItemStylePlain 
          target:self action:@selector(popViewControllerAnimated_)];
    }
    viewController.navigationItem.titleView = [[SubTitleView alloc] 
      initWithFrame:CGRectMake(0, 0, 0, 44)];


    [(SubTitleView*)viewController.navigationItem.titleView setTitleAndSubTitle:APP_NAME 
      subtitle:viewController.navigationItem.title];

    [super pushViewController:viewController animated:animated];
}


- (void)popViewControllerAnimated_ {
    [self popViewControllerAnimated:YES];
}

@end
