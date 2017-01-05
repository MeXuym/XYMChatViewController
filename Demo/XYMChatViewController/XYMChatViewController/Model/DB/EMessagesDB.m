//
//  EMessagesDB.m
//  MCUTest
//
//  Created by Administrators on 15/6/1.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import "EMessagesDB.h"
#import "FMDBHelper.h"
#import "CommonOperation.h"
#import "XYMMessageItemAdaptor.h"
#import "EUserInfo.h"
#import "CUserInfoDB.h"

static EMessagesDB *instance;

@implementation EMessagesDB
{
    NSMutableDictionary* tableDictionary;
    FMDBHelper* dbHelper;
}

+(EMessagesDB *)shareInstance
{
    @synchronized(self){
        if(!instance){
            instance = [[EMessagesDB alloc] init];
        }
        return instance;
    }
}

-(id)init
{
    if(self=[super init])
    {
    }
    return self;
}

-(void)dealloc
{
    [self closeDB];
}

-(void)openDBWithUserID:(NSString*)nUserId block:(void(^)(void))callback
{
    NSString *fileName = [NSString stringWithFormat:@"ChatMessageDB_%@.db",nUserId];
    
    NSLog(@"Message DBName:%@",fileName);
    
    NSString *fileDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    [CommonOperation checkDBDeleteWithClassName:@"EMessagesDB" path:fileDir];
    
    tableDictionary = [NSMutableDictionary dictionary];
    
    dbHelper = [[FMDBHelper alloc] initWithFileName:fileName];
    
    [dbHelper inDatabase:^(FMDatabase *db)
    {
        NSString* sqlstr = @"select name from sqlite_master where type='table' order by name;";
        FMResultSet *resultSet=[db executeQuery:sqlstr];
        while ([resultSet next])
        {
            NSString *name = [resultSet stringForColumn:@"name"];
            NSArray* temp = [name componentsSeparatedByString:@"_"];
            if(temp && temp >0)
            {
                NSString* nUserId = [temp objectAtIndex:1];
                [tableDictionary setObject:name forKey:nUserId];
            }
        }
        [resultSet close];
        
        if (callback) {
            callback();
        }
    }];
}

-(BOOL)isExistTable:(NSString*)friends_UID
{
    return [tableDictionary objectForKey:friends_UID] != nil;
}

-(BOOL)createTable:(NSString*)friends_UID
{
    if(!friends_UID)
        return NO;
    
    if(!dbHelper)
        return NO;
    
    if([self isExistTable:friends_UID])
        return YES;

    __block BOOL result = NO;
    
    NSString* tableName = [NSString stringWithFormat:@"EMessages_%@",friends_UID];
    
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(guid text primary key, myUID text,friends_UID text,group_ID text,content text,time text,messageType text,isSelf text,isRead text,isSend text,picUrls text,isGroup text,resource text,otherData text,userName text,sessionId text,consultId text);",tableName];
    
    [dbHelper inDatabase:^(FMDatabase *db)
    {
        [db beginTransaction];
        result = [db executeUpdate:sql];
        NSLog(@"创建表:%@ 结果:%d",tableName,result);
        [db commit];
        [tableDictionary setObject:tableName forKey:friends_UID];
    }];
    
    return result;
}

-(BOOL)insertWithMessage:(EMessage *)message consultId:(int)consultId isNotifaction:(BOOL)flag
{
    NSString* nUID = message.isGroup ? message.group_ID : message.friends_UID;
    if(![self isMessageExist:nUID consultId:consultId])
    {
        return [self insertWithMessage:message isNotifaction:flag];
    }
    return NO;
}

-(BOOL)insertWithMessage:(EMessage *)message
{
    return [self insertWithMessage:message isNotifaction:YES];
}

