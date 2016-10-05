//
//  NSArray+ObjectMapping.h
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ObjectMapping)

/*!
 Using to create NSArray with NSDictionary representation of NetworkObject descendants.
 @result
 NSArray with NSDictionary representation of NetworkObject descendants.
 */

- (instancetype)mappedRepresentation;

/*!
 Static method that allows to create NSArray of NetworkObjects.
 @param inputArray
 NSArray with NSDictionary objects. Each of dictionaries contains necessary keys and values to fill object with specified class.
 @param objectClass
 Parameter uses to specify NSArray elements class. Must to be NetworkObject descendant.
 @result
 NSArray with filled objects of specified class.
 */

+ (instancetype)initWithArrayForMapping:(NSArray *)inputArray objectsClass:(Class)objectClass;

@end