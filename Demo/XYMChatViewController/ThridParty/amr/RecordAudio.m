//
//  RecordAudio.m
//  JuuJuu
//
//  Created by xiaoguang huang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RecordAudio.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"

@interface RecordAudio (Private)
- (void)play:(NSData *)data;
@end

@implementation RecordAudio

@synthesize delegate=delegate_;

- (void)dealloc {
    if ([recorder isRecording]) {
        [recorder stop];
    }
    [recorder release];
	recorder = nil;
    [recordedTmpFilePath release];
	recordedTmpFilePath = nil;
    [avPlayer stop];
    [avPlayer release];
    avPlayer = nil;
    if (updateTimer_) {
        [updateTimer_ invalidate];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        //Instanciate an instance of the AVAudioSession object.
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
//        //set the delegate
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleInterruption:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:audioSession];
        //Setup the audioSession for playback and record.
        //We could just use record and then switch it to playback leter, but
        //since we are going to do both lets set it up once.
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        //Activate the session
        [audioSession setActive:YES error:&error];
        
        //此处会影响airplay功能!!!~~~很是奇怪
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, //kAudioSessionProperty_OverrideCategoryDefaultToSpeaker
//								 sizeof (audioRouteOverride),
//								 &audioRouteOverride);
    }
    return self;
}

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        //在此写接近时，要做的操作逻辑代码
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        if ([avPlayer isPlaying]) {
            //重新从头开始再播放一次
            [avPlayer stop];
            avPlayer.currentTime = 0.0f;
            [avPlayer play];
        }
    } else {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if ([avPlayer isPlaying]) {
            //重新从头开始再播放一次
            [avPlayer stop];
            avPlayer.currentTime = 0.0f;
            [avPlayer play];
        }
    }
}

- (void)startRecord
{
    //Begin the recording session.
    //Error handling removed.  Please add to your own code.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //Setup the dictionary object with all the recording settings that this
    //Recording sessoin will use
    //Its not clear to me which of these are required and which are the bare minimum.
    //This is a good resource: http://www.totodotnet.net/tag/avaudiorecorder/
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                   [NSNumber numberWithFloat:8000.0], AVSampleRateKey,  //采样率 (8000|44100|96000)
                                   [NSNumber numberWithInt:1], AVNumberOfChannelsKey,   //通道的数目,1单声道,2立体声
                                   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey, //采样位 (8|16|24|32)
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                   nil];
    
    //Now that we have our settings we are going to instanciate an instance of our recorder instance.
    //Generate a temp file for use by the recording.
    //This sample was one I found online and seems to be a good choice for making a tmp file that
    //will not overwrite an existing one.
    //I know this is a mess of collapsed things into 1 call.  I can break it out if need be.
    NSURL* recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
    NSLog(@"Using File called: %@", recordedTmpFile);
    
    //Setup the recorder to use this file and record to it.
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
    
    //Use the recorder to start the recording.
    //Im not sure why we set the delegate to self yet.
    //Found this in antother example, but Im fuzzy on this still.
    [recorder setDelegate:self];
    //We call this to start the recording process and initialize
    //the subsstems so that when we actually say "record" it starts right away.
    [recorder prepareToRecord];
    //Start the actual Recording
    [recorder record];
//    //There is an optional method for doing the recording for a limited time see
//    [recorder recordForDuration:60.0f];
    //metering
    [recorder setMeteringEnabled:YES];
    
    if (updateTimer_) {
        [updateTimer_ invalidate];
        updateTimer_ = nil;
    }
    updateTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(catchVolume:) userInfo:nil repeats:YES];
    
    //纪录一下文件路径
    [recordedTmpFilePath release];
    recordedTmpFilePath = [[recordedTmpFile path] retain];
}

- (void)catchVolume:(id)sender
{
    if ([recorder isRecording]) {
        //发送updateMeters消息来刷新平均和峰值功率。此计数是以对数刻度计量的，-160表示完全安静，0表示最大输入值
        [recorder updateMeters];
        
        double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
        
        if (delegate_ && [delegate_ respondsToSelector:@selector(UpdateRecordDegree:)]) {
            [delegate_ UpdateRecordDegree:lowPassResults]; //转换成百分比
        }
    }
}

