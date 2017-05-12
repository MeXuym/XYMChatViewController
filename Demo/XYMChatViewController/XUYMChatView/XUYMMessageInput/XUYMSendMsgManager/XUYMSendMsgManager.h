//
//  XUYMSendMsgManager.h
//  XYMChatViewController
//
//  Created by xuym on 2017/5/12.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XUYMMessage;

@interface XUYMSendMsgManager : NSObject

+(void)messageInfo:(XUYMMessage *)message toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup;
+(XUYMMessage *)textMessageCreater:(NSString *)text toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup;

@end
