//
//  AFNHttpRequest.m
//  healthcoming
//
//  Created by Franky on 15/8/5.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "AFNHttpRequest.h"
#import "OpenUDID.h"
#import "sys/utsname.h"
#import "XYMConnection.h"

#if OpenScoket
#import "IMSessionRequest.h"
#import "CommonOperation.h"
#endif

@interface AFNHttpRequest()

//记录手机型号和系统版本
@property (nonatomic,strong) NSString *deviceVersion;

@end

@implementation AFNHttpRequest

//+(AFHTTPRequestOperationManager*)getAFNManager
//{
//    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer=[AFJSONRequestSerializer serializer];
//    manager.responseSerializer=[AFJSONResponseSerializer serializer];
//    manager.requestSerializer.timeoutInterval=60;
//    
////    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];//证书的路径
////    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
////    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
////    //需要自建证书则默认YES，测试的时候可以关闭，正式的开启
////    securityPolicy.allowInvalidCertificates = YES;
////    //validatesDomainName 是否验证域名。默认为“是”。 建议开启
//////    securityPolicy.validatesDomainName = NO;
////    securityPolicy.pinnedCertificates = @[cerData];
//    
//    manager.responseSerializer  = [AFHTTPResponseSerializer serializer];
//    //是否接受无效的证书
//    manager.securityPolicy.allowInvalidCertificates= YES;
//    //是否匹配域名
//    manager.securityPolicy.validatesDomainName = NO;
//
//    return manager;
//}
//
////每次都带上的参数（之前貌似不是每次都带上了channelId）
//+(AFHTTPRequestOperation*)getNormalOperation:(NSString*)urlStr
//                                     version:(NSString*)version
//                                  parameters:(NSDictionary*)parameters
//                                   completed:(completedBlock)completed
//{
//    AFHTTPRequestOperationManager* manager = [AFNHttpRequest getAFNManager];
//    [manager.requestSerializer setValue:version forHTTPHeaderField:@"Content-Version"];
//    AFHTTPRequestOperation* operation = [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"每次发送的参数getNormalOperation:%@",parameters);
//        NSString* mothed = [parameters objectWithKey:@"method"];
//        NSString* errorMsg = [responseObject objectWithKey:@"reason"];
//        if(![mothed isEqualToString:@""])
//        {
//            NSLog(@"%@:%@,error:%@",mothed,responseObject,errorMsg);
//        }
//        if([responseObject isKindOfClass:[NSDictionary class]])
//        {
//            int errorCode = [responseObject intWithKey:@"resultCode"];
//            if(errorCode == 0)
//            {
//                NSDictionary* data = [responseObject objectWithKey:@"data"];
//                if(data && [data isKindOfClass:[NSDictionary class]])
//                {
//                    completed(data, YES, NoError, nil);
//                    return;
//                }
//            }
//            else if(errorCode == 304)
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:KUserKickOffNotifaction object:nil];
//            }
//            if(completed)
//            {
//                completed(nil, NO, errorCode, errorMsg);
//            }
//        }
//        else
//        {
//            if(completed)
//            {
//                completed(nil, NO, DataError, @"服务器返回错误");
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if(completed)
//        {
//            completed(nil, NO, NoNetWorkError, @"您的网络好像不太给力，请稍后再试");
//        }
//    }];
//    return operation;
//}


//下面两个方法改用AFHTTPSessionManager来发送请求
+(AFHTTPRequestOperationManager*)getAFNManager
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval=60;
    
    return manager;
}

