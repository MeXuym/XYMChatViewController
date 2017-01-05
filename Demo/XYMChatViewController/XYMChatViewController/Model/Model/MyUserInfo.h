//
//  MyUserInfo.h
//  healthcoming
//
//  Created by Franky on 15/8/6.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HospInfo.h"

@interface MyUserInfo : NSObject<NSCoding,NSMutableCopying>

@property(nonatomic,assign) int userId;
@property(nonatomic,strong) NSString* userName;
@property(nonatomic,strong) NSString* phoneNo;
@property(nonatomic,assign) int hospitalId;
@property(nonatomic,strong) NSString* hospitalName;
@property(nonatomic,assign) int officeId;//科室ID
@property(nonatomic,strong) NSString* officeName;
@property(nonatomic,assign) int titleId;//职称ID
@property(nonatomic,strong) NSString* titleName;
@property(nonatomic,strong) NSString* skilldesc;

@property(nonatomic,strong) NSString* userPhoto;
@property(nonatomic,strong) NSString* userPhotoKey;
@property(nonatomic,strong) NSString* workCert;
@property(nonatomic,strong) NSString* workCertKey;

@property(nonatomic,assign) int checkType; //0未认证1认证2认证未通过3审核中
@property(nonatomic,strong) NSString* tokenId;
@property(nonatomic,strong) NSString* channelId;//推送标识

@property(nonatomic,strong) NSString* province;
@property(nonatomic,strong) NSString* city;
@property(nonatomic,assign) int areaId;
@property(nonatomic,strong) NSString* area;
@property(nonatomic,strong) NSString* userPhotobag;
@property(nonatomic,strong) NSString* userNicename;
@property(nonatomic,strong) NSString* address;
@property(nonatomic,assign) double mapX;
@property(nonatomic,assign) double mapY;
@property(nonatomic,strong) NSString* checkAsk;
@property(nonatomic,strong) NSString* birthday;
@property(nonatomic,assign) double evaLevel;
@property(nonatomic,strong) NSString* orCodeUrl;

//是否显示健康锦囊：0 不显示，1 显示
@property(nonatomic,assign) int isActivityDrShare;

@property(nonatomic,strong) HospInfo* myHosInfo;

@property(nonatomic,strong) HospInfo* oldHospInfo;

+(MyUserInfo*)myInfo;

-(void)updateWithDic:(NSDictionary*)dic;

-(void)saveInfo;
-(NSDictionary*)getInfoDic;
-(void)deleteInfo;

@end
