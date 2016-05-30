//
//  NSString+MayDisplayExtension.m
//  MayLibre
//
//  Created by Jo Brunner on 30.05.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "NSString+MayDisplayExtension.h"

@implementation NSString (MayDisplayExtension)

- (NSString *)unnil {
    
    if (self) {
        
        return self;
    }

    return @"";
}

- (NSString *)shortenToLength:(NSUInteger)maximum {
    
    if (self.length > maximum) {
        
        return [self substringToIndex:(maximum - 1)];
    }
    
    return self;
}

- (NSString *)trimPuctuation {
    
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.punctuationCharacterSet];
}

@end