//每次都带上的参数（之前貌似不是每次都带上了channelId）
+(AFHTTPRequestOperation*)getNormalOperation:(NSString*)urlStr
                                     version:(NSString*)version
                                  parameters:(NSDictionary*)parameters
                                   completed:(completedBlock)completed
{
    AFHTTPRequestOperationManager* manager = [AFNHttpRequest getAFNManager];
    [manager.requestSerializer setValue:version forHTTPHeaderField:@"Content-Version"];
    
    // 加上这行代码，https ssl 验证。
//    [manager setSecurityPolicy:[self customSecurityPolicy]];
    
    AFHTTPRequestOperation* operation = [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"每次发送的参数getNormalOperation:%@",parameters);
        NSString* mothed = [parameters objectWithKey:@"method"];
        NSString* errorMsg = [responseObject objectWithKey:@"reason"];
        if(![mothed isEqualToString:@""])
        {
            NSLog(@"%@:%@,error:%@",mothed,responseObject,errorMsg);
        }
        if([responseObject isKindOfClass:[NSDictionary class]])
        {
            int errorCode = [responseObject intWithKey:@"resultCode"];
            if(errorCode == 0)
            {
                NSDictionary* data = [responseObject objectWithKey:@"data"];
                if(data && [data isKindOfClass:[NSDictionary class]])
                {
                    completed(data, YES, NoError, nil);
                    return;
                }
            }
            else if(errorCode == 304)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:KUserKickOffNotifaction object:nil];
            }
            if(completed)
            {
                completed(nil, NO, errorCode, errorMsg);
            }
        }
        else
        {
            if(completed)
            {
                completed(nil, NO, DataError, @"服务器返回错误");
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completed)
        {
            completed(nil, NO, NoNetWorkError, @"您的网络好像不太给力，请稍后再试");
        }
    }];
    return operation;
}


//AFN发送https
+ (AFSecurityPolicy *)customSecurityPolicy {
    
    // 先导入证书 证书由服务端生成，具体由服务端人员操作
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];//证书的路径
//    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES;
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
//    securityPolicy.pinnedCertificates = @[cerData];
    
    return securityPolicy;
}

+(AFHTTPRequestOperation*)getNormalOperation:(NSString*)urlStr
                                  parameters:(NSDictionary*)parameters
                                   completed:(completedBlock)completed
{
//#if OpenScoket
//    [AFNHttpRequest appSendSCR:parameters completed:completed];
//    return nil;
//#else
    
    //判断网络是否可用
    if([XYMConnection isConnectionAvailable]){
    
    return [AFNHttpRequest getNormalOperation:urlStr version:[self getRequestVersion] parameters:parameters completed:completed];
        
    }else{
        
        [DialogUtil postAlertWithMessage:@"网络不可用"];
        
        return nil;
    }
//#endif
}

+ (NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //CLog(@"%@",deviceString);
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    //CLog(@"NOTE: Unknown device type: %@", deviceString);
    
    return deviceString;
}


+(NSDictionary*)getNormalParameters:(NSDictionary*)data method:(NSString*)action
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    NSString* appId = [OpenUDID value];
    NSString *ios_version = [[UIDevice currentDevice]systemVersion];
    NSString *app_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    appId = [NSString stringWithFormat:@"%@$iOS %@$Verison %@$%@",self.deviceVersion,ios_version,app_version,appId];
    [dic setObject:appId?appId:@"" forKey:@"appId"];
    [dic setObject:action forKey:@"method"];
    [dic setObject:@(1) forKey:@"appType"];
    [dic setObject:[self getRequestVersion] forKey:@"contentVersion"];
    
    
    //如果有channelId
//    NSLog(@"请求的参数获取（看有没channelId）:%@",[MyUserInfo myInfo].channelId);
//    [DialogUtil postAlertWithMessage:str];
    
    
    if([MyUserInfo myInfo].channelId)
    {
        [dic setObject:[MyUserInfo myInfo].channelId forKey:@"channelId"];
    }
    if([MyUserInfo myInfo].tokenId)
    {
        [dic setObject:[MyUserInfo myInfo].tokenId forKey:@"tokenId"];
    }
    else
    {
        [dic setObject:@"" forKey:@"tokenId"];
    }
    if(data)
    {
        [dic setObject:data forKey:@"data"];
    }
    return dic;
}

+(NSString*)getHttpUrl
{
    return [NSString stringWithFormat:@"http://%@",POSTSERVER];
//    return [NSString stringWithFormat:@"https://%@",POSTSERVER];//试一下直接请求https
}


//协议版本号
+(NSString*)getRequestVersion
{
    return @"2.8";
}

+(AFHTTPRequestOperation *)loginRequest:(int)loginType
                                 userId:(NSString *)userId
                               password:(NSString *)password
                              completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithInt:loginType] forKey:@"loginType"];
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:password forKey:@"passWord"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appLogin"];
#if OpenScoket
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:[self getRequestVersion] parameters:parameters completed:completed];
    return operation;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}

+(AFHTTPRequestOperation *)logoutRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appLoginOut"];
#if OpenScoket
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:[self getRequestVersion] parameters:parameters completed:completed];
    return operation;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}

