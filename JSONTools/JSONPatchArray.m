//
//  JSONPatchArray.m
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONPatchArray.h"
#import "NSArray+JSONPointer.h"

@implementation JSONPatchArray

+ (id)applyPatchInfo:(JSONPatchInfo *)info object:(NSMutableArray *)object index:(NSInteger)index
{
    BOOL success = NO;
    switch (info.op)
    {
        case JSONPatchOperationGet:
            return [self getValueForObject:object index:index];
            break;
        case JSONPatchOperationTest:
            return @([self test:object index:index value:info.value]);
            break;
        case JSONPatchOperationAdd:
            success = [self addObject:object index:index value:info.value];
            break;
        case JSONPatchOperationReplace:
            success = [self replaceObject:object index:index value:info.value];
            break;
        case JSONPatchOperationRemove:
            success = [self removeObject:object index:index];
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

+ (BOOL)isArray:(NSArray *)array andIndex:(NSInteger)index inclusive:(BOOL)isInclusive
{
    if (!array ||
        ![array isKindOfClass:[NSArray class]])
    {
        return NO;
    }
    if (isInclusive) {
        return (array.count >= index);
    }
    return (array.count > index);
}

+ (BOOL)test:(NSArray *)object index:(NSInteger)index value:(id)value
{
    if (![self isArray:object andIndex:index inclusive:NO])
    {
        return NO;
    }
    id foundValue = object[index];
    return (foundValue == value || [foundValue isEqual:value]);
}

+ (id)getValueForObject:(NSArray *)object index:(NSInteger)index
{
    if (![self isArray:object andIndex:index inclusive:NO])
    {
        return nil;
    }
    return object[index];
}

+ (BOOL)addObject:(NSMutableArray *)object index:(NSInteger)index value:(id)value
{
    if (![self isArray:object andIndex:index inclusive:YES] ||
        !value)
    {
        return NO;
    }
    [object insertObject:value atIndex:index];
    return YES;
}

+ (BOOL)removeObject:(NSMutableArray *)object index:(NSInteger)index
{
    if (![self isArray:object andIndex:index inclusive:NO])
    {
        return NO;
    }
    [object removeObjectAtIndex:index];
    return YES;
}

+ (BOOL)replaceObject:(NSMutableArray *)object index:(NSInteger)index value:(id)value
{
    if (![self isArray:object andIndex:index inclusive:NO])
    {
        return NO;
    }
    if (!value)
    {
        return [self removeObject:object index:index];
    }
    return [self addObject:object index:index value:value];
}

@end
