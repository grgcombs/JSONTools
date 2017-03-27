//
//  NSDictionary+JSONPointer.h
//  based in part on CWJSONPointer by Jonathan Dring (MIT/Copyright (c) 2014)
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONPointer)

/**
 *  Returns the receiver's value corresponding to the supplied JSON Pointer reference.
 *  This is a convenience category for dictionaries to simplify this call:
 *    `[JSONPointer valueForCollection:self withJSONPointer:pointer]`
 *
 *  @see JSON Pointer RFC 6901 (April 2013)
 *
 *  @param pointer A string in the form of a JSON Pointer, like "/foo/bar/0" or "#/foo"
 *
 *  @return The pointer's corresponding content value (or nil) in the collection.
 */
- (id)valueForJSONPointer:(NSString *)pointer;

/**
 *  Given a single JSON Pointer component, like "bar" from "/foo/bar/0", return the
 *  the receiver's corresponding value.  In general you should use the JSONPointer
 *  class methods or valueForJSONPointer: above, as this method limits the scope.
 *
 *  @param component A string in the form of a JSON Pointer component, like "bar".
 *
 *  @return The pointer component's corresponding content value (or nil).
 */
- (id)valueForJSONPointerComponent:(NSString *)component;

/**
 *  Given a single JSON Pointer component, like "a~1b", return the
 *  component key after converting escape characters, like "a/b".
 *
 *  @param component A string in the form of a JSON Pointer component.
 *
 *  @return The component key after converting escape characters.
 */
- (NSString *)keyForJSONPointerComponent:(NSString *)component;

@end
