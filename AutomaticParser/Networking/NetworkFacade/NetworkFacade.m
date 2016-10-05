//
//  NetworkFacade.m
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import "NetworkFacade.h"
#import "SessionManager.h"
#import "NetworkRequest.h"

#import "Weather.h"

#import "ObtainWeatherRequest.h"

static NSString *const BaseURLString = @"http://api.openweathermap.org/data/2.5";

@implementation NetworkFacade

+ (SessionManager *)sessionManager
{
    static SessionManager *sessionManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[SessionManager alloc] initWithBaseURLString:BaseURLString];
    });
    return sessionManager;
}

+ (NetworkOperation *)obtainWeatherForCity:(NSString *)city withSuccess:(void (^)(Weather *))successBlock orFailure:(FailureOperationBlock)failureBlock
{
    ObtainWeatherRequest *request = [[ObtainWeatherRequest alloc] initWithCityName:city];
    
    return [[self sessionManager] enqueueOperationWithNetworkRequest:request success:^(NetworkOperation *operation) {
        if (successBlock) {
            successBlock(request.weather);
        }
    } orFailure:failureBlock];
}

@end
