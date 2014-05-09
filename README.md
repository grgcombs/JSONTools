JSON Tools (Objective-C)  
=========
by [Gregory Combs](https://github.com/grgcombs)  
(MIT License - 2014)

[![Build Status](https://travis-ci.org/grgcombs/JSONTools.svg?branch=master)](https://travis-ci.org/grgcombs/JSONTools)

JSON Patch, JSON Pointer, and JSON Schema Validation in Objective-C

This Objective-C library is a collection of classes and categories that implement three powerful new features (JSON Patch, JSON Pointer, JSON Schema) that work with JSON data (represented by NSDictionaries and NSArrays in Objective-C).  Unit tests are included for each component.

## To Run the Tests

To build the test project, be sure to do the following:

1. Install CocoaPods (use homebrew) if you haven't already.
2. Run `pod install` from the command line.  
3. Open the newly created **JSONToolsTests.xcworkspace** document ***not*** the JSONToolsTests.xcodeproj document.
4. Hit Command-U to run the tests.

## Features

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
                            @"guts": @"and things"
                        }
                    }
                };

                NSString *result1 = [_obj valueForJSONPointer: @"/data/foo/1" ];
                // Yields -> "baz"

                NSString *result2 = [_obj valueForJSONPointer: @"/data/bork/guts"];
                // Yields -> "and things"

                NSDictionary *result3 = [_obj valueForJSONPointer: @"/data/bork"];
                // Yields -> {"crud": "stuff","guts": "and things"}
            }

        ```

- [JSON Schema](http://tools.ietf.org/html/draft-zyp-json-schema-04) with [Validation](http://tools.ietf.org/html/draft-fge-json-schema-validation-00) - IETF Draft v4, 2013.   ***This functionality is based on [Sam Duke's](https://github.com/samskiter) [KiteJSONValidator](https://github.com/samskiter/KiteJSONValidator)*** but adds additional validations and tests for the JSON-Schema `format` parameter.
    -  Example #1:  

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
               "validData": [0, 1, 2, 3, 4, 5],
               "invalidData": [-12, "Abysmal", null, -141]
            }
        ```
        
        ```objc
        
            /* 
               Assuming that variables are assigned using JSON above: 
                 schema is an NSDictionary
                 validData and invalidData are NSArrays
             */
            
            BOOL success = NO;        
            JSONSchemaValidator *validator = [JSONSchemaValidator new];
                    
            success = [validator validateJSONInstance:validData withSchema:schema];
            // success == YES, All validData values are positive integers.
            
            success = [validator validateJSONInstance:invalidData withSchema:schema];
            // success == NO, invalidData array isn't comprised of positive integers.

        ```

        
   - Example #2:
   
        ```objc
        
            NSDictionary *schema = nil;
            id testData = nil;
            BOOL success = NO;
            
            JSONSchemaValidator *validator = [JSONSchemaValidator new];
            validator.formatValidationEnabled = YES;
        
            schema = @{@"format": @"date-time"};
            testData = @"2000-02-29T08:30:06.283185Z";
            success = [validator validateJSONInstance:testData withSchema:schema];
            // success == YES, February 2000 had 29 days.
            
            schema = @{@"format": @"ipv6"};
            testData = @"12345::";
            success = [validator validateJSONInstance:testData withSchema:schema];
            // success == NO, the IPv6 address has out-of-range values.

        ```
        
