//
//  MayISBNTests.m
//  MayLibre
//
//  Created by Jo Brunner on 24.04.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MayISBN.h"
#import "MayISBNFormatter.h"

@interface MayISBNTests : XCTestCase

@end

@implementation MayISBNTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDigitExctraction {

    NSString *code = @"3-494-01260-1";
    NSUInteger decimal;
    
    decimal = [MayISBN decimalDigitValue:code atPosition:0];
    
    XCTAssertEqual(decimal, 3);
    
    decimal = [MayISBN decimalDigitValue:code atPosition:1];
    XCTAssertEqual(decimal, 0);

    decimal = [MayISBN decimalDigitValue:code atPosition:200];
    XCTAssertEqual(decimal, 0);

    decimal = [MayISBN decimalDigitValue:code atPosition:12];
    XCTAssertEqual(decimal, 1);
}

- (void)testNumberWithString {

    MayISBN *isbn = [MayISBN new];
    NSString *string = @"9999999999999";
    NSNumber *number = [isbn numberWithString:string];
    
    XCTAssertEqualObjects(number, @9999999999999);
}

- (void)testFilterMinus {
    
    NSString *code = @"3-494-01260-1";
    MayISBN *isbn = [MayISBN new];
    
    XCTAssert([isbn filterDigitCharacters:code], @"3494012601");
}

- (void)testFilterX {
    
    NSString *code = @"3-494-01260-X";
    MayISBN *isbn = [MayISBN new];
    
    XCTAssert([isbn filterDigitCharacters:code], @"349401260X");
}

- (void)testISBN10 {

    MayISBN *isbn = [MayISBN new];
    NSString *code = [isbn filterDigitCharacters:@"3-494-01260-1"];
    
    XCTAssertTrue([isbn validateISBN10:code]);
}

- (void)testISBN13 {
    
    MayISBN *isbn = [MayISBN new];
    NSString *code = [isbn filterDigitCharacters:@"978-3-800-13466-3"];
    
    XCTAssertTrue([isbn validateISBN13:code]);
}

- (void)testConstructorWithString {
    
    MayISBN *isbn10 = [MayISBN ISBNFromString:@"3-494-01260-1"];
    
    XCTAssertEqualObjects(isbn10.isbnCode, @3494012601);
    
    MayISBN *isbn13 = [MayISBN ISBNFromString:@"978-3-494-01260-5"];
    XCTAssertEqualObjects(isbn13.isbnCode, @9783494012605);

    MayISBN *notvalid = [MayISBN ISBNFromString:@"9993494"];
    XCTAssertEqualObjects(notvalid.isbnCode, nil);
}

- (void)testNoISBN {

    NSString *code = @"3-494-01260";
    MayISBN *isbn = [MayISBN ISBNFromString:code];
    
    XCTAssertEqualObjects(isbn.isbnCode, nil);
}

- (void)testCalculateErrorCheckingNumberISBN10 {
    
    MayISBN *isbn = [MayISBN new];
    NSString *code = [isbn filterDigitCharacters:@"3-494-01260-1"];

    NSUInteger checkSum = [MayISBN calculateErrorCheckingNumberISBN10:code];
    XCTAssertEqual(checkSum, 1);
}

- (void)testCalculateErrorCheckingNumberISBN10WithX {
    
    MayISBN *isbn = [MayISBN new];
    NSString *code = [isbn filterDigitCharacters:@"0-7356-1993-X"];
    
    NSUInteger checkSum = [MayISBN calculateErrorCheckingNumberISBN10:code];
    XCTAssertEqual(checkSum, 10);
}

- (void)testCalculateErrorCheckingNumberISBN13 {
    
    MayISBN *isbn = [MayISBN new];
    NSString *code = [isbn filterDigitCharacters:@"978-3-800-13466-3"];

    NSUInteger checkSum = [MayISBN calculcateErrorCheckingNumberISBN13:code];
    XCTAssertEqual(checkSum, 3);
}

- (void)testISBNFormatterIsbn13WithHyphenStandard {
    
    NSString *code = @"978-99977-789-1-8";
    MayISBN *isbn = [[MayISBN alloc] initWithISBNFromString:code];
    
    MayISBNFormatter *formatter = [[MayISBNFormatter alloc] init];

    XCTAssertEqual(formatter.isbnType, MayISBNFormatterTypeISBN13);
    XCTAssertEqual(formatter.isbnSeparators, YES);
    
    NSString *formattedISBNString = [formatter stringFromISBN:isbn];
    
    XCTAssertEqualObjects(formattedISBNString, code);
}

- (void)testISBNFormatterIsbn13WithoutHyphen {
    
    NSString *code = @"978-99977-789-1-8";
    MayISBN *isbn = [[MayISBN alloc] initWithISBNFromString:code];

    MayISBNFormatter *formatter = [[MayISBNFormatter alloc] init];
    formatter.isbnType = MayISBNFormatterTypeISBN13;
    formatter.isbnSeparators = NO;
    
    NSString *formattedISBNString = [formatter stringFromISBN:isbn];
    
    XCTAssertEqualObjects(formattedISBNString, @"9789997778918");
}

- (void)testISBNFormatterIsbn10 {
    
    NSString *code = @"978-0-7356-1993-7";
    MayISBN *isbn = [[MayISBN alloc] initWithISBNFromString:code];
    
    MayISBNFormatter *formatter = [[MayISBNFormatter alloc] init];
    
    formatter.isbnType = MayISBNFormatterTypeISBN10;
    
    NSString *formattedISBNString = [formatter stringFromISBN:isbn];
    
    XCTAssertEqualObjects(formattedISBNString, @"0-7356-1993-X");
}

@end
