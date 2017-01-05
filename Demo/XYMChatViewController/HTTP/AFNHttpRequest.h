//
//  AFNHttpRequest.h
//  healthcoming
//
//  Created by Franky on 15/8/5.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef enum {
    NoError = 0,
    DataError,
    NoNetWorkError,
}responseType;

typedef void(^completedBlock)(NSDictionary *response, BOOL isSuccess, int errorCode, NSString* errorMsg);

@interface AFNHttpRequest : NSObject

//3.2登录
+(AFHTTPRequestOperation*)loginRequest:(int)loginType
                                 userId:(NSString *)userId
                               password:(NSString *)password
                              completed:(completedBlock)completed;
//3.3注销
+(AFHTTPRequestOperation*)logoutRequest:(completedBlock)completed;

//获取短信验证码
+(AFHTTPRequestOperation*)getSMSRequest:(int)flag
                                phoneNo:(NSString*)phoneNo
                              completed:(completedBlock)completed;
//3.1注册
+(AFHTTPRequestOperation*)appRegisterRequest:(NSString*)phoneNo
                                    passWord:(NSString*)passWord
                                     smsCode:(NSString*)smsCode
                                   completed:(completedBlock)completed;
//3.4获取医生个人资料（已登录）
+(AFHTTPRequestOperation*)appGetUserRequest:(completedBlock)completed;

//3.5忘记密码
+(AFHTTPRequestOperation*)appForgetPasswordRequest:(NSString*)phoneNo
                             smsCode:(NSString*)smsCode
                            passWord:(NSString*)passWord
                           completed:(completedBlock)completed;

//3.6完善资料
+(AFHTTPRequestOperation*)appSetUserInfoRequest:(NSDictionary*)infoDic
                                      completed:(completedBlock)completed;

//科室列表
+(AFHTTPRequestOperation*)appGetOfficeListRequest:(completedBlock)completed;

//职称列表
+(AFHTTPRequestOperation*)appGetTitleListRequest:(completedBlock)completed;

//3.7医院列表
+(AFHTTPRequestOperation*)appGetHospitalListRequest:(NSString*)hospName
                                           startNum:(int)startNum
                                          completed:(completedBlock)completed;

//3.8医院详情
+(AFHTTPRequestOperation*)appGetHospitalInfoRequest:(int)hospitalId
                                          completed:(completedBlock)completed;

//3.9小助手-个人通知列表
+(AFHTTPRequestOperation*)appPersonalassistantRequest:(int)hospitalId
                                             noticeId:(int)noticeId
                                               getNum:(int)getNum
                                            completed:(completedBlock)completed;

//操作日志
+(AFHTTPRequestOperation*)addIdeaLogRequest:(int)objType
                                      objId:(int)objId
                                    logType:(int)logType
                                  completed:(completedBlock)completed;

//3.10患者分组管理
+(AFHTTPRequestOperation*)appPatientGroupRequest:(int)groupId
                                       groupName:(NSString*)groupName
                                      modifyType:(int)modifyType
                                       completed:(completedBlock)completed;

//3.12患者分组查询
+(AFHTTPRequestOperation*)patientGroupListRequest:(completedBlock)completed;

//3.13分组联系人查询
+(AFHTTPRequestOperation*)patientGroupUserListRequest:(int)userId
                                              groupId:(int)groupId
                                          userNameTag:(NSString*)userNameTag
                                            completed:(completedBlock)completed;

//3.14联系人分组管理
+(AFHTTPRequestOperation*)patientGroupUserModifyRequest:(int)groupId
                                                userIds:(NSArray*)userIds
                                              completed:(completedBlock)completed;

//3.15问诊记录列表
+(AFHTTPRequestOperation*)appUserSessionListRequest:(int)userId
                                         createTime:(NSString*)createTime
                                          completed:(completedBlock)completed;

//3.16标签列表
+(AFHTTPRequestOperation*)laberInfoListRequest:(int)userId
                                     completed:(completedBlock)completed;

//3.17添加标签
+(AFHTTPRequestOperation*)appAddLaberInfoRequest:(int)userId
                                            tags:(NSArray*)tags
                                       completed:(completedBlock)completed;

