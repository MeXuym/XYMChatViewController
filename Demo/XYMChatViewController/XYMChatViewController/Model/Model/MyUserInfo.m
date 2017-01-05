//
//  MyUserInfo.m
//  healthcoming
//
//  Created by Franky on 15/8/6.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "MyUserInfo.h"
#import "NSData+MD5.h"

static MyUserInfo* info;

@implementation MyUserInfo
{
    BOOL hasClean;
    NSMutableDictionary* modifyDic;
}

//@synthesize userId,phoneNo,userName,hospitalId,hospitalName,titleName,officeId,titleId,officeName,skilldesc,userPhoto,userPhotoKey,workCertKey,workCert,checkType,tokenId,channelId;
@synthesize userId,phoneNo,userName,hospitalId,hospitalName,titleName,officeId,titleId,officeName,skilldesc,userPhoto,userPhotoKey,workCertKey,workCert,checkType,tokenId,channelId,isActivityDrShare;

+(MyUserInfo *)myInfo
{
    @synchronized(self)
    {
        if(!info)
        {
            NSString *fileName = [MyUserInfo getFilePath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:fileName])
            {
                info = [[MyUserInfo alloc] init];
            }
            else
            {
                NSData *data = [[NSData alloc] initWithContentsOfFile:[self getFilePath]];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                info = [unarchiver decodeObject];
            }
        }
        return info;
    }
}

-(id)init
{
    if(self = [super init])
    {
        modifyDic = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate2:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    MyUserInfo *info = [MyUserInfo allocWithZone:zone];
    NSDictionary *dic = [self getInfoDic];
    [info updateWithDic:dic];
    return info;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:userName forKey:@"userName"];
    [encoder encodeInt:userId forKey:@"userId"];
    [encoder encodeObject:phoneNo forKey:@"phoneNo"];
    [encoder encodeInt:hospitalId forKey:@"hospitalId"];
    [encoder encodeObject:hospitalName forKey:@"hospitalName"];
    [encoder encodeObject:titleName forKey:@"titleName"];
    [encoder encodeInt:officeId forKey:@"officeId"];
    [encoder encodeInt:titleId forKey:@"titleId"];
    [encoder encodeObject:workCert forKey:@"cert"];
    [encoder encodeObject:workCertKey forKey:@"workCertKey"];
    [encoder encodeObject:officeName forKey:@"officeName"];
    [encoder encodeObject:skilldesc forKey:@"skilldesc"];
    [encoder encodeObject:userPhoto forKey:@"userPhoto"];
    [encoder encodeObject:userPhotoKey forKey:@"userPhotoKey"];
    [encoder encodeInt:checkType forKey:@"checkType"];
    [encoder encodeObject:tokenId forKey:@"tokenId"];
    [encoder encodeObject:channelId forKey:@"channelId"];
    
    //健康锦囊
    [encoder encodeInt:isActivityDrShare forKey:@"isActivityDrShare"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [self init]) {
        userName = [decoder decodeObjectForKey:@"userName"];
        userId = [decoder decodeIntForKey:@"userId"];
        phoneNo = [decoder decodeObjectForKey:@"phoneNo"];
        hospitalId = [decoder decodeIntForKey:@"hospitalId"];
        hospitalName = [decoder decodeObjectForKey:@"hospitalName"];
        titleName = [decoder decodeObjectForKey:@"titleName"];
        officeId = [decoder decodeIntForKey:@"officeId"];
        titleId = [decoder decodeIntForKey:@"titleId"];
        officeName = [decoder decodeObjectForKey:@"officeName"];
        workCert = [decoder decodeObjectForKey:@"cert"];
        workCertKey = [decoder decodeObjectForKey:@"workCertKey"];
        skilldesc = [decoder decodeObjectForKey:@"skilldesc"];
        userPhoto = [decoder decodeObjectForKey:@"userPhoto"];
        userPhotoKey = [decoder decodeObjectForKey:@"userPhotoKey"];
        checkType = [decoder decodeIntForKey:@"checkType"];
        tokenId = [decoder decodeObjectForKey:@"tokenId"];
        channelId = [decoder decodeObjectForKey:@"channelId"];
        
        //健康锦囊
        isActivityDrShare = [decoder decodeIntForKey:@"isActivityDrShare"];
    }
    return self;
}

-(void)appWillTerminate2:(NSNotification*)notification
{
    [self saveInfo];
    [self cleanData];
}

+(NSString*)getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *fileName = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"userInfo.plist"];
    return fileName;
}

