//
//  MessageItemAdaptor.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMessage.h"
#import "EUserInfo.h"

#define CTimeMargin 30
#define ChatPicWH 100     //图片宽高
#define ChatHeadWH 40     //头像宽高
#define ChatContentW [UIScreen mainScreen].bounds.size.width>320?220:180  //内容宽度
#define ChatVoiceW 120    //语音宽度
#define ChatMargin 10       //间隔
#define ChatContentTop 10   //文本内容与按钮上边缘间隔 原来是15
#define ChatContentLeft 25  //文本内容与按钮左边缘间隔
#define ChatContentBottom 10 //文本内容与按钮下边缘间隔 原来是15
#define ChatContentRight 10 //文本内容与按钮右边缘间隔 原来是15

typedef NS_ENUM(NSInteger, XYMMessageType) {
    XYMMessageTypeText     = 0, // 文字
    XYMMessageTypePicture  = 1, // 图片
    XYMMessageTypeVoice    = 2, // 语音
    XYMMessageTypeSystem   = 3, // 系统
    XYMMessageTypeShareHealthNews = 7, //知识百科
    XYMMessageTypeSharePublicClass = 8, //公开课
    XYMMessageTypeShareHealthTips = 9, //优惠券，健康锦囊等
    XYMMessageTypeShare    = 4
};

@interface XYMMessageItemAdaptor : NSObject

@property (nonatomic,retain,readonly) NSString* guId;
@property (nonatomic,assign) BOOL isSelf;
@property (nonatomic,assign) BOOL isSend;
@property (nonatomic,assign) BOOL isGroup;
@property (nonatomic,assign) XYMMessageType msgType;
@property (nonatomic,retain) NSString* msgContent;
@property (nonatomic,retain) NSMutableAttributedString* currentContentAttributedString;
@property (nonatomic,assign) BOOL isGetInfo;
@property (nonatomic,retain) NSString* userName;
@property (nonatomic,retain) NSString* fromUID;
@property (nonatomic,retain) NSString* groupID;
@property (nonatomic,retain) NSString* timeSpan;
@property (nonatomic,retain) NSString* description;
@property (nonatomic,retain) NSDate* timeInterval;
@property (nonatomic,retain) UIFont* font;
@property (nonatomic,copy) NSMutableArray* emjios;
@property (nonatomic,strong) NSDictionary* picUrls;
@property (nonatomic) int height;
@property (nonatomic) CGSize contentSize;//文本文字整体Size
@property (nonatomic) BOOL isHideTime;//列表中是否隐藏时间
@property (nonatomic,retain) NSString* headUrl;
@property (nonatomic,assign) int voiceSecond;
@property (nonatomic,retain,readonly) NSDictionary* mediaData;
@property (nonatomic,assign) BOOL isMediaUploaded;

@property (nonatomic,assign) int sessionId;
@property (nonatomic,assign) int consultId;

-(id)initWithMessage:(EMessage*)message;
#pragma 获取当前所需的数据字典
-(NSDictionary*)getCurrentIdDic;
#pragma 判断消息是否已经发送失败
-(BOOL)isTimeOut;

-(void)updateRepeatTime;
-(void)updateImageUrl:(NSString*)key;
-(void)updateVoiceUrl:(NSString*)key isLocal:(BOOL)isLocal;

-(void)updateUserInfo:(EUserInfo*)info;
-(EMessage*)currentMessage;//用户重发消息

@end
