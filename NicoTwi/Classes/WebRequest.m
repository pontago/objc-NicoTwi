//
//  WebRequest.m
//  NicoTwi
//
//  Created by Pontago on 2013/04/20.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "WebRequest.h"
#import "GDataXMLNode.h"
#import "GTMNSString+HTML.h"

NSString* const API_TW_SEARCH           = @"http://api.twitter.com/1.1/search/tweets.json";
NSString* const API_NICO_GETTHUMBINFO   = @"http://flapi.nicovideo.jp/api/getthumbinfo/";
NSString* const API_NICO_RELATED_VIDEO  = @"http://flapi.nicovideo.jp/api/getrelation";

#ifdef DEBUG
//  NSString* const API_SEARCH_VIDEO       = @"http://192.168.2.8:3000/ios/video/timeline.json";
//  NSString* const API_RELATED_TWEET      = @"http://192.168.2.8:3000/ios/video/tweets.json";
//  NSString* const API_VIDEO_DETAIL       = @"http://192.168.2.8:3000/ios/video/detail.json";
//  NSString* const API_TAG_SEARCH         = @"http://192.168.2.8:3000/ios/tag/search.json";
//  NSString* const API_TAG_LIST           = @"http://192.168.2.8:3000/ios/tag/list.json";
  NSString* const API_SEARCH_VIDEO       = @"http://www.nicotwi.com/ios/video/timeline.json";
  NSString* const API_RELATED_TWEET      = @"http://www.nicotwi.com/ios/video/tweets.json";
  NSString* const API_VIDEO_DETAIL       = @"http://www.nicotwi.com/ios/video/detail.json";
  NSString* const API_TAG_SEARCH         = @"http://www.nicotwi.com/ios/tag/search.json";
  NSString* const API_TAG_LIST           = @"http://www.nicotwi.com/ios/tag/list.json";
#else
  NSString* const API_SEARCH_VIDEO       = @"http://www.nicotwi.com/ios/video/timeline.json";
  NSString* const API_RELATED_TWEET      = @"http://www.nicotwi.com/ios/video/tweets.json";
  NSString* const API_VIDEO_DETAIL       = @"http://www.nicotwi.com/ios/video/detail.json";
  NSString* const API_TAG_SEARCH         = @"http://www.nicotwi.com/ios/tag/search.json";
  NSString* const API_TAG_LIST           = @"http://www.nicotwi.com/ios/tag/list.json";
#endif

NSTimeInterval const REQUEST_TIMEOUT    = 20.0;

@interface WebRequest () {
}

- (NSDictionary*)convertVideoInfo_:(NSDictionary*)item;

@end

@implementation WebRequest

static WebRequest *sharedWebRequest = nil;

+ (WebRequest*)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedWebRequest = [[WebRequest alloc] init];
    });
    return sharedWebRequest;
}


- (NSString*)stringByURLEncoding:(NSString*)string {
    NSString *encodedString = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
      (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return encodedString;
}

- (NSString*)htmlEntityDecode:(NSString*)string {
    return [string gtm_stringByUnescapingFromHTML];
}


- (NSArray*)searchTweet:(NSDictionary*)params {
    UserConfig *userConfig = [UserConfig sharedInstance];
    NSString *twIdentifier = [userConfig getConfig:@"TWITTER_IDENTIFIER"];
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:twIdentifier];

    NSString *keyword = [NSString stringWithFormat:@"%@ %@",
      [params objectForKey:@"keyword"], [params objectForKey:@"excludeIds"]];
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:API_TW_SEARCH] 
      parameters:[NSDictionary dictionaryWithObjectsAndKeys:
        [self stringByURLEncoding:keyword], @"q", 
        [params objectForKey:@"rpp"], @"count", 
        @"recent", @"result_type", 
        @"true", @"include_entities",
        [params objectForKey:@"sinceId"], @"since_id", nil] 
      requestMethod:TWRequestMethodGET];
    [request setAccount:account];

    NSHTTPURLResponse *httpResponse;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:[request signedURLRequest] returningResponse:&httpResponse error:&error];

    if (!error) {
      if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        NSMutableArray *results = [NSMutableArray array];

        if (!error) {
          NSArray *items = [json objectForKey:@"statuses"];
          if (items && [items count] > 0) {
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setLocale:locale];
            [formatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZZZ yyyy"];

            UtilEx *util = [UtilEx sharedInstance];
            for (NSDictionary *item in items) {
              NSDictionary *entities = [item objectForKey:@"entities"];
              NSDictionary *url = [entities objectForKey:@"url"];
              NSArray *movieIds = [util parseMovieIdFromTweet:[item objectForKey:@"text"] 
                urls:[url objectForKey:@"urls"]];

              NSDictionary *userItems = [item objectForKey:@"user"];
              NSMutableDictionary *twItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  [userItems objectForKey:@"name"], @"name", 
                  [userItems objectForKey:@"screen_name"], @"screen_name", 
                  [userItems objectForKey:@"profile_image_url"], @"profile_image_url", 
                  [formatter dateFromString:[item objectForKey:@"created_at"]], @"createdAt", 
                  [item objectForKey:@"id_str"], @"id_str", 
                  [item objectForKey:@"text"], @"text", 
                  [item objectForKey:@"entities"], @"entities", 
                  movieIds, @"movieIds", 
                nil];

              [results addObject:twItem];
            }
          }
        }

        return results;
      }
    };

    return nil;
}

