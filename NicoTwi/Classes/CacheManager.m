//
//  CacheManager.m
//  NicoTwi
//
//  Created by Pontago on 2013/05/08.
//  Copyright (c) 2013年 Pontago. All rights reserved.
//

#import "CacheManager.h"
#import <CommonCrypto/CommonHMAC.h>

NSString* const CACHE_IMAGE_DIRECTORY = @"image";

@interface CacheManager () {
    NSFileManager *fileManager_;
    NSOperationQueue *diskIOQueue_, *httpQueue_;
    NSMutableDictionary *connections_;
}

- (NSString*)cacheFileName:(NSString*)url;
- (NSString*)createCachePath:(NSString*)url;
- (void)saveToDisk:(NSData*)data path:(NSString*)path;

@end

@implementation CacheManager

@synthesize enableDiskCache;

static CacheManager *sharedCacheManager = nil;

+ (CacheManager*)sharedCache {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedCacheManager = [[CacheManager alloc] init];
    });
    return sharedCacheManager;
}

- (id)init {
    self = [super init];
    if (self) {
      fileManager_ = [[NSFileManager alloc] init];
      enableDiskCache = NO;

      diskIOQueue_ = [[NSOperationQueue alloc] init];
      [diskIOQueue_ setMaxConcurrentOperationCount:1];

      httpQueue_ = [[NSOperationQueue alloc] init];
      [httpQueue_ setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
//      [httpQueue_ setMaxConcurrentOperationCount:2];

      connections_ = [NSMutableDictionary dictionary];

//      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) 
//        name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//- (void)didReceiveMemoryWarning:(NSNotification *)notif {
//LOG(@"AAAA");
//    [self removeAllObjects];
//}

- (void)downloadImage:(NSString*)url block:(ImageResultBlock)block {
    [self downloadImage:url resize:CGSizeZero block:block];
}

- (void)downloadImage:(NSString*)url resize:(CGSize)resize block:(ImageResultBlock)block {
    [self downloadImage:url resize:CGSizeZero cornerRadius:0.0 block:block];
}

- (void)downloadImage:(NSString*)url resize:(CGSize)resize cornerRadius:(CGFloat)cornerRadius block:(ImageResultBlock)block {
    UIImage *image = [self objectForKey:url];
    if (image) {
      if (block) block(image);
    }
    else {
      NSDictionary *dict = [connections_ objectForKey:url];
      if (dict) {
        @synchronized(self) {
          NSMutableArray *finishBlocks = dict[@"finishBlocks"];
          [finishBlocks addObject:block];
        }
        return;
      }


      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
      AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request 
        imageProcessingBlock:^UIImage *(UIImage *image) {
          if (image) {
            if (resize.height != 0.0 && resize.width != 0.0) {
              image = [image imageByShrinkingWithSize:resize];
            }
//            if (cornerRadius > 0.0) {
//              image = [[UtilEx sharedInstance] roundCornersOfImage:image cornerRadius:cornerRadius];
//            }
          }
          return image;
        }
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
          if (image) {
            [self setObject:image forKey:url];

            if (enableDiskCache) {
              [diskIOQueue_ addOperationWithBlock:^{
                NSString *path = [self createCachePath:url];
                [self saveToDisk:UIImageJPEGRepresentation(image, 1.0) path:path];
              }];
            }

            if (block) block(image);

            NSDictionary *connection = [connections_ objectForKey:url];
            NSMutableArray *finishBlocks = connection[@"finishBlocks"];
            if ([finishBlocks count] > 0) {
              for (ImageResultBlock finishBlock in finishBlocks) {
                finishBlock(image);
              }
            }
          }

          @synchronized(self) {
            [connections_ removeObjectForKey:url];
          }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
          @synchronized(self) {
            [connections_ removeObjectForKey:url];
          }
        }];


      if (cornerRadius > 0.0) {
        [operation setQueuePriority:NSOperationQueuePriorityLow];
      }

      @synchronized(self) {
        [connections_ setObject:@{ @"operation":operation, @"finishBlocks":[NSMutableArray array] } 
          forKey:url];
        [httpQueue_ addOperation:operation];
      }
    }
}


- (void)cancelRequestForUrls:(NSArray*)urls {
    @synchronized(self) {
      for (NSString *key in urls) {
        NSDictionary *dict = [connections_ objectForKey:key];
        AFImageRequestOperation *operation = dict[@"operation"];
        if (operation) {
          [operation cancel];
          [connections_ removeObjectForKey:key];
        }
      }
    }
}

- (void)cancelAllRequest {
    @synchronized(self) {
      for (AFImageRequestOperation *operation in httpQueue_.operations) {
        [operation cancel];
      }
      [connections_ removeAllObjects];
    }
}


- (UIImage*)cacheImageWithUrl:(NSString*)url {
    UIImage *image = [self objectForKey:url];

    if (!image) {
      NSString *path = [self createCachePath:url];
//      image = [UIImage imageWithContentsOfFile:path];
      image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path options:0 error:NULL]];
      if (image) {
        [self setObject:image forKey:url];
      }
    }

    return image;
}

- (void)cacheImageWithUrl:(NSString*)url block:(ImageResultBlock)block {
    if (enableDiskCache) {
      [diskIOQueue_ addOperationWithBlock:^{
        UIImage *image = [self cacheImageWithUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
          block(image);
        });
      }];
    }
    else {
      UIImage *image = [self objectForKey:url];
      block(image);
    }
}


- (NSString*)cacheFileName:(NSString*)url {
    if ([url length] == 0) return nil;

    const char *cStr = [url UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]]; 
}

- (NSString*)createCachePath:(NSString*)url {
    NSString *cacheFileName = [self cacheFileName:url];
    NSString *cachePath = [[[UtilEx sharedInstance] cachesDirectory] 
      stringByAppendingPathComponent:[cacheFileName substringToIndex:2]];

    if (![fileManager_ fileExistsAtPath:cachePath]) {
      [fileManager_ createDirectoryAtPath:cachePath 
        withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return  [cachePath stringByAppendingPathComponent:cacheFileName];
}

- (void)saveToDisk:(NSData*)data path:(NSString*)path {
    [data writeToFile:path atomically:NO];
}

@end
