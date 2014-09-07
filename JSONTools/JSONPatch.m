//
//  JSONPatch.m
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONPatch.h"
#import "JSONPatchDictionary.h"
#import "JSONPatchArray.h"
#import "JSONPointer.h"

@implementation JSONPatch

+ (id)applyPatches:(NSArray *)patches toCollection:(id)collection
{
    if (!collection ||
        ![collection respondsToSelector:@selector(mutableCopy)])
    {
        return nil;
    }

    id result = nil;

    for (NSDictionary *patch in patches)
    {
        JSONPatchInfo *patchInfo = [JSONPatchInfo newPatchInfoWithDictionary:patch];
        if (!patchInfo)
            break;

        NSArray *pathKeys = [patchInfo.path componentsSeparatedByString:@"/"];
        id object = collection;
        NSInteger t = 1;
        
        while (YES) {
            // path not found, fail this
            if (!object || [object isKindOfClass:NSNull.class]) {
                result = @(0);
                break;
            }
            if (![object isKindOfClass:[NSMutableDictionary class]] &&
                ![object isKindOfClass:[NSMutableArray class]] &&
                [object respondsToSelector:@selector(mutableCopy)])
            {
                object = [object mutableCopy];
            }

            if ([object isKindOfClass:[NSMutableArray class]])
            {
                NSString *component = pathKeys[t];
                NSInteger index = [(NSMutableArray *)object indexForJSONPointerComponent:component allowOutOfBounds:YES];
                if (index == NSNotFound)
                    break;

                t++;

                if (t >= pathKeys.count)
                {
                    BOOL stop = NO;
                    result = [self applyPatch:patchInfo array:object index:index collection:collection stop:&stop];
                    if (stop) {
                        return result;
                    }
                    break;
                }
                object = (NSMutableArray *)object[index];
            }
            else if ([object isKindOfClass:[NSMutableDictionary class]])
            {
                NSString *component =  [(NSMutableDictionary *)object keyForJSONPointerComponent:pathKeys[t]];

                t++;

                if (t >= pathKeys.count)
                {
                    BOOL stop = NO;
                    result = [self applyPatch:patchInfo dictionary:object key:component collection:collection stop:&stop];
                    if (stop) {
                        return result;
                    }
                    break;
                }
                object = (NSMutableDictionary *)object[component];
            }
        }
    }
    return result;
}

#pragma mark - Singular Patch

+ (id)applyPatch:(JSONPatchInfo *)patchInfo array:(NSMutableArray *)array index:(NSInteger)index collection:(id)collection stop:(BOOL *)stop
{
    BOOL success = NO;
    switch (patchInfo.op)
    {
        case JSONPatchOperationGet:
        case JSONPatchOperationTest:
            *stop = YES;
            return [JSONPatchArray applyPatchInfo:patchInfo object:array index:index];
            break;
        case JSONPatchOperationAdd:
        case JSONPatchOperationReplace:
        case JSONPatchOperationRemove:
            success = ([[JSONPatchArray applyPatchInfo:patchInfo object:array index:index] boolValue]);
            break;
        case JSONPatchOperationCopy:
            success = [self applyCopyPatch:patchInfo toCollection:collection];
            break;
        case JSONPatchOperationMove:
            success = [self applyMovePatch:patchInfo toCollection:collection];
            break;
        case JSONPatchOperationUndefined:
            break;
    }
    if (!success)
        return nil;
    return @(success);
}

+ (id)applyPatch:(JSONPatchInfo *)patchInfo dictionary:(NSMutableDictionary *)dictionary key:(NSString *)key collection:(id)collection stop:(BOOL *)stop
{
    BOOL success = NO;
    switch (patchInfo.op)
    {
        case JSONPatchOperationGet:
        case JSONPatchOperationTest:
            *stop = YES;
            return [JSONPatchDictionary applyPatchInfo:patchInfo object:dictionary key:key];
            break;
        case JSONPatchOperationAdd:
        case JSONPatchOperationReplace:
        case JSONPatchOperationRemove:
            success = ([[JSONPatchDictionary applyPatchInfo:patchInfo object:dictionary key:key] boolValue]);
            break;
        case JSONPatchOperationCopy:
            success = [self applyCopyPatch:patchInfo toCollection:collection];
            break;
        case JSONPatchOperationMove:
            success = [self applyMovePatch:patchInfo toCollection:collection];
            break;
        case JSONPatchOperationUndefined:
            break;
    }
    if (!success)
        return nil;
    return @(success);
}

#pragma mark - Aggregated Operations

+ (BOOL)applyCopyPatch:(JSONPatchInfo *)patchInfo toCollection:(id)collection
{
    id fromValue = [self applyPatches:@[@{@"op": @"_get",
                                          @"path": patchInfo.fromPath}] toCollection:collection];
    if (!fromValue) {
        return NO;
    }
    id toResult = [self applyPatches:@[@{@"op": @"add",
                                         @"path": patchInfo.path,
                                         @"value": fromValue}] toCollection:collection];
    return (toResult != NULL);
}

+ (BOOL)applyMovePatch:(JSONPatchInfo *)patchInfo toCollection:(id)collection
{
    id fromValue = [self applyPatches:@[@{@"op": @"_get",
                                          @"path": patchInfo.fromPath}] toCollection:collection];
    if (!fromValue)
    {
        return NO;
    }
    id removeResult = [self applyPatches:@[@{@"op": @"remove",
                                             @"path": patchInfo.fromPath}] toCollection:collection];
    id toResult = [self applyPatches:@[@{@"op": @"add",
                                         @"path": patchInfo.path,
                                         @"value": fromValue}] toCollection:collection];
    return (toResult != NULL &&
            removeResult != NULL);
}

