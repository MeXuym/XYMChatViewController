//
//  IMSessionEvent.m
//  MCUTest
//
//  Created by Administrators on 15-4-28.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "IMSessionEvent.h"
#import "IMServerManager.h"
#include <netdb.h>
#include <arpa/inet.h>

@implementation IMSessionEvent
{
    NSLock *m_Mutex;
    BOOL m_bInit;
    BOOL m_suspend;
    BOOL isConnected;
    IMServerManager* m_Manager;
    IMServerDataOutputCallback callback;
    
    id<IMSessionEventDelegate> m_sessionController;
    
#if TARGET_OS_IPHONE
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
#endif
}


-(id)init
{
    if(self=[super init])
    {
        m_Mutex = [NSLock new];
        m_bInit = false;
        m_suspend = false;
        m_Manager = [[IMServerManager alloc] init];
        m_sessionController = NULL;
    }
    return self;
}

-(void)dealloc
{
    [m_Mutex lock];
    m_bInit = false;
    m_suspend = false;
    m_Manager = NULL;
    m_sessionController = NULL;
    [m_Mutex unlock];
    m_Mutex = nil;
}

-(void)setSessionController:(id<IMSessionEventDelegate>)imController
{
    m_sessionController = imController;
}

-(BOOL)InitIMWithHost:(NSString *)hostName port:(int)port
{
    const char *hostN= [hostName UTF8String];
    hostent* phot = gethostbyname(hostN);
    if(!phot)
        return NO;
    
    struct in_addr ip_addr;
    memcpy(&ip_addr, phot->h_addr_list[0], 4);
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    
    return [self InitIMWithIp:strIPAddress port:port];
}

-(BOOL)InitIMWithIp:(NSString *)ip port:(int)port
{
    [m_Mutex lock];
    m_bInit = [m_Manager initIMServer:ip port:port];
    if(m_bInit)
    {
        callback.dataOutputCallback=IMServerCallback;
        callback.dataOutputRefCon=(__bridge void *)self;
        [m_Manager setSessionCallback:&callback];
    }
    [m_Mutex unlock];
    
    return m_bInit;
}

-(BOOL)connectIM
{
    if(m_bInit)
    {
        isConnected = [m_Manager connectServer];
        return isConnected;
    }
    return NO;
}

-(void)DeInitIM
{
    [m_Mutex lock];
    if(m_bInit)
    {
        [m_Manager disconnectServer];
        [m_Manager setSessionCallback:NULL];
        m_bInit = false;
#if TARGET_OS_IPHONE
        {
            if (readStream || writeStream)
            {
                if (readStream)
                {
                    CFReadStreamSetClient(readStream, kCFStreamEventNone, NULL, NULL);
                    CFReadStreamClose(readStream);
                    CFRelease(readStream);
                    readStream = NULL;
                }
                if (writeStream)
                {
                    CFWriteStreamSetClient(writeStream, kCFStreamEventNone, NULL, NULL);
                    CFWriteStreamClose(writeStream);
                    CFRelease(writeStream);
                    writeStream = NULL;
                }
            }
        }
#endif
        NSLog(@"IMEvent deInit");
    }
    [m_Mutex unlock];
}

void IMServerCallback(void *dataOutputRefCon,void *sourceRefCon,IMData data,BOOL isSuccess)
{
    __weak __block IMSessionEvent* weakSelf= (__bridge IMSessionEvent*)dataOutputRefCon;
    @synchronized(weakSelf)
    {
        [weakSelf ServerDataNotify:data isSuccess:isSuccess];
    }
}

-(void)ServerDataNotify:(IMData)data isSuccess:(BOOL)isSuccess
{
    if(isSuccess)
    {
        if(m_bInit)
        {
            if(m_sessionController && [m_sessionController respondsToSelector:@selector(onUserEvent:buffer:lenght:)])
            {
                [m_sessionController onUserEvent:data.cmdId
                                          buffer:data.buffer
                                          lenght:data.size];
            }
        }
    }
    else if(!m_suspend)
    {
        m_suspend = YES;
        if(m_sessionController && [m_sessionController respondsToSelector:@selector(OnDisConnection)])
        {
            [m_sessionController OnDisConnection];
        }
    }
}

-(BOOL)SendCommand:(unsigned short)usCmd buffer:(const char *)buffer dataLen:(int)dataLen
{
    BOOL ret =YES;
    [m_Mutex lock];
    if(m_bInit)
    {
        ret = [m_Manager SendCmdData:usCmd buffer:buffer dataLen:dataLen];
    }
    [m_Mutex unlock];
    return ret;
}

#if TARGET_OS_IPHONE
- (BOOL)enableBackgroundingOnSocket
{
    if (![self createReadAndWriteStream])
    {
        NSLog(@"Error occurred creating streams (perhaps socket isn't open)");
        return NO;
    }
    
    BOOL r1, r2;

    r1 = CFReadStreamSetProperty(readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
    r2 = CFWriteStreamSetProperty(writeStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
    
    if (!r1 || !r2)
    {
        return NO;
    }
    
    if (![self openStreams])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)openStreams
{
    CFStreamStatus readStatus = CFReadStreamGetStatus(readStream);
    CFStreamStatus writeStatus = CFWriteStreamGetStatus(writeStream);
    
    if ((readStatus == kCFStreamStatusNotOpen) || (writeStatus == kCFStreamStatusNotOpen))
    {
        BOOL r1 = CFReadStreamOpen(readStream);
        BOOL r2 = CFWriteStreamOpen(writeStream);
        
        if (!r1 || !r2)
        {
            NSLog(@"Error in CFStreamOpen");
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)createReadAndWriteStream
{
    if (readStream || writeStream)
    {
        return YES;
    }
    int scoket = [m_Manager getSocketHandle];
    if(scoket == -1)
    {
        return NO;
    }
    
    if(!isConnected)
    {
        return NO;
    }
    
    CFStreamCreatePairWithSocket(NULL, (CFSocketNativeHandle)scoket, &readStream, &writeStream);
    
    if (readStream)
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse);
    if (writeStream)
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse);
    
    if ((readStream == NULL) || (writeStream == NULL))
    {
        if (readStream)
        {
            CFReadStreamClose(readStream);
            CFRelease(readStream);
            readStream = NULL;
        }
        if (writeStream)
        {
            CFWriteStreamClose(writeStream);
            CFRelease(writeStream);
            writeStream = NULL;
        }
        return NO;
    }
    return YES;
}
#endif

@end