- (NSDictionary*)getNicoThumbInfo:(NSDictionary*)params {
    NSString *url = [NSString stringWithFormat:@"%@%@", API_NICO_GETTHUMBINFO, [params objectForKey:@"videoId"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:REQUEST_TIMEOUT];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    if (!error) {
      NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

      NSMutableDictionary *results = [NSMutableDictionary dictionary];
      NSMutableArray *tagList = [NSMutableArray array];
      GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:responseString options:0 error:&error];
      GDataXMLElement *rootNode = [document rootElement];

      NSArray *nodeList = [rootNode nodesForXPath:@"//thumb/*" error:&error];
      for (GDataXMLNode *node in nodeList) {
        if (![node.name isEqualToString:@"tags"]) {
          [results setObject:[node stringValue] forKey:node.name];
        }
      }

      nodeList = [rootNode nodesForXPath:@"//thumb/tags[@domain='jp']/*" error:&error];
      if ([nodeList count]) {
        for (GDataXMLNode *node in nodeList) {
          [tagList addObject:[node stringValue]];
        }
      }


      if ([results count] > 0) {
        return @{ @"video":results, @"tags":tagList };
      }
    }

    return nil;
}

- (NSDictionary*)searchVideo:(NSDictionary*)params {
    NSArray *tags = [params objectForKey:@"tags"];
    NSString *tagStr = @"";
    if (tags) {
      tagStr = [tags componentsJoinedByString:@" "];
    }

    NSString *url = [NSString stringWithFormat:@"%@?ts=%llu&offset=%d&tag=%@", API_SEARCH_VIDEO, 
      (long long int)[[params objectForKey:@"ts"] timeIntervalSince1970],
      [[params objectForKey:@"offset"] intValue],
      [[UtilEx sharedInstance] stringByURLEncoding:tagStr]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    if (!error) {
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];

      if (!error) {
        return json;
      }
    }

    return nil;
}

//- (void)searchVideo:(NSDictionary*)params block:(RequestResultBlock)block {
//    NSArray *tags = [params objectForKey:@"tags"];
//    NSString *tagStr = @"";
//    if (tags) {
//      tagStr = [tags componentsJoinedByString:@" "];
//    }
//
//    NSString *url = [NSString stringWithFormat:@"%@?ts=%llu&offset=%d&tag=%@", API_SEARCH_VIDEO, 
//      (long long int)[[params objectForKey:@"ts"] timeIntervalSince1970],
//      [[params objectForKey:@"offset"] intValue],
//      [[UtilEx sharedInstance] stringByURLEncoding:tagStr]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
//      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
//
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
//      success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        block(JSON);
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        LOG(@"a - %@", error);
//    }];
//    [operation start];
//}

- (NSDictionary*)relatedTweetFromVideo:(NSDictionary*)params {
    NSString *url = [NSString stringWithFormat:@"%@?id=%d&offset=%d", API_RELATED_TWEET, 
      [[params objectForKey:@"videoId"] intValue],
      [[params objectForKey:@"offset"] intValue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:REQUEST_TIMEOUT];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    if (!error) {
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];

      if (!error) {
        return json;
      }
    }

    return nil;
}

- (NSDictionary*)videoDetail:(NSDictionary*)params {
    NSString *url = [NSString stringWithFormat:@"%@?id=%d", API_VIDEO_DETAIL, 
      [[params objectForKey:@"videoId"] intValue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:REQUEST_TIMEOUT];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    if (!error) {
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];

      if (!error) {
        return json;
      }
    }

    return nil;
}

