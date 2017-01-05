//
//  IMSessionRequest.h
//  healthcoming
//
//  Created by Franky on 15/12/10.
//  Copyright © 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const xErrorMsgKey = @"errorMsg";
static NSString *const xErrorCodeKey = @"errorCode";

typedef void(^IMCompletedBlock)(int cmdType, NSDictionary* response, BOOL isSuccess);

@interface IMSessionRequest : NSObject

@property (nonatomic, assign, readonly) BOOL isOnline;
@property (nonatomic, assign) NSTimeInterval IMTimeout;
@property (nonatomic, retain) NSDictionary* userInfo;

+(IMSessionRequest*)shareInstance;

-(BOOL)connect:(NSString *)hostName port:(int)port;
-(void)disconnect;

-(void)sendRequest:(int)cmd data:(NSDictionary*)data completed:(IMCompletedBlock)completed;
-(void)sendRequest:(int)cmd data:(NSDictionary*)data;

@end
