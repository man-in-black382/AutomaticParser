//
//  Details.h
//  AutomaticParser
//
//  Created by Pavlo Muratov on 22.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "NetworkObject.h"

@interface Details : NetworkObject

@property (strong, nonatomic) NSString *main;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *iconName;

@end
