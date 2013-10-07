//
//  WebRequest.h
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestResultBlock)(NSDictionary *results);

@interface WebRequest : NSObject

+ (WebRequest*)sharedInstance;

- (NSString*)stringByURLEncoding:(NSString*)string;
- (NSString*)htmlEntityDecode:(NSString*)string;

- (NSArray*)searchTweet:(NSDictionary*)params;
- (NSDictionary*)getNicoThumbInfo:(NSDictionary*)params;

- (NSDictionary*)searchVideo:(NSDictionary*)params;
- (NSDictionary*)relatedTweetFromVideo:(NSDictionary*)params;
- (NSDictionary*)videoDetail:(NSDictionary*)params;
- (NSDictionary*)relatedVideo:(NSDictionary*)params;

- (NSDictionary*)tagCount:(NSDictionary*)params;
- (NSDictionary*)tagList:(NSDictionary*)params;

@end