+(AFHTTPRequestOperation *)getSMSRequest:(int)flag
                                 phoneNo:(NSString *)phoneNo
                               completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(flag) forKey:@"flag"];
    [dic setObject:phoneNo forKey:@"phoneNo"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"getSmsInfo"];
#if OpenScoket
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:[self getRequestVersion] parameters:parameters completed:completed];
    return operation;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}

+(AFHTTPRequestOperation*)appRegisterRequest:(NSString*)phoneNo
                                    passWord:(NSString*)passWord
                                     smsCode:(NSString*)smsCode
                                   completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:phoneNo forKey:@"phoneNo"];
    [dic setObject:passWord forKey:@"passWord"];
    [dic setObject:smsCode forKey:@"smsCode"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appRegister"];
#if OpenScoket
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:[self getRequestVersion] parameters:parameters completed:completed];
    return operation;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}

+(AFHTTPRequestOperation *)appGetUserRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appGetUser"];
#if OpenScoket
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:[self getRequestVersion] parameters:parameters completed:completed];
    return operation;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}

////获取医生资料（品类推荐：增加 isActivityDrShare）
//+(AFHTTPRequestOperation *)appGetUserRequest:(completedBlock)completed
//{
//    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appGetUser"];
//#if OpenScoket
//    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:[self getRequestVersion] parameters:parameters completed:completed];
//    return operation;
//#else
//    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
//    return operation;
//#endif
//}

+(AFHTTPRequestOperation *)appForgetPasswordRequest:(NSString *)phoneNo smsCode:(NSString *)smsCode passWord:(NSString *)passWord completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:phoneNo forKey:@"phoneNo"];
    [dic setObject:smsCode forKey:@"smsCode"];
    [dic setObject:passWord forKey:@"passWord"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appForgetPassword"];
#if OpenScoket
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:[self getRequestVersion] parameters:parameters completed:completed];
    return operation;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}