//3.17历史问诊记录
+(AFHTTPRequestOperation*)appHistoryConsultRequest:(NSArray*)sessionIds
                                         consultId:(int)consultId
                                           isOrder:(int)isOrder
                                         completed:(completedBlock)completed;

//3.18快捷回复编辑
+(AFHTTPRequestOperation*)appQuickReplyRequest:(int)quickReplyId
                                  replyContent:(NSString*)replyContent
                                    modifyType:(int)modifyType
                                     completed:(completedBlock)completed;

//3.20快捷回复列表
+(AFHTTPRequestOperation*)appQuickReplyListRequest:(completedBlock)completed;

//3.21问题模版列表
+(AFHTTPRequestOperation*)appQuestionListRequest:(int)type
                                       completed:(completedBlock)completed;

//3.22问题使用反馈
+(AFHTTPRequestOperation*)appQuestionLogRequest:(int)type
                                     questionId:(NSArray*)questionIds
                                      completed:(completedBlock)completed;

//联系人详细(已删)
+(AFHTTPRequestOperation*)appPatientUserInfoRequest:(int)userId
                                          completed:(completedBlock)completed;

//3.23未结束会话列表(1.4)
+(AFHTTPRequestOperation*)appNoEndSessionListRequest:(int)sessionId
                                           completed:(completedBlock)completed;

//3.23会话列表(1.5)
+(AFHTTPRequestOperation*)appSessionListRequest:(int)consultId
                                      completed:(completedBlock)completed;

//3.24会话结束反馈
+(AFHTTPRequestOperation*)appReadSessionBackRequest:(int)userId
                                          completed:(completedBlock)completed;

//3.25发送聊天内容
+(AFHTTPRequestOperation*)appSendChatContentRequest:(int)userId
                                         isQuestion:(int)isQuestion
                                            content:(NSString*)content
                                           fileType:(int)fileType
                                          completed:(completedBlock)completed;

//3.25发送聊天内容(单人随访)
+(AFHTTPRequestOperation*)appSendChatContentForFollowRequest:(int)userId
                                         isQuestion:(int)isQuestion
                                           fileType:(int)fileType
                                           objId:(NSString *)objId
                                          completed:(completedBlock)completed;

//4.24发送聊天内容（新改造的发送聊天接口）
+(AFHTTPRequestOperation*)appSendChatContentRequest1:(int)userId
                                          isQuestion:(int)isQuestion
                                             content:(NSString*)content
                                            fileType:(int)fileType
                                            objId:(NSString*)objId
                                           completed:(completedBlock)completed;

//3.26获取聊天内容
+(AFHTTPRequestOperation*)appGetChatContentRequest:(int)consultId
                                         completed:(completedBlock)completed;

//3.27群发消息 16年8月群发消息整改
+(AFHTTPRequestOperation*)appMassMessagesRequest:(NSString*)pushContent
                                         userIds:(NSArray*)userIds
                                       completed:(completedBlock)completed;

//3.28建意与问题
+(AFHTTPRequestOperation*)appComplaintAddRequest:(NSString*)complaintContent
                                  complaintPhone:(NSString*)complaintPhone
                                   complaintType:(int)complaintType
                                       completed:(completedBlock)completed;

//2.4取上传文件权限
+(AFHTTPRequestOperation*)uptokenRequest:(int)fileType
                               completed:(completedBlock)completed;

//2.5取地区信息
+(AFHTTPRequestOperation*)getAreaInfoRequest:(int)parentAreaId
                                   areaLevel:(int)areaLevel
                                   completed:(completedBlock)completed;

//1.1
//3.28轮询机制
+(AFHTTPRequestOperation *)appConsultListRequest:(int)userId
                                         isOrder:(BOOL)isOrder
                                       consultId:(int)consultId
                                       completed:(completedBlock)completed;

//3.29患者备注维护
+(AFHTTPRequestOperation *)patientRemModifyRequest:(int)userId
                                               rem:(NSString*)rem
                                         completed:(completedBlock)completed;

//1.2
//3.30随访问卷模版列表
+(AFHTTPRequestOperation *)appFollowUpModelListRequest:(completedBlock)completed;

