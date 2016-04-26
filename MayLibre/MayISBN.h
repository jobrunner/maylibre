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

// speichert nur den isbnCode als Number
// nimmt ISBNs in 10 und 13 mit und ohne Bindestrich als String an
// nimmt ISBNs als Number an (10 macht in dem Zusammenhang keinen Sinn, weil das immer ein String sein muss)
// rechnet vor dem Speichern 10er IMMER als 13er um.

// Logik zum parsen im formatter
// Logik zur formatieren Ausgabe im formatter

// Was ist besser: im Model Number oder formatieren String speichern?
//  -> ich denke formatiert, weil dadurch die Anzeige nicht immer neu berechnet werden muss.


// Zu lösendes Problem beim Umbau:
// -> Wenn eine ISBN ankommt, soll sie von der Klasse ISBN weder geparsed, noch geprüft werden.
//    das soll die eine validator Klasse übernehmen, die von ISBN als auch ISBNFormatter verwendet wird.
//    diese Klasse kann liefert auch die einzelnen Parts.

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


//+ (instancetype)ISBNFromNumber:(NSNumber *)isbnNumber;
+ (instancetype)ISBNFromString:(NSString *)isbnString;
+ (instancetype)ISBNFromString:(NSString *)isbnString error:(NSError **)error;
+ (NSUInteger)decimalDigitValue:(NSString *)string atPosition:(NSUInteger)index;
+ (NSUInteger)calculateErrorCheckingNumberISBN10:(NSString *)code;
+ (NSUInteger)calculcateErrorCheckingNumberISBN13:(NSString *)code;
+ (NSString *)convertISBN10ToISBN13:(NSString *)isbn10Code;

//- (instancetype)initWithISBNFromNumber:(NSNumber *)isbnNumber;
- (instancetype)initWithISBNFromString:(NSString *)isbnString;
- (instancetype)initWithISBNFromString:(NSString *)isbnString error:(NSError **)error;
- (NSString *)filterDigitCharacters:(NSString *)code;
- (NSNumber *)numberWithString:(NSString *)code;
- (BOOL)validateISBN10:(NSString *)code;
- (BOOL)validateISBN13:(NSString *)code;

//- (NSUInteger)calculateErrorCheckingNumberISBN10:(NSString *)code;
//- (NSUInteger)calculcateErrorCheckingNumberISBN13:(NSString *)code;

//- (void)parseISBNParts:(NSString *)code;

// - (BOOL)isPossibleISBN10Representation;

@end
