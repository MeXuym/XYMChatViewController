//
//  CUserInfoDB.h
//  healthcoming
//
//  Created by Franky on 16/3/10.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUserInfo.h"

@interface CUserInfoDB : NSObject

+(CUserInfoDB *)shareInstance;
-(void)openDBWithUserID:(int)userId;
-(void)deleteTable;
-(BOOL)replaceWithUserInfo:(EUserInfo *)userInfo;
-(BOOL)insertWithUserInfo:(EUserInfo*)userInfo;
-(BOOL)updateWithUserInfo:(EUserInfo*)userInfo;
-(void)deleteUserInfo:(NSString *)uid;
-(EUserInfo*)selectUserInfoById:(NSString*)uid;
//新加一个方法，用来取会话列表的标签数据
-(EUserInfo*)selectUserInfoByIdForIM:(NSString*)uid;
-(NSArray*)selectUserInfoByGroupId:(int)groupId;
-(NSMutableArray *)selectAllUserInfo;
-(NSArray *)getAllNewUser;
//得到全部人数
-(NSUInteger)selectAllUserCount;
//查看他在不在这里表
- (int)isExitInCUser:(NSString*)nUID;

-(NSArray *)getAllNewUserByHY;

-(void)closeDB;

@end
