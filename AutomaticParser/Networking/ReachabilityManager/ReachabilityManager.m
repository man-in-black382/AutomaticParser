//
//  ReachabilityManager.m
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import "ReachabilityManager.h"

static NSString *const InternetNorReachableErrorDomain = @"InternetNorReachableErrorDomain";
static NSString *const InternetNotReachableDescription = @"Internet connection appears to be offline";

@interface ReachabilityManager ()

@property (strong, nonatomic) NSMutableArray<void(^)(AFNetworkReachabilityStatus)> *reachabilityStatusChangeHandlers;

@end

@implementation ReachabilityManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager
{
    static ReachabilityManager *sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ReachabilityManager alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reachabilityStatusChangeHandlers = [NSMutableArray array];
        __weak typeof(self) weakSelf = self;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            dispatch_apply(weakSelf.reachabilityStatusChangeHandlers.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(size_t index) {
                weakSelf.reachabilityStatusChangeHandlers[index](status);
            });
        }];
    }
    return self;
}

- (void)dealloc
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark - Accessors

- (AFNetworkReachabilityStatus)reachabilityStatus
{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

#pragma mark - Public

- (BOOL)checkConnection:(NSError **)error
{
    BOOL connectionAvailable = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable;
    if (!connectionAvailable) {
        *error = [NSError errorWithDomain:InternetNorReachableErrorDomain
                                     code:NSURLErrorNotConnectedToInternet
                                 userInfo:@{ NSLocalizedDescriptionKey : InternetNotReachableDescription }];
        return NO;
    } else {
        *error = nil;
        return YES;
    }
}

- (void)addReachabilityStatusChangeHandler:(void (^)(AFNetworkReachabilityStatus))handler
{
    if (handler) {
        [self.reachabilityStatusChangeHandlers addObject:handler];
    }
}

@end
