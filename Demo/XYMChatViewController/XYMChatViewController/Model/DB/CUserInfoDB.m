//
//  CUserInfoDB.m
//  healthcoming
//
//  Created by Franky on 16/3/10.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "CUserInfoDB.h"
#import "FMDBHelper.h"
#import "CommonOperation.h"
#import "ETagInfo.h"
#import "NewUserDB.h"

static CUserInfoDB *instance;

@implementation CUserInfoDB
{
    FMDBHelper* dbHelper;
    NSString* _tableName;
    NSString* _tableName2;
}

+(CUserInfoDB *)shareInstance
{
    static CUserInfoDB *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)dealloc
{
    [self closeDB];
}

-(void)openDBWithUserID:(int)nUserId
{
    _tableName = [NSString stringWithFormat:@"CUserInfoDB%d",nUserId];
    _tableName2 = [NSString stringWithFormat:@"NewUsers%d",nUserId];
    
    dbHelper = [[FMDBHelper alloc] initWithFileName:IMClientDB];
    
    [self createTable];
}

-(BOOL)createTable
{
    __block BOOL result = NO;
    [CommonOperation checkTableUpdateWithClassName:@"CUserInfoDB" block:^BOOL
     {
         __block BOOL result = YES;
         NSMutableArray* array = [NSMutableArray array];
         [dbHelper inDatabase:^(FMDatabase *db)
          {
              NSString* sqlstr = @"select name from sqlite_master where type='table' order by name;";
              FMResultSet *resultSet = [db executeQuery:sqlstr];
              while ([resultSet next])
              {
                  NSString *name = [resultSet stringForColumn:@"name"];
                  [array addObject:name];
              }
              [resultSet close];
              
              [db beginTransaction];
              for (NSString* name in array)
              {
                  if([name hasPrefix:@"CUserInfoDB"])
                  {
                      NSString *str = [NSString stringWithFormat:@"drop table if exists %@",name];
                      BOOL flag = [db executeUpdate:str];
                      NSLog(@"删除表:%@ 结果:%d",name,flag);
                      result = result & flag;
                  }
              }
              [db commit];
          }];
         return result;
     }];
    
    NSString *str = [NSString stringWithFormat:@"create table if not exists %@(uid text,userName text,userPhoto text,userPhotobag text,phoneNo text,patientSex integer,birthday text,age integer,groupId integer,patientIsMarry integer,labers text,address text,patientTxt text,rem text,archivesLaber text,motherArchives text,childArchives text,hdArchives text,primary key(uid));",_tableName];
    
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         [db beginTransaction];
         result = [db executeUpdate:str];
         NSLog(@"创建表:%@ 结果:%d",_tableName,result);
         [db commit];
     }];
    
    return result;
}

-(void)deleteTable
{
    NSString *str = [NSString stringWithFormat:@"delete from %@;",_tableName];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         BOOL result = [db executeUpdate:str];
         if(!result)
         {
             NSLog(@"deleteAllMessage失败");
         }
     }];
}

-(BOOL)replaceWithUserInfo:(EUserInfo *)userInfo
{
    if(![self isUserInfoExist:userInfo.nUID])
    {
        return [self insertWithUserInfo:userInfo];
    }
    else
    {
        return [self updateWithUserInfo:userInfo];
    }
}

-(BOOL)insertWithUserInfo:(EUserInfo *)userInfo
{
    __block BOOL result = NO;
    
    [dbHelper inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        NSString* labers = nil;
        if(userInfo.labers)
        {
            NSMutableArray* array = [NSMutableArray array];
            for (ETagInfo* tag in userInfo.labers)
            {
                [array addObject:[tag getCurrentDic]];
            }
            labers = array.JSONString;
        }
        
        NSString* archivesLaber = nil;
        if(userInfo.archivesLaber)
        {
            archivesLaber = userInfo.archivesLaber.JSONString;
        }
        
        NSString* motherArchives = nil;
        if(userInfo.motherArchives)
        {
            motherArchives = userInfo.motherArchives.JSONString;
        }
        
        NSString* childArchives = nil;
        if(userInfo.childArchives)
        {
            childArchives = userInfo.childArchives.JSONString;
        }
        
        NSString* hdArchives = nil;
        if(userInfo.hdArchives)
        {
            hdArchives = userInfo.hdArchives.JSONString;
        }
        
        NSString *str = [NSString stringWithFormat:@"insert into %@(uid,userName,userPhoto,userPhotobag,phoneNo,patientSex,birthday,age,groupId,patientIsMarry,labers,address,patientTxt,rem,archivesLaber,motherArchives,childArchives,hdArchives) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",_tableName];
        
        result = [db executeUpdate:str,
                  userInfo.nUID,
                  userInfo.userName?userInfo.userName:@"",
                  userInfo.userPhoto?userInfo.userPhoto:@"",
                  userInfo.userPhotobag?userInfo.userPhotobag:@"",
                  userInfo.phoneNo?userInfo.phoneNo:@"",
                  @(userInfo.patientSex),
                  userInfo.birthday?userInfo.birthday:@"",
                  @(userInfo.age),
                  @(userInfo.groupId),
                  @(userInfo.patientIsMarry),
                  labers,
                  userInfo.address?userInfo.address:@"",
                  userInfo.patientTxt?userInfo.patientTxt:@"",
                  userInfo.rem?userInfo.rem:@"",
                  archivesLaber,
                  motherArchives,
                  childArchives,
                  hdArchives];
        
        if (result)
        {
            NSLog(@"CUserInfoDB--insertWithInfo插入数据成功");
        }
        
        [db commit];
        NSLog(@"dbcommit成功");
    }];
    
    return result;
}