- (NSDictionary*)relatedVideo:(NSDictionary*)params {
    NSString *url = [NSString stringWithFormat:@"%@?video=%@&page=%d&sort=p&order=d", API_NICO_RELATED_VIDEO, 
      [params objectForKey:@"videoId"],
      [[params objectForKey:@"page"] intValue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:REQUEST_TIMEOUT];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    if (!error) {
      NSMutableArray *results = [NSMutableArray array];
      NSString *nextPage = [params objectForKey:@"page"];
      NSString *totalCountStr = @"0";

//      if ([request responseStatusCode] >= 200 && [request responseStatusCode] < 300) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:responseString options:0 error:&error];
        GDataXMLElement *rootNode = [document rootElement];
        NSArray *nodeList = [rootNode nodesForXPath:@"//video" error:&error];

        for (GDataXMLElement *node in nodeList) {
          NSArray *nodeChildList = [node children];
          NSMutableDictionary *item = [NSMutableDictionary dictionary];
          for (GDataXMLNode *nodeChild in nodeChildList) {
            [item setObject:[nodeChild stringValue] forKey:nodeChild.name];
          }
          [results addObject:[self convertVideoInfo_:item]];
        }

        NSArray *elmPageCount = [rootNode elementsForName:@"page_count"];
        NSArray *elmTotalCount = [rootNode elementsForName:@"total_count"];
        totalCountStr = [[elmTotalCount objectAtIndex:0] stringValue];
        NSUInteger pageCount = [[[elmPageCount objectAtIndex:0] stringValue] intValue];
        NSUInteger currentPage = [[params objectForKey:@"page"] intValue];

        if ((currentPage + 1) <= pageCount) {
          nextPage = [@(currentPage  + 1) stringValue];
        }
//      }

      return [NSDictionary dictionaryWithObjectsAndKeys:
        results, @"items",
        nextPage, @"nextPage", 
        totalCountStr, @"totalCount", nil];
    }

    return nil;
}

- (NSDictionary*)convertVideoInfo_:(NSDictionary*)item {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setObject:[self htmlEntityDecode:[item objectForKey:@"title"]] forKey:@"title"];

    NSString *val = [item objectForKey:@"time"];
    if (val) {
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
      [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
      [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzz"];

      NSDate *date = [NSDate dateWithTimeIntervalSince1970:[val intValue]];
      [dict setObject:[formatter stringFromDate:date] forKey:@"first_retrieve"];
    }

    val = [item objectForKey:@"thumbnail"];
    if (val) {
      [dict setObject:val forKey:@"thumbnail_url"];
    }

    val = [item objectForKey:@"comment"];
    if (val) {
      [dict setObject:[[UtilEx sharedInstance] numberFormatFromString:val] forKey:@"comment_num"];
    }
    val = [item objectForKey:@"view"];
    if (val) {
      [dict setObject:[[UtilEx sharedInstance] numberFormatFromString:val] forKey:@"view_counter"];
    }
    val = [item objectForKey:@"mylist"];
    if (val) {
      [dict setObject:[[UtilEx sharedInstance] numberFormatFromString:val] forKey:@"mylist_counter"];
    }

    val = [item objectForKey:@"length"];
    if (val) {
      NSNumber *videoLength = [NSNumber numberWithInt:[val intValue]];
      [dict setObject:[[UtilEx sharedInstance] timeFormatFromNumber:videoLength] forKey:@"length"];
    }


    val = [item objectForKey:@"url"];
    NSRegularExpression *reMovieId = [NSRegularExpression regularExpressionWithPattern:@"watch/(.+)" 
      options:0 error:nil];
    [reMovieId enumerateMatchesInString:val options:0 range:NSMakeRange(0, val.length) 
      usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
        if ([match numberOfRanges] == 2) {
          NSString *movieId = [val substringWithRange:[match rangeAtIndex:1]];
          [dict setObject:movieId forKey:@"video_id"];
          *stop = YES;
        }
      }];


    return dict;
}


- (NSDictionary*)tagCount:(NSDictionary*)params {
    NSArray *tags = [params objectForKey:@"tags"];
    NSString *tagStr = @"";
    if (tags) {
      tagStr = [tags componentsJoinedByString:@" "];
    }

    NSString *url = [NSString stringWithFormat:@"%@?name=%@", API_TAG_SEARCH, 
      [[UtilEx sharedInstance] stringByURLEncoding:tagStr]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:REQUEST_TIMEOUT];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    if (!error) {
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];

      if (!error) {
        return json;
      }
    }

    return nil;
}

- (NSDictionary*)tagList:(NSDictionary*)params {
    NSString *url = [NSString stringWithFormat:@"%@", API_TAG_LIST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:REQUEST_TIMEOUT];
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    if (!error) {
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];

      if (!error) {
        return json;
      }
    }

    return nil;
}

@end
