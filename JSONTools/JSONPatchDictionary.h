//
//  JSONPatchDictionary.h
//  inspired by https://github.com/Starcounter-Jack/JSON-Patch
//
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import "JSONTools.h"
#import "JSONPatchInfo.h"

@interface JSONPatchDictionary: NSObject
+ (id)applyPatchInfo:(JSONPatchInfo *)info object:(NSMutableDictionary *)object key:(NSString *)key;
@end
