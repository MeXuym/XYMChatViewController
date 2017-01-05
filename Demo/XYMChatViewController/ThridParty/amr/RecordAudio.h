//
//  RecordAudio.h
//  JuuJuu
//
//  Created by xiaoguang huang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "amrFileCodec.h"

@protocol RecordAudioDelegate <NSObject>
//status:0 播放 1 播放完成 2出错
-(void)RecordStatus:(int)status;
//更新输入语音大小
-(void)UpdateRecordDegree:(CGFloat)degree;
@end

@interface RecordAudio : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    //Variables setup for access in the class:
	NSString * recordedTmpFilePath;
	AVAudioRecorder * recorder;
	NSError * error;
    AVAudioPlayer * avPlayer;
    
    NSTimer* updateTimer_;
    id<RecordAudioDelegate> delegate_;
}

@property (nonatomic, assign) id<RecordAudioDelegate> delegate;

- (NSURL*)stopRecord;
- (void)startRecord;

- (BOOL)isRecording;
- (BOOL)isPlaying;
- (void)playOfFile:(NSString *)filePath;
- (void)stopPlay;

//获取文件时间长度
+ (NSTimeInterval)getAudioTime:(NSString *)filePath;
//将caf文件转码成amr格式文件
+ (NSString *)encodeToAMR:(NSString *)cafFilePath;
//删除录音时的语音原文件(audioFilePath既可以是caf文件,也可以是amr文件)
+ (BOOL)deleteAudioSrcFile:(NSString *)audioFilePath;

@end
