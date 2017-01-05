//
//  XYMSessionManager.m
//  healthcoming
//
//  Created by jack xu on 16/12/27.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "XYMSessionManager.h"
#import "EMessage.h"
#import "MyUserInfo.h"

@interface XYMSessionManager()

@property(nonatomic,strong)NSMutableArray *messageArray;   //消息数组

@end


static XYMSessionManager* sessionSingleton = nil;

@implementation XYMSessionManager

//单例相关
+ (XYMSessionManager *)instance{
    @synchronized(self){
        if (sessionSingleton == nil) {
            sessionSingleton = [[XYMSessionManager alloc] init];
        }
    }
    return sessionSingleton;
}

//模拟的会话数据加载（加载的假数据）
- (void)getMessageWithUserId:(NSString*)toUID completed:(void (^)(BOOL, NSArray*))completed
{
    [self setUpMessageArray];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    
    //子线程中执行
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        
        //延迟执行
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            completed(YES, _messageArray);
        });
    });
}

- (void)setUpMessageArray{
    
    EMessage* message = [[EMessage alloc] init];
    message.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
    message.isSelf = YES;
    message.isSend = YES;
    message.friends_UID = @"6990";
    message.isRead = YES;
    message.content = @"测试会话";
    message.createTime = @"2016-11-30 09:58:42";
    message.sessionId = 240508;
    message.messageType = 4;
    
    EMessage* message1 = [[EMessage alloc] init];
    message1.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
    message1.isSelf = YES;
    message1.isSend = YES;
    message1.friends_UID = @"6990";
    message1.isRead = YES;
    message1.content = @"测试会话1";
    message1.createTime = @"2016-11-30 09:59:42";
    message1.sessionId = 240508;
    message1.messageType = 4;
    
    EMessage* message2 = [[EMessage alloc] init];
    message2.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
    message2.isSelf = NO;
    message2.isSend = YES;
    message2.friends_UID = @"6990";
    message2.isRead = YES;
    message2.content = @"测试会话2";
    message2.createTime = @"2016-11-30 09:59:42";
    message2.sessionId = 240508;
    message2.messageType = 4;
    
    EMessage* message3 = [[EMessage alloc] init];
    message3.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
    message3.isSelf = NO;
    message3.isSend = YES;
    message3.friends_UID = @"6990";
    message3.isRead = YES;
    message3.content = @"测试会话3";
    message3.createTime = @"2016-11-30 09:59:42";
    message3.sessionId = 240508;
    message3.messageType = 4;
    
    NSMutableArray *messageArray = [NSMutableArray array];
    _messageArray = messageArray;
    [_messageArray addObject:message];
    [_messageArray addObject:message1];
    [_messageArray addObject:message2];
    [_messageArray addObject:message3];
}


@end
