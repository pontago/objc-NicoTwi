//
//  ViewController.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/19.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate, PSCollectionViewDelegate, PSCollectionViewDataSource,
  TwitterViewDelegate, MovieCellDelegate, AdBannerDelegate> {
}

@property (strong, nonatomic) NSString *tagName;
@property (unsafe_unretained, nonatomic) BOOL isClipMode;

@end
