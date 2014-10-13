//
//  JSONPatchApplyTests.m
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

@import XCTest;
#import "JSONPatch.h"
#import "JSONDeeplyMutable.h"

@interface JSONPatchApplyTests : XCTestCase

@end

@implementation JSONPatchApplyTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldApplyAdd
{
    NSMutableDictionary *initial = [@{@"foo": @1,
                                      @"baz": @[@{@"qux": @"hello"}]} copyAsDeeplyMutableJSON];
    NSMutableDictionary *obj = [initial mutableCopy];
    NSMutableDictionary *expected = [initial mutableCopy];


    expected[@"bar"] = @[@1,@2,@3,@4];
    [JSONPatch applyPatches:@[@{@"op": @"add",
                                @"path": @"/bar",
                                @"value": @[@1, @2, @3, @4]}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply add patch, expected %@, found %@", expected, obj);



    expected[@"baz"][0] = @{@"qux": @"hello",
                            @"foo": @"world"};
    [JSONPatch applyPatches:@[@{@"opp": @"add",
                                @"path": @"/baz/0/foo",
                                @"value": @"world"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply add patch, expected %@, found %@", expected, obj);



    obj = [initial mutableCopy];
    expected = [initial mutableCopy];
    expected[@"bar"] = @YES;
    [JSONPatch applyPatches:@[@{@"op": @"add",
                                @"path": @"/bar",
                                @"value": @YES}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply add patch, expected %@, found %@", expected, obj);


    expected[@"bar"] = @NO;
    [JSONPatch applyPatches:@[@{@"op": @"add",
                                @"path": @"/bar",
                                @"value": @NO}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply add patch, expected %@, found %@", expected, obj);

    obj = [initial mutableCopy];
    expected = [initial mutableCopy];
    expected[@"bar"] = [NSNull null];
    [JSONPatch applyPatches:@[@{@"op": @"add",
                                @"path": @"/bar",
                                @"value": [NSNull null]}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply add patch, expected %@, found %@", expected, obj);
}

- (void)testShouldApplyRemove
{
    NSMutableDictionary *obj = [@{@"foo": @1,
                                  @"baz": @[@{@"qux": @"hello"}],
                                  @"bar": @[@1,@2,@3,@4]} copyAsDeeplyMutableJSON];

    NSMutableDictionary *expected = [obj copyAsDeeplyMutableJSON];
    [expected removeObjectForKey:@"bar"];
    [JSONPatch applyPatches:@[@{@"op": @"remove",
                                @"path": @"/bar"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply remove patch, expected %@, found %@", expected, obj);

    expected = [@{@"foo": @1,
                  @"baz": @[@{}]} copyAsDeeplyMutableJSON];
    [JSONPatch applyPatches:@[@{@"op": @"remove",
                                @"path": @"/baz/0/qux"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply remove patch, expected %@, found %@", expected, obj);
}

- (void)testShouldApplyReplace
{
    NSMutableDictionary *obj = [@{@"foo": @1,
                                  @"baz": @[@{@"qux": @"hello"}]} copyAsDeeplyMutableJSON];

    NSMutableDictionary *expected = [obj copyAsDeeplyMutableJSON];
    expected[@"foo"] = @[@1,@2,@3,@4];
    [JSONPatch applyPatches:@[@{@"op": @"replace",
                                @"path": @"/foo",
                                @"value": @[@1,@2,@3,@4]}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply replace patch, expected %@, found %@", expected, obj);

    expected[@"baz"][0][@"qux"] = @"world";
    [JSONPatch applyPatches:@[@{@"op": @"replace",
                                @"path": @"/baz/0/qux",
                                @"value": @"world"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply replace patch, expected %@, found %@", expected, obj);
}

- (void)testShouldApplyTest
{
    NSDictionary *obj = @{@"foo": @{@"bar": @[@1,@2,@5,@4]}};
    NSDictionary *testObj = @{@"bar": @[@1,@2,@5,@4]};
    NSNumber *result = [JSONPatch applyPatches:@[@{@"op": @"test",
                                                   @"path": @"/foo",
                                                   @"value": testObj}] toCollection:obj];
    XCTAssertNotNil(result, @"Failed to apply test patch, expected a non-nil test result");
    XCTAssertTrue([result boolValue], @"Failed to apply test patch, expected TRUE, found %@", result);

    result = [JSONPatch applyPatches:@[@{@"op": @"test",
                                         @"path": @"/foo",
                                         @"value": @[@1,@2]}] toCollection:obj];
    XCTAssertNotNil(result, @"Failed to apply test patch, expected a non-nil test result");
    XCTAssertFalse([result boolValue], @"Failed to apply test patch, expected FALSE, found %@", result);
}

- (void)testShouldApplyMove
{
    NSMutableDictionary *obj = [@{@"foo": @1,
                                  @"baz": @[@{@"qux": @"hello"}]} copyAsDeeplyMutableJSON];
    NSMutableDictionary *expected = [obj copyAsDeeplyMutableJSON];

    expected[@"bar"] = @1;
    [expected removeObjectForKey:@"foo"];
    [JSONPatch applyPatches:@[@{@"op": @"move",
                                @"from": @"/foo",
                                @"path": @"/bar"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply move patch, expected %@, found %@", expected, obj);

    [expected[@"baz"][0] removeAllObjects];
    [expected[@"baz"] addObject:@"hello"];
    [JSONPatch applyPatches:@[@{@"op": @"move",
                                @"from": @"/baz/0/qux",
                                @"path": @"/baz/1"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply move patch, expected %@, found %@", expected, obj);
}

- (void)testShouldApplyCopy
{
    NSMutableDictionary *obj = [@{@"foo": @1,
                                  @"baz": @[@{@"qux": @"hello"}]} copyAsDeeplyMutableJSON];
    NSMutableDictionary *expected = [obj copyAsDeeplyMutableJSON];

    expected[@"bar"] = @1;
    [JSONPatch applyPatches:@[@{@"op": @"copy",
                                @"from": @"/foo",
                                @"path": @"/bar"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply copy patch, expected %@, found %@", expected, obj);

    [expected[@"baz"] addObject:@"hello"];
    [JSONPatch applyPatches:@[@{@"op": @"copy",
                                @"from": @"/baz/0/qux",
                                @"path": @"/baz/1"}] toCollection:obj];
    XCTAssertEqualObjects(obj, expected, @"Failed to apply copy patch, expected %@, found %@", expected, obj);
}

- (void)testShouldApplyMultiplePatches
{
    NSMutableDictionary *obj = [@{@"firstName": @"Albert",
                                  @"contactDetails": @{
                                          @"phoneNumbers": @[]
                                          }
                                  } copyAsDeeplyMutableJSON];

    NSArray *patches = @[
                         @{@"op": @"replace",
                           @"path": @"/firstName",
                           @"value": @"Joachim"
                           },
                         @{@"op": @"add",
                           @"path": @"/lastName",
                           @"value": @"Wester"
                           },
                         @{@"op": @"add",
                           @"path": @"/contactDetails/phoneNumbers/0",
                           @"value": @{ @"number": @"555-123" }
                           }
                         ];

    NSMutableDictionary *expected = [@{@"firstName": @"Joachim",
                                       @"lastName": @"Wester",
                                       @"contactDetails": @{
                                               @"phoneNumbers": @[
                                                    @{@"number": @"555-123"}
                                                ]
                                            }
                                       } mutableCopy];

    [JSONPatch applyPatches:patches toCollection:obj];

    XCTAssertEqualObjects(obj, expected, @"Failed to apply multiple patches, expected %@, found %@", expected, obj);
}

/**
 *  Empty path strings should be accepted as the pointer to root
 *  https://github.com/grgcombs/JSONTools/issues/3
 *
 *  JSON Pointer RFC
 *  http://tools.ietf.org/html/rfc6901#section-5
 *
 *  The following JSON strings evaluate to the accompanying values:
 *
 *      ""           // the whole document
 */
- (void)testShouldAcceptPatchesToRootPointer
{
    NSMutableDictionary *obj = [@{@"foo": @1,
                                  @"baz": @[@{@"qux": @"hello"}]} copyAsDeeplyMutableJSON];

    NSDictionary *expected = @{@"bar": @[@1,@2,@3,@4]};
    id result = [JSONPatch applyPatches:@[@{@"op": @"replace",
                                            @"path": @"",
                                            @"value": @{@"bar": @[@1,@2,@3,@4]}}] toCollection:obj];
    XCTAssertEqualObjects(result, @1, @"The root-level patch should succeed.");
    XCTAssertEqualObjects(obj, expected, @"Failed to apply root-level patch, expected %@, found %@", expected, obj);
}

- (void)testShouldNotPatchIncompatibleTopLevelCollections
{
    NSMutableDictionary *dictionary = [@{@"foo": @1,
                                         @"baz": @[@{@"qux": @"hello"}]} copyAsDeeplyMutableJSON];
    NSArray *replacementArray = @[@1,@2,@3,@4];

    id result = [JSONPatch applyPatches:@[@{@"op": @"replace",
                                            @"path": @"",
                                            @"value": replacementArray}] toCollection:dictionary];
    XCTAssertEqualObjects(result, @0, @"Should have failed to replace a top level dictionary with an array: %@", result);

    NSMutableArray *array = [@[@1,@2,@3,@4] copyAsDeeplyMutableJSON];
    NSDictionary *replacementDictionary = @{@"1": @1,
                                            @"2": @2,
                                            @"3": @3,
                                            @"4": @4};

    result = [JSONPatch applyPatches:@[@{@"op": @"replace",
                                            @"path": @"",
                                            @"value": replacementDictionary}] toCollection:array];
    XCTAssertEqualObjects(result, @0, @"Should have failed to replace a top level array with a dictionary: %@", result);
}

@end
