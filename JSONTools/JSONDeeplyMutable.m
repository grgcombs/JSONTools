//
//  JSONDeeplyMutable.m
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONDeeplyMutable.h"

@implementation JSONDeepMutable

+ (id)copyAsDeeplyMutableValue:(id)oldValue throwsExceptions:(BOOL)throwsExceptions
{
    id newCopy = nil;

    if ([oldValue respondsToSelector: @selector(copyAsDeeplyMutableJSON)])
    {
        newCopy = [oldValue copyAsDeeplyMutableJSON];
    }
    else if ([oldValue conformsToProtocol:@protocol(NSMutableCopying)])
    {
        newCopy = [oldValue mutableCopy];
    }
    else if ([oldValue conformsToProtocol:@protocol(NSCopying)])
    {
        newCopy = [oldValue copy];
    }
    
    if (!newCopy && throwsExceptions)
    {
        [NSException raise:NSDestinationInvalidException format:@"Object is not mutable or copyable: %@", oldValue];
    }

    return newCopy;
}

@end