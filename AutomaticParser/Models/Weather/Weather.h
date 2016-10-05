//
//  Weather.h
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "NetworkObject.h"

@class Wind;
@class Details;

@interface Weather : NetworkObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) NSUInteger identifier;
@property (strong, nonatomic) Wind *wind;
@property (strong, nonatomic) Details *details;

@end
