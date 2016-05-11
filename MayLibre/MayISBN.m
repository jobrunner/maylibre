//
//  ISBN.m
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import "MayISBN.h"
#import "MayISBNFormatter.h"
#import "MayISBNRangeDictionary.h"

@interface MayISBN ()

@end

@implementation MayISBN

+ (instancetype)ISBNFromString:(NSString *)isbnString {
    
    return [[MayISBN alloc] initWithISBNFromString:isbnString];
}

+ (instancetype)ISBNFromString:(NSString *)isbnString
                         error:(NSError **)error {
    
    return [[MayISBN alloc] initWithISBNFromString:isbnString
                                             error:error];
}

- (instancetype)initWithISBNFromString:(NSString *)isbnString {

    NSError *error = nil;
    return [self initWithISBNFromString:isbnString
                                  error:&error];
}

- (instancetype)initWithISBNFromString:(NSString *)isbnString
                                 error:(NSError **)error {

    if (self = [super init]) {
        
        // Filters all but 0-9 and X.
        NSString *filteredCode = [self filterDigitCharacters:isbnString];
        
        if ([self validateISBN10:filteredCode]) {
            NSString *newISBNString = [MayISBN convertISBN10ToISBN13:filteredCode];
            _isbnCode = [self numberWithString:newISBNString];
            *error = nil;
        }
        else if ([self validateISBN13:filteredCode]) {
            _isbnCode = [self numberWithString:filteredCode];
            *error = nil;
        }
        else {
            _isbnCode = nil;
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Could not detect valid ISBN.", nil)};
            *error = [NSError errorWithDomain:kMayISBNErrorDomain
                                         code:MayISBNErrorISBNDetection
                                     userInfo:userInfo];
        }
    }
    
    return self;
}

+ (NSString *)convertISBN10ToISBN13:(NSString *)isbn10Code {

    NSString *withoutErrorCheckingNumber = [isbn10Code substringToIndex:9];
    NSString *isbn13WithoutErrorCheckingCode = [NSString stringWithFormat:@"978%@", withoutErrorCheckingNumber];
    
    return [NSString stringWithFormat:@"%@%@",
            isbn13WithoutErrorCheckingCode,
            @([MayISBN calculcateErrorCheckingNumberISBN13:isbn13WithoutErrorCheckingCode])];
}

/**
 * Returns the decimal value of a digit at (zero based) string position or 0 if isn't a digit between 0 and 9.
 */
+ (NSUInteger)decimalDigitValue:(NSString *)string
                     atPosition:(NSUInteger)index {
    
    if (index >= [string length]) {
        
        return 0;
    }
    
    unichar c = [string characterAtIndex:index];
    
    if ((c >= '0') && (c <= '9')) {
        
        return c - '0';
    }
    
    if (c == 'X') {
        return 10;
    }
    
    return 0;
}

/**
 * Returns the string without non digit characters
 */
- (NSString *)filterDigitCharacters:(NSString *)code {
    
    NSMutableString *buffer = [NSMutableString new];
    
    for (int index = 0; index < [code length]; index++) {
        unichar c = [code characterAtIndex:index];
        if (((c >= '0') && (c <= '9')) || (c == 'X')) {
            [buffer appendFormat:@"%@", [code substringWithRange:NSMakeRange(index, 1)]];
        }
    }
    
    return [buffer copy];
}

- (NSNumber *)numberWithString:(NSString *)code {
    
    NSString *string = [self filterDigitCharacters:code];
    
    return [NSNumber numberWithLong:[string longLongValue]];
}

/**
 * Calculates and returns error checking number of a ISBN-10.
 * String representation of ISBN-10 (code) must not include any hyphen.
 */
+ (NSUInteger)calculateErrorCheckingNumberISBN10:(NSString *)code {

    if ([code length] > 10) {
        code = [[code copy] substringFromIndex:3];
    }
    
    NSUInteger checkSum = 0;
    for (NSUInteger index = 0; index < 9; index++) {
        checkSum = checkSum + (index + 1) * [MayISBN decimalDigitValue:code
                                                            atPosition:index];
    }
    checkSum = checkSum % 11;
    
    return checkSum;
}

/**
 * Calculates error checking number of an ISBN-13 without '-'.
 */
+ (NSUInteger)calculcateErrorCheckingNumberISBN13:(NSString *)code {
    
    if ([code length] < 12) {
        
        return NO;
    }
    
    NSUInteger checkSum = 0;
    
    // sum up digits at even positions (with weight 3)
    for (NSUInteger index = 1; index < 12; index+=2) {
        checkSum = checkSum + 3 * [MayISBN decimalDigitValue:code
                                                  atPosition:index];
    }
    
    // sum up digits at odd positions (with weight 1)
    for (NSUInteger index = 0; index < 11; index +=2) {
        checkSum = checkSum + [MayISBN decimalDigitValue:code
                                              atPosition:index];
    }

    checkSum = (10 - (checkSum % 10)) % 10;
    
    return checkSum;
}

/**
 * Basic validation of a ISBN-10 without '-' sign.
 */
- (BOOL)validateISBN10:(NSString *)code {

    if ([code length] != 10) {
        
        return NO;
    }

    NSUInteger checkSum = 0;
    for (NSUInteger index = 0; index < 10; index++) {
        checkSum = checkSum + (index + 1) * [MayISBN decimalDigitValue:code
                                                            atPosition:index];
    }

    return (0 == (checkSum % 11));
}

/**
 * Basic validation of a ISBN-10 without '-' sign.
 */
- (BOOL)validateISBN13:(NSString *)code {
    
    if ([code length] != 13) {
        
        return NO;
    }

    NSUInteger checkSum = 0;

    // sum up digits at even positions (with weight 3)
    for (NSUInteger index = 1; index < 12; index+=2) {
        checkSum = checkSum + 3 * [MayISBN decimalDigitValue:code
                                                  atPosition:index];
    }

    // sum up digits at odd positions (with weight 1)
    for (NSUInteger index = 0; index < 13; index +=2) {
        checkSum = checkSum + [MayISBN decimalDigitValue:code
                                              atPosition:index];
    }
    return (0 == (checkSum % 10));
}

- (NSString *)description {

    return [NSString stringWithFormat:@"ISBN-13: %@", _isbnCode];
}

@end
