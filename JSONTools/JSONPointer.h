//
//  JSONPointer.h
//  based in part on CWJSONPointer by Jonathan Dring (MIT/Copyright (c) 2014)
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

@import Foundation;
#import "NSArray+JSONPointer.h"
#import "NSDictionary+JSONPointer.h"

@interface JSONPointer : NSObject

/**
 *  Implements IETF RFC6901 - JSON Pointer
 *  @see https://tools.ietf.org/html/rfc6901
 *
 *  The supplied collection (dictionary or array) returns a value corresponding to
 *  the supplied JSON Pointer reference.
 *
 *  @param collection A collection (either dictionary or array).
 *
 *  @param pointer A string in the form of a JSON Pointer, like "/foo/bar/0" or "#/foo"
 *
 *  @return The pointer's corresponding content value (or nil) in the collection.
 */
+ (id)valueForCollection:(id)collection withJSONPointer:(NSString *)pointer;

@end
