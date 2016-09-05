//
//  MayImageManager.m
//  MayLibre
//
//  Created by Jo Brunner on 01.05.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MayImageManager.h"
#import "AFNetworking.h"
#import "MayDigest.h"

@interface MayImageManager()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation MayImageManager

@synthesize cacheImagePath;

#pragma mark Singleton Methods

+ (instancetype)sharedManager {

    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Init

- (instancetype)init {

    if (self = [super init]) {
    
        cacheImagePath = [self createPathForCachableImages];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    
    return self;
}

- (void)dealloc {
    
    abort();
}

#pragma mark URL related

- (NSURL *)cachedImageURL:(NSString *)imageUrl {
    
    NSString *path = [self cachedImagePath:imageUrl];

    return [NSURL fileURLWithPath:path];
}

- (NSString *)cachedImagePath:(NSString *)imageUrl {
    
    NSString *filename = [self filenameFromUrlString:imageUrl];
    NSString *path = self.cacheImagePath;
    
    // create the full file path
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filename]];
}

- (NSString *)filenameFromUrlString:(NSString *)imageUrl {
    
    if (imageUrl == nil) {
        
        return nil;
    }

    return [[MayDigest sha1WithString:[imageUrl stringByAppendingString:@"1"]] stringByAppendingString:@".jpg"];
}

- (NSString *)createPathForCachableImages {
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:kMayImageManagerImagePathPart];
    
    // Does directory already exist? No, then create it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        if (![fileManager createDirectoryAtPath:path
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:&error]) {
            if (error) {

                // Internal Error Handling
                // Storing the image should't be continued.
                NSLog(@"Create directory error:\n%@", error.userInfo);
                return nil;
            }
        }
    }
    
    return path;
}

- (void)imageWithUrlString:(NSString *)imageUrl
                completion:(void(^)(UIImage *image, NSError *error))completion {
    
    if (imageUrl == nil) {
        completion([UIImage imageNamed:@"DummyBook"], nil);
        return;
    }
    
    NSString *cachedFilePath = [self cachedImagePath:imageUrl];
    NSData *imageData = [NSData dataWithContentsOfFile:cachedFilePath];
    
    if (imageData == nil) {
        [self download:imageUrl
            completion:^(UIImage *image, NSError *error) {

                if (image == nil) {
                    image = [UIImage imageNamed:@"DummyBook"];
                }
                
                completion(image, error);
            }];
    }
    else {
        completion([UIImage imageWithData:imageData], nil);
    }
}

- (void)download:(NSString *)imageUrl
      completion:(void(^)(UIImage *image, NSError *error))complete {

    if (imageUrl == nil) {
        if (complete) {
            complete(nil, nil);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSessionDownloadTask *downloadTask =
    [_manager downloadTaskWithRequest:request
                            progress:nil
                         destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                             
                             NSURL *ret = [self cachedImageURL:imageUrl];
                             
                             return ret;
                         }
                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                       
                       if (error) {
                           NSLog(@"completion-error: %@", error.userInfo);
                           NSLog(@"completion-response: %@", response);
                           NSLog(@"filePath: %@", filePath);
                       }
                       
                       NSData *imageData = [NSData dataWithContentsOfURL:filePath];
                       UIImage *image = [UIImage imageWithData:imageData];

                       complete(image, error);
                   }];
    
    [downloadTask resume];
}

@end
