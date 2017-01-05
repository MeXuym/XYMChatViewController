//
//  IMSessionRequest.m
//  healthcoming
//
//  Created by Franky on 15/12/10.
//  Copyright © 2015年 Franky. All rights reserved.
//

#import "IMSessionRequest.h"
#import "IMSessionEvent.h"
#include "IMdefine.h"
#import "CommonOperation.h"
#import "EMessagesDB.h"
//#import "ContactManager.h"
#import "AFNHttpRequest.h"
#import "CUserInfoDB.h"
#import "NewUserDB.h"
//#import "NewFollowDB.h"

static IMSessionRequest* instance;
static NSString *const xCompletedCallbackKey = @"completed";
static NSString *const xTimeOutSourceKey = @"timeout";

@interface IMSessionRequest()<IMSessionEventDelegate>
{
    NSString* currentUID;
    NSString* currentUName;
    BOOL connected;
    BOOL validated;
    IMSessionEvent* _IMEvent;
    dispatch_source_t heartTimer;
    
    NSMutableArray* onLineUserList;
    NSDictionary* normalInfo;
}

@property (strong,nonatomic) NSMutableDictionary* IMCallBacks;
@property (strong,nonatomic) dispatch_queue_t IMbarrierQueue;
@property (strong,nonatomic) dispatch_queue_t UserbarrierQueue;

@end

@implementation IMSessionRequest

@synthesize IMCallBacks;
@synthesize IMbarrierQueue;
@synthesize IMTimeout;

-(void)setUserInfo:(NSDictionary *)userInfo
{
    normalInfo = userInfo;
}

-(BOOL)isOnline
{
    return connected && validated;
}

+(IMSessionRequest*)shareInstance
{
    @synchronized(self){
        if(!instance){
            instance = [[IMSessionRequest alloc] init];
        }
        return instance;
    }
}

- (id)init
{
    self = [super init];
    if (self)
    {
        IMCallBacks = [NSMutableDictionary dictionary];
        onLineUserList = [NSMutableArray array];
        IMbarrierQueue = dispatch_queue_create("com.IMServer.BarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        IMTimeout = 5.0;
    }
    return self;
}

-(void)dealloc
{
    [self clean];
}

-(BOOL)connect:(NSString *)hostName port:(int)port
{
    if(connected)
        return YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IMConnectStateChangeNotiction
                                                        object:nil
                                                      userInfo:@{@"State":@(0)}];
    if(!_IMEvent)
    {
        _IMEvent = [[IMSessionEvent alloc] init];
        [_IMEvent setSessionController:self];
    }
    
    if(![_IMEvent InitIMWithHost:hostName port:port])
        return NO;
    
    if(![_IMEvent connectIM])
    {
        return NO;
    }
    else
    {
        __weak IMSessionRequest *wself = self;
        heartTimer = [self createDispatchTimer:^{
            [wself Heartbet];
        } timeOut:60.0
                                         queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    connected = YES;
#if TARGET_OS_IPHONE
    [_IMEvent enableBackgroundingOnSocket];
#endif
    return YES;
}

-(void)disconnect
{
    if(!connected)
        return;
    
    if(_IMEvent)
    {
        [_IMEvent DeInitIM];
    }
    if(heartTimer)
    {
        dispatch_source_cancel(heartTimer);
    }
    normalInfo = nil;
    connected = NO;
    validated = NO;
}

-(void)clean
{
    [IMCallBacks removeAllObjects];
    IMCallBacks = nil;
    IMbarrierQueue = nil;
    currentUID = nil;
    instance = nil;
}

-(void)sendRequest:(int)cmd data:(NSDictionary *)data
{
    [self sendRequest:cmd data:data completed:^(int cmdType, NSDictionary *response, BOOL isSuccess) {}];
}

-(void)sendRequest:(int)cmd data:(NSDictionary *)data completed:(IMCompletedBlock)completed
{
    if(!data || !connected)
        return;
    
    NSMutableDictionary* mutableData = [NSMutableDictionary dictionaryWithDictionary:data];
    NSString* reqId = [mutableData objectWithKey:@"reqId"];
    if(!reqId)
    {
        reqId = [CommonOperation stringWithGUID];
        [mutableData setObject:reqId forKey:@"reqId"];
    }
    __weak IMSessionRequest *wself = self;
    [self addCompletedBlock:cmd reqId:reqId andCompletedBlock:completed createCallback:^{
        NSData* jsonData = [CommonOperation dictionaryToJsonData:mutableData];
        if(jsonData)
        {
            [wself SendCommand:cmd buffer:(char*)jsonData.bytes dataLen:(int)jsonData.length];
        }
    }];
}

-(void)Heartbet
{
    [self sendRequest:IM_WATCH_REQUEST data:normalInfo?normalInfo:@{} completed:^(int cmdType, NSDictionary *response, BOOL isSuccess) {
        if(!isSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"心跳没响应，断开连接");
                [self disconnect];
            });
        }
    }];
}

