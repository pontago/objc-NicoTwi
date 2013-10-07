//
//  DataManager.m
//  TVJikkyoNow
//
//  Created by Pontago on 12/08/03.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"


NSString* const COREDATA_NAME    = @"appdata";
NSString* const MODEL_FAVORITE   = @"Favorite";
NSString* const MODEL_CLIP       = @"Clip";

@implementation DataManager

@synthesize managedObjectModel, persistentStoreCoordinator;
@synthesize contextList;

static DataManager *sharedDataManager = nil;

+ (DataManager*)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedDataManager = [[DataManager alloc] init];
    });
    return sharedDataManager;
}


- (NSManagedObjectModel*)getManagedObjectModel {
    if (self.managedObjectModel != nil) {
      return self.managedObjectModel;
    }

    NSString *modelPath = [[NSBundle mainBundle] pathForResource:COREDATA_NAME ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return self.managedObjectModel;
}

- (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator {
    if (self.persistentStoreCoordinator != nil) {
      return self.persistentStoreCoordinator;
    }
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeURL = [NSURL fileURLWithPath:
      [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", COREDATA_NAME]]];
    
    NSError *error = nil;
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
      [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
      nil];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
      initWithManagedObjectModel:[self getManagedObjectModel]];
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
        configuration:nil URL:storeURL options:options error:&error]) {
      LOG(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return self.persistentStoreCoordinator;
}

- (NSManagedObjectContext*)addManagedObjectContext {
    NSPersistentStoreCoordinator *coordinator = [self getPersistentStoreCoordinator];
    if (coordinator != nil) {
      NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
      [managedObjectContext setPersistentStoreCoordinator:coordinator];
      return managedObjectContext;
    }
    return nil;
}

- (NSManagedObjectContext*)managedObjectContext:(NSString*)keyName {
    if (keyName != nil) {
      if (self.contextList == nil) {
        self.contextList = [NSMutableDictionary dictionary];
      }

      NSManagedObjectContext *managedObjectContext = [self.contextList objectForKey:keyName];
      if (managedObjectContext == nil) {
        managedObjectContext = [self addManagedObjectContext];
        [self.contextList setObject:managedObjectContext forKey:keyName];
      }
      return managedObjectContext;
    }

    return nil;
}

@end
