//
//  NewUserDB.m
//  healthcoming
//
//  Created by Franky on 16/2/24.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "NewUserDB.h"
#import "FMDBHelper.h"
#import "CommonOperation.h"
#import "EUserInfo.h"

@implementation KUserInfo

@end

static NewUserDB *instance;

@implementation NewUserDB
{
    FMDBHelper* dbHelper;
    NSString* _tableName;
}

+(NewUserDB *)shareInstance
{
    static NewUserDB *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
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

-(void)openDBWithUserID:(int)nUserId
{
    _tableName = [NSString stringWithFormat:@"NewUsers%d",nUserId];
    
    dbHelper = [[FMDBHelper alloc] initWithFileName:IMClientDB];
    
    [self createTable];
}

-(BOOL)createTable
{
    __block BOOL result = NO;
    
    [CommonOperation checkTableUpdateWithClassName:@"NewUserDB" block:^BOOL
     {
         __block BOOL result = NO;
         NSString *str = [NSString stringWithFormat:@"drop table if exists %@",_tableName];
         [dbHelper inDatabase:^(FMDatabase *db)
          {
              [db beginTransaction];
              result = [db executeUpdate:str];
              NSLog(@"删除表:%@ 结果:%d",_tableName,result);
              [db commit];
          }];
         return result;
     }];
    
    NSString *str = [NSString stringWithFormat:@"create table if not exists %@(uid integer,isNewP integer,isNewF integer,primary key(uid));",_tableName];
    
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         [db beginTransaction];
         result = [db executeUpdate:str];
         NSLog(@"创建表:%@ 结果:%d",_tableName,result);
         [db commit];
     }];
    
    return result;
}

-(BOOL)replaceWithUserInfo:(KUserInfo *)userInfo
{
    if(![self isUserInfoExist:userInfo.userId])
    {
        return [self insertWithUserInfo:userInfo];
    }
    else
    {
        return [self updateWithUserInfo:userInfo];
    }
}

-(BOOL)isUserInfoExist:(int)userId
{
    NSString *str = [NSString stringWithFormat:@"select * from %@ where uid='%d'",_tableName,userId];
    
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

-(BOOL)insertWithUserInfo:(KUserInfo *)info
{
    __block BOOL result = NO;
    
    [dbHelper inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        NSString *str = [NSString stringWithFormat:@"insert into %@(uid,isNewP,isNewF) values(?,?,?);",_tableName];
        
        result = [db executeUpdate:str,
                  @(info.userId),
                  @(info.isNewP),
                  @(info.isNewF)];
        
        if (result)
        {
            NSLog(@"NewUserDB--insertWithInfo插入数据成功");
        }
        
        [db commit];
        NSLog(@"新用户表commit成功");
    }];
    
    
    
    return result;
}

-(BOOL)updateWithUserInfo:(KUserInfo *)info
{
    NSString* str = [NSString stringWithFormat:@"update %@ set isNewP=?,isNewF=? where uid='%d';",_tableName,info.userId];
    
    [dbHelper inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        BOOL result = [db executeUpdate:str,
                       @(info.isNewP),
                       @(info.isNewF)];
        if (result)
        {
            NSLog(@"updateWithInfo更新数据成功");
        }
        
        [db commit];
    }];
    return YES;
}

-(void)getIsNewUser:(EUserInfo*)info
{
    NSString *str = [NSString stringWithFormat:@"select * from %@ where uid='%@';",_tableName,info.nUID];
    
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet = [db executeQuery:str];
         if ([resultSet next])
         {
             info.isNewP = [resultSet boolForColumn:@"isNewP"];
             info.isNewF = [resultSet boolForColumn:@"isNewF"];
         }
         [resultSet close];
     }];
}

-(void)closeDB
{
    [dbHelper close];
    dbHelper = nil;
    _tableName = nil;
}
-(void)deleteUserInfo:(NSString *)uid
{
    NSString *str = [NSString stringWithFormat:@"delete from %@ where uid='%@';",_tableName,uid];
    [dbHelper inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:str];
        if(result)
        {
            NSLog(@"deleteUserInfo删除数据成功");
        }
    }];
}

- (int)isFollowed:(NSString*)nUID
{
    NSString *str = [NSString stringWithFormat:@"select * from %@ where uid='%@';",_tableName,nUID];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet = [db executeQuery:str];
         while ([resultSet next])
         {
             KUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
             [arr addObject:userInfo];
         }
         [resultSet close];
     }];
    NSLog(@"找到新用户表里面有人：%lu",(unsigned long)arr.count);
    return arr.count;
}


#pragma mark - 查询这个UID在不在表
- (int)isExitInNewUser:(NSString*)nUID
{
    NSString *str = [NSString stringWithFormat:@"select * from %@ where uid='%@';",_tableName,nUID];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet = [db executeQuery:str];
         while ([resultSet next])
         {
             EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
             [arr addObject:userInfo];
         }
         [resultSet close];
     }];
    NSLog(@"找到新用户表里面有人：%lu",(unsigned long)arr.count);
    return arr.count;
}


#pragma mark - 查询该表所有新用户的信息 

-(NSArray *)getAllNewUserByHY {
    
    NSString *strNew = [NSString stringWithFormat:@"select * from %@",_tableName];
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    [dbHelper inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:strNew];
        while ([resultSet next])
        {
            EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
            [newArray addObject:userInfo];
        }
        [resultSet close];
        
    }];
    return newArray;
    
}

-(EUserInfo*)userInfoItemWithResultSet:(FMResultSet*)aResultSet
{
    EUserInfo* userInfo = [[EUserInfo alloc] init];
    
    //@"create table if not exists %@(uid text,userName text,userPhoto text,userPhotobag text,phoneNo text,patientSex integer,birthday text,age integer,patientIsMarry integer,labers text,address text,patientTxt text,rem text,primary key(uid));"
    
    userInfo.nUID = [aResultSet stringForColumn:@"uid"];
    userInfo.userName = [aResultSet stringForColumn:@"userName"];
    userInfo.userPhoto = [aResultSet stringForColumn:@"userPhoto"];
    userInfo.userPhotobag = [aResultSet stringForColumn:@"userPhotobag"];
    userInfo.phoneNo = [aResultSet stringForColumn:@"phoneNo"];
    userInfo.patientSex = [aResultSet intForColumn:@"patientSex"];
    userInfo.birthday = [aResultSet stringForColumn:@"birthday"];
    userInfo.age = [aResultSet intForColumn:@"age"];
    userInfo.groupId = [aResultSet intForColumn:@"groupId"];
    userInfo.patientIsMarry = [aResultSet intForColumn:@"patientIsMarry"];
    userInfo.address = [aResultSet stringForColumn:@"address"];
    userInfo.patientTxt = [aResultSet stringForColumn:@"patientTxt"];
    userInfo.rem = [aResultSet stringForColumn:@"rem"];
    
    NSString* labers = [aResultSet stringForColumn:@"labers"];
//    if(labers)
//    {
//        NSMutableArray* array = [NSMutableArray array];
//        NSArray* tempArray = labers.objectFromJSONString;
//        for (NSDictionary* item in tempArray)
//        {
//            ETagInfo* tag = [[ETagInfo alloc] initWithDic:item];
//            [array addObject:tag];
//        }
//        userInfo.labers = array;
//    }
    
    return userInfo;
}

@end
