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
    return [self copyAsDeeplyMutableJSONWithExceptions:YES];
}

- (NSMutableDictionary *)copyAsDeeplyMutableJSONWithExceptions:(BOOL)throwsExceptions
{
    NSMutableDictionary * ret = [[NSMutableDictionary alloc] init];

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id newCopy = [JSONDeepMutable copyAsDeeplyMutableValue:obj throwsExceptions:throwsExceptions];
        if (newCopy)
        {
            ret[key] = newCopy;
        }
    }];
    
    return ret;
}

@end
