//
//  ObtainWeatherRequest.m
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "ObtainWeatherRequest.h"

#import "Weather.h"

@implementation ObtainWeatherRequest

- (instancetype)initWithCityName:(NSString *)cityName
{
    if (self = [super init]) {
        self.path = @"weather";
        self.method = @"GET";
        self.parameters[@"q"] = cityName;
    }
    return self;
}

- (BOOL)parseResponse:(id)response error:(NSError *__autoreleasing *)error
{
    _weather = [Weather objectFromJSON:[super parseResponsePreliminary:response error:error]];
    return !!_weather;
}

@end
