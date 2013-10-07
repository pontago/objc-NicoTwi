//
//  WebRequestTest.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "WebRequestTest.h"
#import "WebRequest.h"

@interface WebRequestTest () {
    WebRequest *request_;
}
@end

@implementation WebRequestTest

- (void)setUp {
    [super setUp];

    request_ = [WebRequest sharedInstance];
}

- (void)tearDown {
    [super tearDown];

    request_ = nil;
}


- (void)testSearchTweet {
    NSString *keyword = SEARCH_KEYWORD;
    NSString *excludeIds = @"";
    NSString *rpp = @"100";
    NSArray *results = [request_ searchTweet:[NSDictionary dictionaryWithObjectsAndKeys:
        keyword, @"keyword", 
        rpp, @"rpp", 
        excludeIds, @"excludeIds", 
        nil, @"sinceId", 
      nil]];

    STAssertNotNil(results, @"ツイート検索失敗");

    NSDictionary *item = [results objectAtIndex:0];
    STAssertFalse([[item objectForKey:@"text"] isEqualToString:@""], @"ツイート内容取得失敗");
}

- (void)testGetNicoThumbInfo {
    NSDictionary *result = [request_ getNicoThumbInfo:[NSDictionary dictionaryWithObjectsAndKeys:
        @"sm9", @"movieId", 
      nil]];

    STAssertNotNil(result, @"動画情報取得失敗");
    STAssertFalse([[result objectForKey:@"title"] isEqualToString:@""], @"動画タイトル取得失敗");

    NSArray *tags = [result objectForKey:@"tags"];
    STAssertTrue([tags count] > 0, @"動画タグ取得失敗");


    result = [request_ getNicoThumbInfo:[NSDictionary dictionaryWithObjectsAndKeys:
        @"sm20667520", @"movieId", 
      nil]];

    STAssertNil(result, @"動画情報取得失敗");
}

@end
