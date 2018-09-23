//
//  DataRetTests.m
//  DataRetTests
//
//  Created by oakleyk on 09/08/2018.
//  Copyright © 2018 abc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DataRet_main.h"
@interface DataRetTests : XCTestCase

@end

@implementation DataRetTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssertNotNil([[DataRet DataRet] getUserData:@"nielsen"], "Should returned an array containing the segment for the user nielsen");
    
    XCTAssertNotNil([[DataRet DataRet] getUserData:@"eyeota"], "Should returned an array containing the segment for the user nielsen");
    XCTAssertNil([[DataRet DataRet] getUserData:@"NOT_A_USER"], "Shouldn't return an array");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
