//
//  NetworkRequest.h
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import <AFNetworking/AFURLRequestSerialization.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RequestSerializationType) {
    RequestSerializationTypeHTTP,
    RequestSerializationTypeJSON
};

@interface NetworkRequest : NSObject

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSMutableDictionary *parameters;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSMutableDictionary *customHeaders;
@property (copy, nonatomic) void(^multipartFormDataConstructingBlock)(id<AFMultipartFormData> formData);
@property (assign, nonatomic) RequestSerializationType serializationType;

- (id)parseResponsePreliminary:(id)response error:(NSError **)error;

@end
