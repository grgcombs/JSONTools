//
//  NSArray+JSONPointer.h
//  based in part on CWJSONPointer by Jonathan Dring (MIT/Copyright (c) 2014)
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

@import Foundation;

@interface NSArray (JSONPointer)

/**
 *  Returns the receiver's value corresponding to the supplied JSON Pointer reference.
 *  This is a convenience category for arrays to simplify this call:
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
 *  Given a single JSON Pointer component, like "12" from "/foo/bar/12", return the
 *  the receiver's corresponding value.  In general you should use the JSONPointer
 *  class methods or valueForJSONPointer: above, as this method limits the scope.
 *
 *  @param component A string in the form of a JSON Pointer component, like "12".
 *
 *  @return The pointer component's corresponding content value (or nil).
 */
- (id)valueForJSONPointerComponent:(NSString *)component;

/**
 *  Given a single JSON Pointer component, like "bar" or "0" from "/foo/bar/0", return the
 *  the receiver's corresponding array index.  In general you should use the JSONPointer
 *  class methods instead, as this method is limited in the pointer's scope.
 *
 *  @param component A string in the form of a JSON Pointer component, like "bar" or "0".
 *
 *  @return The pointer component's corresponding array index, or NSNotFound.
 */
- (NSInteger)indexForJSONPointerComponent:(NSString *)component;

/**
 *  Given a single JSON Pointer component, like "bar" or "0" from "/foo/bar/0", return the
 *  the receiver's corresponding array index.  In general you should use the JSONPointer
 *  class methods instead, as this method is limited in the pointer's scope.
 *
 *  @param component A string in the form of a JSON Pointer component, like "bar" or "0".
 *  @param allowOutOfBounds A boolean indicating whether to permit out-of-bounds array indexes.
 *         Such indexes should be treated with care, as they are not "navigable" in the array and
 *         will trigger exceptions.  They are are useful when used in conjunction with JSON Patch, however.
 *
 *  @return The pointer component's corresponding array index, or NSNotFound.
 */
- (NSInteger)indexForJSONPointerComponent:(NSString *)component allowOutOfBounds:(BOOL)allowOutOfBounds;

@end