+(AFHTTPRequestOperation *)appSetUserInfoRequest:(NSDictionary *)infoDic completed:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:infoDic method:@"appSetUserInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appGetOfficeListRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appGetOfficeList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appGetTitleListRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appGetTitleList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appGetHospitalListRequest:(NSString *)hospName startNum:(int)startNum completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(hospName){
        [dic setObject:hospName forKey:@"hospitalName"];
    }
    [dic setObject:@(startNum) forKey:@"startNum"];
    [dic setObject:@(15) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appGetHospitalList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appGetHospitalInfoRequest:(int)hospitalId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(hospitalId) forKey:@"hospitalId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appGetHospitalInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appPersonalassistantRequest:(int)hospitalId noticeId:(int)noticeId getNum:(int)getNum completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(hospitalId >= 0)
    {
        [dic setObject:@(hospitalId) forKey:@"hospitalId"];
    }
    if(noticeId >= 0)
    {
        [dic setObject:@(noticeId) forKey:@"noticeId"];
    }
    if(getNum > 0)
    {
        [dic setObject:@(getNum) forKey:@"getNum"];
    }
    else
    {
        [dic setObject:@(15) forKey:@"getNum"];
    }
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appPersonalassistant"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)addIdeaLogRequest:(int)objType objId:(int)objId logType:(int)logType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(objType) forKey:@"objType"];
    [dic setObject:@(objId) forKey:@"objId"];
    [dic setObject:@(logType) forKey:@"logType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"addIdeaLog"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appPatientGroupRequest:(int)groupId groupName:(NSString *)groupName modifyType:(int)modifyType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(groupId >= 0)
    {
        [dic setObject:@(groupId) forKey:@"groupId"];
    }
    if(groupName)
    {
        [dic setObject:groupName forKey:@"groupName"];
    }
    [dic setObject:@(modifyType) forKey:@"modifyType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appPatientGroup"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)patientGroupListRequest:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(1) forKey:@"isTotal"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"patientGroupList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)patientGroupUserListRequest:(int)userId groupId:(int)groupId userNameTag:(NSString *)userNameTag completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(userId > 0)
    {
        [dic setObject:@(userId) forKey:@"userId"];
    }
    if(groupId >= 0)
    {
        [dic setObject:@(groupId) forKey:@"groupId"];
    }
    if(userNameTag)
    {
       [dic setObject:userNameTag forKey:@"userNameTag"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"patientGroupUserList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)patientGroupUserModifyRequest:(int)groupId userIds:(NSArray *)userIds completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(groupId) forKey:@"groupId"];
    if(userIds)
    {
        [dic setObject:userIds forKey:@"userId"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"patientGroupUserModify"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appUserSessionListRequest:(int)userId createTime:(NSString *)createTime completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    if(createTime)
    {
        [dic setObject:createTime forKey:@"createTime"];
    }
    [dic setObject:@(15) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appUserSessionList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)laberInfoListRequest:(int)userId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"laberInfoList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appAddLaberInfoRequest:(int)userId tags:(NSArray *)tags completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    if(tags)
    {
        [dic setObject:tags forKey:@"laber"];
    }

    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appAddLaberInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appHistoryConsultRequest:(NSArray *)sessionIds consultId:(int)consultId isOrder:(int)isOrder completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:sessionIds forKey:@"sessionId"];
//    if(consultId > 0)
//    {
//        [dic setObject:@(consultId) forKey:@"consultId"];
//    }
            [dic setObject:@(consultId) forKey:@"consultId"];
    [dic setObject:@(isOrder) forKey:@"isOrder"];
    [dic setObject:@(30) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appHistoryConsult"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];

    return operation;
}

+(AFHTTPRequestOperation *)appQuickReplyRequest:(int)quickReplyId replyContent:(NSString *)replyContent modifyType:(int)modifyType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(quickReplyId >= 0)
    {
        [dic setObject:@(quickReplyId) forKey:@"quickReplyId"];
    }
    if(replyContent)
    {
        [dic setObject:replyContent forKey:@"replyContent"];
    }
    [dic setObject:@(modifyType) forKey:@"modifyType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appQuickReply"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appQuickReplyListRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{@"andSystem":@(1)} method:@"appQuickReplyList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appQuestionListRequest:(int)type completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(type) forKey:@"type"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appQuestionList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appQuestionLogRequest:(int)type questionId:(NSArray *)questionIds completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(type) forKey:@"type"];
    [dic setObject:questionIds forKey:@"questionId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appQuestionLog"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appPatientUserInfoRequest:(int)userId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appPatientUserInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appNoEndSessionListRequest:(int)sessionId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(sessionId >= 0)
    {
        [dic setObject:@(sessionId) forKey:@"sessionId"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appNoEndSessionList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] version:@"1.4" parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation*)appSessionListRequest:(int)consultId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(consultId >= 0)
    {
        [dic setObject:@(consultId) forKey:@"consultId"];
    }
    [dic setObject:@(100) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appSessionList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appReadSessionBackRequest:(int)userId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appReadSessionBack"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appSendChatContentRequest:(int)userId isQuestion:(int)isQuestion content:(NSString *)content fileType:(int)fileType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    if(!content) content = @"";
    [dic setObject:@(isQuestion) forKey:@"isQuestion"];
    [dic setObject:content forKey:@"consultContent"];
    [dic setObject:@(fileType) forKey:@"fileType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appSendChatContent"];
#if OpenScoket
    if([AFNHttpRequest appIsConnected])
    {
        [AFNHttpRequest appSendSCR:parameters completed:completed];
    }
    else
    {
        AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
        return operation;
    }
    return nil;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}

//发送聊天内容（会话中发送随访）
+(AFHTTPRequestOperation *)appSendChatContentForFollowRequest:(int)userId isQuestion:(int)isQuestion  fileType:(int)fileType objId:(NSString *)objId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    [dic setObject:@(isQuestion) forKey:@"isQuestion"];
    [dic setObject:@(fileType) forKey:@"fileType"];
    [dic setObject:objId forKey:@"objId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appSendChatContent"];
#if OpenScoket
    if([AFNHttpRequest appIsConnected])
    {
        [AFNHttpRequest appSendSCR:parameters completed:completed];
    }
    else
    {
        AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
        return operation;
    }
    return nil;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif
}


//4.24发送聊天内容（新改造的发送聊天接口）
+(AFHTTPRequestOperation*)appSendChatContentRequest1:(int)userId
                                          isQuestion:(int)isQuestion
                                             content:(NSString*)content
                                            fileType:(int)fileType
                                               objId:(NSString*)objId
                                           completed:(completedBlock)completed{

    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    if(!content) content = @"";
    [dic setObject:@(isQuestion) forKey:@"isQuestion"];
    [dic setObject:content forKey:@"consultContent"];
    [dic setObject:@(fileType) forKey:@"fileType"];
    [dic setObject:objId forKey:@"objId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appSendChatContent"];
#if OpenScoket
    if([AFNHttpRequest appIsConnected])
    {
        [AFNHttpRequest appSendSCR:parameters completed:completed];
    }
    else
    {
        AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
        return operation;
    }
    return nil;
#else
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
#endif

}

+(AFHTTPRequestOperation *)appGetChatContentRequest:(int)consultId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(consultId) forKey:@"consultId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appGetChatContent"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//16年8月群发消息整改
+(AFHTTPRequestOperation *)appMassMessagesRequest:(NSString *)pushContent userIds:(NSArray *)userIds completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:pushContent forKey:@"pushContent"];
    [dic setObject:userIds forKey:@"userId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appMassMessages"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appComplaintAddRequest:(NSString *)complaintContent complaintPhone:(NSString *)complaintPhone complaintType:(int)complaintType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:complaintContent forKey:@"complaintContent"];
    if(complaintPhone)
    {
        [dic setObject:complaintPhone forKey:@"complaintPhone"];
    }
    [dic setObject:@(complaintType) forKey:@"complaintType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appComplaintAdd"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)uptokenRequest:(int)fileType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(1) forKey:@"type"];
    [dic setObject:@(fileType) forKey:@"fileType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"uptoken"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)getAreaInfoRequest:(int)parentAreaId areaLevel:(int)areaLevel completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(parentAreaId) forKey:@"parentAreaId"];
    [dic setObject:@(areaLevel) forKey:@"areaLevel"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"getAreaInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appConsultListRequest:(int)userId isOrder:(BOOL)isOrder consultId:(int)consultId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    [dic setObject:@(isOrder) forKey:@"isOrder"];
    if(consultId > 0)
    {
        [dic setObject:@(consultId) forKey:@"consultId"];
    }
    [dic setObject:@(20) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appConsultList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)patientRemModifyRequest:(int)userId rem:(NSString*)rem completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    [dic setObject:rem forKey:@"rem"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"patientRemModify"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appFollowUpModelListRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appFollowUpModelList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appFollowAnswerSendRequest:(NSArray *)userIds modelId:(int)modelId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:userIds forKey:@"userId"];
    [dic setObject:@(modelId) forKey:@"modelId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appFollowAnswerSend"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

#pragma mark - 分享联系人：知识百科 和 公开课
// appContactShare 接口
+(AFHTTPRequestOperation *)appContactShareSendRequest:(NSArray *)userIds consultContent:(NSString *)consultContent fileType:(int)fileType objId:(NSString *)objId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:userIds forKey:@"userId"];
    [dic setObject:consultContent forKey:@"consultContent"];
    [dic setObject:@(fileType) forKey:@"fileType"];
    [dic setObject:objId forKey:@"objId"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appContactShare"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}



+(AFHTTPRequestOperation *)appFollowAnswerListRequest:(int)userId consultId:(int)consultId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    if(consultId > 0)
    {
        [dic setObject:@(consultId) forKey:@"consultId"];
    }
    [dic setObject:@(15) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appFollowAnswerList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//群发消息列表2.2修改了
+(AFHTTPRequestOperation *)appMassMessagesListRequest:(int)pushId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(pushId > 0)
    {
        [dic setObject:@(pushId) forKey:@"pushId"];
    }
    [dic setObject:@(15) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appMassMessagesList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appChangePwdRequest:(NSString *)oldPwd passWord:(NSString *)passWord comfirmPassWord:(NSString *)comfirmPassWord completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:oldPwd forKey:@"oldPwd"];
    [dic setObject:passWord forKey:@"passWord"];
    [dic setObject:comfirmPassWord forKey:@"comfirmPassWord"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appChangePwd"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appShareRequest:(int)shareType objType:(int)objType objId:(int)objId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(shareType) forKey:@"shareType"];
    [dic setObject:@(objType) forKey:@"objType"];
    if(objId > 0)
    {
        [dic setObject:@(objId) forKey:@"objId"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appShare"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appInvitationListRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appInvitationList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appInvitationRequest:(NSString *)phoneNo completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:phoneNo forKey:@"phoneNo"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appInvitation"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appDrFriendListRequest:(int)startNum completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(startNum) forKey:@"startNum"];
    [dic setObject:@(15) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appDrFriendList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appAddPatientFriendRequest:(int)userId modifyType:(int)modifyType groupId:(int)groupId rem:(NSString *)rem completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    [dic setObject:@(modifyType) forKey:@"modifyType"];
    if(groupId > 0)
    {
        [dic setObject:@(groupId) forKey:@"groupId"];
    }
    if(rem)
    {
        [dic setObject:rem forKey:@"rem"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appAddPatientFriend"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appDrLaberRequest:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(10) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appDrLaber"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appOpenCloseSoundRequest:(int)modifyType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(modifyType) forKey:@"modifyType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appOpenCloseSound"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appMyGoodsRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appMyGoods"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appGiveListRequest:(int)startNum completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(startNum >= 0)
    {
        [dic setObject:@(startNum) forKey:@"startNum"];
    }
    [dic setObject:@(20) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appGiveList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appMyGoodsListRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appMyGoodsList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appCashListRequest:(int)startNum completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(startNum) forKey:@"startNum"];
    [dic setObject:@(30) forKey:@"getNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appCashList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appAddCashRequest:(double)cashNum completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(cashNum) forKey:@"cashNum"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appAddCash"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//1.7
+(AFHTTPRequestOperation *)commonScheduleInfoRequset:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"commonScheduleInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appScheduleJobListRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appScheduleJobList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appScheduleJobModifyRequest:(int)jobId jobName:(NSString *)jobName modifyType:(int)modifyType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(jobId > 0)
    {
        [dic setObject:@(jobId) forKey:@"jobId"];
    }
    if(jobName)
    {
        [dic setObject:jobName forKey:@"jobName"];
    }
    [dic setObject:@(modifyType) forKey:@"modifyType"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appScheduleJobModify"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}
/**
 *  @author Bennett.Peng, 16-05-03 01:05:14
 *
 *  @brief 排班保存操作
 *
 *  @param isChange     必填	是否改变	0不改变1改变
 *  @param scheduleKeep 必填	是否保持排班	0不保持1保持
 *  @param schedule     可选	本周排班组	0时可为空
 *  @param scheduleNext 可选	下周排班组	0时可为空
 *  @param completed    <#completed description#>
 *
 *  @return <#return value description#>
 *
 *  @since <#1.3.2#>
 */

+(AFHTTPRequestOperation *)appScheduleInfoSaveRequest:(int)isChange scheduleKeep:(int)scheduleKeep schedule:(NSArray *)schedule scheduleNext:(NSArray *)scheduleNext completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(isChange) forKey:@"isChange"];
    [dic setObject:@(scheduleKeep) forKey:@"scheduleKeep"];
    if(schedule)
    {
        [dic setObject:schedule forKey:@"schedule"];
    }
    if(scheduleNext)
    {
        [dic setObject:scheduleNext forKey:@"scheduleNext"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appScheduleInfoSave"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appScheduleInfoWarnRequest:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:@{} method:@"appScheduleInfoWarn"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appIsFinishUserInfoRequest:(int)userId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appIsFinishUserInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appGetUserInfoRequest:(int)userId completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appGetUserInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appGetFollowUserListRequest:(int)modelId groupId:(int)groupId dateNum:(int)dateNum state:(int)state completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(modelId) forKey:@"modelId"];
    if(groupId >= 0)
    {
        [dic setObject:@(groupId) forKey:@"groupId"];
    }
    if(dateNum > 0)
    {
        [dic setObject:@(dateNum) forKey:@"dateNum"];
    }
    if(state >= 0)
    {
        [dic setObject:@(state) forKey:@"state"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appGetFollowUserList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

+(AFHTTPRequestOperation *)appSendChatContent2Request:(int)userId content:(NSString *)content archivesType:(NSArray *)archivesType completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(userId) forKey:@"userId"];
    if(!content) content = @"";
    [dic setObject:@(2) forKey:@"isQuestion"];
    [dic setObject:content forKey:@"consultContent"];
    [dic setObject:@(4) forKey:@"fileType"];
    if(archivesType)
    {
        [dic setObject:archivesType forKey:@"archivesType"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appSendChatContent"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}


//登录授权请求
+(AFHTTPRequestOperation *)appLoginEmpower:(NSString *)key completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:key forKey:@"key"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appLoginEmpower"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}


//退出授权请求
+(AFHTTPRequestOperation *)appLoginOutEmpower:(completedBlock)completed
{
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:nil
                                                            method:@"appLoginOutEmpower"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//4.58可分享活动列表
+(AFHTTPRequestOperation *)appActivityDrShareListRequest:(int)startNum getNum:(int)getNum completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(startNum) forKey:@"startNum"];
    [dic setObject:@(getNum) forKey:@"getNum"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appActivityDrShareList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//4.59可分享活动详情
+(AFHTTPRequestOperation *)appActivityDrShareInfoRequest:(int)activityId completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(activityId) forKey:@"activityId"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appActivityDrShareInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;

}

//3.24广告区域列表
+(AFHTTPRequestOperation *)commonAdMessageListRequest:(int)adSet completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(adSet) forKey:@"adSet"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"commonAdMessageList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//4.61患者填写资料列表
+(AFHTTPRequestOperation *)appUserNeedInfoListRequest:(completedBlock)completed{
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:nil
                                                            method:@"appUserNeedInfoList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
    
}


//4.62患者填写资料设置
+(AFHTTPRequestOperation *)appUserNeedInfoModifyRequest:(NSArray *)needKeys completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:needKeys forKey:@"needKey"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appUserNeedInfoModify"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

////4.26群发消息
//+(AFHTTPRequestOperation *)appMassMessagesRequest:(NSString *)pushContent
//                                            userId:(int)userId
//                                            pushId:(int)pushId
//                                         pushOther:(NSArray *)pushOther
//                                         completed:(completedBlock)completed{
//
//    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
//    [dic setObject:pushContent forKey:@"pushContent"];
//    [dic setObject:@(userId) forKey:@"userId"];
//    [dic setObject:@(pushId) forKey:@"pushId"];
//    [dic setObject:pushOther forKey:@"pushId"];
//    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
//                                                            method:@"appMassMessages"];
//    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
//    return operation;
//}

//4.26群发消息（16年8月群发助手整改）
+(AFHTTPRequestOperation *)appMassMessagesRequest1:(NSString *)pushContent userIds:(NSArray *)userIds pushOther:(NSArray *)pushOther completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (pushContent) {
        [dic setObject:pushContent forKey:@"pushContent"];
    }
    [dic setObject:userIds forKey:@"userId"];
    
    if (pushOther.count > 0) {
        [dic setObject:pushOther forKey:@"pushOther"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appMassMessages"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//4.26群发消息（16年10月群发助手优化：加上再次发送）
+(AFHTTPRequestOperation *)appMassMessagesRequest2:(NSString *)pushContent pushId:(int)pushId pushOther:(NSArray *)pushOther completed:(completedBlock)completed
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:pushContent forKey:@"pushContent"];
    [dic setObject:@(pushId) forKey:@"pushId"];
    
    if (pushOther.count > 0) {
        [dic setObject:pushOther forKey:@"pushOther"];
    }
    
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic method:@"appMassMessages"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}




//4.33群发消息列表
+(AFHTTPRequestOperation *)appMassMessagesListRequest:(int)pushId
                                               getNum:(int)getNum
                                            completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(getNum) forKey:@"getNum"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appMassMessagesList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
    
}

//4.33群发消息列表(https)
+(AFHTTPRequestOperation *)appMassMessagesListRequestHttps:(int)pushId
                                               getNum:(int)getNum
                                            completed:(completedBlock)completed{
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(getNum) forKey:@"getNum"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appMassMessagesList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[NSString stringWithFormat:@"https://%@",POSTSERVER] parameters:parameters completed:completed];
    return operation;
    
}


//4.33.1群发消息列表
+(AFHTTPRequestOperation *)appMassMessagesMoreListRequest:(int)pushId
                                                   getNum:(int)getNum
                                                completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(pushId) forKey:@"pushId"];
    [dic setObject:@(getNum) forKey:@"getNum"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appMassMessagesList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
}

//4.34群发消息详情
+(AFHTTPRequestOperation *)appMassMessagesInfoRequest:(int)pushId
                                            completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(pushId) forKey:@"pushId"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appMassMessagesInfo"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;
    
}

//4.35群发消息联系人列表
+(AFHTTPRequestOperation*)appMassMessagesUserListRequest:(int)pushId
                                                startNum:(int)startNum
                                                  getNum:(int)getNum
                                               completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(pushId) forKey:@"pushId"];
    [dic setObject:@(startNum) forKey:@"startNum"];
    [dic setObject:@(getNum) forKey:@"getNum"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appMassMessagesUserList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;

    
}

//群发随访已回复联系人列表
+(AFHTTPRequestOperation*)appFollowMessagesUserListtRequest:(int)pushId
                                                   startNum:(int)startNum
                                                     getNum:(int)getNum
                                                  completed:(completedBlock)completed{
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(pushId) forKey:@"pushId"];
    [dic setObject:@(startNum) forKey:@"startNum"];
    [dic setObject:@(getNum) forKey:@"getNum"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appFollowMessagesUserList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;

}

//5.77分类医生列表
+(AFHTTPRequestOperation*)appNotedDrUserListRequest:(int)startNum
                                             getNum:(int)getNum
                                          completed:(completedBlock)completed{

    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@(startNum) forKey:@"startNum"];
    [dic setObject:@(getNum) forKey:@"getNum"];
    NSDictionary* parameters = [AFNHttpRequest getNormalParameters:dic
                                                            method:@"appNotedDrUserList"];
    AFHTTPRequestOperation* operation = [AFNHttpRequest getNormalOperation:[self getHttpUrl] parameters:parameters completed:completed];
    return operation;

}


#if OpenScoket
+(NSDictionary*)getIMNormalParameter
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    NSString* appId = [OpenUDID value];
    [dic setObject:appId?appId:@"" forKey:@"appId"];
    [dic setObject:@(1) forKey:@"appType"];
    if([MyUserInfo myInfo].channelId)
    {
        [dic setObject:[MyUserInfo myInfo].channelId forKey:@"channelId"];
    }
    if([MyUserInfo myInfo].tokenId)
    {
        [dic setObject:[MyUserInfo myInfo].tokenId forKey:@"tokenId"];
    }
    else
    {
        [dic setObject:@"" forKey:@"tokenId"];
    }
    return dic;
}

+(BOOL)appConnectIM
{
    if([IMSessionRequest shareInstance].isOnline)
        return YES;
    
    NSDictionary* dic = [AFNHttpRequest getIMNormalParameter];
    BOOL flag = [[IMSessionRequest shareInstance] connect:IMSERVER port:IMPORT];
    if(flag)
    {
        NSLog(@"IM连接成功");
        [IMSessionRequest shareInstance].userInfo = dic;
        [AFNHttpRequest appSendCLR:^(NSDictionary *response, BOOL isSuccess, int errorCode, NSString *errorMsg) {
            
        }];
    }
    return flag;
}

+(void)appDisconnectIM
{
    [[IMSessionRequest shareInstance] disconnect];
}

+(void)appIMClean
{
    
}

+(BOOL)appIsConnected
{
    return [IMSessionRequest shareInstance].isOnline;
}

+(void)appSendCLR:(completedBlock)completed
{
    NSDictionary* dic = [AFNHttpRequest getIMNormalParameter];
    [[IMSessionRequest shareInstance] sendRequest:1 data:dic completed:^(int cmdType, NSDictionary *dictionary, BOOL isSuccess) {
        if(isSuccess)
        {
            NSLog(@"IM登录验证成功");
        }
        else
        {
            NSString* reqId = [dictionary objectWithKey:@"reqId"];
            NSLog(@"IM登录验证失败,reqId = %@",reqId);
            dispatch_async(dispatch_get_main_queue(), ^{
                [AFNHttpRequest appDisconnectIM];
            });
        }
    }];
}

//+(void)appSendDWR:(completedBlock)completed
//{
//    NSDictionary* dic = [AFNHttpRequest getIMNormalParameter];
//    [[IMSessionRequest shareInstance] sendRequest:3 data:dic completed:^(int cmdType, NSDictionary *dictionary, BOOL finished) {
//        
//    }];
//}

+(void)appSendSCR:(NSDictionary*)dic completed:(completedBlock)completed
{
    [[IMSessionRequest shareInstance] sendRequest:5 data:dic completed:^(int cmdType, NSDictionary *response, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(finished)
            {
                if(completed)
                {
                    completed(response, YES, NoError, nil);
                }
            }
            else
            {
                int errorCode = [response intWithKey:xErrorCodeKey];
                NSString* errorMsg = [response objectWithKey:xErrorMsgKey];
                if(completed)
                {
                    completed(nil, NO, errorCode, errorMsg);
                }
                
            }
        });
    }];
}
#endif

@end
