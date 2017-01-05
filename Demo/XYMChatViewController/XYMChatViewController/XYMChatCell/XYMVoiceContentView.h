//
//  VoiceContentView.h
//  healthcoming
//
//  Created by Franky on 15/8/19.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "XYMRequestContentView.h"

@interface XYMVoiceContentView : XYMRequestContentView

@property (nonatomic,retain) NSString* LocalPath;
@property (nonatomic,retain) NSString* VoiceUrl;

-(id)initDownLoadWithFrame:(CGRect)frame mediaDic:(NSDictionary *)dic isSelf:(BOOL)isSelf isUpload:(BOOL)flag;

-(void)voiceLength:(int)length;
-(void)loadingVoice;
-(void)loadedVoice;
-(void)startPlay;
-(void)stopPlay;

@end
