//
//  NSArray+JSONDeepMutable.m
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "NSArray+JSONDeepMutable.h"
#import "JSONDeeplyMutable.h"

@implementation NSArray (JSONDeepMutable)

- (NSMutableArray *)copyAsDeeplyMutableJSON
{
    NSMutableArray* ret = [[NSMutableArray alloc] initWithCapacity: [self count]];
    for (id oldValue in self)
    {
        id newCopy = [JSONDeepMutable copyAsDeeplyMutableValue:oldValue];
        if (newCopy)
        {
            [ret addObject:newCopy];
        }
    }
    return ret;
}

@end
