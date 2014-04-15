JSON Tools (Objective-C)
by [Gregory Combs](https://github.com/grgcombs)  
(MIT License - 2014)
=========

JSON Patch, JSON Pointer, and JSON Schema Validation in Objective-C

This Objective-C library is a collection of classes and categories that implement three powerful new features (JSON Patch, JSON Pointer, JSON Schema) that work with JSON data (represented by NSDictionaries and NSArrays in Objective-C).  Unit tests are included for each component.

- [JSON Patch](https://tools.ietf.org/html/rfc6902) - IETF RFC6902: Create and apply operation patches (add, remove, copy, move, test, _get) to serially transform JSON Data.  ***This functionality was inspired by [Joachim Wester's](https://github.com/Starcounter-Jack) [JavaScript implementation of JSON Patch](https://github.com/Starcounter-Jack/JSON-Patch).***
    -  Example Patch Copy:  
        
        ```objc
        
            #import "JSONTools.h"
            #import "JSONDeeplyMutable.h"

            - (void)examplePatchCopy
            {
                 NSMutableDictionary *obj = nil;
                 NSMutableDictionary *expected = nil;
                 NSDictionary *patch = nil;
                 
                 obj = [@{@"foo": @1,
                          @"baz": @[@{@"qux": @"hello"}]} copyAsDeeplyMutableJSON];
                
                 patch = @{@"op": @"copy",
                           @"from": @"/foo",
                           @"path": @"/bar"};
                           
                 [JSONPatch applyPatches:@[patch] toCollection:obj];

                 expected = [@{@"foo": @1,
                               @"baz": @[@{@"qux": @"hello"}],
                               @"bar": @1} copyAsDeeplyMutableJSON];
            }

        ```
        
    -  Example Patch Generation (JSON Diff):
        
        ```objc
        
            #import "JSONTools.h"

            - (void)examplePatchGeneration
            {
                NSDictionary *objA = nil;
                NSDictionary *objB = nil;
                NSArray *patches = nil;
                NSArray *expected = nil;
                
                objA = @{@"user": @{@"firstName": @"Albert",
                                    @"lastName": @"Einstein"}};
            
                objB = @{@"user": @{@"firstName": @"Albert"}};
            
                patches = [JSONPatch createPatchesComparingCollectionsOld:objA toNew:objB];
                                            
                expected = @[@{@"op": @"remove",
                               @"path": @"/user/lastName"}];

            }
        
        ```
        

- [JSON Pointer](https://tools.ietf.org/html/rfc6901) - IETF RFC6901: Reference and access values and objects within a hierarchical JSON structure using a concise path pattern notation.  ***This functionality is based on [Jonathan Dring's](https://github.com/C-Works) [NSDictionary-CWJSONPointer](https://github.com/C-Works/NSDictionary-CWJSONPointer).***
    -  Example:  
  
        ```objc
        
            #import "JSONTools.h"
                
            - (void)exampleJSONPointer
            {
                NSDictionary *obj = @{
                    @"data": @{
                        @"foo": @[@"bar", @"baz"],
                        @"bork": @{
                            @"crud": @"stuff",
                            @"guts": @"and things"                        }
                    }
                };

                NSString *result1 = [_obj valueForJSONPointer: @"/data/foo/1" ];
                // Yields -> "baz"

                NSString *result2 = [_obj valueForJSONPointer: @"/data/bork/guts"];
                // Yields -> "and things"

                NSDictionary *result3 = [_obj valueForJSONPointer: @"/data/bork"];
                // Yields -> {"crud": "stuff","guts": "and things"}            }

        ```

- <del>[JSON Schema](http://tools.ietf.org/html/draft-zyp-json-schema-04) with [Validation](http://tools.ietf.org/html/draft-fge-json-schema-validation-00) - IETF Draft v4, 2013</del>: (*TBD / WIP*).  ***This functionality will likely be based on [Sam Duke's](https://github.com/samskiter) [KiteJSONValidator](https://github.com/samskiter/KiteJSONValidator).***
    -  Example:  

        ```json
        
            {
               "schema": {
                   "type": "array",
                   "items": { "$ref": "#/definitions/positiveInteger" },
                   "definitions": {
                       "positiveInteger": {
                           "type": "integer",
                           "minimum": 0,
                           "exclusiveMinimum": true
                       }
                   }
               },
               "valid_data": [0, 1, 2, 3, 4, 5],
               "invalid_data": [-12, "Abysmal", null, -141]
            }
        ```
        