//3.31随访问卷发送
+(AFHTTPRequestOperation *)appFollowAnswerSendRequest:(NSArray*)userIds
                                              modelId:(int)modelId
                                            completed:(completedBlock)completed;

//3.32患者随访问卷历史列表
+(AFHTTPRequestOperation *)appFollowAnswerListRequest:(int)userId
                                            consultId:(int)consultId
                                            completed:(completedBlock)completed;

//3.33群发消息列表
+(AFHTTPRequestOperation *)appMassMessagesListRequest:(int)pushId
                                            completed:(completedBlock)completed;

//3.34修改密码
+(AFHTTPRequestOperation *)appChangePwdRequest:(NSString*)oldPwd
                                      passWord:(NSString*)passWord
                               comfirmPassWord:(NSString*)comfirmPassWord
                                     completed:(completedBlock)completed;

//3.35分享
//shareType 1微信好友、2微信朋友圈、3QQ、4QQ空间、5短信
//objType   2医护6通知公告11APP应用
//objId     objType为2，objId 表示医生ID，为6，objId 表示公告ID，为11时，objId 为空
+(AFHTTPRequestOperation *)appShareRequest:(int)shareType
                                   objType:(int)objType
                                     objId:(int)objId
                                 completed:(completedBlock)completed;

//3.36已邀请联系人列表
+(AFHTTPRequestOperation *)appInvitationListRequest:(completedBlock)completed;

//3.37发送邀请操作
+(AFHTTPRequestOperation *)appInvitationRequest:(NSString*)phoneNo
                                      completed:(completedBlock)completed;

//3.39好友申请列表
+(AFHTTPRequestOperation *)appDrFriendListRequest:(int)startNum
                                        completed:(completedBlock)completed;

//3.40
+(AFHTTPRequestOperation *)appAddPatientFriendRequest:(int)userId
                                           modifyType:(int)modifyType
                                              groupId:(int)groupId
                                                  rem:(NSString*)rem
                                            completed:(completedBlock)completed;

//3.38
+(AFHTTPRequestOperation *)appDrLaberRequest:(completedBlock)completed;

//3.41
+(AFHTTPRequestOperation *)appOpenCloseSoundRequest:(int)modifyType completed:(completedBlock)completed;

//我的道具
+(AFHTTPRequestOperation *)appMyGoodsRequest:(completedBlock)completed;

//赠送记录列表
+(AFHTTPRequestOperation *)appGiveListRequest:(int)startNum completed:(completedBlock)completed;

//道具列表
+(AFHTTPRequestOperation *)appMyGoodsListRequest:(completedBlock)completed;

//正在处理提现记录
+(AFHTTPRequestOperation *)appCashListRequest:(int)startNum completed:(completedBlock)completed;

//提现提交
+(AFHTTPRequestOperation *)appAddCashRequest:(double)cashNum completed:(completedBlock)completed;

//1.7
//排班信息获取
+(AFHTTPRequestOperation *)commonScheduleInfoRequset:(completedBlock)completed;

//值班事项列表
+(AFHTTPRequestOperation *)appScheduleJobListRequest:(completedBlock)completed;

//值班事项操作
+(AFHTTPRequestOperation *)appScheduleJobModifyRequest:(int)jobId jobName:(NSString*)jobName modifyType:(int)modifyType completed:(completedBlock)completed;

//排班保存操作
+(AFHTTPRequestOperation *)appScheduleInfoSaveRequest:(int)isChange scheduleKeep:(int)scheduleKeep schedule:(NSArray*)schedule scheduleNext:(NSArray*)scheduleNext completed:(completedBlock)completed;

//超时未设排班提醒
+(AFHTTPRequestOperation *)appScheduleInfoWarnRequest:(completedBlock)completed;

//患者是否已完善信息
+(AFHTTPRequestOperation *)appIsFinishUserInfoRequest:(int)userId completed:(completedBlock)completed;

//患者资料获取
+(AFHTTPRequestOperation *)appGetUserInfoRequest:(int)userId completed:(completedBlock)completed;

//历史随访人员列表
+(AFHTTPRequestOperation *)appGetFollowUserListRequest:(int)modelId groupId:(int)groupId dateNum:(int)num state:(int)state completed:(completedBlock)completed;

