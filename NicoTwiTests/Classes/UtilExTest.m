//
//  UtilExTest.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/21.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "UtilExTest.h"
#import "UtilEx.h"

@interface UtilExTest () {
    UtilEx *util_;
}
@end

@implementation UtilExTest

- (void)setUp {
    [super setUp];

    util_ = [UtilEx sharedInstance];
}

- (void)tearDown {
    [super tearDown];

    util_ = nil;
}


- (void)testDirectoriesMethods {
    NSString *documentDirectory = [util_ documentDirectory];
    NSString *cachesDirectory = [util_ cachesDirectory];

    STAssertNotNil(documentDirectory, @"ドキュメントディレクトリ取得失敗");
    STAssertNotNil(cachesDirectory, @"キャッシュディレクトリ取得失敗");
}

- (void)testParseNicoMovieIds {
    NSString *text = @"http://www.nicovideo.jp/watch/sm9";

    NSArray *movieIds = [util_ parseNicoMovieIds:text];
    STAssertNotNil(movieIds, @"URLに含んだ動画ID抽出失敗");
    STAssertTrue([movieIds count] == 1, @"抽出した動画IDが1ではない");
    STAssertTrue([[movieIds objectAtIndex:0] isEqualToString:@"sm9"], @"抽出した動画IDがsm9ではない");

    text = @"sm9 sm10";
    movieIds = [util_ parseNicoMovieIds:text];
    STAssertNotNil(movieIds, @"テキストに含まれた複数動画ID抽出失敗");
    STAssertTrue([movieIds count] == 2, @"抽出した動画IDが2ではない");
    STAssertTrue([[movieIds objectAtIndex:0] isEqualToString:@"sm9"], @"抽出した動画IDがsm9ではない");
    STAssertTrue([[movieIds objectAtIndex:1] isEqualToString:@"sm10"], @"抽出した動画IDがsm10ではない");

    text = @"sm9 nm9 so9";
    movieIds = [util_ parseNicoMovieIds:text];
    STAssertNotNil(movieIds, @"sm,nm,soの接頭辞の動画ID抽出失敗");
    STAssertTrue([movieIds count] == 3, @"抽出した動画IDが3ではない");

    text = @"sm9 sm9";
    movieIds = [util_ parseNicoMovieIds:text];
    STAssertNotNil(movieIds, @"重複した動画ID抽出失敗");
    STAssertTrue([movieIds count] == 1, @"重複した動画IDがユニークになって返されてない");
}

- (void)testParseMovieIdFromTweet {
    NSString *text = @"sm10";
    NSArray *urls = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
      @"http://www.nicovideo.jp/watch/sm9", @"expanded_url", nil]];

    NSArray *movieIds = [util_ parseMovieIdFromTweet:text urls:urls];
    STAssertNotNil(movieIds, @"動画ID抽出失敗");
    STAssertTrue([movieIds count] == 2, @"抽出した動画IDが2ではない");
    STAssertTrue([[movieIds objectAtIndex:0] isEqualToString:@"sm9"], @"抽出した動画IDがsm9ではない");
    STAssertTrue([[movieIds objectAtIndex:1] isEqualToString:@"sm10"], @"抽出した動画IDがsm10ではない");
}

@end
