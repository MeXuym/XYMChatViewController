//
//  XYMConnection.m
//  healthcoming
//
//  Created by jack xu on 16/11/14.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "XYMConnection.h"
#import "Reachability.h"


@implementation XYMConnection


+(BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
}



@end
