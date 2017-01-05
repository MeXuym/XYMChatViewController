//
//  AcuDeviceHardware.m
//  AcuConference
//
//  Created by Aculearn on 10/31/13.
//  Copyright (c) 2013 aculearn. All rights reserved.
//

#import "CommonOperation.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <CoreText/CoreText.h>

@implementation CommonOperation

#if 0
SMutableDictionary *devices = [[NSMutableDictionary alloc] init];
[devices setObject:@"simulator"                     forKey:@"i386"];
[devices setObject:@"iPod Touch"                    forKey:@"iPod1,1"];
[devices setObject:@"iPod Touch Second Generation"  forKey:@"iPod2,1"];
[devices setObject:@"iPod Touch Third Generation"   forKey:@"iPod3,1"];
[devices setObject:@"iPod Touch Fourth Generation"  forKey:@"iPod4,1"];
[devices setObject:@"iPhone"                        forKey:@"iPhone1,1"];
[devices setObject:@"iPhone 3G"                     forKey:@"iPhone1,2"];
[devices setObject:@"iPhone 3GS"                    forKey:@"iPhone2,1"];
[devices setObject:@"iPad"                          forKey:@"iPad1,1"];
[devices setObject:@"iPad 2"                        forKey:@"iPad2,1"];
[devices setObject:@"iPhone 4"                      forKey:@"iPhone3,1"];
[devices setObject:@"iPhone 4S"                     forKey:@"iPhone4"];
[devices setObject:@"iPhone 5"                      forKey:@"iPhone5"];

- (NSString *) getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [devices objectForKey:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
}

- (NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    if ([sDeviceModel isEqual:@"i386"])      return @"Simulator";  //iPhone Simulator
    if ([sDeviceModel isEqual:@"iPhone1,1"]) return @"iPhone1G";   //iPhone 1G
    if ([sDeviceModel isEqual:@"iPhone1,2"]) return @"iPhone3G";   //iPhone 3G
    if ([sDeviceModel isEqual:@"iPhone2,1"]) return @"iPhone3GS";  //iPhone 3GS
    if ([sDeviceModel isEqual:@"iPhone3,1"]) return @"iPhone3GS";  //iPhone 4 - AT&T
    if ([sDeviceModel isEqual:@"iPhone3,2"]) return @"iPhone3GS";  //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone3,3"]) return @"iPhone4";    //iPhone 4 - Other carrier
    if ([sDeviceModel isEqual:@"iPhone4,1"]) return @"iPhone4S";   //iPhone 4S
    if ([sDeviceModel isEqual:@"iPod1,1"])   return @"iPod1stGen"; //iPod Touch 1G
    if ([sDeviceModel isEqual:@"iPod2,1"])   return @"iPod2ndGen"; //iPod Touch 2G
    if ([sDeviceModel isEqual:@"iPod3,1"])   return @"iPod3rdGen"; //iPod Touch 3G
    if ([sDeviceModel isEqual:@"iPod4,1"])   return @"iPod4thGen"; //iPod Touch 4G
    if ([sDeviceModel isEqual:@"iPad1,1"])   return @"iPadWiFi";   //iPad Wifi
    if ([sDeviceModel isEqual:@"iPad1,2"])   return @"iPad3G";     //iPad 3G
    if ([sDeviceModel isEqual:@"iPad2,1"])   return @"iPad2";      //iPad 2 (WiFi)
    if ([sDeviceModel isEqual:@"iPad2,2"])   return @"iPad2";      //iPad 2 (GSM)
    if ([sDeviceModel isEqual:@"iPad2,3"])   return @"iPad2";      //iPad 2 (CDMA)
    
    NSString *aux = [[sDeviceModel componentsSeparatedByString:@","] objectAtIndex:0];
    
    //If a newer version exist
    if ([aux rangeOfString:@"iPhone"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] intValue];
        if (version == 3) return @"iPhone4"
            if (version >= 4) return @"iPhone4s";
        
    }
    if ([aux rangeOfString:@"iPod"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPod" withString:@""] intValue];
        if (version >=4) return @"iPod4thGen";
    }
    if ([aux rangeOfString:@"iPad"].location!=NSNotFound) {
        int version = [[aux stringByReplacingOccurrencesOfString:@"iPad" withString:@""] intValue];
        if (version ==1) return @"iPad3G";
        if (version >=2) return @"iPad2";
    }
    //If none was found, send the original string
    return sDeviceModel;
}
#endif


+(NSDictionary *)jsonToDictionary:(NSString *)json
{
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    return userInfo;
}

