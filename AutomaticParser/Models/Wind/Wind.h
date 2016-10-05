//
//  Wind.h
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NetworkObject.h"

@interface Wind : NetworkObject

@property (assign, nonatomic) CGFloat speed;
@property (assign, nonatomic) CGFloat degrees;

@end
