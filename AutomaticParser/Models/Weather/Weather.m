//
//  Weather.m
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "Weather.h"
#import "Wind.h"
#import "Details.h"

@implementation Weather

- (NSDictionary *)map
{
    return @{ @"identifier" : @"id",
              @"name" : @"name",
              @"wind" : @"wind",
              @"details" : @"weather" };
}

- (NSDictionary *)classNamesMap
{
    return @{ @"details" : @"Details" };
}

- (id)adaptJSONObject:(id)JSONObject forKey:(NSString *)key
{
    if ([key isEqualToString:@"details"]) {
        return [(NSArray *)JSONObject firstObject];
    }
    
    return [super adaptJSONObject:JSONObject forKey:key];
}

@end
