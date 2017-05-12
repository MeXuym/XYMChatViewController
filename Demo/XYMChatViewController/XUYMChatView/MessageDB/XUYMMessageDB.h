//
//  XUYMMessageDB.h
//  XYMChatViewController
//
//  Created by xuym on 2017/5/12.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XUYMMessageDB.h"
#import "XUYMMessage.h"

@interface XUYMMessageDB : NSObject

+ (XUYMMessageDB *)shareInstance; //单例方法
- (void)openDBWithUserID:(NSString*)nUserId block:(void(^)(void))callback;
- (void)insertWithMessage:(XUYMMessage *)message;

@end
