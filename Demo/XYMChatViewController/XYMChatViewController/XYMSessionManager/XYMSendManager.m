//
//  XYMSendManager.m
//  healthcoming
//
//  Created by jack xu on 16/12/30.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "XYMSendManager.h"
#import "EMessage.h"
#import "SDImageCache.h"
#import "AFNHttpRequest.h"
#import "QNResourceManager.h"

@implementation XYMSendManager

+(void)messageInfo:(EMessage *)message toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup
{
    [message getSelfStringGUID];
    message.time = [[NSDate date] timeIntervalSince1970];
    message.createTime = [[NSDate date] getDateString:@"yyyy-MM-dd HH:mm:ss"];
    message.isSelf = YES;
    message.isRead = YES;
    message.isGroup = isGroup;
    if(isGroup)
    {
        message.group_ID = toUID;
    }
    else
    {
        message.friends_UID = toUID;
    }
    message.myUID = myUID;
}

+(EMessage*)imageMessageCreater:(UIImage*)image toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup isPng:(BOOL)isPng isScale:(BOOL)isScale
{
    EMessage* message = [[EMessage alloc] init];
    message.messageType = 1;
    [self messageInfo:message toUID:toUID myUID:myUID isGroup:isGroup];
    NSString* key = [QNResourceManager getNormalImageKey];
    NSString* urlKey = QN_URL_FOR_KEY(key);
    [self saveUpLoadPicWithPath:urlKey image:image isPng:isPng isScale:isScale];
    message.picUrls = @{DSelfUpLoadImg:key};
    
    return message;
}

+(EMessage*)voiceMessageCreater:(NSString*)amrPath toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup
{
    EMessage* message = [[EMessage alloc] init];
    message.messageType = 2;
    message.otherData = @{DVoicePath:amrPath.lastPathComponent};
    [self messageInfo:message toUID:toUID myUID:myUID isGroup:isGroup];
    return message;
}

+(EMessage*)textMessageCreater:(NSString *)text toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup
{
    EMessage* message = [[EMessage alloc] init];
    message.content = text;
    message.messageType = 4;
    [self messageInfo:message toUID:toUID myUID:myUID isGroup:isGroup];
    return message;
}

+(EMessage*)systemMessageCreater:(NSString *)text toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup
{
    EMessage* message = [[EMessage alloc] init];
    message.content = text;
    message.messageType = 99;
    message.isSend = YES;
    [self messageInfo:message toUID:toUID myUID:myUID isGroup:isGroup];
    return message;
}

+(EMessage*)shareMessageCreater:(NSDictionary*)dic toUID:(NSString *)toUID myUID:(NSString *)myUID isGroup:(BOOL)isGroup
{
    EMessage* message = [[EMessage alloc] init];
    message.messageType = 6;
    message.otherData = [NSDictionary dictionaryWithDictionary:dic];
    [self messageInfo:message toUID:toUID myUID:myUID isGroup:isGroup];
    return message;
}

+(void)saveUpLoadPicWithPath:(NSString*)key image:(UIImage*)image isPng:(BOOL)isPng isScale:(BOOL)isScale
{
    NSData* data;
    if(isPng){
        data = UIImagePNGRepresentation(image);
    }else{
        data = UIImageJPEGRepresentation(image, isScale?0.5:0.8);
    }
    //新版的SD
    //    [[SDImageCache sharedImageCache] storeImage:image recalculateFromImage:YES imageData:data forKey:key toDisk:YES];
    
    [[SDImageCache sharedImageCache] storeImageDataToDisk:data forKey:key];
}

+(void)sendMessage:(EMessage*)message completed:(SendCompleted)completed
{
    [XYMSendManager sendMessage:message completed:completed isQuestion:0];
}

+(void)sendMessage2:(EMessage*)message archivesType:(NSArray*)archivesType completed:(SendCompleted)completed
{
    int userId = [message.friends_UID intValue];
    NSString* content = message.content;
    [AFNHttpRequest appSendChatContent2Request:userId content:content archivesType:archivesType completed:^(NSDictionary *response, BOOL isSuccess, int errorCode, NSString *errorMsg) {
        if(isSuccess)
        {
            int sessionId = [response intWithKey:@"sessionId"];
            int consultId = [response intWithKey:@"consultId"];
            
            if(completed)
            {
                completed(YES, sessionId, consultId);
            }
        }
        else
        {
            if(completed)
            {
                completed(NO, -1, -1);
            }
        }
    }];
}

//+(void)sendMessage:(EMessage*)message completed:(SendCompleted)completed isQuestion:(int)isQuestion
//{
//    int userId = [message.friends_UID intValue];
//    NSString* content = message.content;
//    int fileType = message.messageType;
//    if(fileType == 6)
//    {
//        int modelId = [message.otherData intWithKey:@"modelId"];
//        if(modelId <= 0)
//            return;
//        
//        //10月群发修改（单人的随访也走发送聊天接口）
//        NSString *modelIdStr = [NSString stringWithFormat:@"%d",modelId];
//        [AFNHttpRequest appSendChatContentForFollowRequest:userId isQuestion:0  fileType:6 objId:modelIdStr completed:^(NSDictionary *response, BOOL isSuccess, int errorCode, NSString *errorMsg) {
//            if(isSuccess)
//            {
//                int sessionId = [response intWithKey:@"sessionId"];
//                int consultId = [response intWithKey:@"consultId"];
//                
//                if(completed)
//                {
//                    completed(YES, sessionId, consultId);
//                }
//                return;
//            }
//            if(completed)
//            {
//                completed(NO, -1, -1);
//            }
//            
//        }];
//        
//    }
//    else
//    {
//        [AFNHttpRequest appSendChatContentRequest:userId isQuestion:isQuestion content:content fileType:fileType completed:^(NSDictionary *response, BOOL isSuccess, int errorCode, NSString* errorMsg) {
//            if(isSuccess)
//            {
//                int sessionId = [response intWithKey:@"sessionId"];
//                int consultId = [response intWithKey:@"consultId"];
//                
//                if(completed)
//                {
//                    completed(YES, sessionId, consultId);
//                }
//            }
//            else
//            {
//                if(completed)
//                {
//                    completed(NO, -1, -1);
//                }
//            }
//        }];
//    }
//}

//模拟发送消息请求
+(void)sendMessage:(EMessage*)message completed:(SendCompleted)completed isQuestion:(int)isQuestion
{
    //模拟发送消息成功
    completed(YES, 240508, 240508);
}


@end
