//
//  JSONPatchInfo.m
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONPatchInfo.h"

@interface JSONPatchInfo ()
@end

@implementation JSONPatchInfo

+ (instancetype)newPatchInfoWithDictionary:(NSDictionary *)patch
{
    if (!patch ||
        ![patch isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }

    JSONPatchOperation patchOp = [self operationForToken:patch[@"op"]];
    if (patchOp == JSONPatchOperationUndefined)
    {
        return nil;
    }

    JSONPatchInfo *info = [[JSONPatchInfo alloc] init];
    info->_op = patchOp;

    NSString *token = @"path";
    if ([self operation:patchOp needsToken:token])
    {
        NSString *patchPath = patch[token];
        if (!patchPath ||
            ![patchPath isKindOfClass:[NSString class]])
        {
            return nil;
        }
        info->_path = [patchPath copy];
    }

    token = @"from";
    if ([self operation:patchOp needsToken:token])
    {
        NSString *fromPath = patch[token];
        if (!fromPath ||
            ![fromPath isKindOfClass:[NSString class]])
        {
            return nil;
        }
        info->_fromPath = fromPath;
    }

    token = @"value";
    if ([self operation:patchOp needsToken:token])
    {
        id patchValue = patch[token];
        if (!patchValue)
            return nil;
        info->_value = patchValue;
    }

    return info;
}

+ (BOOL)operation:(JSONPatchOperation)op needsToken:(NSString *)token
{
    if ([token isEqualToString:@"path"] ||
        [token isEqualToString:@"op"])
    {
        return (op != JSONPatchOperationUndefined);
    }

    if ([token isEqualToString:@"from"])
    {
        return (op == JSONPatchOperationMove ||
                op == JSONPatchOperationCopy);
    }

    if ([token isEqualToString:@"value"])
    {
        return (op == JSONPatchOperationAdd ||
                op == JSONPatchOperationReplace ||
                op == JSONPatchOperationTest);
    }

    return NO;
}

+ (JSONPatchOperation)operationForToken:(NSString *)token
{
    if (!token || ![token isKindOfClass:[NSString class]])
        return JSONPatchOperationUndefined;
    if ([token caseInsensitiveCompare:@"add"] == NSOrderedSame)
        return JSONPatchOperationAdd;
    if ([token caseInsensitiveCompare:@"replace"] == NSOrderedSame)
        return JSONPatchOperationReplace;
    if ([token caseInsensitiveCompare:@"test"] == NSOrderedSame)
        return JSONPatchOperationTest;
    if ([token caseInsensitiveCompare:@"remove"] == NSOrderedSame)
        return JSONPatchOperationRemove;
    if ([token caseInsensitiveCompare:@"move"] == NSOrderedSame)
        return JSONPatchOperationMove;
    if ([token caseInsensitiveCompare:@"copy"] == NSOrderedSame)
        return JSONPatchOperationCopy;
    if ([token caseInsensitiveCompare:@"_get"] == NSOrderedSame)
        return JSONPatchOperationGet;
    return JSONPatchOperationUndefined;
}

+ (NSString *)tokenForOperation:(JSONPatchOperation)operation
{
    NSString *token = nil;

    switch (operation) {
        case JSONPatchOperationAdd:
            token = @"add";
            break;
        case JSONPatchOperationReplace:
            token = @"replace";
            break;
        case JSONPatchOperationTest:
            token = @"test";
            break;
        case JSONPatchOperationRemove:
            token = @"remove";
            break;
        case JSONPatchOperationMove:
            token = @"move";
            break;
        case JSONPatchOperationCopy:
            token = @"copy";
            break;
        case JSONPatchOperationGet:
            token = @"_get";
            break;
        case JSONPatchOperationUndefined:
            token = @"undefined";
            break;
    }
    return token;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: op=%@; path=%@; from=%@; value=%@",
            [super description],
            [[self class] tokenForOperation:_op],
            _path,
            _fromPath,
            _value];
}

- (BOOL)isEqual:(id)obj
{
    if (![obj isKindOfClass:[JSONPatchInfo class]])
        return NO;

    JSONPatchInfo *other = (JSONPatchInfo *)obj;
    BOOL equalOps = (_op == other->_op);
    BOOL equalPaths = (_path == other->_path || [_path isEqual:other->_path]);
    BOOL equalValues = (_value == other->_value || [_value isEqual:other->_value]);
    BOOL equalFroms = (_fromPath == other->_fromPath || [_fromPath isEqual:other->_fromPath]);

    return (equalOps &&
            equalPaths &&
            equalValues &&
            equalFroms);
}

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

- (NSUInteger)hash
{
    NSUInteger current = 31;
    current = [self hashForComponentOrNil:_op index:1] ^ current;
    current = [self hashForComponentOrNil:[_path hash] index:2] ^ current;
    current = [self hashForComponentOrNil:[_value hash] index:3] ^ current;
    current = [self hashForComponentOrNil:[_fromPath hash] index:4] ^ current;
    return current;
}

- (NSUInteger)hashForComponentOrNil:(NSUInteger)hash index:(NSUInteger)hashIndex
{
    if (hash == 0)
    {
        // accounts for nil objects
        hash = 31;
    }
    return NSUINTROTATE(hash, NSUINT_BIT / (hashIndex + 1));
}

@end
