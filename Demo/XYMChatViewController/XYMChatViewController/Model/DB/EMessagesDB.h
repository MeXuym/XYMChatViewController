//
//  EMessagesDB.h
//  MCUTest
//
//  Created by Administrators on 15/6/1.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMessage.h"

@interface EMessagesDB : NSObject

+(EMessagesDB *)shareInstance;
-(void)openDBWithUserID:(NSString*)nUserId block:(void(^)(void))callback;
-(BOOL)insertWithMessage:(EMessage *)message consultId:(int)consultId isNotifaction:(BOOL)flag;
-(BOOL)insertWithMessage:(EMessage *)message;
-(BOOL)insertWithMessage:(EMessage *)message isNotifaction:(BOOL)flag;
-(void)updateWithMessage:(EMessage *)message;
-(void)updateWithMessage:(EMessage *)message isNotifaction:(BOOL)flag;
-(void)setMessageStateWithIsRead:(NSString*)friends_UID isRead:(BOOL)isRead;
-(void)deleteAllMessage:(NSString*)friends_UID;
-(BOOL)deleteMessage:(NSString*)friends_UID guid:(NSString*)guid;
-(void)deleteAllTable;
-(NSArray *)selectMessageWithPage:(NSString*)friends_UID page:(int)page;
-(EMessage*)getLastMessage:(NSString*)friends_UID;
-(int)getUnReadCountWithUID:(NSString *)myUID friends_UID:(NSString*)friends_UID;
-(NSArray*)getUnSendedMessages:(NSString*)friends_UID;
-(NSArray *)getImageTypeMessages:(NSString*)friends_UID;
-(void)closeDB;

@end