-(BOOL)updateWithUserInfo:(EUserInfo *)userInfo
{
    __block BOOL result = NO;
    
    NSString* str = [NSString stringWithFormat:@"update %@ set userName=?,userPhoto=?,userPhotobag=?,phoneNo=?,patientSex=?,birthday=?,age=?,groupId=?,patientIsMarry=?,labers=?,address=?,patientTxt=?,rem=?,archivesLaber=?,motherArchives=?,childArchives=?,hdArchives=? where uid='%@';",_tableName,userInfo.nUID];
    
    [dbHelper inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        
        NSString* labers = nil;
        if(userInfo.labers)
        {
            NSMutableArray* array = [NSMutableArray array];
            for (ETagInfo* tag in userInfo.labers)
            {
                [array addObject:[tag getCurrentDic]];
            }
            labers = array.JSONString;
        }
        
        NSString* archivesLaber = nil;
        if(userInfo.archivesLaber)
        {
            archivesLaber = userInfo.archivesLaber.JSONString;
        }
        
        NSString* motherArchives = nil;
        if(userInfo.motherArchives)
        {
            motherArchives = userInfo.motherArchives.JSONString;
        }
        
        NSString* childArchives = nil;
        if(userInfo.childArchives)
        {
            childArchives = userInfo.childArchives.JSONString;
        }
        
        NSString* hdArchives = nil;
        if(userInfo.hdArchives)
        {
            hdArchives = userInfo.hdArchives.JSONString;
        }
        
        result = [db executeUpdate:str,
                  userInfo.userName?userInfo.userName:@"",
                  userInfo.userPhoto?userInfo.userPhoto:@"",
                  userInfo.userPhotobag?userInfo.userPhotobag:@"",
                  userInfo.phoneNo?userInfo.phoneNo:@"",
                  @(userInfo.patientSex),
                  userInfo.birthday?userInfo.birthday:@"",
                  @(userInfo.age),
                  @(userInfo.groupId),
                  @(userInfo.patientIsMarry),
                  labers,
                  userInfo.address?userInfo.address:@"",
                  userInfo.patientTxt?userInfo.patientTxt:@"",
                  userInfo.rem?userInfo.rem:@"",
                  archivesLaber,
                  motherArchives,
                  childArchives,
                  hdArchives];
        if (result)
        {
            NSLog(@"updateWithInfo更新数据成功");
        }
        
        [db commit];
    }];
    
    return result;
}

-(BOOL)isUserInfoExist:(NSString*)uid
{
    NSString *str = [NSString stringWithFormat:@"select * from %@ where uid='%@'",_tableName,uid];
    
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

-(EUserInfo*)selectUserInfoById:(NSString*)uid
{
    __block EUserInfo* info = nil;
    NSString *str = [NSString stringWithFormat:@"select * from %@ where uid='%@';",_tableName,uid];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         while ([resultSet next])
         {
             info= [self userInfoItemWithResultSet:resultSet];
         }
         [resultSet close];
     }];
    return info;
}

//用于取会话中的标签数据
-(EUserInfo*)selectUserInfoByIdForIM:(NSString*)uid
{
    __block EUserInfo* info = nil;
    NSString *str = [NSString stringWithFormat:@"select * from %@ where uid='%@';",_tableName,uid];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         while ([resultSet next])
         {
             info= [self userInfoItemWithResultSetForIM:resultSet];
         }
         [resultSet close];
     }];
    return info;
}




-(NSArray *)selectUserInfoByGroupId:(int)groupId
{
    NSMutableArray* array = [NSMutableArray array];
    NSString *str = [NSString stringWithFormat:@"select * from %@ where groupId='%d';",_tableName,groupId];
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         while ([resultSet next])
         {
             EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
             [[NewUserDB shareInstance] getIsNewUser:userInfo];
             [array addObject:userInfo];
         }
         [resultSet close];
     }];
    
    return array;
}

-(NSMutableArray *)selectAllUserInfo
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSString *str = [NSString stringWithFormat:@"select * from %@;",_tableName];
    
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         while ([resultSet next])
         {
             EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
             [[NewUserDB shareInstance] getIsNewUser:userInfo];
             [array addObject:userInfo];
         }
         [resultSet close];
     }];
    
    return array;
}

