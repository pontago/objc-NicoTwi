//
//  Favorite.h
//  NicoTwi
//
//  Created by Pontago on 2013/05/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * watchId;
@property (nonatomic, retain) NSString * data;

@end
