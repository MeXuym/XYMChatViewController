//
//  FMDBHelper.h
//  NewEshore
//
//  Created by Mirror on 15-4-28.
//  Copyright (c) 2015年 eshore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface FMDBHelper : NSObject
{
    
}
-(id)initWithFileName:(NSString*)fileName;
-(void) inDatabase:(void(^)(FMDatabase*))block;
-(void)close;
@end
