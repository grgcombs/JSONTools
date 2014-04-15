//
//  NSDictionary+JSONDeepMutable.m
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "NSDictionary+JSONDeepMutable.h"
#import "JSONDeeplyMutable.h"

@implementation NSDictionary (JSONDeepMutable)

- (NSMutableDictionary *)copyAsDeeplyMutableJSON
{
    NSMutableDictionary * ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id newCopy = [JSONDeepMutable copyAsDeeplyMutableValue:obj];
        if (newCopy)
        {
            ret[key] = newCopy;
        }
    }];
    
    return ret;
}

@end
