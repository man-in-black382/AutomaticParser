//
//  ObtainWeatherRequest.h
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "NetworkRequest.h"

@class Weather;

@interface ObtainWeatherRequest : NetworkRequest

@property (strong, nonatomic, readonly) Weather *weather;

- (instancetype)initWithCityName:(NSString *)cityName;

@end
