@import Foundation;
@import UIKit;

#define kMayImageManagerCacheDirectoryComponent      @"Pictures"
#define kMayImageManagerDocumentDirectoryComponent   @"Pictures"

#define kMayImageManagerErrorDomain                  @"MayLibreImageManagerErrorDomain"

typedef NS_ENUM(NSUInteger, MayImageManagerErrorNumber) {
    MayImageManagerErrorOk = 0,
    MayImageManagerParameter,
    MayImageManagerIO
};

typedef void (^MayImageManagerCompletionHandler)(NSURLResponse *response, NSURL *filePath, NSError *error);

@interface MayImageManager : NSObject <NSURLSessionTaskDelegate>{

    NSString *_cacheDirectory;
    NSString *_documentDirectory;
}

@property (nonatomic, retain, readonly) NSString *cacheDirectory;
@property (nonatomic, retain, readonly) NSString *documentDirectory;

+ (instancetype)sharedManager;
- (NSURL *)cachedImageURL:(NSString *)imageUrl;
- (NSString *)cachedImagePath:(NSString *)imageUrl;
- (void)imageWithUrlString:(NSString *)imageUrl
                completion:(void(^)(UIImage *image, NSError *error))completion;

// neue Methoden

//- (NSString *)userFileDirectory;

// bekomme ich nun ein großes Original-Bild oder eines aus dem Cache?! Ist von der Benamung nicht gut...
- (NSString *)userFilenameWithPath:(NSString *)filename;
- (void)storeImage:(UIImage *)image
        completion:(void(^)(NSString *filename,
                            NSError *error))completion;
- (void)removeUserFile:(NSString *)filename
            completion:(void(^)(NSError *error))completion;

- (UIImage *)imageWithFilename:(NSString *)filename;

@end
