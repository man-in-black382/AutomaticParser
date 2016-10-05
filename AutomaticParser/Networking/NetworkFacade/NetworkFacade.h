//
//  NetworkFacade.h
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetworkOperation.h"

@class Weather;

typedef void(^RequestFailureBlock)(NetworkOperation *networkOperation, NSError *error, BOOL isCancelled);

@interface NetworkFacade : NSObject

+ (NetworkOperation *)obtainWeatherForCity:(NSString *)city withSuccess:(void(^)(Weather *weather))successBlock orFailure:(FailureOperationBlock)failureBlock;

@end
