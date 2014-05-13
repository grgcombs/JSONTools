//
//  JSONSchemaValidator.h
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

#import <KiteJSONValidator/KiteJSONValidator.h>

@interface JSONSchemaValidator : KiteJSONValidator

/**
 *  Whether to enable the optional 'format' validation for JSON strings (enabled by default).
 */
@property (nonatomic,assign,getter = isFormatValidationEnabled) BOOL formatValidationEnabled;

@end
