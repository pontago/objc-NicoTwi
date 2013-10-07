//
//  MovieCell.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class MovieCell;
@protocol MovieCellDelegate;

@interface MovieCell : PSCollectionViewCell

@property (strong, nonatomic) VideoThumbnail *videoThumb;
@property (strong, nonatomic) TwitterView *twitterView;

@property (strong, nonatomic) NSDictionary *videoInfo;
@property (strong, nonatomic) NSString *videoTitle;
@property (strong, nonatomic) NSString *videoLength;

@property (strong, nonatomic) NSString *viewCounter;
@property (strong, nonatomic) NSString *commentNum;

@property (unsafe_unretained, nonatomic) id<MovieCellDelegate> delegate;

- (void)showThumbnailImage:(UIImage*)image star:(BOOL)star;
- (void)showThumbnailImage:(UIImage*)image;

@end


#pragma mark - Delegate

@protocol MovieCellDelegate <NSObject>

@optional
- (void)cell:(MovieCell*)cell didSelect:(UIGestureRecognizerState)state;
- (void)cell:(MovieCell*)cell didSwipe:(UISwipeGestureRecognizer*)gestureRecognizer;

@end
