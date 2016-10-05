//
//  SessionManager.m
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "SessionManager.h"
#import "ReachabilityManager.h"

#import "NetworkRequest.h"

static CGFloat const RequestTimeoutInterval = 20.0;
static CGFloat const ResourceTimeoutInterval = 60.0;
static NSInteger const MaxConcurentRequests = 100;
static NSInteger const AllCleansCount = 1;

static NSString *const CleanSessionLock = @"CleanSessionLock";

@interface SessionManager ()

@property (copy, nonatomic) CleanBlock cleanBlock;

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (assign, nonatomic) AFNetworkReachabilityStatus reachabilityStatus;
@property (strong, nonatomic) NSMutableArray *operationsQueue;
@property (strong, nonatomic) NSLock *lock;

@property (assign, nonatomic) NSUInteger cleanCount;

@property (strong, nonatomic) AFHTTPRequestSerializer *HTTPRequestSerializer;
@property (strong, nonatomic) AFJSONRequestSerializer *JSONRequestSerializer;

@end

@implementation SessionManager

#pragma mark - Lifecycle

- (instancetype)initWithBaseURLString:(NSString *)baseURLString
{
    if ((self = [super init])) {
        _baseURL = [NSURL URLWithString:baseURLString];
        
        NSURLSessionConfiguration* taskConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        taskConfig.HTTPMaximumConnectionsPerHost = MaxConcurentRequests;
        taskConfig.timeoutIntervalForRequest = RequestTimeoutInterval;
        taskConfig.timeoutIntervalForResource = ResourceTimeoutInterval;
        taskConfig.allowsCellularAccess = YES;
                
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL sessionConfiguration:taskConfig];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        self.lock = [[NSLock alloc] init];
        self.lock.name = CleanSessionLock;
        
        self.operationsQueue = [NSMutableArray array];
        
        __weak typeof(self) weakSelf = self;
        self.reachabilityStatus = [ReachabilityManager sharedManager].reachabilityStatus;
        
        [[ReachabilityManager sharedManager] addReachabilityStatusChangeHandler:^(AFNetworkReachabilityStatus newStatus) {
            weakSelf.reachabilityStatus = newStatus;
            
#ifdef DEBUG
            NSString* stateText = nil;
            switch (weakSelf.reachabilityStatus) {
                case AFNetworkReachabilityStatusUnknown: {
                    stateText = @"Network reachability is unknown";
                    break;
                }
                case AFNetworkReachabilityStatusNotReachable: {
                    stateText = @"Network is not reachable";
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWWAN: {
                    stateText = @"Network is reachable via WWAN";
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    stateText = @"Network is reachable via WiFi";
                    break;
                }
            }
            NSLog(@"%@", stateText);
#endif
        }];
    }
    return self;
}

#pragma mark - Accessors

- (AFJSONRequestSerializer *)JSONRequestSerializer
{
    if (!_JSONRequestSerializer) {
        _JSONRequestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _JSONRequestSerializer;
}

- (AFHTTPRequestSerializer *)HTTPRequestSerializer
{
    if (!_HTTPRequestSerializer) {
        _HTTPRequestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _HTTPRequestSerializer;
}

#pragma mark - Actions

- (void)cleanManagersWithCompletionBlock:(CleanBlock)block
{
    self.cleanCount = 0;
    self.cleanBlock = block;
    
    __weak typeof(self) weakSelf = self;
    [_sessionManager setSessionDidBecomeInvalidBlock:^(NSURLSession *session, NSError *error) {
        [weakSelf syncCleans];
        weakSelf.sessionManager = nil;
    }];
    [_sessionManager invalidateSessionCancelingTasks:YES];
}

- (void)syncCleans
{
    [self.lock lock];
    self.cleanCount++;
    [self.lock unlock];
    
    if (self.cleanCount == AllCleansCount) {
        if (self.cleanBlock) {
            self.cleanBlock();
        }
    }
}

#pragma mark - Operation cycle

- (NetworkOperation *)enqueueOperationWithNetworkRequest:(NetworkRequest *)networkRequest
                                                 success:(SuccessOperationBlock)successBlock
                                                 orFailure:(FailureOperationBlock)failureBlock
{
    switch (networkRequest.serializationType) {
        case RequestSerializationTypeHTTP:
            [self.sessionManager setRequestSerializer:self.HTTPRequestSerializer];
            break;
            
        case RequestSerializationTypeJSON:
            [self.sessionManager setRequestSerializer:self.JSONRequestSerializer];
            break;
    }
    
    NetworkOperation *operation = [[NetworkOperation alloc] initWithNetworkRequest:networkRequest networkManager:self.sessionManager];
    
    [operation setCompletionSuccessBlock:^(NetworkOperation *operation) {
        [self finishOperationInQueue:operation];
        if (successBlock) {
            successBlock(operation);
        }
    } andFailureBlock:^(NetworkOperation *operation, NSError *error, BOOL isCanceled) {
        [self finishOperationInQueue:operation];
        if (failureBlock) {
            failureBlock(operation, error, isCanceled);
        }
    }];
    
    NSError *connectionError = nil;
    if (![[ReachabilityManager sharedManager] checkConnection:&connectionError]) {
        if (failureBlock) {
            failureBlock(operation, connectionError, NO);
        }
    } else {
        [self addOperationToQueue:operation];
    }

    return operation;
}

/**
 *  Cancel all operations
 */
- (void)cancelAllOperations
{
    for (NetworkOperation *operation in self.operationsQueue) {
        [operation cancel];
    }
    [self.sessionManager.operationQueue cancelAllOperations];
}

/**
 *  Check whether operation is in process
 *
 *  @return Returns 'YES' in any operation is in process
 */
- (BOOL)isOperationInProcess
{
    for (NetworkOperation *operation in self.operationsQueue) {
        if ([operation isInProcess]) {
            return YES;
        }
    }
    return NO;
}

/**
 *  Remove operation from normal queue
 *
 *  @param operation Operation that has to be removed
 */
- (void)finishOperationInQueue:(NetworkOperation*)operation
{
    [self.operationsQueue removeObject:operation];
}

/**
 *  Add new operation to normal queue
 *
 *  @param operation Operation that has to be added to queue
 */
- (void)addOperationToQueue:(NetworkOperation*)operation
{
    [self.operationsQueue addObject:operation];
    [operation start];
}

@end
