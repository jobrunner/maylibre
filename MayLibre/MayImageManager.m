#import "AppDelegate.h"
#import "MayImageManager.h"
#import "AFNetworking.h"
#import "MayDigest.h"

@interface MayImageManager()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation MayImageManager

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

        _cacheDirectory = [self cacheDirectoryWithPathComponent:kMayImageManagerCacheDirectoryComponent];
        _documentDirectory = [self documentDirectoryWithPathComponent:kMayImageManagerDocumentDirectoryComponent];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    
    return self;
}

- (void)dealloc {
    
    abort();
}

#pragma mark Path initializers

- (NSString *)cacheDirectoryWithPathComponent:(NSString *)pathComponent {
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:pathComponent];
    
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

- (NSString *)documentDirectoryWithPathComponent:(NSString *)pathComponent {
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:pathComponent];
    
    // Does directory already exist? No, then create it.
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error]) {
            // Handle error here...
            NSLog(@"Create directory error: %@", error);
        }
    }
    
    return path;
}

#pragma mark URL related

- (NSURL *)cachedImageURL:(NSString *)imageUrl {
    
    NSString *path = [self cachedImagePath:imageUrl];

    return [NSURL fileURLWithPath:path];
}

// nimmt den vollständigen Bild-URL-String und erzeugt einen Dateinamen daraus <sha1>.jpg

- (NSString *)cachedImagePath:(NSString *)imageUrl {
    
    NSString *filename = [self filenameFromUrlString:imageUrl];
    
    // create the full file path
    return [_cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filename]];
}

- (NSString *)filenameFromUrlString:(NSString *)imageUrl {
    
    if (imageUrl == nil) {
        
        return nil;
    }

    return [[MayDigest sha1WithString:[imageUrl stringByAppendingString:@"1"]] stringByAppendingString:@".jpg"];
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

#pragma mark User File related

// create the full file path to a file in Cache.
- (NSString *)userFilenameWithPath:(NSString *)filename {
    
    return [[self documentDirectory] stringByAppendingPathComponent:filename];
}

- (void)storeImage:(UIImage *)image
        completion:(void(^)(NSString *filename,
                            NSError *error))completion {

    NSError *error = nil;
    
    if (image == nil) {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Could not store empty image.", nil)};
        error                   = [NSError errorWithDomain:kMayImageManagerErrorDomain
                                                      code:MayImageManagerParameter
                                                  userInfo:userInfo];
        return completion(nil, error);
    }
    
    NSData *pngImageData = UIImagePNGRepresentation(image);

    // generate a filename used a sha1 hash over binary data.
    NSString *sha1Hash = [MayDigest sha1WithBinary:pngImageData];
    
    // filename for PNG image with extension but without path
    NSString *filename = [NSString stringWithFormat:@"%@.png", sha1Hash];
    
    // save binary data to disc
    if (YES == [[NSFileManager defaultManager] createFileAtPath:[self userFilenameWithPath:filename]
                                                       contents:pngImageData
                                                     attributes:nil]) {
        // store the PNG
        completion(filename, error);
    }
    else {
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Could not store image.", nil)};
        error                   = [NSError errorWithDomain:kMayImageManagerErrorDomain
                                                      code:MayImageManagerIO
                                                  userInfo:userInfo];
    }
    
    completion(filename, error);
}

- (void)removeUserFile:(NSString *)filename
            completion:(void(^)(NSError *error))completion {
    
    NSError *error = nil;
    
    NSString *fullname = [self userFilenameWithPath:filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    [fileManager removeItemAtPath:fullname
                            error:&error];
    completion(error);
}

// nimmt einen Filenamen, sucht ihn im Documents/Pictures-Directory und liefert ein UIImage dazu zurück
- (UIImage *)imageWithFilename:(NSString *)filename {
    
    NSString *filenameWithPath = [self userFilenameWithPath:filename];
    
    NSData *imageData = [NSData dataWithContentsOfFile:filenameWithPath];
    
    return [UIImage imageWithData:imageData];
}

@end
