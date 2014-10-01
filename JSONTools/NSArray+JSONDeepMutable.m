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
    return [self copyAsDeeplyMutableJSONWithExceptions:YES];
}

- (NSMutableArray *)copyAsDeeplyMutableJSONWithExceptions:(BOOL)throwsExceptions
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    for (id oldValue in self)
    {
        id newCopy = [JSONDeepMutable copyAsDeeplyMutableValue:oldValue throwsExceptions:throwsExceptions];
        if (newCopy)
        {
            [ret addObject:newCopy];
        }
    }
    return ret;
}

@end
