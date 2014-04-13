//
//  JSONPatchInfo.h
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

@import Foundation;

typedef NS_ENUM(NSInteger, JSONPatchOperation)
{
    JSONPatchOperationUndefined = -1,
    JSONPatchOperationAdd,
    JSONPatchOperationReplace,
    JSONPatchOperationTest,
    JSONPatchOperationRemove,
    JSONPatchOperationMove,
    JSONPatchOperationCopy,
    JSONPatchOperationGet
};

@interface JSONPatchInfo : NSObject
+ (instancetype)newPatchInfoWithDictionary:(NSDictionary *)patch;
@property (nonatomic,copy,readonly) NSString *path;
@property (nonatomic,copy,readonly) NSString *fromPath; // for move/copy ops
@property (nonatomic,readonly) JSONPatchOperation op;
@property (nonatomic,strong,readonly) id value;
@end
