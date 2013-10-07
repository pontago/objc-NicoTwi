//
//  DataHelper.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHelper : NSObject

+ (DataHelper*)sharedInstance;

- (BOOL)toggleFavorite:(NSDictionary*)videoInfo;
- (BOOL)isFavoriteWithVideoId:(NSString*)videoId;
- (NSDictionary*)favoriteVideosWithVideoIds:(NSArray*)videoIds;

- (BOOL)addClip:(NSString*)tagName checkLimit:(BOOL)checkLimit;
- (NSUInteger)clipCount;
- (NSArray*)clipTags;
- (BOOL)deleteClip:(NSString*)tagName;

@end
