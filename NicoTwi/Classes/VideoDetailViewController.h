//
//  VideoDetailViewController.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/16.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
  PSCollectionViewDelegate, PSCollectionViewDataSource, MovieCellDelegate, AdBannerDelegate>

@property (strong, nonatomic) NSDictionary *videoDetail;

@end
