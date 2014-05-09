//
//  JSONSchemaTests.m
//  JSONTools
//
//  Created by Gregory Combs on 4/29/14.
//  Copyright (c) 2014 Sleestacks. All rights reserved.
//

@import XCTest;
#import "JSONSchemaValidator.h"

@interface JSONSchemaTests : XCTestCase
@property (nonatomic,strong) JSONSchemaValidator *validator;
@property (nonatomic,strong) NSURL *draft4SpecDirectory;
@end

@implementation JSONSchemaTests

- (void)setUp
{
    [super setUp];

    _validator = [JSONSchemaValidator new];

    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [mainBundle pathForResource:@"JSON-Schema-Test-Suite" ofType:@"bundle"];
    NSBundle *suiteBundle = [NSBundle bundleWithPath:bundlePath];
    _draft4SpecDirectory = [[suiteBundle resourceURL] URLByAppendingPathComponent:@"tests/draft4" isDirectory:YES];

    NSString * directory = [[suiteBundle resourcePath] stringByAppendingPathComponent:@"remotes"];
    NSArray * refPaths = [self recursivePathsForResourcesOfType:@"json" inDirectory:directory];
    for (NSString * path in refPaths)
    {
        NSString * fullpath  = [directory stringByAppendingPathComponent:path];
        NSData * data = [NSData dataWithContentsOfFile:fullpath];
        NSURL * url = [NSURL URLWithString:@"http://localhost:1234/"];
        url = [NSURL URLWithString:path relativeToURL:url];

        NSError *error = nil;
        id schema = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        XCTAssertNil(error, @"Should have a valid JSON object for remote %@", path);
        XCTAssertTrue([schema isKindOfClass:[NSDictionary class]], @"JSON object should be a dictionary for remote %@, was %@", path, schema);

        BOOL success = [_validator addRefSchema:schema atURL:url validateSchema:YES];
        XCTAssertTrue(success, @"JSON object should be a valid JSON Schema for remote %@", path);
    }
}

- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath {
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];

    NSString *filePath;

    while ((filePath = [enumerator nextObject]) != nil) {
        if (!type || [[filePath pathExtension] isEqualToString:type]){
            [filePaths addObject:filePath];
        }
    }

    return filePaths;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testAdditionalItems
{
    [self runSpecGroupWithName:@"additionalItems"];
}

- (void)testAdditionalProperties
{
    [self runSpecGroupWithName:@"additionalProperties"];
}

- (void)testAllOf
{
    [self runSpecGroupWithName:@"allOf"];
}

- (void)testAnyOf
{
    [self runSpecGroupWithName:@"anyOf"];
}

- (void)testDefinitions
{
    [self runSpecGroupWithName:@"definitions"];
}

- (void)testDependencies
{
    [self runSpecGroupWithName:@"dependencies"];
}

- (void)testEnum
{
    [self runSpecGroupWithName:@"enum"];
}

- (void)testItems
{
    [self runSpecGroupWithName:@"items"];
}

- (void)testMaximum
{
    [self runSpecGroupWithName:@"maximum"];
}

- (void)testMaxItems
{
    [self runSpecGroupWithName:@"maxItems"];
}

- (void)testMaxLength
{
    [self runSpecGroupWithName:@"maxLength"];
}

- (void)testMaxProperties
{
    [self runSpecGroupWithName:@"maxProperties"];
}

- (void)testMinimum
{
    [self runSpecGroupWithName:@"minimum"];
}

- (void)testMinItems
{
    [self runSpecGroupWithName:@"minItems"];
}

- (void)testMinLength
{
    [self runSpecGroupWithName:@"minLength"];
}

- (void)testMinProperties
{
    [self runSpecGroupWithName:@"minProperties"];
}

- (void)testMultipleOf
{
    [self runSpecGroupWithName:@"multipleOf"];
}

- (void)testNot
{
    [self runSpecGroupWithName:@"not"];
}

- (void)testOneOf
{
    [self runSpecGroupWithName:@"oneOf"];
}

- (void)testPattern
{
    [self runSpecGroupWithName:@"pattern"];
}

- (void)testPatternProperties
{
    [self runSpecGroupWithName:@"patternProperties"];
}

- (void)testProperties
{
    [self runSpecGroupWithName:@"properties"];
}

- (void)testRef
{
    [self runSpecGroupWithName:@"ref"];
}

//  Not relying on local web services to run this test
- (void)testRefRemote
{
    _validator.formatValidationEnabled = NO;
    [self runSpecGroupWithName:@"refRemote"];
}

- (void)testRequired
{
    [self runSpecGroupWithName:@"required"];
}

- (void)testType
{
    [self runSpecGroupWithName:@"type"];
}

- (void)testUniqueItems
{
    [self runSpecGroupWithName:@"uniqueItems"];
}

- (void)testOptionalBignum
{
    [self runSpecGroupWithName:@"optional/bignum"];
}

- (void)testOptionalFormat
{
    _validator.formatValidationEnabled = YES;
    [self runSpecGroupWithName:@"optional/format"];
}

/* This optional test won't ever pass when using NSJSONSerialization
- (void)testOptionalZeroTerminatedFloats
{
    [self runSpecSuiteWithName:@"optional/zeroTerminatedFloats"];
}
 */

- (void)testDateInLeapYears
{
    JSONSchemaValidator *validator = _validator;
    _validator.formatValidationEnabled = YES;
    NSDictionary *dateFormat = @{@"format": @"date-time"};

    NSString *testData = @"1963-02-29T08:30:06.283185Z";
    BOOL result = [validator validateJSONInstance:testData withSchema:dateFormat];
    XCTAssertFalse(result, @"February 1963 didn't have 29 days.");

    testData = @"2000-02-29T08:30:06.283185Z";
    result = [validator validateJSONInstance:testData withSchema:dateFormat];
    XCTAssertTrue(result, @"February 2000 had 29 days");

    testData = @"2005-07-01T12:00:00-0700";
    result = [validator validateJSONInstance:testData withSchema:dateFormat];
    XCTAssertTrue(result, @"Validator should accept GMT offsets.");

}

- (void)runSpecGroupWithName:(NSString *)groupName
{
    NSString *invalidStatus = @"invalid";
    NSString *validStatus = @"valid";

    NSArray *group = [self getSpecGroupWithName:groupName];
    XCTAssertNotNil(group, @"Couldn't find a spec group with the name '%@'", groupName);

    for (NSDictionary *spec in group)
    {
        NSDictionary *schema = spec[@"schema"];
        NSArray *tests = spec[@"tests"];
        NSString *specDescription = spec[@"description"];

        XCTAssertTrue(tests.count > 0, @"Invalid test spec, no tests defined");

        for (NSDictionary *test in tests)
        {
            NSString *testDescription = test[@"description"];
            id testData = test[@"data"];
            BOOL result = [_validator validateJSONInstance:testData withSchema:schema];
            BOOL desired = [test[@"valid"] boolValue];

            if (result != desired) {
                NSString *resultStatus = (result == YES) ? validStatus : invalidStatus;
                NSString *expectedStatus = (desired == YES) ? validStatus : invalidStatus;
                XCTFail(@"Group: %@; Spec: %@; Test: %@; Result: %@; Expected: %@", groupName, specDescription, testDescription, resultStatus, expectedStatus);
            }
        }
    }
}

- (NSArray *)getSpecGroupWithName:(NSString *)suiteName
{
    NSString *filename = [suiteName stringByAppendingString:@".json"];
    NSURL *url = [_draft4SpecDirectory URLByAppendingPathComponent:filename isDirectory:NO];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
}

@end
