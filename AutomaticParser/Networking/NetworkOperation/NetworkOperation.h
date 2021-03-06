//
//  NetworkOperation.h
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NetworkOperation;
@class NetworkRequest;
@class AFHTTPSessionManager;

typedef void(^SuccessOperationBlock)(NetworkOperation *operation);
typedef void(^FailureOperationBlock)(NetworkOperation *operation, NSError *error, BOOL isCanceled);
typedef void(^ProgressBlock)(NSProgress *progress);

@interface NetworkOperation : NSObject

@property (assign, nonatomic) BOOL performInBackgroundIfPossible;
@property (assign, nonatomic, readonly, getter = isInProcess) BOOL inProcess;
@property (copy, nonatomic, readonly) SuccessOperationBlock successBlock;
@property (copy, nonatomic, readonly) FailureOperationBlock failureBlock;
@property (strong, nonatomic, readonly) NSProgress *currentProgress;

@property (strong, nonatomic, readonly) NetworkRequest *request;
@property (strong, nonatomic, readonly) id response;
@property (strong, nonatomic, readonly) NSError *error;
@property (assign, nonatomic, readonly) NSInteger statusCode;

- (instancetype)initWithNetworkRequest:(NetworkRequest *)networkRequest networkManager:(AFHTTPSessionManager *)networkManager;
- (void)setCompletionSuccessBlock:(SuccessOperationBlock)successBlock andFailureBlock:(FailureOperationBlock)failureBlock;
- (void)start;
- (void)restart;
- (void)pause;
- (void)cancel;
- (void)addProgressObserver:(ProgressBlock)observer;
- (void)removeProgressObserver:(ProgressBlock)observer;

@end
