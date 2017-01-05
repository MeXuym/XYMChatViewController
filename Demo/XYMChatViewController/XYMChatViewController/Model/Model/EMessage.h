//
//  EMessage.h
//  MCUTest
//
//  Created by Administrators on 15/6/1.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMessage : NSObject

@property (nonatomic, retain) NSString* myUID;//自己的ID
@property (nonatomic, retain) NSString* friends_UID;//发送方userID
@property (nonatomic, retain) NSString* group_ID;//群聊ID
@property (nonatomic, retain) NSString* content;
@property (nonatomic, assign) double time;
@property (nonatomic, retain) NSString* createTime; //服务器时间
@property (nonatomic, assign) int messageType;    // 1图片2音频3视频4文本5其它6随访消息 99本地系统消息
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) BOOL isRead;              // 是否已读 1=已读
@property (nonatomic, assign) BOOL isSend;              // 发送是否成功
@property (nonatomic, assign) BOOL isGroup;             // 是否群聊
@property (nonatomic, retain) NSString *guid;           // GUID
@property (nonatomic, retain) NSDictionary* picUrls;         //保存图片地址
@property (nonatomic, retain) NSString* resource;       //消息来源

@property (nonatomic, retain) NSDictionary* otherData; //保存音视频，用户头像等信息

@property (nonatomic,retain) NSString* userName;
@property (nonatomic,retain) NSString* rem;
@property (nonatomic,assign) int sessionId;
@property (nonatomic,assign) int consultId;
@property (nonatomic,assign) int isQuestion;

@property (nonatomic,retain) NSString* showName;


//患者相关的标签数据
@property(nonatomic,retain) NSArray* labers;
@property(nonatomic,retain) NSArray* archivesLaber;
@property(nonatomic,retain) NSArray* motherArchives;
@property(nonatomic,retain) NSArray* childArchives;
@property(nonatomic,retain) NSArray* hdArchives;

-(id)initWithDic:(NSDictionary*)dic;
-(void)getSelfStringGUID;

@end
