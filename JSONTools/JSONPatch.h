//
//  JSONPatch.h
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONTools.h"

@interface JSONPatch : NSObject

/**
 *  Implements IETF RFC6902 - JSON Patch
 *  @see https://tools.ietf.org/html/rfc6902
 *
 *  @param patches    An array of one or more patch dictionaries in the form of:
 *      `{"op":"add",  "path": "/foo/0/bar",  "value": "thing"}`
 *      - `op` is one of: "add", "remove", "copy", "move", "test", "_get"
 *      - `path` is a JSON Pointer (RFC 6901) (see JSONPointer.h)
 *      - `value` is an objective-c object (
 *
 *  @param collection A ***mutable*** dictionary or ***mutable*** array to patch
 *
 *  @return For all but "_get", the result is an NSNumber boolean indicating patch success.
 *  However, for "_get" operations, the result will be the collection's content
 *  corresponding to the supplied patch JSON Pointer (i.e. "path")
 */
+ (id)applyPatches:(NSArray *)patches toCollection:(id)collection;

+ (NSArray *)createPatchesComparingCollectionsOld:(id)oldCollection toNew:(id)newCollection;

@end