+(AFHTTPRequestOperation *)appSendChatContent2Request:(int)userId
                                              content:(NSString*)content
                                         archivesType:(NSArray*)archivesType
                                            completed:(completedBlock)completed;

// 分享知识百科和公开课联系人:appContactShare
+(AFHTTPRequestOperation *)appContactShareSendRequest:(NSArray *)userIds consultContent:(NSString *)consultContent fileType:(int)fileType objId:(NSString *)objId completed:(completedBlock)completed;


//授权登录请求
+(AFHTTPRequestOperation *)appLoginEmpower:(NSString *)key completed:(completedBlock)completed;

//退出授权请求
+(AFHTTPRequestOperation *)appLoginOutEmpower:(completedBlock)completed;

//4.58可分享活动列表
+(AFHTTPRequestOperation *)appActivityDrShareListRequest:(int)startNum
                                              getNum:(int)getNum
                                            completed:(completedBlock)completed;

//4.59可分享活动详情
+(AFHTTPRequestOperation *)appActivityDrShareInfoRequest:(int)activityId
                                               completed:(completedBlock)completed;

//3.24广告区域列表
+(AFHTTPRequestOperation *)commonAdMessageListRequest:(int)adSet
                                               completed:(completedBlock)completed;

//4.61患者填写资料列表
+(AFHTTPRequestOperation *)appUserNeedInfoListRequest:(completedBlock)completed;


//4.62患者填写资料设置
+(AFHTTPRequestOperation *)appUserNeedInfoModifyRequest:(NSArray *)needKeys
                                               completed:(completedBlock)completed;

//4.26群发消息
//+(AFHTTPRequestOperation *)appMassMessagesRequest:(NSString *)pushContent
//                                                     userId:(NSArray *)userId
//                                                     pushOther:(NSArray *)pushOther
//                                              completed:(completedBlock)completed;

+(AFHTTPRequestOperation*)appMassMessagesRequest1:(NSString*)pushContent
                                         userIds:(NSArray*)userIds
                                         pushOther:(NSArray*)pushOther
                                       completed:(completedBlock)completed;

+(AFHTTPRequestOperation*)appMassMessagesRequest2:(NSString*)pushContent
                                          pushId:(int)pushId
                                        pushOther:(NSArray*)pushOther
                                        completed:(completedBlock)completed;


//4.33群发消息列表
+(AFHTTPRequestOperation *)appMassMessagesListRequest:(int)pushId
                                            getNum:(int)getNum
                                         completed:(completedBlock)completed;

//4.33群发消息列表(https)
+(AFHTTPRequestOperation *)appMassMessagesListRequestHttps:(int)pushId
                                               getNum:(int)getNum
                                            completed:(completedBlock)completed;

//4.33.1群发消息列表（自己写的本地用的接口）
+(AFHTTPRequestOperation *)appMassMessagesMoreListRequest:(int)pushId
                                               getNum:(int)getNum
                                            completed:(completedBlock)completed;

//4.34群发消息详情
+(AFHTTPRequestOperation *)appMassMessagesInfoRequest:(int)pushId
                                            completed:(completedBlock)completed;

//4.35群发消息联系人列表
+(AFHTTPRequestOperation*)appMassMessagesUserListRequest:(int)pushId
                                        startNum:(int)startNum
                                        getNum:(int)getNum
                                        completed:(completedBlock)completed;

//群发随访已回复联系人列表
+(AFHTTPRequestOperation*)appFollowMessagesUserListtRequest:(int)pushId
                                                startNum:(int)startNum
                                                  getNum:(int)getNum
                                               completed:(completedBlock)completed;

//5.77分类医生列表
+(AFHTTPRequestOperation*)appNotedDrUserListRequest:(int)startNum
                                                  getNum:(int)getNum
                                               completed:(completedBlock)completed;

#if OpenScoket
+(BOOL)appConnectIM;
+(BOOL)appIsConnected;
+(void)appDisconnectIM;
+(void)appSendCLR:(completedBlock)completed;
//+(void)appSendDWR:(completedBlock)completed;
#endif

@end
