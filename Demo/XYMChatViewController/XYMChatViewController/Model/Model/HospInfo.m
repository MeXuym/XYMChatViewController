//
//  HospInfo.m
//  healthcoming
//
//  Created by Franky on 15/8/7.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "HospInfo.h"

@implementation HospInfo

-(id)initWithDic:(NSDictionary *)dic
{
    if(self = [super init])
    {
        self.hpId = [dic intWithKey:@"hospitalId"];
        self.hpName = [dic objectWithKey:@"hospitalName"];
        self.areaid = [dic intWithKey:@"areaid"];
        self.province = [dic objectWithKey:@"province"];
        self.city = [dic objectWithKey:@"city"];
        self.area = [dic objectWithKey:@"area"];
        self.hospitalAddress = [dic objectWithKey:@"hospitalAddress"];
        self.phoneNo = [dic objectWithKey:@"phoneNo"];
        self.mapX = [dic doubleWithKey:@"mapX"];
        self.mapY = [dic doubleWithKey:@"mapY"];
        self.appUrl = [dic objectWithKey:@"appUrl"];
    }
    return self;
}

- (NSString*)description {
    NSMutableString *tmp = [[NSMutableString alloc] init];
    [tmp appendFormat:@"%@" ,@(self.hpId)];
    [tmp appendFormat:@"%@" ,self.hpName];
    [tmp appendFormat:@"%@" ,self.province];
    [tmp appendFormat:@"%@" ,self.city];
    [tmp appendFormat:@"%@" ,self.area];
    [tmp appendFormat:@"%@" ,self.hospitalAddress];
    [tmp appendFormat:@"%@" ,self.phoneNo];
    [tmp appendFormat:@"%@" ,@(self.mapX)];
    [tmp appendFormat:@"%@" ,@(self.mapY)];
    [tmp appendFormat:@"%@" ,self.appUrl];
    return tmp;
}

- (BOOL)isEqual:(HospInfo*)object {
    return [self.description isEqual:object.description];
}

@end
