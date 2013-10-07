//
//  UtilEx.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/21.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "UtilEx.h"
#import "AppDelegate.h"


NSString* const URL_NICO_HOME       = @"http://www.nicovideo.jp";
NSString* const URL_NICO_WATCH      = @"http://www.nicovideo.jp/watch/";
NSString* const URL_NICO_COMMUNITY  = @"http://com.nicovideo.jp/community/";

@interface UtilEx () {
    CALayer *imageLayer_;
}

@end

@implementation UtilEx

static UtilEx *sharedUtilEx = nil;

+ (UtilEx*)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedUtilEx = [[UtilEx alloc] init];
    });
    return sharedUtilEx;
}


- (NSString*)documentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString*)cachesDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString*)stringByURLEncoding:(NSString*)string {
    NSString *encodedString = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
      (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return encodedString;
}

- (NSArray*)parseNicoMovieIds:(NSString*)text {
    NSMutableSet *results = [NSMutableSet set];
    NSRegularExpression *reMovieId = [NSRegularExpression regularExpressionWithPattern:@"watch/([0-9]+)" 
      options:0 error:nil];
    NSRegularExpression *reMovieId2 = [NSRegularExpression regularExpressionWithPattern:@"(sm[0-9]+|nm[0-9]+|so[0-9]+)" 
      options:0 error:nil];

    [reMovieId enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) 
      usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
        if ([match numberOfRanges] == 2) {
          NSString *movieId = [text substringWithRange:[match rangeAtIndex:1]];
          [results addObject:movieId];
        }
      }];

    [reMovieId2 enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) 
      usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
        if ([match numberOfRanges] == 2) {
          NSString *movieId = [text substringWithRange:[match rangeAtIndex:1]];
          [results addObject:movieId];
        }
      }];

    return [results count] > 0 ? [results allObjects] : nil;
}

- (NSArray*)parseMovieIdFromTweet:(NSString*)text urls:(NSArray*)urls {
    NSString *tmp = text;

    for (NSDictionary *url in urls) {
      tmp = [tmp stringByAppendingString:[url objectForKey:@"expanded_url"]];
    }

    return [self parseNicoMovieIds:tmp];
}

- (NSArray*)nicoCategories {
    return @[@"音楽", @"エンターテイメント", @"アニメ", @"ゲーム", @"ラジオ", @"スポーツ",
      @"科学", @"料理", @"政治", @"動物", @"歴史", @"自然", @"ニコニコ動画講座",
      @"演奏してみた", @"歌ってみた", @"踊ってみた", @"描いてみた", @"ニコニコ技術部",
      @"アイドルマスター", @"東方", @"VOCALOID",
//      @"アイドルマスター", @"東方", @"VOCALOID", @"例のアレ", @"日記", @"その他",
      @"ニコニコインディーズ", @"旅行", @"車載動画", @"ニコニコ手芸部", @"作ってみた"];
}

- (NSString*)parseNumNicoVideoId:(NSString*)videoId {
    NSRegularExpression *reVideoId = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)" 
      options:0 error:nil];
    __block NSString *numVideoId;

    [reVideoId enumerateMatchesInString:videoId options:0 range:NSMakeRange(0, videoId.length) 
      usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
        if ([match numberOfRanges] == 2) {
          numVideoId = [videoId substringWithRange:[match rangeAtIndex:1]];
        }
      }];

    return numVideoId;
}


- (UIImage*)roundCornersOfImage:(UIImage*)image cornerRadius:(CGFloat)cornerRadius {
    if (!imageLayer_) {
      imageLayer_ = [CALayer layer];
      imageLayer_.masksToBounds = YES;
      imageLayer_.cornerRadius = cornerRadius;
    }
    imageLayer_.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer_.contents = (__bridge id)image.CGImage;

    UIGraphicsBeginImageContextWithOptions(imageLayer_.frame.size, NO, [UIScreen mainScreen].scale);
    [imageLayer_ renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return roundedImage;
}

- (NSString*)twDateString:(NSDate*)date shortFormat:(BOOL)shortFormat {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *diff = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
        NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) 
      fromDate:date toDate:now options:0];


    NSString *buffer;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    if (shortFormat) {
      [outputFormatter setDateFormat:@"YYYY/MM/dd"];
    }
    else {
      [outputFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    }

    if ([diff year] > 0 || [diff month] > 0 || [diff day] > 0) {
      buffer = [outputFormatter stringFromDate:date];
    }
    else if ([diff hour] > 0) {
      buffer = [NSString stringWithFormat:@"%d時間前", [diff hour]];
    }
    else if ([diff minute] > 0) {
      buffer = [NSString stringWithFormat:@"%d分前", [diff minute]];
    }
    else {
      buffer = [NSString stringWithFormat:@"%d秒前", [diff second]];
    }

    return buffer;
}

- (NSString*)numberFormatFromString:(NSString*)string {
    NSNumberFormatter *formatter= [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"#,##0"];
    NSNumber *num = [NSNumber numberWithLongLong:[string longLongValue]];
    NSString *result = [formatter stringFromNumber:num];
    return result;
}

- (NSString*)timeFormatFromNumber:(NSNumber*)num {
    NSInteger length = [num intValue];
    return [NSString stringWithFormat:@"%d:%02d", length / 60, length % 60];
}


