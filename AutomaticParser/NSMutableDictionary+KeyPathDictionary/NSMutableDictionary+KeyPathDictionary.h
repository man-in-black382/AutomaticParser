//
//  NSMutableDictionary+KeyPathDictionary.h
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Used for creating nested dictionaries if path contains "." symbol. For example if called [NSMutableDictionary setValue:someValue forKeyPath:@"first.second"] it will create such a dictionary:  @{@"first" : @{ @"second" : value }}
 */
@interface NSMutableDictionary (KeyPathDictionary)

@end