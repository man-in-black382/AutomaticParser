//
//  NSArray+ObjectMapping.m
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "NSArray+ObjectMapping.h"
#import "NetworkObject.h"

@implementation NSArray (ObjectMapping)

- (instancetype)mappedRepresentation
{
    if (![self.firstObject isKindOfClass:[NetworkObject class]]) {
        return nil;
    }
    
    NSMutableArray *mappedRepresentationArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(NetworkObject *obj, NSUInteger idx, BOOL *stop) {
        [mappedRepresentationArray addObject:obj.JSONRepresentation];
    }];
    return mappedRepresentationArray;
}

+ (instancetype)initWithArrayForMapping:(NSArray *)inputArray objectsClass:(Class)objectClass
{
    NSMutableArray *mappedArray = [NSMutableArray array];
    
    [inputArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NetworkObject *networkObject = [[objectClass alloc] init];
        networkObject.JSONRepresentation = obj;
        [mappedArray addObject:networkObject];
    }];
    
    return mappedArray;
}

@end