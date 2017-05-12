//
//  XUYMSendMsgManager.m
//  XYMChatViewController
//
//  Created by xuym on 2017/5/12.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import "XUYMSendMsgManager.h"
#import "XUYMMessage.h"

@implementation XUYMSendMsgManager

//消息组装
+ (void)messageInfo:(XUYMMessage *)message toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup {

    //组装基本信息（发送方，接收方等）
}

//文字消息组装
+ (XUYMMessage *)textMessageCreater:(NSString *)text toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup {
    
    XUYMMessage* message = [[XUYMMessage alloc] init];
    message.content = text;
    message.messageType = 1;
    [self messageInfo:message toUID:toUID myUID:myUID isGroup:isGroup];
    return message;
}

@end
