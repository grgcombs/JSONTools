//
//  NSDictionary+JSONPointer.m
//  based in part on CWJSONPointer by Jonathan Dring (MIT/Copyright (c) 2014)
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "NSDictionary+JSONPointer.h"
#import "JSONPointer.h"

@implementation NSDictionary (JSONPointer)

- (id)valueForJSONPointer:(NSString *)pointer
{
    return [JSONPointer valueForCollection:self withJSONPointer:pointer];
}

- (id)valueForJSONPointerComponent:(NSString *)component
{
    component = [self keyForJSONPointerComponent:component];
    if (!component)
        return nil;

    // Section 4. If value is an object return the referenced property.
    return self[component];
}

- (NSString *)keyForJSONPointerComponent:(NSString *)component
{
    if (!component || ![component isKindOfClass:[NSString class]])
        return nil;

    //Section 4. Transform any escaped characters, in the order ~1 then ~0.
    component = [component stringByReplacingOccurrencesOfString:@"~1" withString:@"/"];
    component = [component stringByReplacingOccurrencesOfString:@"~0" withString:@"~"];
    return component;
}

@end
