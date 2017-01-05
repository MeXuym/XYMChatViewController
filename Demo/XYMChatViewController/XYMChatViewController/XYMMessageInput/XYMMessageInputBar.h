//
//  MessageInputBar.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "XYMMessageInputManager.h"

#define Time  0.2
#define keyboardHeight 216
#define MoreMenuHeight 200
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width

static const float XYMkNavHeight=44.0;
static const float XYMkTabHeight=49.0;
static const float XYMkStatusHeight=20.0;

@class XYMMessageInputBar;

@protocol XYMMessageInputBarDelegate <NSObject>
@optional
#pragma 键盘高度变化代理
- (void)keyboardAction:(CGFloat)height;
#pragma 发送文字代理
- (void)sendTextAction:(NSString*)text;
#pragma 录音备用
- (void)startRecording:(XYMMessageInputBar*)toolbar;
- (void)endRecording:(XYMMessageInputBar*)toolbar isSend:(BOOL)isSend;
#pragma 选择图片代理
- (void)pickPhoto:(XYMMessageInputBar*)toolbar;
#pragma 打开摄影机代理
- (void)openCamera:(XYMMessageInputBar*)toolbar;
- (void)fullInfo:(XYMMessageInputBar*)toolbar;

#pragma 发随访代理
- (void)sendFollow:(XYMMessageInputBar*)toolbar;


@end

@interface XYMMessageInputBar : UIView<HPGrowingTextViewDelegate,XYMFaceViewDelegate,XYMMoreMenuViewDelegate>
{
    HPGrowingTextView* textView_;
    UIButton *faceBtn_;
    UIButton *voiceBtn_;
    UIButton *recordBtn_;
    UIButton *moreBtn_;
    
    const UIView* superView;
    UIImageView* backgroundImage_;
    XYMMesssageBarState currentState_;
    BOOL isVoiceModel;
}

@property (nonatomic,assign) XYMMesssageBarState currentState;
@property (nonatomic,assign) id<XYMMessageInputBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame superView:(const UIView*)view;
#pragma 隐藏键盘
- (void)hideKeyBoard;
#pragma 填充文字数据
- (void)fitTextView:(NSString*)text;
- (void)cleanData;
- (void)initNotification;
- (void)removeNotification;
- (NSString*)curText;

@end
