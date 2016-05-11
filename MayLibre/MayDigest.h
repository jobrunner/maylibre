//
//  MayHash.h
//  MayLibre
//
//  Created by Jo Brunner on 28.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MayDigest : NSObject

+ (NSString *)sha1WithString:(NSString *)string;
+ (NSString *)sha1WithBinary:(NSData *)data;

@end