-(BOOL)SendCommand:(unsigned short)usCmd buffer:(const char *)buffer dataLen:(int)dataLen
{
    if(_IMEvent)
    {
        return [_IMEvent SendCommand:usCmd buffer:buffer dataLen:dataLen];
    }
    return NO;
}

-(void)addCompletedBlock:(int)cmdType reqId:(NSString*)reqId andCompletedBlock:(IMCompletedBlock)completedBlock createCallback:(void (^)())createCallback
{
    if(cmdType == 0)
    {
        if(completedBlock != nil){
            completedBlock(cmdType, nil, NO);
        }
        return;
    }
    NSString* guid = [NSString stringWithFormat:@"%@",reqId];
    dispatch_barrier_sync(IMbarrierQueue, ^{
        BOOL first=NO;
        if(!IMCallBacks[guid]){
            IMCallBacks[guid] = [NSMutableArray new];
            first=YES;
        }
        
        NSMutableArray* callbacksForGuid = IMCallBacks[guid];
        NSMutableDictionary *callbacks = [NSMutableDictionary new];
        if (completedBlock)
        {
            callbacks[xCompletedCallbackKey] = [completedBlock copy];
        }
        dispatch_source_t timer=[self createDispatchTimer:^{
            [self removeCallbacksForGuid:cmdType guid:guid isTimeOut:YES];
        } timeOut:IMTimeout
            queue:IMbarrierQueue];
        callbacks[xTimeOutSourceKey]=timer;
        [callbacksForGuid addObject:callbacks];
        IMCallBacks[guid] = callbacksForGuid;
        
        if(first){
            createCallback();
        }
    });
}

- (NSArray *)callbacksForGuid:(NSString *)guid
{
    __block NSArray *callbackForGuid;
    dispatch_sync(IMbarrierQueue, ^{
        callbackForGuid = IMCallBacks[guid];
    });
    return [callbackForGuid copy];
}

- (void)removeCallbacksForGuid:(int)cmdType guid:(NSString *)guid isTimeOut:(BOOL)isTimeOut
{
    dispatch_barrier_async(IMbarrierQueue, ^{
        NSArray* callbackForGuid = IMCallBacks[guid];
        for(NSDictionary* callback in callbackForGuid)
        {
            dispatch_source_t timer=callback[xTimeOutSourceKey];
            if(timer){
                dispatch_source_cancel(timer);
            }
            if(isTimeOut)
            {
                IMCompletedBlock completed=callback[xCompletedCallbackKey];
                if(completed)
                {
                    completed(cmdType, @{xErrorMsgKey:@"请求超时",xErrorCodeKey:@(-1),@"reqId":guid}, NO);
                }
            }
        }
        [IMCallBacks removeObjectForKey:guid];
    });
}

-(dispatch_source_t)createDispatchTimer:(dispatch_block_t)block timeOut:(NSTimeInterval)timeOut queue:(dispatch_queue_t)queue
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, timeOut*NSEC_PER_SEC), timeOut*NSEC_PER_SEC, 0.1);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