- (NSString*)replaceUrlAndMovieIdFromText:(NSString*)body {
    NSRegularExpression *reMyList = [NSRegularExpression regularExpressionWithPattern:@"(mylist/[0-9]+)" 
      options:0 error:nil];
    NSRegularExpression *reUser = [NSRegularExpression regularExpressionWithPattern:@"(user/[0-9]+)" 
      options:0 error:nil];
    NSRegularExpression *reCommunity = [NSRegularExpression regularExpressionWithPattern:@"(co[0-9]+)" 
      options:0 error:nil];
    NSRegularExpression *reMovieId = [NSRegularExpression regularExpressionWithPattern:@"watch/([0-9]+)" 
      options:0 error:nil];
    NSRegularExpression *reMovieId2 = [NSRegularExpression regularExpressionWithPattern:@"((sm|nm|so)[0-9]+)" 
      options:0 error:nil];

    body = [reMyList stringByReplacingMatchesInString:body
      options:0 range:NSMakeRange(0, body.length) 
      withTemplate:[NSString stringWithFormat:@"<a href=\"%@/$1\">$1</a>", URL_NICO_HOME]];
    body = [reUser stringByReplacingMatchesInString:body
      options:0 range:NSMakeRange(0, body.length) 
      withTemplate:[NSString stringWithFormat:@"<a href=\"%@/$1\">$1</a>", URL_NICO_HOME]];
    body = [reCommunity stringByReplacingMatchesInString:body
      options:0 range:NSMakeRange(0, body.length) 
      withTemplate:[NSString stringWithFormat:@"<a href=\"%@$1\">$1</a>", URL_NICO_COMMUNITY]];
    body = [reMovieId stringByReplacingMatchesInString:body
      options:0 range:NSMakeRange(0, body.length) 
      withTemplate:[NSString stringWithFormat:@"<a href=\"%@/watch/$1\">watch/$1</a>", URL_NICO_HOME]];
    body = [reMovieId2 stringByReplacingMatchesInString:body
      options:0 range:NSMakeRange(0, body.length) 
      withTemplate:[NSString stringWithFormat:@"<a href=\"%@/watch/$1\">$1</a>", URL_NICO_HOME]];

    return body;
}

- (NSString*)replaceUrlTagFromText:(NSArray*)tags delimiter:(NSString*)delimiter {
    NSMutableArray *tmp = [NSMutableArray array];

    for (NSString *tag in tags) {
      [tmp addObject:[NSString stringWithFormat:@"<a href=\"%@/tag/%@\">%@</a>", URL_NICO_HOME, tag, tag]];
    }

    return [tmp componentsJoinedByString:delimiter];
}

- (NSString*)replaceTwitterProfileImageMini:(NSString*)url {
    return [url stringByReplacingOccurrencesOfString:@"_normal." 
      withString:@"_mini." options:NSBackwardsSearch range:NSMakeRange(0, url.length)];
}


- (void)openVideo:(NSString*)videoId {
    NSURL *url;
    NSString *openVideoApp = [[UserConfig sharedInstance] getConfig:@"OPEN_VIDEO_APP"];

    if ([openVideoApp isEqualToString:OPEN_VIDEO_APP_OFFICIAL]) {
      url = [NSURL URLWithString:[NSString stringWithFormat:@"nicovideo://%@", videoId]];
    }
    else if ([openVideoApp isEqualToString:OPEN_VIDEO_APP_SMILEPLAYER]) {
      url = [NSURL URLWithString:[NSString stringWithFormat:@"smileplayer://play/%@", videoId]];
    }
    else if ([openVideoApp isEqualToString:OPEN_VIDEO_APP_SAFARI]) {
      url = [NSURL URLWithString:[URL_NICO_WATCH stringByAppendingString:videoId]];
    }
    else if ([openVideoApp isEqualToString:OPEN_VIDEO_APP_BUILTIN]) {
      url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@", URL_SCHEME, URL_SCHEME_URL, 
        [URL_NICO_WATCH stringByAppendingString:videoId]]];
    }

    if (url) {
      if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
      }
      else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URL_NICO_WATCH stringByAppendingString:videoId]]];
      }
    }
}

- (void)openNicoUrl:(NSURL*)url {
    NSString *urlStr = [url absoluteString];
    NSURL *openUrl;
    NSString *openUrlApp = [[UserConfig sharedInstance] getConfig:@"OPEN_URL_APP"];

    if ([urlStr hasPrefix:URL_NICO_WATCH]) {
      [self openVideo:[url lastPathComponent]];
      return;
    }
    else {
      if ([openUrlApp isEqualToString:OPEN_VIDEO_APP_SAFARI]) {
        openUrl = [NSURL URLWithString:urlStr];
      }
      else if ([openUrlApp isEqualToString:OPEN_VIDEO_APP_BUILTIN]) {
        openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@", URL_SCHEME, URL_SCHEME_URL, urlStr]];
      }
    }

    if (openUrl) {
      if ([[UIApplication sharedApplication] canOpenURL:openUrl]) {
        [[UIApplication sharedApplication] openURL:openUrl];
      }
      else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
      }
    }
}

- (void)openTweet:(NSString*)statusId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://status?id=%@",
      OPEN_TWITTER_APP_OFFICIAL, statusId]];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
      [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openTwitterUser:(NSString*)screenName {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:@%@",
      OPEN_TWITTER_APP_OFFICIAL, screenName]];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
      [[UIApplication sharedApplication] openURL:url];
    }
}


- (TWTweetComposeViewController*)postTweet:(NSString*)title videoId:(NSString*)videoId {
    TWTweetComposeViewController *twViewController = [[TWTweetComposeViewController alloc] init];
    NSString *initialText = [NSString stringWithFormat:@"%@ #%@ %@", title, videoId, TWITTER_HASHTAG];

    [twViewController addURL:
      [NSURL URLWithString:[URL_NICO_WATCH stringByAppendingString:videoId]]];
    [twViewController setInitialText:initialText];

    return twViewController;
}

- (CGSize)applicationSize {
    CGSize size;

    size = [UIScreen mainScreen].applicationFrame.size;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
      size.height -= 40.0f;
    }

    return size;
}

@end
