//
//  DataHelper.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "DataHelper.h"

@implementation DataHelper

static DataHelper *sharedDataHelper = nil;

+ (DataHelper*)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedDataHelper = [[DataHelper alloc] init];
    });
    return sharedDataHelper;
}

- (BOOL)toggleFavorite:(NSDictionary*)videoInfo {
    NSString *videoId = [videoInfo objectForKey:@"video_id"];
    if ([videoId length] == 0) return NO;


    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_FAVORITE];
    NSManagedObjectModel *managedObjectModel = [[managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:videoId, @"videoId", nil];
    NSFetchRequest *fetchRequest = [managedObjectModel fetchRequestFromTemplateWithName:@"findByVideoId" 
      substitutionVariables:subs];
    Favorite *moFavorite;

    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
      for (moFavorite in fetchedObjects) {
        [managedObjectContext deleteObject:moFavorite];
      }

      if (![managedObjectContext save:&error]) {
        return NO;
      }
    }
    else {
//      NSRegularExpression *reNum = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" 
//        options:0 error:nil];
//      BOOL = [reNum numberOfMatchesInString:videoId options:0 range:NSMakeRange(0, [videoId length])];
      NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:videoInfo];
      [dic removeObjectForKey:@"tweet"];
      NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&error];

      moFavorite = [NSEntityDescription insertNewObjectForEntityForName:MODEL_FAVORITE
        inManagedObjectContext:managedObjectContext];
      moFavorite.videoId = videoId;
      moFavorite.watchId = videoId;
      moFavorite.data = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      moFavorite.createdAt = [NSDate date];

      if (![moFavorite.managedObjectContext save:&error]) {
        return NO;
      }
    }

    return YES;
}

- (BOOL)isFavoriteWithVideoId:(NSString*)videoId {
    if ([videoId length] == 0) return NO;

    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_FAVORITE];
    NSManagedObjectModel *managedObjectModel = [[managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:videoId, @"videoId", nil];
    NSFetchRequest *fetchRequest = [managedObjectModel fetchRequestFromTemplateWithName:@"findByVideoId" 
      substitutionVariables:subs];

    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (![fetchedObjects count]) {
      return NO;
    }

    return YES;
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


- (BOOL)addClip:(NSString*)tagName checkLimit:(BOOL)checkLimit {
    if ([tagName length] == 0) return NO;

    if (checkLimit) {
      NSUInteger clipCount = [self clipCount];
      if (clipCount >= MAX_CLIP) {
        [SVProgressHUD showErrorWithStatus:@"登録数オーバー"];
        return NO;
      }
    }


    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_CLIP];
    NSManagedObjectModel *managedObjectModel = [[managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:tagName, @"tagName", nil];
    NSFetchRequest *fetchRequest = [managedObjectModel fetchRequestFromTemplateWithName:@"findByTagName" 
      substitutionVariables:subs];

    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] == 0) {
      Clip *moClip = [NSEntityDescription insertNewObjectForEntityForName:MODEL_CLIP
        inManagedObjectContext:managedObjectContext];
      moClip.tagName = tagName;
      moClip.createdAt = [NSDate date];

      if ([moClip.managedObjectContext save:&error]) {
        return YES;
      }
    }
    else {
      [SVProgressHUD showErrorWithStatus:@"登録済みです"];
    }

    return NO;
}

- (NSUInteger)clipCount {
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_CLIP];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:MODEL_CLIP
      inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
      return [fetchedObjects count];
    }

    return 0;
}

- (NSArray*)clipTags {
    NSMutableArray *results = [NSMutableArray array];

    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_CLIP];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:MODEL_CLIP
      inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    Clip *moClip;

    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
      for (moClip in fetchedObjects) {
        [results addObject:moClip.tagName];
      }
    }

    return results;
}

- (BOOL)deleteClip:(NSString*)tagName {
    if ([tagName length] == 0) return NO;

    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext:MODEL_CLIP];
    NSManagedObjectModel *managedObjectModel = [[managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:tagName, @"tagName", nil];
    NSFetchRequest *fetchRequest = [managedObjectModel fetchRequestFromTemplateWithName:@"findByTagName" 
      substitutionVariables:subs];

    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
      Clip *moClip;
      for (moClip in fetchedObjects) {
        [managedObjectContext deleteObject:moClip];
      }

      if (![managedObjectContext save:&error]) {
        return NO;
      }
    }

    return YES;
}

@end
