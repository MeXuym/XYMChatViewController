//
//  AcuDeviceHardware.h
//  AcuConference
//
//  Created by Aculearn on 10/31/13.
//  Copyright (c) 2013 aculearn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonOperation : NSObject

+(NSDictionary*)jsonToDictionary:(NSString*)json;
+(NSData*)dictionaryToJsonData:(NSDictionary*)dic;
+(NSString *)platformString;
+(BOOL)isValidateEmail:(NSString*)email;
+(BOOL)isValidateMobile:(NSString*)mobile;
+(BOOL)isvalidate:(NSString*)value;
//手机号码过滤字符
+(NSString*)replaceStr:(NSString *)phonenum;
+(NSString*)stringWithGUID;
+(void)checkTableUpdateWithClassName:(NSString *)className block:(BOOL(^)())block;
+(void)checkDBDeleteWithClassName:(NSString *)className path:(NSString*)path;
+(void)TimeOutCount:(int)timeOut event:(void(^)(int timeout))event completed:(void(^)(void))completed;
+(void)gotoViewController:(UIViewController*)controller;
+(int)startCount;
+(int)addStartCount;
+(int)addStartCount:(int)type;

@end
