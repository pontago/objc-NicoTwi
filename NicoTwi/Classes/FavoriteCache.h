//
//  FavoriteCache.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/21.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteCache : NSCache

+ (FavoriteCache*)sharedCache;

- (void)reloadData:(NSArray*)videoIds;
- (NSDictionary*)favoriteVideosWithVideoIds:(NSArray*)videoIds;

@end