-(void)completeCallBack:(int)cmdType reqId:(NSString*)reqId userObject:(NSDictionary*)userObject result:(BOOL)result
{
    __block IMCompletedBlock completed = nil;
    __block NSString* guid = [NSString stringWithFormat:@"%@",reqId];
    
    void (^block)(void)=^
    {
        NSArray* callbackForGuid=IMCallBacks[guid];
        if(callbackForGuid)
        {
            [self removeCallbacksForGuid:cmdType guid:guid isTimeOut:NO];
            for(NSDictionary* callback in callbackForGuid)
            {
                completed = callback[xCompletedCallbackKey];
            }
        }
    };
    
    if(guid)
    {
        block();
        if(completed)
        {
            completed(cmdType, userObject, result);
        }
    }
}

#pragma mark ----IMSessionEventDelegate----

-(void)onUserEvent:(int)cmdID buffer:(const char *)buffer lenght:(int)lenght
{
    if (!_IMEvent) {
        return;
    }
    
//    if(cmdID != IM_WATCH_ANSWER)
//    {
        NSLog(@"Cmd=%d Content=%s DataLen=%d",cmdID,buffer,lenght);
//    }
    
    void (^completed)(NSDictionary*, BOOL, NSString*, NSString*, int, NSString*) = ^(NSDictionary* data, BOOL isSuccess, NSString* reqId, NSString* method, int errorCode, NSString* errorMsg)
    {
        switch (cmdID)
        {
            case IM_LINK_ANSWER://2
            {
                validated = YES;
                [self completeCallBack:cmdID reqId:reqId userObject:data result:YES];
            }
                break;
            case IM_WATCH_REQUEST://3
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendRequest:IM_WATCH_ANSWER data:@{@"reqId":reqId}];
                });
            }
                break;
            case IM_WATCH_ANSWER://4
            {
                [self completeCallBack:cmdID reqId:reqId userObject:data result:YES];
            }
                break;
            case IM_SERVICE_REQUEST://5
            {
                if([method isEqualToString:@"appLoginEmpowerPush"])
                {
                    NSLog(@"登录授权推送");

                }

                else if([method isEqualToString:@"pcLoginOutPush"])
                {
                    NSLog(@"收到PC退出推送");
                    //发送通知给会话页面去掉悬浮
                    isPCLogin = 0;
                    NSNotification *notification =[NSNotification notificationWithName:@"PCLoginOutSuccess" object:nil userInfo:nil];
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                }
                //PC端发消息，过来的推送
                else if([method isEqualToString:@"appSyncMyselfContent"])
                {
                    NSLog(@"收到PC端聊天消息推送（杀死APP要走百度）");
                    
                    /*
                     同步过来的消息，因为怕影响到其他地方，这里先特殊处理了一下。
                     */
                    
                    EMessage* message = [[EMessage alloc] initWithDic:data];
                    message.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
                    message.isSelf = YES;
                    message.isRead = YES;
                    message.isSend = YES;
                    NSDictionary *userDrPatient = [data objectForKey:@"userDrPatient"];
                    int toUserId = [userDrPatient intWithKey:@"userId"];
                    message.friends_UID = [NSString stringWithFormat:@"%d",toUserId];
                    [[EMessagesDB shareInstance] insertWithMessage:message consultId:message.consultId isNotifaction:YES];
                }
                //收到聊天消息推送
                else if([method isEqualToString:@"appRequestChatContentHsp"])//9.1
                {
                    NSLog(@"收到微信聊天消息推送");
                    EMessage* message = [[EMessage alloc] initWithDic:data];
                    message.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
                    [[EMessagesDB shareInstance] insertWithMessage:message consultId:message.consultId isNotifaction:YES];
                }

                else if ([method isEqualToString:@"appSessionOverHsp"])//9.2
                {
                    NSLog(@"会话已经结束");
                    
                }
                else if ([method isEqualToString:@"appAddUserHsp"])//9.3
                {
                    NSLog(@"新加好友推送");
                    EUserInfo* info = [[EUserInfo alloc] initWithDic:data];
                    [[CUserInfoDB shareInstance] insertWithUserInfo:info];
                    int userId = [data intWithKey:@"userId"];
//                    [[ContactManager instance] addNewUser:userId];
                    
                }
                else if ([method isEqualToString:@"appNoticePushHsp"])//9.4
                {
                    NSString* content = [data objectWithKey:@"noticeContent"];
                    int belongType = [data intWithKey:@"belongType"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNewPushMsgNotifaction
                                                                            object:nil
                                                                     userInfo:@{@"content":content,@"addRead":@(1),@"belongType":@(belongType)}];
                    });
                }
                else if ([method isEqualToString:@"appCheckPushHsp"])//9.5
                {
                    [AFNHttpRequest appGetUserRequest:^(NSDictionary *response, BOOL isSuccess, int errorCode, NSString* errorMsg) {
                        [DialogUtil hideWaitingView];
                        if(isSuccess)
                        {
                            [[MyUserInfo myInfo] updateWithDic:response];
                            [[MyUserInfo myInfo] saveInfo];
                            [[NSNotificationCenter defaultCenter] postNotificationName:KSignChangedNotifaction object:nil userInfo:data];
                        }
                    }];
                }
                else if ([method isEqualToString:@"appAddFriendMsgHsp"])//9.6
                {
                    NSLog(@"收到申请推送");
                    int userId = [data intWithKey:@"userId"];
                    
//                    //另外一张DB存请的申请
//                    FUserInfo* info = [[FUserInfo alloc] init];
//                    info.userId = userId;
//                    [[NewFollowDB shareInstance]insertWithUserInfo:info];
//                    
//                    [[ContactManager instance] addFollowUser:userId];
                }
                else if ([method isEqualToString:@"appGoodsSendMsgHsp"])//9.7
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:KMyGoodsChangedNotifaction
                                                                            object:nil
                                                                          userInfo:data];
                    });
                }
                else if ([method isEqualToString:@"appCashAuditMsgHsp"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:KCashAuditMsgNotifaction
                                                                            object:nil
                                                                          userInfo:data];
                    });
                }
                else if ([method isEqualToString:@"appUserInfoModifyHsp"])
                {
                    NSDictionary* userPatient = [data objectWithKey:@"userPatient"];
                    EUserInfo* info = [[EUserInfo alloc] initWithDic:userPatient];
                    [[CUserInfoDB shareInstance] updateWithUserInfo:info];
                    KUserInfo* info2 = [[KUserInfo alloc] init];
                    info2.userId = [info.nUID intValue];
                    info2.isNewF = YES;
                    [[NewUserDB shareInstance] replaceWithUserInfo:info2];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:KGroupUserChangedNotifaction
                                                                            object:nil
                                                                          userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KSessionNameNotifaction
                                                                            object:nil
                                                                          userInfo:@{@"userId":info.nUID,@"userNicename":info.rem?info.rem:@"",@"patientSex":@(info.patientSex),@"age":@(info.age)}];
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendRequest:IM_SERVICE_ANSWER data:@{@"reqId":reqId}];
                });
            }
                break;
            case IM_SERVICE_ANSWER://6
            {
                [self completeCallBack:cmdID reqId:reqId userObject:data result:YES];
            }
                break;
            default:
                break;
        }
    };
    
    NSString *jsonString = [[NSString alloc] initWithBytes:buffer length:lenght encoding:NSUTF8StringEncoding];
    NSDictionary* dic = [CommonOperation jsonToDictionary:jsonString];
    if([dic isKindOfClass:[NSDictionary class]])
    {
        NSString* mothed = [dic objectWithKey:@"method"];
        NSString* errorMsg = [dic objectWithKey:@"reason"];
        NSString* reqId = [dic objectWithKey:@"reqId"];
        int errorCode = [dic intWithKey:@"resultCode"];
        if(reqId)
        {
            if(errorCode == 0)
            {
                NSDictionary* data = [dic objectWithKey:@"data"];
                if(data && [data isKindOfClass:[NSDictionary class]])
                {
                    completed(data, YES, reqId, mothed, 0, nil);
                }
            }
            else if(errorCode == 304)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KUserKickOffNotifaction object:nil];
                });
            }
            else
            {
                [self completeCallBack:cmdID reqId:reqId userObject:@{xErrorMsgKey:errorMsg,xErrorCodeKey:@(errorCode)} result:NO];
            }
        }
    }
}

-(void)OnDisConnection
{
    [self disconnect];
    [[NSNotificationCenter defaultCenter] postNotificationName:IMConnectStateChangeNotiction
                                                        object:nil
                                                      userInfo:@{@"State":@(-1),@"IsReConnect":@(YES)}];
}

@end
