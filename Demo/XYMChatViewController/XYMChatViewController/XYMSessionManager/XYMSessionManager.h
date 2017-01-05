//
//  XYMSessionManager.h
//  healthcoming
//
//  Created by jack xu on 16/12/27.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SessionInstance [XYMSessionManager instance]

@interface XYMSessionManager : NSObject

+ (XYMSessionManager *)instance;

-(void)getMessageWithUserId:(NSString*)toUID completed:(void (^)(BOOL, NSArray*))completed;

@end
