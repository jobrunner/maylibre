@import Foundation;

@interface MayDigest : NSObject

+ (NSString *)sha1WithString:(NSString *)string;
+ (NSString *)sha1WithBinary:(NSData *)data;

@end
