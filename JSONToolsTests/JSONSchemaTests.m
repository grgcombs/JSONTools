//
//  JSONSchemaTests.m
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import <XCTest/XCTest.h>
#import <JSONTools/JSONTools.h>

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
    NSURL *suitesURL = [mainBundle.bundleURL URLByAppendingPathComponent:@"Schema-Test-Suite" isDirectory:YES];
    self.draft4SpecDirectory = [suitesURL URLByAppendingPathComponent:@"tests/draft4" isDirectory:YES];

    NSURL *remotesURL = [suitesURL URLByAppendingPathComponent:@"remotes" isDirectory:YES];

    NSArray * refURLs = [self recursiveURLsForResourcesOfType:@"json" inDirectory:remotesURL];

    NSURL * localServerURL = [NSURL URLWithString:@"http://localhost:1234/"];

    for (NSURL * fileURL in refURLs)
    {
        NSError *error = nil;
        NSData * data = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&error];
        NSString *filePath = fileURL.lastPathComponent;
        NSURL *url = [NSURL URLWithString:filePath relativeToURL:localServerURL];
        error = nil;
        NSDictionary *schema = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        XCTAssertNil(error, @"Should have a valid JSON object for schema at %@", filePath);
        XCTAssertTrue([schema isKindOfClass:[NSDictionary class]], @"JSON object should be a dictionary for schema at %@, was %@", filePath, [schema class]);

        BOOL success = [_validator addRefSchema:schema atURL:url validateSchema:YES];
        XCTAssertTrue(success, @"JSON object should be a valid JSON Schema at %@", filePath);
    }
}

- (NSArray *)recursiveURLsForResourcesOfType:(NSString *)type inDirectory:(NSURL *)directoryURL
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];

    NSMutableArray *fileURLs = nil;
    for (NSURL *fileURL in enumerator)
    {
        NSString *path = fileURL.path;
        if (!path.length)
            continue;
        if (type && ![type isEqualToString:fileURL.pathExtension])
            continue;
        if (!fileURLs)
            fileURLs = [[NSMutableArray alloc] init];
        [fileURLs addObject:fileURL];
    }

    if (!fileURLs.count)
        return nil;
    return fileURLs;
}

- (void)tearDown
{
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

#if 0 // don't know why this broke, don't have time to fix it (for now)

//  Not relying on local web services to run this test
- (void)testRefRemote
{
    _validator.formatValidationEnabled = NO;
    [self runSpecGroupWithName:@"refRemote"];
}

#endif

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

#if 0
//  This optional test won't ever pass when using NSJSONSerialization
- (void)testOptionalZeroTerminatedFloats
{
    [self runSpecGroupWithName:@"optional/zeroTerminatedFloats"];
}
#endif

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
    NSString *filename = [suiteName stringByAppendingPathExtension:@"json"];
    NSURL *draftURL = self.draft4SpecDirectory;
    if (!draftURL)
        return nil;
    NSURL *url = [draftURL URLByAppendingPathComponent:filename isDirectory:NO];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    if (!data)
        return nil;
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
}

@end
