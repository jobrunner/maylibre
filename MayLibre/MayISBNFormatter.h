//
//  MayISBNFormatter.h
//  MayLibre
//
//  Created by Jo Brunner on 24.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMayISBNFormatterErrorDomain         @"MayISBNFormatterErrorDomain"

typedef enum MayISBNFormatterError : NSUInteger {

    MayISBNFormatterErrorISBN10Representation,
    MayISBNFormatterErrorGroupNumber,
    MayISBNFormatterErrorPublisherNumber,
    MayISBNFormatterErrorErrorCheckingNumber

} MayISBNFormatterError;

typedef enum MayISBNFormatterType : NSUInteger {
    // supress ISBN
    MayISBNFormatterTypeNone,
    // format as descripted in the object
    MayISBNFormatterTypeFromObject,
    // enforces ISBN10
    MayISBNFormatterTypeISBN10,
    // enforces ISBN13
    MayISBNFormatterTypeISBN13
} MayISBNFormatterType;

typedef enum MayISBNFormatterSeparators : NSUInteger {
    // only digits
    MayISBNFormatterFormatSeparatorsNone,
    // digits and white spaces between groups
    MayISBNFormatterFormatSeparatorsWhiteSpace,
    // digits and hyphens (standard)
    MayISBNFormatterFormatSeparatorsHyphen
} MayISBNFormatterSeparators;

@interface MayISBNFormatter : NSFormatter

@property (nonatomic, readwrite) MayISBNFormatterType isbnType;
@property (nonatomic,readwrite) MayISBNFormatterSeparators isbnSeparators;
@property (nonatomic,readwrite) BOOL isbnLabeled;

+ (NSString *)stringFromISBN:(MayISBN *)isbn;
- (NSString *)stringFromISBN:(MayISBN *)isbn;

@end
