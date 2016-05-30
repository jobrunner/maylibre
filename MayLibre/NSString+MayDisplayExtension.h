//
//  NSString+MayDisplayExtension.h
//  MayLibre
//
//  Created by Jo Brunner on 30.05.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MayDisplayExtension)

/**
 * Returns an empty string if string is nil.
 * It should prevent to display "(null)".
 */
- (NSString *)unnil;

/**
 * Cuts a string to given maximum lenght if longer.
 */
- (NSString *)shortenToLength:(NSUInteger)maximum;

/**
 * Trims punctuation characters of the string
 */
- (NSString *)trimPuctuation;

@end
