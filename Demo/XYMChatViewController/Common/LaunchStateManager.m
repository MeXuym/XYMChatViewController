//
//  LaunchStateManager.m
//  healthcoming
//
//  Created by Bennett on 16/5/4.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "LaunchStateManager.h"

@implementation LaunchStateManager

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static LaunchStateManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[LaunchStateManager alloc] init];
    });
    return manager;
}
- (id)init {
    if (self = [super  init]) {
        
        
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunch"]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunch"];
            
        } else {
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
            
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.firstLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
        self.everLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunch"];
        
    }
    return self;
}


@end