-(void)updateWithDic:(NSDictionary *)dic
{
    userId = [dic intWithKey:@"userId"];
    userName = [dic objectWithKey:@"userName"];
    phoneNo = [dic objectWithKey:@"phoneNo"];
    userPhoto = [dic objectWithKey:@"userPhoto"];
    officeId = [dic intWithKey:@"officeId"];
    officeName = [dic objectWithKey:@"officeName"];
    titleId = [dic intWithKey:@"titleId"];
    titleName = [dic objectWithKey:@"titleName"];
    workCert = [dic objectWithKey:@"cert"];
    checkType = [dic intWithKey:@"checkType"];
    skilldesc = [dic objectWithKey:@"skill"];
    hospitalId = [dic intWithKey:@"hospitalId"];
    hospitalName = [dic objectWithKey:@"hospitalName"];
    NSString* str2 = [dic objectWithKey:@"otherHospitalName"];
    if(str2 && !hospitalName)
    {
        hospitalName = str2;
    }
    
    self.areaId = [dic intWithKey:@"areaId"];
    self.province = [dic objectWithKey:@"province"];
    self.city = [dic objectWithKey:@"city"];
    self.area = [dic objectWithKey:@"area"];
    self.userPhotobag = [dic objectWithKey:@"userPhotobag"];
    self.userNicename = [dic objectWithKey:@"userNicename"];
    self.address = [dic objectWithKey:@"address"];
    self.mapX = [dic doubleWithKey:@"mapX"];
    self.mapY = [dic doubleWithKey:@"mapY"];
    self.checkAsk = [dic objectWithKey:@"checkAsk"];
    self.evaLevel = [dic doubleWithKey:@"evaLevel"];
    self.orCodeUrl = [dic objectWithKey:@"orCodeUrl"];
    
    //健康锦囊
    self.isActivityDrShare = [dic intWithKey:@"isActivityDrShare"];
}

-(void)saveInfo
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:info];
    [archiver finishEncoding];
    [data writeToFile:[MyUserInfo getFilePath] atomically:YES];
    NSLog(@"MyUserInfo save");
}

-(NSDictionary*)getInfoDic
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if(userName)
    {
        [dic setObject:userName forKey:@"userName"];
    }
    if(hospitalId > 0)
    {
        [dic setObject:@(hospitalId) forKey:@"hospitalId"];
    }
    else if(hospitalName)
    {
        [dic setObject:hospitalName forKey:@"otherHospitalName"];
    }
    if(self.address)
    {
        [dic setObject:self.address forKey:@"address"];
    }
    if(self.mapX > 0)
    {
        [dic setObject:@(self.mapX) forKey:@"mapX"];
    }
    if(self.mapY > 0)
    {
        [dic setObject:@(self.mapY) forKey:@"mapY"];
    }
    if(userPhotoKey)
    {
        [dic setObject:userPhotoKey forKey:@"userPhoto"];
    }
    [dic setObject:@(officeId) forKey:@"officeId"];
    if(titleId > 0)
    {
        [dic setObject:@(titleId) forKey:@"titleId"];
    }

    if(workCertKey)
    {
        [dic setObject:workCertKey forKey:@"cert"];
    }if(skilldesc)
    {
        [dic setObject:skilldesc forKey:@"skill"];
    }
    //健康锦囊
    if(isActivityDrShare)
    {
        [dic setObject:@(isActivityDrShare) forKey:@"isActivityDrShare"];
    }

    
    return dic;
}

-(void)deleteInfo
{
    NSString* path = [MyUserInfo getFilePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path])
    {
        [fm removeItemAtPath:path error:nil];
    }
    [self cleanData];
}

-(void)cleanData
{
    if(hasClean)
        return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    userId = 0;
    userName = nil;
    tokenId = nil;
    checkType = 0;
    hospitalName = nil;
    titleName = nil;
    officeName = nil;
    userPhoto = nil;
    userPhotoKey = nil;
    workCert = nil;
    workCertKey = nil;
    skilldesc = nil;
    
    self.userPhotobag = nil;
    self.orCodeUrl = nil;
    self.myHosInfo = nil;
    self.oldHospInfo = nil;
    hasClean = YES;
    info = nil;
    NSLog(@"MyUserInfo clean");
}

-(void)dealloc
{
    [self cleanData];
}

- (NSData*)encode {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:info];
    [archiver finishEncoding];
    return data;
}

//MD5加密
- (BOOL)isEqual:(MyUserInfo*)object {
    return [[[self encode] MD5] isEqualToString:[[object encode] MD5]];
}

@end
