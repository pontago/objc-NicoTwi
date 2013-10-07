//
//  FavoriteCache.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/21.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "FavoriteCache.h"

@implementation FavoriteCache

static FavoriteCache *sharedFavoriteCache = nil;

+ (FavoriteCache*)sharedCache {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedFavoriteCache = [[FavoriteCache alloc] init];
    });
    return sharedFavoriteCache;
}

- (void)reloadData:(NSArray*)videoIds {
    NSMutableArray *ids = [NSMutableArray array];

    for (NSString *videoId in videoIds) {
      NSNumber *num = [self objectForKey:videoId];
      if (!num) {
        [ids addObject:videoId];
      }
    }

    if ([ids count] > 0) {
      NSDictionary *favorites = [self favoriteVideosWithVideoIds:ids];
      if ([favorites count] > 0) {
        for (NSString *key in favorites) {
          [self setObject:[favorites objectForKey:key] forKey:key];
        }
      }
    }
}

- (NSDictionary*)favoriteVideosWithVideoIds:(NSArray*)videoIds {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSMutableArray *vars = [NSMutableArray array];

    for (NSString *videoId in videoIds) {
      [vars addObject:videoId];
      [results setObject:@NO forKey:videoId];
    }

    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_FAVORITE];
    NSManagedObjectModel *managedObjectModel = [[managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:vars, @"videoIds", nil];
    NSFetchRequest *fetchRequest = [managedObjectModel fetchRequestFromTemplateWithName:@"findByVideoIds" 
      substitutionVariables:subs];
    Favorite *moFavorite;

    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
      for (moFavorite in fetchedObjects) {
        [results setObject:@YES forKey:moFavorite.videoId];
      }
    }

    return results;
}

@end
