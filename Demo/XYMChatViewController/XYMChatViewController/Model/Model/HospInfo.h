//
//  HospInfo.h
//  healthcoming
//
//  Created by Franky on 15/8/7.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HospInfo : NSObject

@property (nonatomic,assign) int hpId;
@property (nonatomic,retain) NSString* hpName;
@property (nonatomic,assign) int areaid;
@property (nonatomic,retain) NSString* province;
@property (nonatomic,retain) NSString* city;
@property (nonatomic,retain) NSString* area;
@property (nonatomic,retain) NSString* hospitalAddress;
@property (nonatomic,retain) NSString* phoneNo;
@property (nonatomic,retain) NSString* hpDesc;
@property (nonatomic,retain) NSString* hpLogoUrl;
@property (nonatomic,assign) double mapX;
@property (nonatomic,assign) double mapY;
@property (nonatomic,retain) NSString* appUrl;

-(id)initWithDic:(NSDictionary*)dic;

@end
