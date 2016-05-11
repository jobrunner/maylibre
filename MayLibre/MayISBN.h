//
//  ISBN.h
//  MayLibre
//
//  Created by Jo Brunner on 22.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMayISBNErrorDomain         @"MayISBNErrorDomain"

typedef enum MayISBNErrorNumber : NSUInteger {
    MayISBNErrorOk = 0,
    MayISBNErrorISBNDetection
} MayISBNErrorNumber;


@interface MayISBN : NSObject

@property (nonatomic, strong) NSNumber *isbnCode;

//@property (nonatomic, strong) NSString *language;
//@property MayISBNType isbnType;
//@property NSUInteger prefix;
//@property NSUInteger groupNumber;
//@property NSUInteger groupNumberDigits;
//@property NSUInteger publishingNumber;
//@property NSUInteger titleNumber;
//@property NSUInteger titleNumberDigits;
//@property NSUInteger errorCheckingNumber;


+ (instancetype)ISBNFromString:(NSString *)isbnString;
+ (instancetype)ISBNFromString:(NSString *)isbnString error:(NSError **)error;
+ (NSUInteger)decimalDigitValue:(NSString *)string atPosition:(NSUInteger)index;
+ (NSUInteger)calculateErrorCheckingNumberISBN10:(NSString *)code;
+ (NSUInteger)calculcateErrorCheckingNumberISBN13:(NSString *)code;
+ (NSString *)convertISBN10ToISBN13:(NSString *)isbn10Code;
- (instancetype)initWithISBNFromString:(NSString *)isbnString;
- (instancetype)initWithISBNFromString:(NSString *)isbnString error:(NSError **)error;
- (NSString *)filterDigitCharacters:(NSString *)code;
- (NSNumber *)numberWithString:(NSString *)code;
- (BOOL)validateISBN10:(NSString *)code;
- (BOOL)validateISBN13:(NSString *)code;

@end
