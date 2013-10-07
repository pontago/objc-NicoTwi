//
//  DataManager.h
//  TVJikkyoNow
//
//  Created by Pontago on 12/08/03.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString* const MODEL_FAVORITE;
extern NSString* const MODEL_CLIP;

@interface DataManager : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    NSMutableDictionary *contextList;
}

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSMutableDictionary *contextList;

+ (DataManager*)sharedManager;

- (NSManagedObjectModel*)getManagedObjectModel;
- (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator;
- (NSManagedObjectContext*)addManagedObjectContext;
- (NSManagedObjectContext*)managedObjectContext:(NSString*)keyName;

@end
