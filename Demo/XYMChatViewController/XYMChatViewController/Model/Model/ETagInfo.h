//
//  ETagInfo.h
//  healthcoming
//
//  Created by Franky on 15/8/27.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ETagInfoTypePreg = 1,//孕妇
    ETagInfoTypeChild,//儿童
    ETagInfoTypeHD,//高血压、糖尿病
} ETagInfoType;

@interface ETagInfo : NSObject

@property (nonatomic,assign) BOOL isUser;
@property (nonatomic,assign) BOOL isSys;
@property (nonatomic,assign) int laberId;
@property (nonatomic,retain) NSString* laberName;
@property (nonatomic,assign) int type;

-(id)initWithDic:(NSDictionary*)dic;
-(NSDictionary*)getCurrentDic;

@end