//得到全部人数
-(NSUInteger)selectAllUserCount
{
    NSMutableArray* array = [NSMutableArray array];
    
    NSString *str = [NSString stringWithFormat:@"select * from %@;",_tableName];
    
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet=[db executeQuery:str];
         while ([resultSet next])
         {
             EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
             [[NewUserDB shareInstance] getIsNewUser:userInfo];
             [array addObject:userInfo];
         }
         [resultSet close];
     }];
    
    return array.count;
}

-(NSArray *)getAllNewUser
{
    NSMutableArray* array = [NSMutableArray array];
//    NSMutableArray *allArray = [NSMutableArray arrayWithCapacity:0];
//    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    NSString *str = [NSString stringWithFormat:@"select * from %@ as t1 inner join %@ as t2 on t1.uid = t2.uid where isNewP = 1;",_tableName,_tableName2];
//    
//    NSString *strAll = [NSString stringWithFormat:@"select * from %@",_tableName];
//    NSString *strNew = [NSString stringWithFormat:@"select * from %@",_tableName2];
//    
//    [dbHelper inDatabase:^(FMDatabase *db) {
//        FMResultSet *resultSet = [db executeQuery:strAll];
//        while ([resultSet next])
//        {
//            EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
//            [allArray addObject:userInfo];
//        }
//        [resultSet close];
//
//    }];
//    [dbHelper inDatabase:^(FMDatabase *db) {
//        FMResultSet *resultSet = [db executeQuery:strNew];
//        while ([resultSet next])
//        {
//            EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
//            [newArray addObject:userInfo];
//        }
//        [resultSet close];
//        
//    }];
//    NSLog(@"All Array ==%@",allArray);
//    NSLog(@"New Array ==%@",newArray);
    
    [dbHelper inDatabase:^(FMDatabase *db)
     {
         FMResultSet *resultSet = [db executeQuery:str];
         while ([resultSet next])
         {
             EUserInfo* userInfo = [self userInfoItemWithResultSet:resultSet];
             userInfo.isNewP = YES;
             [array addObject:userInfo];
         }
         [resultSet close];
     }];
    
    return array;
}

#pragma mark - 查询这个UID在不在表
- (int)isExitInCUser:(NSString*)nUID
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


-(NSArray *)getAllNewUserByHY {
    
    NSString *strNew = [NSString stringWithFormat:@"select * from %@",_tableName2];
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
    if(labers)
    {
        NSMutableArray* array = [NSMutableArray array];
        NSArray* tempArray = labers.objectFromJSONString;
        for (NSDictionary* item in tempArray)
        {
            ETagInfo* tag = [[ETagInfo alloc] initWithDic:item];
            [array addObject:tag];
        }
        userInfo.labers = array;
    }
    
//    NSString* labers = [aResultSet stringForColumn:@"labers"];
//    if(labers)
//    {
//        userInfo.labers = labers.objectFromJSONString;
//    }
    
    NSString* archivesLaber = [aResultSet stringForColumn:@"archivesLaber"];
    if(archivesLaber)
    {
        userInfo.archivesLaber = archivesLaber.objectFromJSONString;
    }
    
    NSString* motherArchives = [aResultSet stringForColumn:@"motherArchives"];
    if(motherArchives)
    {
        userInfo.motherArchives = motherArchives.objectFromJSONString;
    }
    
    NSString* childArchives = [aResultSet stringForColumn:@"childArchives"];
    if(childArchives)
    {
        userInfo.childArchives = childArchives.objectFromJSONString;
    }
    
    NSString* hdArchives = [aResultSet stringForColumn:@"hdArchives"];
    if(hdArchives)
    {
        userInfo.hdArchives = hdArchives.objectFromJSONString;
    }
    
    return userInfo;
}

-(EUserInfo*)userInfoItemWithResultSetForIM:(FMResultSet*)aResultSet
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
    
//    NSString* labers = [aResultSet stringForColumn:@"labers"];
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
    
        NSString* labers = [aResultSet stringForColumn:@"labers"];
        if(labers)
        {
            userInfo.labers = labers.objectFromJSONString;
        }
    
    NSString* archivesLaber = [aResultSet stringForColumn:@"archivesLaber"];
    if(archivesLaber)
    {
        userInfo.archivesLaber = archivesLaber.objectFromJSONString;
    }
    
    NSString* motherArchives = [aResultSet stringForColumn:@"motherArchives"];
    if(motherArchives)
    {
        userInfo.motherArchives = motherArchives.objectFromJSONString;
    }
    
    NSString* childArchives = [aResultSet stringForColumn:@"childArchives"];
    if(childArchives)
    {
        userInfo.childArchives = childArchives.objectFromJSONString;
    }
    
    NSString* hdArchives = [aResultSet stringForColumn:@"hdArchives"];
    if(hdArchives)
    {
        userInfo.hdArchives = hdArchives.objectFromJSONString;
    }
    
    return userInfo;
}


-(void)closeDB
{
    [dbHelper close];
    dbHelper = nil;
}

@end
