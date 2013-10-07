//
//  SafeURLProtocol.m
//  TVJikkyoNow
//
//  Created by Pontago on 12/08/27.
//
//
//  http://iphone-dev.g.hatena.ne.jp/laiso/20111130/1322649990
//

#import "SafeURLProtocol.h"

@implementation SafeURLProtocol

+(BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSMutableArray* allowSchemes = [NSMutableArray arrayWithObjects:@"http", @"https", nil];
    NSMutableArray* allowURLs = [NSMutableArray array];
    NSArray* paths = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:nil];
    [paths enumerateObjectsUsingBlock:^(NSString* path, NSUInteger idx, BOOL *stop) {
        [allowURLs addObject:[NSString stringWithFormat:@"file://%@", path]];
    }];
    
    BOOL goodScheme = [allowSchemes containsObject:[request.URL scheme]];
    NSString* urlString = [request.URL description];
    BOOL goodURL = [allowURLs containsObject:urlString];
    return (goodScheme == NO && goodURL == NO);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSLog(@"[DEBUG] startLoading: %@", self.request.URL);
}

- (void)stopLoading
{
    NSLog(@"[DEBUG] stopLoading");
}

@end