//这里消息入库（标签优化，入库的时候带上标签资料）
-(BOOL)insertWithMessage:(EMessage *)message isNotifaction:(BOOL)flag
{
    NSString* nUID = message.isGroup ? message.group_ID : message.friends_UID;
    NSString* tableName = [self getTableName:nUID];
    
    if(!tableName)
        return NO;
    
    __block BOOL result = NO;
    [dbHelper inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        
        NSString* picUrls = nil;
        if(message.picUrls)
        {
            picUrls = message.picUrls.JSONString;
        }
        
        NSString* otherData = nil;
        if(message.otherData)
        {
            otherData = message.otherData.JSONString;
        }
        
        NSString *sql = [NSString stringWithFormat:@"replace into %@(guid,myUID,friends_UID,group_ID,content,time,messageType,isSelf,isRead,isSend,picUrls,isGroup,resource,otherData,userName,sessionId,consultId) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",tableName];
        result = [db executeUpdate:sql,
                  message.guid,
                  message.myUID,
                  message.friends_UID,
                  message.group_ID,
                  message.content,
                  [NSNumber numberWithDouble:message.time],
                  [NSNumber numberWithInt:message.messageType],
                  [NSNumber numberWithBool:message.isSelf],
                  [NSNumber numberWithBool:message.isRead],
                  [NSNumber numberWithBool:message.isSend],
                  picUrls,
                  [NSNumber numberWithBool:message.isGroup],
                  message.resource,
                  otherData,
                  message.userName,
                  @(message.sessionId),
                  @(message.consultId)];
        if (result)
        {
            NSLog(@"insertWithMessage插入数据成功");
            if(flag)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"拿到消息数据，发通知");
                    //这里发消息通知之前先把用户的标签资料组装(为了解决医生主动发起会话的时候没有标签显示的问题)
                    EUserInfo *item =  [[CUserInfoDB shareInstance] selectUserInfoByIdForIM:message.friends_UID];
                    message.labers = item.labers;
                    message.archivesLaber = item.archivesLaber;
                    message.motherArchives = item.motherArchives;
                    message.childArchives = item.childArchives;
                    message.hdArchives = item.hdArchives;
                    
                    XYMMessageItemAdaptor* adaptor = [[XYMMessageItemAdaptor alloc] initWithMessage:message];
                    [[NSNotificationCenter defaultCenter] postNotificationName:IMNewMsgNotifaction
                                                                       object:adaptor
                                                                     userInfo:nil];
                });
            }
        }
        [db commit];
    }];
    return result;
}

-(void)updateWithMessage:(EMessage *)message
{
    [self updateWithMessage:message isNotifaction:YES];
}

-(void)updateWithMessage:(EMessage *)message isNotifaction:(BOOL)flag
{
    NSString* nUID = message.isGroup ? message.group_ID : message.friends_UID;
    NSString* tableName = [self getTableName:nUID];
    
    if(!tableName)
        return;
    
    [dbHelper inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
    
        NSString* sql=[NSString stringWithFormat:@"update %@ set myUID=?,friends_UID=?,group_ID=?,content=?,time=?,messageType=?,isSelf=?,isRead=?,isSend=?,picUrls=?,otherData=?,userName=?,sessionId=?,consultId=? where guid='%@';",tableName,message.guid];
    
        NSString* picUrls = nil;
        if(message.picUrls)
        {
            picUrls = message.picUrls.JSONString;
        }
        
        NSString* otherData = nil;
        if(message.otherData)
        {
            otherData = message.otherData.JSONString;
        }
        
        BOOL result = [db executeUpdate:sql,
                       message.myUID,
                       message.friends_UID,
                       message.group_ID,
                       message.content,
                       [NSNumber numberWithDouble:message.time],
                       [NSNumber numberWithInt:message.messageType],
                       [NSNumber numberWithBool:message.isSelf],
                       [NSNumber numberWithBool:message.isRead],
                       [NSNumber numberWithBool:message.isSend],
                       picUrls,
                       otherData,
                       message.userName,
                       @(message.sessionId),
                       @(message.consultId)];
        if (result)
        {
            NSLog(@"updateWithMessage更新数据成功");
            if(flag)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:IMMsgStatusNotifaction
                                                                       object:message.guid
                                                                     userInfo:nil];
                });
            }
        }
    
        [db commit];
    }];
}

-(void)setMessageStateWithIsRead:(NSString*)friends_UID isRead:(BOOL)isRead
{
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return;
    
    NSString* str = [NSString stringWithFormat:@"update %@ set isRead=%d where isRead=0;",tableName,isRead];
    [dbHelper inDatabase:^(FMDatabase *db)
    {
        BOOL result = [db executeUpdate:str];
        if(!result)
        {
            NSLog(@"setMessageStateWithIsRead失败");
        }
    }];
}

-(void)deleteAllMessage:(NSString*)friends_UID
{
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return;
    
    NSString *str = [NSString stringWithFormat:@"delete from %@;",tableName];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         BOOL result = [db executeUpdate:str];
         if(!result)
         {
             NSLog(@"deleteAllMessage失败");
         }
     }];
}

-(BOOL)deleteMessage:(NSString*)friends_UID guid:(NSString*)guid
{
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return NO;
    
    __block BOOL result = NO;
    
    NSString *str = [NSString stringWithFormat:@"delete from %@ where (guid='%@');",tableName,guid];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         result = [db executeUpdate:str];
         if(!result)
         {
             NSLog(@"deleteMessage:%@ guid:%@ 失败",friends_UID,guid);
         }
     }];
    
    return result;
}

