//
//  JSONPatchGenerateTests.m
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

@import XCTest;
#import "JSONPatch.h"
#import "JSONDeeplyMutable.h"

@interface JSONPatchGenerateTests : XCTestCase

@end

@implementation JSONPatchGenerateTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldGenerateAdd
{
    NSDictionary *objA = @{@"user": @{@"firstName": @"Albert"}};
    NSDictionary *objB = @{@"user": @{@"firstName": @"Albert",
                                      @"lastName": @"Einstein"}};

    NSArray *patches = [JSONPatch createPatchesComparingCollectionsOld:objA toNew:objB];
    NSArray *expected = @[@{@"op": @"add",
                            @"path": @"/user/lastName",
                            @"value": @"Einstein"}];
    XCTAssertEqualObjects(patches, expected, @"Failed to generate add patch, expected %@, found %@", expected, patches);
}

- (void)testShouldGenerateReplace
{
    NSDictionary *objA = @{@"firstName": @"Albert",
                           @"lastName": @"Einstein"};

    NSDictionary *objB = @{@"firstName": @"Albert",
                           @"lastName": @"Statham"};

    NSArray *expected = @[@{@"op": @"replace",
                            @"path": @"/lastName",
                            @"value": @"Statham"}];
    NSArray *patches = [JSONPatch createPatchesComparingCollectionsOld:objA toNew:objB];
    XCTAssertEqualObjects(patches, expected, @"Failed to generate replace patch, expected %@, found %@", expected, patches);
}

- (void)testShouldGenerateReplaceAndAdd
{
    NSMutableDictionary *objA = [@{@"firstName": @"Albert",
                                   @"lastName": @"Einstein",
                                   @"phoneNumbers": @[@{@"phone": @"123-4444"}]} copyAsDeeplyMutableJSON];

    NSMutableDictionary *objB = [@{@"firstName": @"Albert",
                                   @"lastName": @"Statham",
                                   @"phoneNumbers": @[@{@"phone": @"123-4453"},
                                                      @{@"cell": @"456-3533"}]} copyAsDeeplyMutableJSON];

    NSArray *patches = [JSONPatch createPatchesComparingCollectionsOld:objA toNew:objB];
    XCTAssertTrue(patches.count > 1, @"Failed to generate a composite replace/add patch: %@", patches);

    NSNumber *result = [JSONPatch applyPatches:patches toCollection:objA];
    XCTAssertNotNil(result, @"Patch apply results should not be nil");
    XCTAssertTrue([result boolValue], @"Failed to apply the replace/add patch: %@", patches);
    XCTAssertEqualObjects(objA, objB, @"The patched collection should equal that of the opposing collection");
}

- (void)testShouldGenerateRemove
{
    NSDictionary *objA = @{@"firstName": @"Albert",
                           @"lastName": @"Einstein"};

    NSDictionary *objB = @{@"firstName": @"Albert"};

    NSArray *expected = @[@{@"op": @"remove",
                            @"path": @"/lastName"}];

    NSArray *patches = [JSONPatch createPatchesComparingCollectionsOld:objA toNew:objB];
    XCTAssertEqualObjects(patches, expected, @"Failed to generate remove patch, expected %@, found %@", expected, patches);
}

@end
