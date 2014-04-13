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
            if (![object isKindOfClass:[NSMutableDictionary class]] &&
                ![object isKindOfClass:[NSMutableArray class]] &&
                [object respondsToSelector:@selector(mutableCopy)])
            {
                object = [object mutableCopy];
            }

            if ([object isKindOfClass:[NSMutableArray class]])
            {
                NSString *component = pathKeys[t];
                NSInteger index = [(NSMutableArray *)object indexForJSONPointerComponent:component];
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

@end
