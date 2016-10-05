//
//  ViewController.m
//  AutomaticParser
//
//  Created by Pavlo Muratov on 12.08.16.
//  Copyright © 2016 PrivatBank. All rights reserved.
//

#import "ViewController.h"

#import "NetworkFacade.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NetworkFacade obtainWeatherForCity:@"Donetsk" withSuccess:^(Weather *weather) {
        NSLog(@"%@", weather);
    } orFailure:^(NetworkOperation *operation, NSError *error, BOOL isCanceled) {
        NSLog(@"%@", operation.response);
    }];
}

@end
