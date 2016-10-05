//
//  NetworkRequest.m
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import "NetworkRequest.h"

@implementation NetworkRequest

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        _path = @"";
        _parameters = [@{ } mutableCopy];
        _customHeaders = [@{} mutableCopy];
        _serializationType = RequestSerializationTypeJSON;
    }
    return self;
}

#pragma mark - Methods

- (id)parseResponsePreliminary:(id)response error:(NSError **)error
{
    id json;
    
    if (!response) {
        *error = [NSError errorWithDomain:@"ErrorEmptyResponse"
                                     code:1
                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@ - response is empty", NSStringFromClass([self class])] }];
        return nil;
    }
    
    if ([response isKindOfClass:[NSData class]]) {
        json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:error];
        return *error ? nil : json;
    } else if ([response isKindOfClass:[NSDictionary class]] || [response isKindOfClass:[NSArray class]]) {
        json = response;
    } else {
        *error = [NSError errorWithDomain:@"ErrorResponseWrongType"
                                     code:1
                                 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Response is of wrong type (%@)", NSStringFromClass([response class])] }];
        return nil;
    }
    
    return json;
}

@end
