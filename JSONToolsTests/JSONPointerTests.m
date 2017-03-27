//
//  JSONPointerTests
//  based in part on CWJSONPointer by Jonathan Dring (MIT/Copyright (c) 2014)
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import <XCTest/XCTest.h>
#import <JSONTools/JSONTools.h>

@interface JSONPointerTests : XCTestCase
@property (nonatomic,strong) NSDictionary *jsonRFC6901;
@property (nonatomic,strong) NSDictionary *jsonAdditional;
@end

@implementation JSONPointerTests

- (void)setUp
{
    [super setUp];
    _jsonRFC6901 = @{
                     @"foo"  : @[@"bar", @"baz"],
                     @""     : @0,
                     @"a/b"  : @1,
                     @"c%d"  : @2,
                     @"e^f"  : @3,
                     @"g|h"  : @4,
                     @"i\\j" : @5,
                     @"k\"l" : @6,
                     @" "    : @7,
                     @"m~n"  : @8
                     };

    _jsonAdditional = @{
                        @"foo": @{
                                @"bar": @{
                                        @"true": @YES,
                                        @"false": @NO,
                                        @"number": @55,
                                        @"negative": @(-55),
                                        @"string": @"mystring",
                                        @"null": [NSNull null],
                                        @"array": @[@1,@2,@3],
                                        @"object": @{
                                                @"a": @1,
                                                @"b": @2,
                                                @"c": @3
                                                }
                                        }
                                }
                        };
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - RFC6901 Specs

/* RFC6901 String Representations
     ""       // the whole document
     "/foo"   ["bar", "baz"]
     "/foo/0" "bar"
     "/"      0
     "/a~1b"  1
     "/c%d"   2
     "/e^f"   3
     "/g|h"   4
     "/i\\j"  5
     "/k\"l"  6
     "/ "     7
     "/m~0n"  8
 */

- (void)testRFC6901StringRepresentations
{
    NSDictionary *json = _jsonRFC6901;
	NSDictionary *tests = @{@"": json,
                            @"/foo": @[@"bar", @"baz"],
                            @"/foo/0": @"bar",
                            @"/": @0,
                            @"/a~1b": @1,
                            @"/c%d": @2,
                            @"/e^f": @3,
                            @"/g|h": @4,
                            @"/i\\j": @5,
                            @"/k\"l": @6,
                            @"/ ": @7,
                            @"/m~0n": @8
                            };

	[tests enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    XCTAssertEqualObjects([json valueForJSONPointer:key], obj, @"RFC6901 Test '%@' Failed", key);
	}];
}

/* RFC6901 URI Fragment Representations
     "#"          the whole document
     "#/foo"      ["bar", "baz"]
     "#/foo/0"    "bar"
     "#/"         0
     "#/a~1b"     1
     "#/c%25d"    2
     "#/e%5Ef"    3
     "#/g%7Ch"    4
     "#/i%5Cj"    5
     "#/k%22l"    6
     '#/%20"      7
     "#/m~0n"     8
 */

- (void)testRFC6901URIRepresentations
{
    NSDictionary *json = _jsonRFC6901;
    NSDictionary *tests = @{@"#": json,
                            @"#/foo": @[@"bar", @"baz"],
                            @"#/foo/0": @"bar",
                            @"#/": @0,
                            @"#/a~1b": @1,
                            @"#/c%25d": @2,
                            @"#/e%5Ef": @3,
                            @"#/g%7Ch": @4,
                            @"#/i%5Cj": @5,
                            @"#/k%22l": @6,
                            @"#/%20": @7,
                            @"#/m~0n": @8
                            };

	[tests enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
	    XCTAssertEqualObjects([json valueForJSONPointer:key], obj, @"URI Test '%@' Failed", key);
	}];
}

- (void)testRFC6901InvalidReferences
{
    NSDictionary *json = _jsonRFC6901;
    NSString *prefix = @"Expected nil for invalid";

	XCTAssertNil([json valueForJSONPointer:@"/u110000"], @"%@ character", prefix);
	XCTAssertNil([json valueForJSONPointer:@"/c%25d"], @"%@ escaped non-fragment pointer", prefix);
	XCTAssertNil([json valueForJSONPointer:@"/foo/00"], @"%@ array reference with leading zero's", prefix);
	XCTAssertNil([json valueForJSONPointer:@"/foo/a"], @"%@ array reference", prefix);
}

#pragma mark - Boolean Values

- (void)testSuccessForBoolean
{
    NSDictionary *json = _jsonAdditional;
    NSString *pointer = @"/foo/bar/true";
    NSNumber *result = [json valueForJSONPointer:pointer];
    [self expectClass:[NSNumber class] forResult:result];
	XCTAssertEqual([result boolValue], YES, @"Expected true from pointer %@", pointer);

    pointer = @"/foo/bar/false";
    result = [json valueForJSONPointer:pointer];
    [self expectBooleanForResult:result];
	XCTAssertEqual([result boolValue], NO, @"Expected false from pointer %@", pointer);
}