-(void)deleteAllTable
{
    for (NSString* userId in tableDictionary.allKeys)
    {
        [self deleteAllMessage:userId];
    }
}

-(NSArray *)selectMessageWithPage:(NSString*)friends_UID page:(int)page
{
    
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return nil;
    
    NSString *str = [NSString stringWithFormat:@"select * from %@ order by time desc limit %d*15,15;", tableName, page];
    
    return [self getSelectArrayBySQL:str];
}

-(BOOL)isMessageExist:(NSString*)friends_UID consultId:(int)consultId
{
    NSString* tableName = [self getTableName:friends_UID];
    if(!tableName)
        return NO;
    
    NSString *str = [NSString stringWithFormat:@"select * from %@ where consultId='%d'",tableName,consultId];
    
    __block int row = 0;
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         if ([resultSet next])
         {
             row++;
         }
         [resultSet close];
     }];
    return row;
}

-(EMessage*)getLastMessage:(NSString*)friends_UID
{
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return nil;
    
    __block EMessage *message = nil;
    NSString *str = [NSString stringWithFormat:@"select * from %@ order by time desc limit 0,1;",tableName];
    
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         if ([resultSet next])
         {
             message = [self messageItemWithResultSet:resultSet];
         }
         [resultSet close];
     }];
    
    return message;
}

-(int)getUnReadCountWithUID:(NSString *)myUID friends_UID:(NSString*)friends_UID
{
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return 0;
    
    NSString *str = [NSString stringWithFormat:@"select * from %@ where isRead='0' and myUID='%@'",tableName,myUID];
    
    __block int row = 0;
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         if ([resultSet next])
         {
             row++;
         }
         [resultSet close];
     }];
    return row;
}

-(NSArray*)getUnSendedMessages:(NSString*)friends_UID
{
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return nil;
    
    NSString *string=[NSString stringWithFormat:@"select * from %@ where isSend=0 order by time asc;",tableName];
    return [self getSelectArrayBySQL:string];
}

-(NSArray *)getImageTypeMessages:(NSString*)friends_UID
{
    NSString* tableName = [self getTableName:friends_UID];
    
    if(!tableName)
        return nil;
    
    NSString *string=[NSString stringWithFormat:@"select * from %@ where messageType=1 order by time asc;",tableName];
    return [self getSelectArrayBySQL:string];
}

-(NSArray*)getSelectArrayBySQL:(NSString*)strSQL
{
    NSMutableArray *array = [NSMutableArray array];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:strSQL];
         while ([resultSet next])
         {
             EMessage* message = [self messageItemWithResultSet:resultSet];
             [array addObject:message];
         }
         [resultSet close];
     }];
    
    return array;
}

-(NSString*)getTableName:(NSString*)friends_UID
{
    if(![self isExistTable:friends_UID])
    {
        if(![self createTable:friends_UID])
        {
            return nil;
        }
    }
    
    return [tableDictionary objectForKey:friends_UID];
}

-(EMessage*)messageItemWithResultSet:(FMResultSet*)aResultSet
{
    EMessage* message = [[EMessage alloc] init];
    
    message.guid = [aResultSet stringForColumn:@"guid"];
    message.myUID = [aResultSet stringForColumn:@"myUID"];
    message.friends_UID = [aResultSet stringForColumn:@"friends_UID"];
    message.group_ID = [aResultSet stringForColumn:@"group_ID"];
    message.content = [aResultSet stringForColumn:@"content"];
    message.time = [aResultSet doubleForColumn:@"time"];
    message.messageType = [aResultSet intForColumn:@"messageType"];
    message.isSelf = [aResultSet boolForColumn:@"isSelf"];
    message.isRead = [aResultSet boolForColumn:@"isRead"];
    message.isSend = [aResultSet boolForColumn:@"isSend"];
    message.isGroup = [aResultSet boolForColumn:@"isGroup"];
    message.resource = [aResultSet stringForColumn:@"resource"];
    message.userName = [aResultSet stringForColumn:@"userName"];
    message.sessionId = [aResultSet intForColumn:@"sessionId"];
    message.consultId = [aResultSet intForColumn:@"consultId"];
    
    NSString* picUrls = [aResultSet stringForColumn:@"picUrls"];
    message.picUrls = picUrls.objectFromJSONString;
    
    NSString* otherData = [aResultSet stringForColumn:@"otherData"];
    message.otherData = otherData.objectFromJSONString;
    
    return message;
}

-(void)closeDB
{
    [tableDictionary removeAllObjects];
    tableDictionary = nil;
    
    [dbHelper close];
    dbHelper = nil;
}

@end
