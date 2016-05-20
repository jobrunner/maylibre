//
//  MayImageManager.h
//  MayLibre
//
//  Created by Jo Brunner on 01.05.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

@import Foundation;
@import UIKit;

#define kImagePathPart  @"images"

typedef void (^MayImageManagerCompletionHandler)(NSURLResponse *response, NSURL *filePath, NSError *error);

@interface MayImageManager : NSObject {

    NSString *cacheImagePath;
}

@property (nonatomic, retain, readonly) NSString *cacheImagePath;

+ (id)sharedManager;
- (NSURL *)cachedImageURL:(NSString *)imageUrl;
- (NSString *)cachedImagePath:(NSString *)imageUrl;
- (void)imageWithUrlString:(NSString *)imageUrl
                completion:(void(^)(UIImage *image, NSError *error))completion;

@end