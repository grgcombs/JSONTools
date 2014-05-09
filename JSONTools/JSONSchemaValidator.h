//
//  JSONSchemaValidator.h
//  JSONTools
//
//  Created by Gregory Combs on 4/30/14.
//  Copyright (c) 2014 Sleestacks. All rights reserved.
//

#import <KiteJSONValidator/KiteJSONValidator.h>

@interface JSONSchemaValidator : KiteJSONValidator

/**
 *  Whether to enable the optional 'format' validation for JSON strings (enabled by default).
 */
@property (nonatomic,assign,getter = isFormatValidationEnabled) BOOL formatValidationEnabled;

@end
