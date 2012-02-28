//
//  CTCoreDataAPIFrameworkAdditionsTests.m
//  CTCoreDataAPI
//
//  Created by Oliver Letterer on 24.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//

#import "FrameworkAdditionsTests.h"
#import "CTRESTfulCoreData.h"
//#import "SampleEntity.h"

@implementation CTCoreDataAPIFrameworkAdditionsTests

- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{
    [super tearDown];
    
}

// All code under test must be linked into the Unit Test bundle
- (void)testCamelizing
{
    NSString *string = @"this_is_a_test";
    NSString *expectedResult = @"thisIsATest";
    
    STAssertEqualObjects(string.stringByCamelizingString, expectedResult, @"camelizing not working.");
}

- (void)testUnderscoring
{
    NSString *string = @"thisIsATest";
    NSString *expectedResult = @"this_is_a_test";
    
    STAssertEqualObjects(string.stringByUnderscoringString, expectedResult, @"underscoring not working.");
}

@end