- (void)testFailureForBoolean
{
    NSDictionary *json = _jsonAdditional;
    NSDictionary *tests = @{@"array": @"/foo/bar/array",
                            @"negative": @"/foo/bar/negative",
                            @"object": @"/foo/bar/object",
                            @"number": @"/foo/bar/number",
                            @"string": @"/foo/bar/string",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *result = [json valueForJSONPointer:obj];
        XCTAssertFalse([self isBooleanResult:result], @"Expected a non-boolean (%@) result for %@", key, obj);
    }];
}

#pragma mark - Number Values

- (void)testSuccessForNumber
{
    NSDictionary *json = _jsonAdditional;
    NSNumber *result = [json valueForJSONPointer:@"/foo/bar/number"];
    [self expectClass:[NSNumber class] forResult:result];
	XCTAssertEqual([result intValue], 55, @"Expected result to equal 55, found %@", result);

    result = [json valueForJSONPointer:@"/foo/bar/negative"];
    [self expectClass:[NSNumber class] forResult:result];
    XCTAssertEqual([result intValue], -55, @"Expected result to equal -55, found %@", result);
}

- (void)testFailureForNumber
{
    NSDictionary *json = _jsonAdditional;
    NSDictionary *tests = @{@"string": @"/foo/bar/string",
                            @"array": @"/foo/bar/array",
                            @"object": @"/foo/bar/object",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *result = [json valueForJSONPointer:obj];
        XCTAssertFalse([result isKindOfClass:[NSNumber class]], @"Expected a non-number result, found %@", result);
    }];
}

#pragma mark - String Values

- (void)testSuccessForString
{
    NSDictionary *json = _jsonAdditional;
    NSString *result = [json valueForJSONPointer:@"/foo/bar/string"];
    [self expectClass:[NSString class] forResult:result];
	XCTAssertEqualObjects(result, @"mystring", @"Expected a matching string result.");
}

- (void)testFailureForString
{
    NSDictionary *json = _jsonAdditional;
    NSDictionary *tests = @{@"array": @"/foo/bar/array",
                            @"bool": @"/foo/bar/true",
                            @"number": @"/foo/bar/number",
                            @"object": @"/foo/bar/object",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *result = [json valueForJSONPointer:obj];
        XCTAssertFalse([result isKindOfClass:[NSString class]], @"Expected a non-string result, found %@", result);
    }];
}

#pragma mark - Array Values

- (void)testSuccessForArray
{
    NSDictionary *json = _jsonAdditional;
	NSArray *array = @[@1,
                       @2,
                       @3];
    NSArray *result = [json valueForJSONPointer:@"/foo/bar/array"];
    [self expectClass:[NSArray class] forResult:result];
	XCTAssertEqualObjects(result, array, @"Expected a matching array result, found %@", result);
}

- (void)testFailureForArray
{
    NSDictionary *json = _jsonAdditional;
    NSDictionary *tests = @{@"string": @"/foo/bar/string",
                            @"bool": @"/foo/bar/true",
                            @"number": @"/foo/bar/number",
                            @"object": @"/foo/bar/object",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *result = [json valueForJSONPointer:obj];
        XCTAssertFalse([result isKindOfClass:[NSArray class]], @"Expected a non-array result, found %@", result);
    }];
}

#pragma mark - Dictionary Values

- (void)testSuccessForDictionary
{
    NSDictionary *json = _jsonAdditional;
	NSDictionary *dictionary = @{@"a": @1,
                                 @"b": @2,
                                 @"c": @3};
    NSDictionary *result = [json valueForJSONPointer:@"/foo/bar/object"];
    [self expectClass:[NSDictionary class] forResult:result];
    XCTAssertEqualObjects(result, dictionary, @"Expected a matching dictionary result, found %@", result);
}

- (void)testFailureForDictionary
{
    NSDictionary *json = _jsonAdditional;
    NSDictionary *tests = @{@"array": @"/foo/bar/array",
                            @"bool": @"/foo/bar/true",
                            @"number": @"/foo/bar/number",
                            @"string": @"/foo/bar/string",
                            @"null": @"/foo/bar/null"};
    [tests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *result = [json valueForJSONPointer:obj];
        XCTAssertFalse([result isKindOfClass:[NSDictionary class]], @"Expected a non-dictionary result, found %@", result);
    }];
}

#pragma mark - Utilities

- (void)expectClass:(Class)class forResult:(id)result
{
    XCTAssertTrue([result isKindOfClass:class], @"Expected an %@ result, found %@", class, [result class]);
}

- (void)expectBooleanForResult:(id)result
{
    XCTAssertTrue([self isBooleanResult:result], @"Expected a boolean result, found %@", result);
}

- (BOOL)isBooleanResult:(NSNumber *)result
{
    return ([result isKindOfClass:[NSNumber class]] &&
            (result.intValue == 0 || result.intValue == 1));
}

@end