+(NSData *)dictionaryToJsonData:(NSDictionary *)dic
{
    NSData *commandData = [NSJSONSerialization dataWithJSONObject:dic
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];
    return commandData;
}

+ (NSString *) platformString
{
    
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
#if 0
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
#endif
    return platform;
}

+(BOOL)isValidateEmail:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//手机号码验证
+(BOOL)isValidateMobile:(NSString*)mobile
{
    //手机号以13， 15，17,18开头，八个 \d 数字字符
    //NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$";
    //11位数字
    NSString *phoneRegex =@"^\\d{11}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

//只能数字和字母
+(BOOL)isvalidate:(NSString*)value{
    NSString *phoneRegex =@"^[A-Za-z0-9]+$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:value];
}

//手机号码过滤
+(NSString*)replaceStr:(NSString *)phonenum
{
    NSString *num=phonenum;
    num=[num stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    num=[num stringByReplacingOccurrencesOfString:@"-" withString:@""];
    num=[num stringByReplacingOccurrencesOfString:@" (" withString:@""];
    num=[num stringByReplacingOccurrencesOfString:@") " withString:@""];
    num=[num stringByReplacingOccurrencesOfString:@"(" withString:@""];
    num=[num stringByReplacingOccurrencesOfString:@")" withString:@""];
    num=[num stringByReplacingOccurrencesOfString:@" " withString:@""];
    return num;
}

+(void)checkTableUpdateWithClassName:(NSString *)className block:(BOOL(^)())block
{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DBList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *version1=[data objectForKey:className];
    NSString *version2 = [[NSUserDefaults standardUserDefaults] objectForKey:className];
    
    if (!version2 || ![version2 isEqual:version1])
    {//需要删除旧表
        if(block())
        {
            if(version1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:version1 forKey:className];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
        }
    }
}

+(void)checkDBDeleteWithClassName:(NSString *)className path:(NSString*)path
{
    //plist资源
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DBList" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *version1=[data objectForKey:className];
    NSString *version2 = [[NSUserDefaults standardUserDefaults] objectForKey:className];
    
    if (!version2 || ![version2 isEqual:version1])
    {//需要删除旧数据库
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:path])
        {
            [fileManager removeItemAtPath:path error:nil];
        }
        if(version1)
        {
            [[NSUserDefaults standardUserDefaults] setObject:version1 forKey:className];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+(void)TimeOutCount:(int)timeOut event:(void(^)(int timeout))event completed:(void(^)(void))completed
{
    __block int timeout=timeOut; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                if(completed){
                    completed();
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                if(event){
                    event(timeout);
                }
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

#pragma mark 具体跳转操作(公共方法)
+(void)gotoViewController:(UIViewController*)controller
{
    UIViewController* nav = [CommonOperation getCurrectNavigationController];
    if(!nav)
        return;
    
    if([nav isKindOfClass:[UINavigationController class]])
    {
        if(nav.presentedViewController)
        {
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
        [((UINavigationController*)nav) pushViewController:controller animated:YES];
    }
    else
    {
        [nav presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark 获取当前UINavigationController
+(UIViewController*)getCurrectNavigationController
{
    UIViewController *result;
    UIWindow *topWindow = [[UIApplication sharedApplication].delegate window];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    if ([nextResponder isKindOfClass:[UINavigationController class]])
    {
        result = nextResponder;
    }
    else if([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
    {
        result = topWindow.rootViewController;
    }
    else
    {
        NSLog(@"找不到根页面");
    }
    return result;
}

+(NSString*)stringWithGUID
{
    CFUUIDRef guidObj = CFUUIDCreate(nil);
    NSString *guidString = CFBridgingRelease(CFUUIDCreateString(nil, guidObj));
    CFRelease(guidObj);
    return guidString;
}

+(int)startCount
{
    NSString* key=[NSString stringWithFormat:@"startcount_version%@",appversion];
    
    int startcount=[((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:key]) intValue];
    
    return startcount;
}

+(int)addStartCount
{
    NSString* key=[NSString stringWithFormat:@"startcount_version%@",appversion];
    
    int startcount=[((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:key]) intValue];
    startcount++;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:startcount] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return startcount;
}

///> 根据每个版本的版本号来判断是否需要添加引导图判断;
+(int)addStartCount:(int)type
{
    NSString* key=[NSString stringWithFormat:@"start%dcount_version%@",type,appversion];
    
    int startcount=[((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:key]) intValue];
    startcount++;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:startcount] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return startcount;
}

@end
