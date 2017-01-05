//
//  IMServerManager.h
//  MCUTest
//
//  Created by Administrators on 15-4-28.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct IMData
{
    int cmdId;
    const char *buffer;
    int size;
}IMData;

typedef void (*IMDataOutputCallback)(void *dataOutputRefCon,void *sourceRefCon,IMData data,BOOL isSuccess);

struct IMServerDataOutputCallback {
    IMDataOutputCallback  dataOutputCallback;
    void* dataOutputRefCon;
};
typedef struct IMServerDataOutputCallback IMServerDataOutputCallback;

@interface IMServerManager : NSObject

-(BOOL)initIMServer:(NSString*)ip port:(int)port;
-(void)setSessionCallback:(IMServerDataOutputCallback*)pSession;

-(BOOL)connectServer;
-(void)disconnectServer;
-(int)getSocketHandle;

-(int)SendCmdData:(unsigned short)usCmd
           buffer:(const char*)buffer
          dataLen:(int)dataLen;

@end
