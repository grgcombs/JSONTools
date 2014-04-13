//
//  JSONPointer.m
//  based in part on CWJSONPointer by Jonathan Dring (MIT/Copyright (c) 2014)
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONPointer.h"

@implementation JSONPointer

+ (id)valueForCollection:(id)collection withJSONPointer:(NSString *)pointer
{
	if (!pointer || ![pointer isKindOfClass:[NSString class]])
    {
		return nil;
	}

    // JSON Pointer RFC 6901 (April 2013)

    // Section 6: URI fragment evaluation: if a fragment, remove the fragment marker and de-escape.
    pointer = [self trimAndUnescapeJSONPointerFragment:pointer];

    // Section 5. Blank Pointer evaluates to complete JSON document.
	if ([pointer isEqualToString:@""])
    {
		return collection;
	}

    // Section 3. Token without leading '/' is illegal, terminate evaluation
	if (![pointer hasPrefix:@"/"])
    {
        return nil;
    }

    // Section 3. Legal leading '/', strip and continue;
    pointer = [pointer substringFromIndex:1];


    // Section 3. Check for valid character ranges upper and lower limits.
	if ([self pointerHasInvalidCharacters:pointer])
    {
		return nil;
	}

	// Section 4. Evaluate the tokens one by one starting with the root.
	id object = collection;
	NSArray *pointerComponents = [pointer componentsSeparatedByString:@"/"];
	for (NSString *component in pointerComponents)
    {
        object = [self valueForCollection:object withJSONPointerComponent:component];
        if (!object || [object isEqual:[NSNull null]])
        {
            return nil;
        }
	}
	return object;
}

+ (NSString *)trimAndUnescapeJSONPointerFragment:(NSString *)pointer
{
	if ([pointer hasPrefix:@"#"])
    {
		pointer = [pointer substringFromIndex:1];
		pointer = [pointer stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
    return pointer;
}

+ (BOOL)pointerHasInvalidCharacters:(NSString *)pointer
{
    static NSCharacterSet *illegalChars;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        illegalChars = [[NSCharacterSet characterSetWithRange:NSMakeRange(0x0000, 0x10FFFF)] invertedSet];
    });

	return ([pointer rangeOfCharacterFromSet:illegalChars].location != NSNotFound);
}

+ (id)valueForCollection:(id)collection withJSONPointerComponent:(NSString *)component
{
    if (collection == nil || collection == [NSNull null])
    {
        // If the object is nil or null, terminate evaluation.
        return nil;
    }

    if ([collection isKindOfClass:[NSDictionary class]])
    {
        return [(NSDictionary *)collection valueForJSONPointerComponent:component];
    }

    if ([collection isKindOfClass:[NSArray class]])
    {
        return [(NSArray *)collection valueForJSONPointerComponent:component];
    }

    // Unspecified object type, terminate evaluation.
    return nil;
}

@end
