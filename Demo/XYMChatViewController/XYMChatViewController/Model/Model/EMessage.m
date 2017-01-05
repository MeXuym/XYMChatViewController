//
//  EMessage.m
//  MCUTest
//
//  Created by Administrators on 15/6/1.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import "EMessage.h"
#import "CommonOperation.h"

@implementation EMessage

-(id)initWithDic:(NSDictionary *)dic
{
    if(self = [super init])
    {
        [self getSelfStringGUID];
        self.sessionId = [dic intWithKey:@"sessionId"];
        int userId = [dic intWithKey:@"userId"];
        self.friends_UID = [NSString stringWithFormat:@"%d",userId];
        self.userName = [dic objectWithKey:@"userName"];
        self.rem = [dic objectWithKey:@"rem"];
        self.content = [dic objectWithKey:@"consultContent"];
        self.createTime = [dic objectWithKey:@"createTime"];
        self.time = [NSDate dateWithDateString:self.createTime].timeIntervalSince1970;
        self.consultId = [dic intWithKey:@"consultId"];
        
        int fileType = [dic intWithKey:@"fileType"];
        self.messageType = fileType > 0?fileType:4;

        NSString* userPhoto = [dic objectWithKey:@"userPhoto"];
        NSString* userPhotobag = [dic objectWithKey:@"userPhoto"];
        NSString* userNicename = [dic objectWithKey:@"userNicename"];
        
        
        //患者标签的相关数据
        self.labers = [dic objectWithKey:@"laber"];
        self.archivesLaber = [dic objectWithKey:@"archivesLaber"];
        self.motherArchives = [dic objectWithKey:@"motherArchives"];
        self.childArchives = [dic objectWithKey:@"childArchives"];
        self.hdArchives = [dic objectWithKey:@"hdArchives"];

        
        NSMutableDictionary* myData = [NSMutableDictionary dictionary];
        if(userPhoto)
        {
            [myData setObject:userPhoto forKey:@"userPhoto"];
        }
        if(userPhotobag)
        {
            [myData setObject:userPhotobag forKey:@"userPhotobag"];
        }
        if(userNicename)
        {
            [myData setObject:userNicename forKey:@"userNicename"];
        }
        
        if(self.messageType == 1)
        {
            NSMutableDictionary* picDic = [NSMutableDictionary dictionary];
            if(self.content)
            {
                [picDic setObject:self.content forKey:DSamllPic];
            }
            NSString* contentPhoto = [dic objectWithKey:@"contentPhoto"];
            if(contentPhoto)
            {
                [picDic setObject:contentPhoto forKey:DLargePic];
            }
            self.picUrls = picDic;
        }
        else if (self.messageType == 2)
        {
            [myData setObject:self.content forKey:DVoiceUrl];
        }
        else if (self.messageType == 6)
        {
            NSDictionary* follow = [dic objectWithKey:@"follow"];
            if(follow && [follow isKindOfClass:[NSDictionary class]])
            {
                [myData setValuesForKeysWithDictionary:follow];
            }
        }else if (self.messageType == 7 || self.messageType == 8 || self.messageType == 9) { // 健教分享  加一个优惠券的
            NSDictionary* share = [dic objectWithKey:@"share"];
            if(share && [share isKindOfClass:[NSDictionary class]])
            {
                [myData setValuesForKeysWithDictionary:share];
            }
        }
        
        self.otherData = myData;
    }
    return self;
}

-(void)getSelfStringGUID
{
    self.guid = [CommonOperation stringWithGUID];
}

-(NSString *)showName
{
    if(self.rem && self.rem.length > 0)
    {
        return self.rem;
    }
    return self.userName;
}

@end
