//
//  MayImageManager.h
//  MayLibre
//
//  Created by Jo Brunner on 01.05.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import Foundation;
@import UIKit;

#define kMayImageManagerImagePathPart    @"images"
#define kMayImageManagerImageDirectory   @"Pictures"
#define kMayImageManagerErrorDomain      @"MayLibreImageManagerErrorDomain"

typedef NS_ENUM(NSUInteger, MayImageManagerErrorNumber) {
    MayImageManagerErrorOk = 0,
    MayImageManagerParameter,
    MayImageManagerIO
};

typedef void (^MayImageManagerCompletionHandler)(NSURLResponse *response, NSURL *filePath, NSError *error);

@interface MayImageManager : NSObject {

    NSString *cacheImagePath;
}

@property (nonatomic, retain, readonly) NSString *cacheImagePath;

+ (instancetype)sharedManager;
- (NSURL *)cachedImageURL:(NSString *)imageUrl;
- (NSString *)cachedImagePath:(NSString *)imageUrl;
- (void)imageWithUrlString:(NSString *)imageUrl
                completion:(void(^)(UIImage *image, NSError *error))completion;

- (NSString *)userFileDirectory;
- (NSString *)userFilePath:(NSString *)filename;
- (void)storeImage:(UIImage *)image
        completion:(void(^)(NSString *filename,
                            NSError *error))completion;
- (void)removeUserFile:(NSString *)filename
            completion:(void(^)(NSError *error))completion;

@end