#pragma mark - Patch Generation

+ (NSArray *)createPatchesComparingCollectionsOld:(id)oldCollection toNew:(id)newCollection
{
    return [self compareOldCollection:oldCollection toNew:newCollection path:@""];
}

+ (NSArray *)compareOldCollection:(id)oldCollection toNew:(id)newCollection path:(NSString *)path
{
    if ([self isCompatibleDictionaries:oldCollection dict2:newCollection])
    {
        return [self compareOldDictionary:oldCollection toNew:newCollection path:path];
    }
    if ([self isCompatibleArrays:oldCollection array2:newCollection])
    {
        return [self compareOldArray:oldCollection toNew:newCollection path:path];
    }
    return nil;
}

+ (NSArray *)compareValue:(id)oldValue toNew:(id)newValue path:(NSString *)path replacement:(BOOL *)hasReplacementPtr
{
    NSMutableArray *patches = [[NSMutableArray alloc] init];

    if ([self isCompatibleDictionaries:oldValue dict2:newValue])
    {
        NSArray *subPatches = [self compareOldDictionary:oldValue toNew:newValue path:path];
        if (subPatches.count) {
            [patches addObjectsFromArray:subPatches];
        }
    }
    else if ([self isCompatibleArrays:oldValue array2:newValue])
    {
        NSArray *subPatches = [self compareOldArray:oldValue toNew:newValue path:path];
        if (subPatches.count) {
            [patches addObjectsFromArray:subPatches];
        }
    }
    else if (oldValue &&
             newValue &&
            ![oldValue isEqual:newValue])
    {
            *hasReplacementPtr = YES;
            [patches addObject:@{@"op": @"replace",
                                 @"path": path,
                                 @"value": newValue}];
    }
    return patches;
}

+ (NSArray *)compareOldDictionary:(NSDictionary *)oldDict toNew:(NSDictionary *)newDict path:(NSString *)path
{
    NSMutableArray *patches = [[NSMutableArray alloc] init];
    __block BOOL changed = NO;
    __block BOOL deleted = NO;

    [oldDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *escapedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *escapedPath = [path stringByAppendingFormat:@"/%@", escapedKey];
        id newValue = newDict[key];

        if (!newValue) {
            [patches addObject:@{@"op": @"remove",
                                 @"path": escapedPath}];
            deleted = YES;
        }
        else
        {
            NSArray *subPatches = [self compareValue:obj toNew:newValue path:escapedPath replacement:&changed];
            if (subPatches.count) {
                [patches addObjectsFromArray:subPatches];
            }
        }
    }];

    if (!deleted &&
        newDict.count == oldDict.count)
    {
        return patches;
    }

    [newDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *escapedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *escapedPath = [path stringByAppendingFormat:@"/%@", escapedKey];
        id oldValue = oldDict[key];
        if (!oldValue)
        {
            [patches addObject:@{@"op": @"add",
                                 @"path": escapedPath,
                                 @"value": obj}];
        }
    }];

    return patches;
}

+ (NSArray *)compareOldArray:(NSArray *)oldArray toNew:(NSArray *)newArray path:(NSString *)path
{
    NSMutableArray *patches = [[NSMutableArray alloc] init];
    NSUInteger oldCount = [oldArray count];
    NSUInteger newCount = [newArray count];
    NSUInteger maxCount = MAX(oldCount, newCount);
    NSInteger index = maxCount - 1;
    while (index >= 0)
    {
        NSString *indexPath = [path stringByAppendingFormat:@"/%lu", (unsigned long)index];
        BOOL changes = NO;

        if (index < oldCount &&
            index < newCount)
        {
            id oldValue = oldArray[index];
            id newValue = newArray[index];
            NSArray *subPatches = [self compareValue:oldValue toNew:newValue path:indexPath replacement:&changes];
            if (subPatches.count)
            {
                [patches addObjectsFromArray:subPatches];
            }
        }
        else if (index < newCount)
        {
            id newValue = newArray[index];
            [patches addObject:@{@"op": @"add",
                                 @"path": indexPath,
                                 @"value": newValue}];
        }
        else if (index < oldCount)
        {
            [patches addObject:@{@"op": @"remove",
                                 @"path": indexPath}];
        }
        index--;
    }
    return patches;
}

+ (BOOL)isCompatibleCollection:(id)collection toCollection:(id)otherCollection
{
    return ([self isCompatibleDictionaries:collection dict2:otherCollection] ||
            [self isCompatibleArrays:collection array2:otherCollection]);
}

+ (BOOL)isCompatibleDictionaries:(NSDictionary *)dict1 dict2:(NSDictionary *)dict2
{
    if (!dict1 || !dict2)
        return NO;
    return ([dict1 isKindOfClass:[NSDictionary class]] &&
            [dict2 isKindOfClass:[NSDictionary class]]);
}

+ (BOOL)isCompatibleArrays:(NSArray *)array1 array2:(NSArray *)array2
{
    if (!array1 || !array2)
        return NO;
    return ([array1 isKindOfClass:[NSArray class]] &&
            [array2 isKindOfClass:[NSArray class]]);
}

@end
