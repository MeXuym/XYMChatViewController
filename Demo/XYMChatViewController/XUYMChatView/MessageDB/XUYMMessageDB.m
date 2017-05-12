//
//  XUYMMessageDB.m
//  XYMChatViewController
//
//  Created by xuym on 2017/5/12.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import "XUYMMessageDB.h"
#import "XUYMMessage.h"

static XUYMMessageDB *instance;

@implementation XUYMMessageDB

+ (XUYMMessageDB *)shareInstance {
    
    @synchronized(self){
        if(!instance){
            instance = [[XUYMMessageDB alloc] init];
        }
        return instance;
    }
}

//插入消息
- (void)insertWithMessage:(XUYMMessage *)message {

}

//消息入库
- (BOOL)insertWithMessage:(XUYMMessage *)message isNotifaction:(BOOL)flag {
    
    return YES;
}

//打开数据库（创建表）
- (void)openDBWithUserID:(NSString*)nUserId block:(void(^)(void))callback {
    
}

@end
