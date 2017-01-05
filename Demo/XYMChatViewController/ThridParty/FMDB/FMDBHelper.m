//
//  FMDBHelper.m
//  NewEshore
//
//  Created by Mirror on 15-4-28.
//  Copyright (c) 2015年 eshore. All rights reserved.
//

#import "FMDBHelper.h"
#import "FMDatabaseQueue.h"

@implementation FMDBHelper
{
    FMDatabaseQueue* queue;
}

-(id)initWithFileName:(NSString*)fileName
{
    self = [super init];
    if(self){
        NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *pathName=[doc stringByAppendingPathComponent:fileName];
        queue = [FMDatabaseQueue databaseQueueWithPath:pathName];
    }
    return self;
}

-(void) inDatabase:(void(^)(FMDatabase*))block
{
    [queue inDatabase:^(FMDatabase *db){
        block(db);
    }];
}

- (void)close
{
    [queue close];
}
@end