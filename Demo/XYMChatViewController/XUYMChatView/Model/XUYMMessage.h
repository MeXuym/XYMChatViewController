//
//  XUYMMessage.h
//  XYMChatViewController
//
//  Created by xuym on 2017/5/12.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XUYMMessage : NSObject

@property (nonatomic, strong) NSString* myUID;//自己的ID
@property (nonatomic, strong) NSString* friends_UID;//发送方userID
@property (nonatomic, strong) NSString* group_ID;//群聊ID
@property (nonatomic, strong) NSString* content;//内容
@property (nonatomic, assign) double time;//发送时间
@property (nonatomic, strong) NSString* createTime;//服务器时间
@property (nonatomic, assign) int messageType; // 1图片2音频3视频4文本5其它6随访消息 99本地系统消息（这里的消息类型根据自身业务来制定）
@property (nonatomic, assign) BOOL isSelf;//是否是自己发的消息
@property (nonatomic, assign) BOOL isRead;  // 是否已读 1=已读
@property (nonatomic, assign) BOOL isSend;  // 发送是否成功
@property (nonatomic, assign) BOOL isGroup;  // 是否群聊
@property (nonatomic, strong) NSDictionary* picUrls; //保存图片地址
@property (nonatomic, strong) NSString* resource; //消息来源
@property (nonatomic, strong) NSDictionary* otherData; //保存音视频，用户头像等信息
@property (nonatomic,retain) NSString* showName;//显示名称

-(id)initWithDic:(NSDictionary*)dic;//提供一个根据字典初始化消息对象的方法

@end
