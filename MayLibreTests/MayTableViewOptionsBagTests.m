//
//  MayTableViewOptionsBag.m
//  MayLibre
//
//  Created by Jo Brunner on 10.09.16.
//  Copyright © 2016 Mayflower. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MayTableViewOptionsBag.h"

@interface MayTableViewOptionsBagTests : XCTestCase

@property (nonatomic, assign) MayTableViewOptionsBag *optionsBag;

@end

@implementation MayTableViewOptionsBagTests
    
- (void)setUp {

    [super setUp];
    
    self.optionsBag = [MayTableViewOptionsBag sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStructureIntegrationTest {
    
    NSArray *sortOptions = [self.optionsBag sortOptions:@"Entry"];
    NSInteger countOptions = [sortOptions count];
    XCTAssert(countOptions > 0);

    for (NSDictionary *option in sortOptions) {

        XCTAssertNil([option objectForKey:@"should not defined"]);

        NSString *tagString = [option objectForKey:MayTableViewOptionsBagItemKeyKey];
        XCTAssertNotNil(tagString);
        XCTAssert([tagString integerValue] > 0);

        XCTAssertNotNil([option objectForKey:MayTableViewOptionsBagItemTextKey]);
        XCTAssertNotNil([option objectForKey:MayTableViewOptionsBagItemFieldKey]);
        XCTAssertNotNil([option objectForKey:MayTableViewOptionsBagItemVisibilityKey]);
        XCTAssertNotNil([option objectForKey:MayTableViewOptionsBagItemAscendingKey]);
        XCTAssertNotNil([option objectForKey:MayTableViewOptionsBagItemDisplayOrderKey]);
    }
}

- (void)testSortOption5IntegrationTest {
    
    NSDictionary *option = [self.optionsBag sortOptionWithKey:5
                                                        entry:@"Entry"];
    NSString *ascending = [option objectForKey:MayTableViewOptionsBagItemAscendingKey];

    // Option 5 should be descending order:
    XCTAssertFalse([ascending boolValue]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
