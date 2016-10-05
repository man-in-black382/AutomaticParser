//
//  SessionManager.h
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetworkOperation.h"

typedef void (^CleanBlock)();

@class NetworkRequest;

@interface SessionManager : NSObject

@property (assign, atomic, readonly) NSInteger requestNumber;
@property (strong, nonatomic, readonly) NSURL *baseURL;

- (instancetype)initWithBaseURLString:(NSString *)baseURLString;

- (void)cancelAllOperations;
- (void)cleanManagersWithCompletionBlock:(CleanBlock)block;

- (NetworkOperation *)enqueueOperationWithNetworkRequest:(NetworkRequest *)networkRequest
                                                 success:(SuccessOperationBlock)successBlock
                                               orFailure:(FailureOperationBlock)failureBlock;

- (BOOL)isOperationInProcess;

@end
