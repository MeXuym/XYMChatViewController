//
//  IMSessionEvent.h
//  MCUTest
//
//  Created by Administrators on 15-4-28.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMSessionController;

@protocol IMSessionEventDelegate <NSObject>
- (void)onUserEvent:(int)cmdID
             buffer:(const char*)buffer
             lenght:(int)lenght;

- (void)OnDisConnection;
@end

@interface IMSessionEvent : NSObject

-(void)setSessionController:(id<IMSessionEventDelegate>)delegate;

-(BOOL)InitIMWithHost:(NSString *)hostName port:(int)port;
-(BOOL)InitIMWithIp:(NSString *)ip port:(int)port;
-(BOOL)connectIM;
-(void)DeInitIM;

-(BOOL)SendCommand:(unsigned short)usCmd
            buffer:(const char*)buffer
           dataLen:(int)dataLen;

#if TARGET_OS_IPHONE
- (BOOL)enableBackgroundingOnSocket;
#endif
@end
