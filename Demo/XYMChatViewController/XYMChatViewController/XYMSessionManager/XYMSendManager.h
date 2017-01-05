//
//  XYMSendManager.h
//  healthcoming
//
//  Created by jack xu on 16/12/30.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMessage;

typedef void(^SendCompleted)(BOOL success, int sessionId, int consultId);

@interface XYMSendManager : NSObject

+(void)messageInfo:(EMessage *)message toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup;
+(EMessage*)imageMessageCreater:(UIImage*)image toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup isPng:(BOOL)isPng isScale:(BOOL)isScale;
+(EMessage*)voiceMessageCreater:(NSString*)amrPath toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup;
+(EMessage*)textMessageCreater:(NSString *)text toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup;
+(EMessage*)systemMessageCreater:(NSString *)text toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup;
+(EMessage*)shareMessageCreater:(NSDictionary*)dic toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup;
+(void)sendMessage:(EMessage*)message completed:(SendCompleted)completed;
+(void)sendMessage:(EMessage*)message completed:(SendCompleted)completed isQuestion:(int)isQuestion;
+(void)sendMessage2:(EMessage*)message archivesType:(NSArray*)archivesType completed:(SendCompleted)completed;
@end
