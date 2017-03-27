//
//  JSONPatchDictionary.m
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONPatchDictionary.h"
#import "JSONPointer.h"

@implementation JSONPatchDictionary

+ (id)applyPatchInfo:(JSONPatchInfo *)info object:(NSMutableDictionary *)object key:(NSString *)key
{
    BOOL success = NO;
    switch (info.op)
    {
        case JSONPatchOperationGet:
            return [self getValueForObject:object key:key];
            break;
        case JSONPatchOperationTest:
            return @([self test:object key:key value:info.value]);
            break;
        case JSONPatchOperationAdd:
            success = [self addObject:object key:key value:info.value];
            break;
        case JSONPatchOperationReplace:
            success = [self replaceObject:object key:key value:info.value];
            break;
        case JSONPatchOperationRemove:
            success = [self removeObject:object key:key];
            break;
        case JSONPatchOperationMove:
        case JSONPatchOperationCopy:
        case JSONPatchOperationUndefined:
            // These are handled in the main patch loop
            break;
    }
    if (!success)
    {
        return nil;
    }
    return @(success);
}

+ (BOOL)isDictionary:(NSDictionary *)dictionary andString:(NSString *)string
{
    if (!string ||
        ![string isKindOfClass:[NSString class]] ||
        !dictionary ||
        ![dictionary isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    return YES;
}

+ (BOOL)test:(NSDictionary *)object key:(NSString *)key value:(id)value
{
    if (![self isDictionary:object andString:key])
    {
        return NO;
    }
    id foundValue = object[key];
    return (foundValue == value || [foundValue isEqual:value]);
}

+ (id)getValueForObject:(NSDictionary *)object key:(NSString *)key
{
    if (![self isDictionary:object andString:key])
    {
        return nil;
    }
    // this.value = object[key] ????
    return object[key];
}

+ (BOOL)addObject:(NSMutableDictionary *)object key:(NSString *)key value:(id)value
{
    if (![self isDictionary:object andString:key] ||
        !value)
    {
        return NO;
    }
    object[key] = value;
    return YES;
}

+ (BOOL)removeObject:(NSMutableDictionary *)object key:(NSString *)key
{
    if (![self isDictionary:object andString:key] ||
        !object[key])
    {
        return NO;
    }
    [object removeObjectForKey:key];
    return YES;
}

+ (BOOL)replaceObject:(NSMutableDictionary *)object key:(NSString *)key value:(id)value
{
    if (![self isDictionary:object andString:key] ||
        !object[key])
    {
        return NO;
    }
    if (!value)
    {
        return [self removeObject:object key:key];
    }
    return [self addObject:object key:key value:value];
}

@end
