//
//  EUserInfo.h
//  healthcoming
//
//  Created by Franky on 15/8/6.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EUserInfo : NSObject

@property(nonatomic,retain) NSString* nUID;
@property(nonatomic,retain) NSString* userName;
@property(nonatomic,assign) int groupId;
@property(nonatomic,retain) NSString* userPhoto;
@property(nonatomic,retain) NSString* userPhotobag;
@property(nonatomic,retain) NSString* phoneNo;
@property(nonatomic,assign) int patientSex;
@property(nonatomic,retain) NSString* birthday;
@property(nonatomic,assign) int age;
@property(nonatomic,assign) int patientIsMarry;
@property(nonatomic,retain) NSArray* labers;
@property(nonatomic,retain) NSArray* patientLaber;

@property(nonatomic,retain) NSArray* archivesLaber;
@property(nonatomic,retain) NSArray* motherArchives;
@property(nonatomic,retain) NSArray* childArchives;
@property(nonatomic,retain) NSArray* hdArchives;

@property(nonatomic,retain) NSString* address;
@property(nonatomic,retain) NSString* patientTxt;
@property(nonatomic,retain) NSString* rem;

@property(nonatomic,retain) NSString* information;
@property(nonatomic,retain) NSString* patientHis;
@property(nonatomic,retain) NSString* showName;

@property(nonatomic,assign) BOOL isSelected;
@property(nonatomic,assign) BOOL isNewP;
@property(nonatomic,assign) BOOL isNewF;
@property(nonatomic,retain) NSString* pinyin;

@property(nonatomic,retain) NSArray* otherTag;
@property(nonatomic,retain) NSArray* archivesLaber2;
@property(nonatomic,retain) NSArray* motherArchives2;
@property(nonatomic,retain) NSArray* childArchives2;
@property(nonatomic,retain) NSArray* hdArchives2;

//另外用来传给会话模型的labers2（直接转json的）
@property(nonatomic,retain) NSArray* labers2;

//新的预产标签数组
@property(nonatomic,retain) NSArray* motherDate2;

-(id)initWithDic:(NSDictionary *)dic;

@end

@interface MotherArchive : NSObject

@property (nonatomic,retain) NSString* motherDate; // 生孩子日期：计算孩子年龄
@property (nonatomic,retain) NSString* lastMen;    // 经期：统计怀孕多长时间
@property (nonatomic,retain) NSString* insHospital;
@property (nonatomic,assign) BOOL isPerCard;

@property (nonatomic,assign) int yunzhong; //0表示孕中，1表示产后
@property (nonatomic,assign) int chanhou;  //负数 绝对值为离生产天数，没有生产，正数:已产

@end

@interface ChildArchive : NSObject

@property (nonatomic,retain) NSString* childName;
@property (nonatomic,retain) NSString* birthday;
@property (nonatomic,retain) NSString* address;
@property (nonatomic,assign) int childSex;

@property (nonatomic,assign) int tianshu;
@property (nonatomic,assign) int nianling;

@end

@interface HdArchive : NSObject

@property (nonatomic,retain) NSString* hdName;
@property (nonatomic,retain) NSString* birthday;
@property (nonatomic,retain) NSString* sureDate;
@property (nonatomic,retain) NSString* medical;
@property (nonatomic,retain) NSString* otherMedical;

@end

@interface FollowUser : NSObject

@property (nonatomic,assign) int userId;
@property (nonatomic,retain) NSString* createTime;
@property (nonatomic,retain) NSString* showTime;

-(id)initWithDic:(NSDictionary *)dic;

@end
