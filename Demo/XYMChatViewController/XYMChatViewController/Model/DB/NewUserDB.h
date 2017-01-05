//
//  NewUserDB.h
//  healthcoming
//
//  Created by Franky on 16/2/24.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EUserInfo;
@interface KUserInfo : NSObject

@property (nonatomic,assign) int userId;
@property (nonatomic,assign) BOOL isNewP;
@property (nonatomic,assign) BOOL isNewF;

@end

@interface NewUserDB : NSObject

+(NewUserDB *)shareInstance;
-(void)openDBWithUserID:(int)userId;
-(BOOL)replaceWithUserInfo:(KUserInfo *)userInfo;
-(BOOL)insertWithUserInfo:(KUserInfo*)info;
-(void)getIsNewUser:(EUserInfo*)info;
-(BOOL)updateWithUserInfo:(KUserInfo*)info;
-(void)closeDB;
-(void)deleteUserInfo:(NSString *)uid;;

-(NSArray *)getAllNewUserByHY; ///> 新用户
-(BOOL)isUserInfoExist:(int)userId;

//是不是申请过
-(int)isFollowed:(NSString*)nUID;
//看这个用户在不在表里
-(int)isExitInNewUser:(NSString*)info;
@end