- (NSURL *)stopRecord {
    if (recorder == nil) {
        return nil;
    }
    NSURL *url = [[NSURL alloc] initWithString:recorder.url.absoluteString];
    [recorder stop];
    [recorder release];
    recorder = nil;
    [updateTimer_ invalidate];
    updateTimer_ = nil;
    //
    return [url autorelease];
}

+ (NSTimeInterval)getAudioTime:(NSString *)filePath
{
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    if(!data)
    {
        return 0;
    }
    NSError *error;
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithData:data error:&error];
    [play setDelegate:nil];
    [play prepareToPlay];
    NSTimeInterval time = [play duration];
    [play release];
    return time;
}

//status:0播放 1播放完成 2出错
- (void)sendStatus:(int)status {
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(RecordStatus:)]) {
        [delegate_ RecordStatus:status];
    }
    
    if (status != 0) {
        if (avPlayer!=nil) {
            [avPlayer stop];
            [avPlayer release];
            avPlayer = nil;
        }
        //移除监听
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    } else {
        //开启监听近接传感器
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
}

- (void)stopPlay {
    if (avPlayer!=nil) {
        [avPlayer stop];
        [avPlayer release];
        avPlayer = nil;
        [self sendStatus:1];
    }
}

- (NSData *)decodeAmr:(NSData *)data
{
    if (!data) {
        return data;
    }

    return DecodeAMRToWAVE(data);
}

- (BOOL)isRecording
{
    return [recorder isRecording];
}

- (BOOL)isPlaying
{
    return [avPlayer isPlaying];
}

- (void)play:(NSData *)wavData
{
	//Setup the AVAudioPlayer to play the file that we just recorded.
    //在播放时，先停止
    if (avPlayer!=nil) {
        [self stopPlay];
    }
    avPlayer = [[AVAudioPlayer alloc] initWithData:wavData error:&error];
    avPlayer.delegate = self;
	[avPlayer prepareToPlay];
    [avPlayer setVolume:1.0];
	if(![avPlayer play]) {
        [self sendStatus:1];
    } else {
        [self sendStatus:0];
    }
}

- (void)playOfFile:(NSString *)filePath
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //判断文件类型(caf,amr)
    NSString* suffix = [filePath pathExtension];
    if ([suffix isEqualToString:@"caf"]) {     //caf
        NSData* wavData = [NSData dataWithContentsOfFile:filePath];
        if (wavData) {
            [self play:wavData];
        }
    } else {                                    //amr
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            NSLog(@"start decode");
            NSData* wavData = [self decodeAmr:data];
            NSLog(@"end decode");
            [self play:wavData];
        }
    }
}

+ (NSString *)encodeToAMR:(NSString *)cafFilePath
{
    NSData* cafData = [NSData dataWithContentsOfFile:cafFilePath];
    NSData* curAudio = EncodeWAVEToAMR(cafData, 1, 16);
    //写入新文件里面去
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* amrFilePath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr", cafFilePath.lastPathComponent.stringByDeletingPathExtension]];
    BOOL bWriteRet = [curAudio writeToFile:amrFilePath atomically:YES];
    
    if (bWriteRet) {
        return amrFilePath;
    }
    return nil;
}

+ (BOOL)deleteAudioSrcFile:(NSString *)audioFilePath
{
    NSError* error = nil;
    NSString* cafFilePath = [NSString stringWithFormat:@"%@.caf", [audioFilePath stringByDeletingPathExtension]];
    [[NSFileManager defaultManager] removeItemAtPath:cafFilePath error:&error];
    NSString* amrFilePath = [NSString stringWithFormat:@"%@.amr", [audioFilePath stringByDeletingPathExtension]];
    [[NSFileManager defaultManager] removeItemAtPath:amrFilePath error:&error];
    return YES;
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self sendStatus:1];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self sendStatus:2];
}

#pragma mark -
#pragma mark AVAudioSessionDelegate

- (void)beginInterruption
{
    NSLog(@"beginInterruption");
}
- (void)endInterruption
{
    NSLog(@"endInterruption");
}
- (void)handleInterruption:(NSNotification *)notification
{
    NSLog(@"handleInterruption");
}

@end
