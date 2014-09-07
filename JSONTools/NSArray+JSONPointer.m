//
//  NSArray+JSONPointer.m
//  based in part on CWJSONPointer by Jonathan Dring (MIT/Copyright (c) 2014)
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "NSArray+JSONPointer.h"
#import "JSONPointer.h"

@implementation NSArray (JSONPointer)

- (id)valueForJSONPointer:(NSString *)pointer
{
    return [JSONPointer valueForCollection:self withJSONPointer:pointer];
}

- (id)valueForJSONPointerComponent:(NSString *)component
{
    NSInteger index = [self indexForJSONPointerComponent:component];

    if (index == NSNotFound)
    {
        return nil;
    }

    // Section 4. Valid array reference so navigate to object.
    return self[index];
}

- (NSInteger)indexForJSONPointerComponent:(NSString *)component
{
    return [self indexForJSONPointerComponent:component allowOutOfBounds:NO];
}

- (NSInteger)indexForJSONPointerComponent:(NSString *)component allowOutOfBounds:(BOOL)allowOutOfBounds
{
    if (!component || ![component isKindOfClass:[NSString class]])
        return NSNotFound;

    //Section 4. Transform any escaped characters, in the order ~1 then ~0.
    component = [component stringByReplacingOccurrencesOfString:@"~1" withString:@"/"];
    component = [component stringByReplacingOccurrencesOfString:@"~0" withString:@"~"];

    // Section 4. Process array objects with ABNF Rule: 0x30/(0x31-39 *(0x30-0x39))

    static NSCharacterSet *numberSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    });

    if (![[component stringByTrimmingCharactersInSet:numberSet] isEqualToString:@""])
    {
        return NSNotFound;
    }

    // Section 4. Check for leading zero's
    if ([component hasPrefix:@"0"] &&
        [component length] > 1)
    {
        return NSNotFound;
    }

    // Section 4. Non-existant array element, terminate evaluation.
    if ([component isEqualToString:@"-"])
    {
        return NSNotFound;
    }

    // Avoid any out-of-bounds exceptions, if necessary
    NSInteger index = [component integerValue];
    if (!allowOutOfBounds &&
        self.count <= index)
    {
        return NSNotFound;
    }

    // Section 4. Valid array reference so navigate to object.
    return index;
}

@end
