//
//  VoiceContentView.m
//  healthcoming
//
//  Created by Franky on 15/8/19.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "XYMVoiceContentView.h"
#import "FileUtil.h"
#import "QNResourceManager.h"

@implementation XYMVoiceContentView
{
    UIView *voiceBackView;
    UILabel *second;
    UIImageView *voice;
    UIActivityIndicatorView *indicator;
    
    BOOL isUpload;
    NSString* localUrl_;
    NSString* voiceUrl_;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        voiceBackView = [[UIView alloc] init];
        voiceBackView.userInteractionEnabled = NO;
        voiceBackView.backgroundColor = [UIColor clearColor];
        [self addSubview:voiceBackView];
        
        second = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        second.textAlignment = NSTextAlignmentCenter;
        second.font = [UIFont systemFontOfSize:14];
        second.userInteractionEnabled = NO;
        second.backgroundColor = [UIColor clearColor];
        [voiceBackView addSubview:second];
        
        voice = [[UIImageView alloc] initWithFrame:CGRectMake(50, 5, 20, 20)];
        voice.image = [UIImage imageNamed:@"play_animation3.png"];
        voice.animationImages = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"play_animation1.png"],
                                 [UIImage imageNamed:@"play_animation2.png"],
                                 [UIImage imageNamed:@"play_animation3.png"],nil];
        voice.animationDuration = 1;
        voice.animationRepeatCount = 0;
        voice.userInteractionEnabled = NO;
        voice.backgroundColor = [UIColor clearColor];
        [voiceBackView addSubview:voice];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center=CGPointMake(80, 15);
        [voiceBackView addSubview:indicator];
    }
    return self;
}

-(id)initDownLoadWithFrame:(CGRect)frame mediaDic:(NSDictionary *)dic isSelf:(BOOL)isSelf isUpload:(BOOL)flag
{
    if(self = [self initWithFrame:frame])
    {
        isUpload = flag;
        localUrl_ = [dic objectForKey:DVoicePath];
        voiceUrl_ = [dic objectForKey:DVoiceUrl];
        if(isSelf)
        {
            voice.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else
        {
            CGRect frame = voice.frame;
            frame.origin.x = self.width - 80;
            voice.frame = frame;
        }
    }
    return self;
}

-(void)startRequestWithCompleted:(void (^)(XYMRequestContentView *, NSString *))block
{
    if(isUpload)
    {
        if(localUrl_ && localUrl_.length > 0)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[QNResourceManager sharedManager] uploadFileWithUrlkey:localUrl_
                                                                    key:nil
                                                             folderName:Audio_Folder
                                                          progressBlock:nil completeBlock:^(BOOL success, NSString *key) {
                                                              if(success)
                                                              {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      if(block)
                                                                      {
                                                                          block(self, key);
                                                                      }
                                                                  });
                                                              }
                                                          }];
            });
        }
    }
    else
    {
        if(!localUrl_ && voiceUrl_)
        {
            [self loadingVoice];
            NSString* tmpFile = [FileUtil tempPathWithFileName:voiceUrl_.lastPathComponent];
            if([[NSFileManager defaultManager] fileExistsAtPath:tmpFile])
            {
                [self loadedVoice];
            }
            else
            {
                [[QNResourceManager sharedManager] downloadFileWithUrl:voiceUrl_ progressBlock:^(CGFloat progress) {}
                                                         completeBlock:^(BOOL success, NSError *error) {
                                                             if(success)
                                                             {
                                                                 [self loadedVoice];
                                                                 if(block)
                                                                 {
                                                                     block(self, voiceUrl_);
                                                                 }
                                                                 NSLog(@"语音下载成功");
                                                             }
                                                         }];
            }
        }
    }
}

-(void)voiceLength:(int)length
{
    second.text = [NSString stringWithFormat:@"%d'",length];
}

-(void)loadingVoice
{
    voice.hidden = YES;
    [indicator startAnimating];
}

-(void)loadedVoice
{
    voice.hidden = NO;
    [indicator stopAnimating];
}

-(void)startPlay
{
    [voice startAnimating];
}

-(void)stopPlay
{
    [voice stopAnimating];
}

-(void)dealloc
{
    [self cancelAndClean];
}

@end
