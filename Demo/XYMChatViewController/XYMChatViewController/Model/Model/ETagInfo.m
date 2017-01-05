//
//  ETagInfo.m
//  healthcoming
//
//  Created by Franky on 15/8/27.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "ETagInfo.h"

@implementation ETagInfo

@synthesize isUser,isSys,laberId,laberName;
//@synthesize laberName;

-(id)initWithDic:(NSDictionary*)dic
{
    if(self = [super init])
    {
        self.isUser = [dic intWithKey:@"isUser"];
        self.isSys = [dic intWithKey:@"isSys"];
        self.laberId = [dic intWithKey:@"laberId"];
        self.type = [dic intWithKey:@"laberType"];
        NSString* str = [dic objectWithKey:@"laberName"];
        if(str)
        {
            str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            laberName = str;
//            self.laberName = str;
        }
    }
    return self;
}

//重写get方法
//-(NSString *)laberName{
//    
//    return laberName;
//}

-(NSDictionary *)getCurrentDic
{
    return @{@"laberName":laberName,@"laberId":@(laberId),@"isSys":@(isSys),@"isUser":@(isUser)};
//    return @{@"laberName":self.laberName};
}



@end
