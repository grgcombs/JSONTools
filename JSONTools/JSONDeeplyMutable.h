//
//  JSONDeeplyMutable.h
//  JSONTools
//
//  Copyright (C) 2014 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.

@import Foundation;
#import "NSArray+JSONDeepMutable.h"
#import "NSDictionary+JSONDeepMutable.h"

@interface JSONDeepMutable : NSObject

/**
 *  @private
 *  Use the NSArray+JSONDeepMutable and NSDictionary+JSONDeepMutable
 *  categories instead.  This is an intern implementation that only operates
 *  on one instance of a container's content. Throws an exception if any 
 *  interior value objects aren't copyable in some way. This method
 *  prefers NSMutableCopying over NSCopying whenever possible.
 *
 *  @param oldValue A value object to (mutably) copy.
 *
 *  @param throwsExceptions Conditionally throw exceptions if an interior 
 *                           object isn't mutable or copyable, otherwise it 
 *                           merely omits that object from the new collection.
 *
 *  @return A (mutable) copy of the object.
 */
+ (id)copyAsDeeplyMutableValue:(id)oldValue throwsExceptions:(BOOL)throwsExceptions;

@end