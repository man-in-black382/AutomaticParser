//
//  NSMutableDictionary+KeyPathDictionary.m
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "NSMutableDictionary+KeyPathDictionary.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (KeyPathDictionary)

+ (void)load
{
    Method originalMethod = class_getInstanceMethod([self class], @selector(setValue:forKeyPath:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(swizzled_setValue:forKeyPath:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)swizzled_setValue:(id)value forKeyPath:(NSString *)keyPath
{
    NSParameterAssert(value);
    NSParameterAssert(keyPath);
    
    NSMutableArray *keys = [[keyPath componentsSeparatedByString:@"."] mutableCopy];
    if (keys.count <= 1) {
        [self setValue:value forKey:keyPath];
        return;
    }
    
    if ([self objectForKey:keys.firstObject]) {
        NSMutableDictionary *dict = self[keys.firstObject];
        if (![dict isKindOfClass:[NSMutableDictionary class]]) {
            dict = [dict mutableCopy];
            self[keys.firstObject] = dict;
        }
        [keys removeObject:keys.firstObject];
        [dict setValue:value forKeyPath:[keys componentsJoinedByString:@"."]];
    } else {
        [self setValue:[NSMutableDictionary dictionary] forKey:keys.firstObject];
        [self setValue:value forKeyPath:keyPath];
    }
}

@end
