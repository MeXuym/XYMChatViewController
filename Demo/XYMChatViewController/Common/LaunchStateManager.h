//
//  LaunchStateManager.h
//  healthcoming
//
//  Created by Bennett on 16/5/4.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaunchStateManager : NSObject

@property (nonatomic,assign) BOOL firstLaunch;//是否是首次安装
@property (nonatomic,assign) BOOL everLaunch;//是否是曾经登陆过

@property (nonatomic,assign) BOOL authCompletion;//是否是授权完成

+ (instancetype)share;

@end
