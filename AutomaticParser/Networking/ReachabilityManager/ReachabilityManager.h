//
//  ReachabilityManager.h
//  CAPT
//
//  Created by Pavlo on 2/15/16.
//  Copyright © 2016 Thinkmobiles. All rights reserved.
//

#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface ReachabilityManager : NSObject

@property (assign, nonatomic, readonly) AFNetworkReachabilityStatus reachabilityStatus;

+ (instancetype)sharedManager;
- (BOOL)checkConnection:(NSError **)error;
- (void)addReachabilityStatusChangeHandler:(void(^)(AFNetworkReachabilityStatus newStatus))handler;

@end
