//
//  XUYMMessageInputBar.m
//  XYMChatViewController
//
//  Created by xuym on 2017/5/10.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import "XUYMMessageInputBar.h"
#import "XUYMMessageInputManager.h"
#import "HPGrowingTextView.h"
#import <AVFoundation/AVFoundation.h>

@interface XUYMMessageInputBar()<HPGrowingTextViewDelegate>
{
    BOOL isAudioGranted;     //纪录麦克风权限
}

@property (nonatomic,weak) HPGrowingTextView *textView;
@property (nonatomic,weak) UIButton *recordBtn;
@property (nonatomic,weak) UIButton *voiceBtn;
@property (nonatomic,weak) UIButton *faceBtn;
@property (nonatomic,weak) UIButton *moreBtn;

@end

@implementation XUYMMessageInputBar

# pragma mark - life cycle
- (id)initWithFrame:(CGRect)frame superView:(const UIView*)view
{
    self = [super initWithFrame:frame];
    if (self) {

        self.currentState = XUYMViewStateShowNone;
        isVoiceModel = NO;
        superView = view;
        isAudioGranted = YES;
        
        self.backgroundColor = UIColorFromRGB(0xe1e1e1);
        
        //可以自适应高度的文本输入框
        HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(45, 8, ScreenWidth - 125, 30)];
        textView.delegate = self; //设置代理
        textView.isScrollable = NO;
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        textView.minNumberOfLines = 1;
        textView.maxNumberOfLines = 4;
        
        textView.font = [UIFont systemFontOfSize:15.0f];
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView.backgroundColor = [UIColor whiteColor];
        textView.placeholder = @"请输入消息";
        textView.returnKeyType = UIReturnKeySend;
        textView.layer.cornerRadius=5;
        textView.enablesReturnKeyAutomatically = YES;
        self.textView = textView;
        [self addSubview:self.textView];
        
        UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [recordBtn setFrame:CGRectMake(45, 9, ScreenWidth - 125, 30)];
        [recordBtn setBackgroundImage:[UIImage imageNamed:@"voice_bg.png"] forState:UIControlStateNormal];
        
        [recordBtn setTitle:@"按住说话" forState:UIControlStateNormal];
        [recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [recordBtn addTarget:self action:@selector(onStartRecord) forControlEvents:UIControlEventTouchDown];
        [recordBtn addTarget:self action:@selector(onEndRecord) forControlEvents:UIControlEventTouchUpInside];
        [recordBtn addTarget:self action:@selector(onStopRecord) forControlEvents:UIControlEventTouchUpOutside]; //添加按下后向上滑动取消语音操作
        [recordBtn setHidden:YES];
        self.recordBtn = recordBtn;
        [self addSubview:self.recordBtn];
        
        //音频按钮
        UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [voiceBtn setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
        [voiceBtn setImage:[UIImage imageNamed:@"voice_h.png"] forState:UIControlStateHighlighted];
        [voiceBtn addTarget:self action:@selector(onVoiceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        voiceBtn.frame = CGRectMake(0,4.5,40,40);
        self.voiceBtn = voiceBtn;
        [self addSubview:self.voiceBtn];
        
        //表情按钮
        UIButton *faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        faceBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [faceBtn setImage:[UIImage imageNamed:@"emoji.png"] forState:UIControlStateNormal];
        [faceBtn setImage:[UIImage imageNamed:@"emoji_h.png"] forState:UIControlStateHighlighted];
        [faceBtn addTarget:self action:@selector(onFaceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        faceBtn.frame = CGRectMake(ScreenWidth - 75,4.5,40,40);
        self.faceBtn = faceBtn;
        [self addSubview:self.faceBtn];
        
        //更多按钮
        UIButton *moreBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [moreBtn setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        [moreBtn setImage:[UIImage imageNamed:@"add_green.png"] forState:UIControlStateHighlighted];
        [moreBtn addTarget:self action:@selector(onMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        moreBtn.frame = CGRectMake(ScreenWidth - 40,4.5,40,40);
        self.moreBtn = moreBtn;
        [self addSubview:self.moreBtn];
        
        //给键盘注册通知
        [self initNotification];
        
    }
    return self;
}

-(void)initNotification
{
    //给键盘注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}



#pragma mark - HPGrowingTextViewDelegate

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    NSLog(@"点了文字输入框");
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    NSLog(@"改变高度");
    float diff = growingTextView.frame.size.height - height;
    CGRect rect = self.frame;
    rect.size.height -= diff;
    rect.origin.y += diff;
    self.frame = rect;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    NSLog(@"点了发送");
    return YES;
}


#pragma mark - private methods
#pragma mark 点击发送
- (void)sendAction
{
    if (self.textView.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendTextAction:)])
        {
            [self.delegate sendTextAction:self.textView.text];
        }
        self.textView.text = @"";//输入框置空（这里置空是不是最合适的位置）
    }
}


#pragma mark 键盘高度回调事件
- (void)callbackAction {
    
    if(self.delegate&&[self.delegate respondsToSelector:@selector(keyboardAction:)]) {
        
        [self.delegate keyboardAction:self.frame.origin.y];
    }
}

#pragma mark 弹出键盘事件
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        self.frame = CGRectMake(0, keyBoardFrame.origin.y-self.frame.size.height-44-20,ScreenWidth,self.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    self.currentState = XUYMViewStateShowNormal;
    [self.textView becomeFirstResponder];
    //回调
    [self callbackAction];
}

#pragma mark 隐藏键盘事件
-(void)inputKeyboardWillHide:(NSNotification *)notification
{
    if(self.currentState == XUYMViewStateShowNormal)
    {
        [self hideKeyBoard];
    }
}



//隐藏键盘（这个方法还要封装一些其他能力进去）
- (void)hideKeyBoard {

//    [self.textView resignFirstResponder];
    if(self.currentState != XUYMViewStateShowNone) {
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.frame;
            if (self.frame.size.height > 49) {
                frame.origin.y = superView.frame.size.height - self.frame.size.height;
            } else {
                frame.origin.y = superView.frame.size.height - 49;
            }
            self.frame = frame;

        } completion:^(BOOL finished) {
        }];

        [self.textView resignFirstResponder];
        self.currentState = XUYMViewStateShowNone;
        [self callbackAction];
    }
}

//音频按钮的响应方法
- (void)onVoiceBtnClick
{
    isVoiceModel=!isVoiceModel;
    [self hideKeyBoard];
    [self updateVoiceModel];
    
    if ([self.textView isHidden] == NO) {
        [self.textView becomeFirstResponder];
    } else {
        [self.faceBtn setImage:[UIImage imageNamed:@"emoji.png"] forState:UIControlStateNormal];
    }
    
    //麦克风权限获取情况
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            isAudioGranted = granted;
        }];
    }
}

//更多按钮（+号按钮）响应方法
- (void)onMoreBtnClick
{
    isVoiceModel = NO;
    [self updateVoiceModel];
    
    if (self.frame.origin.y == superView.bounds.size.height-self.frame.size.height)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=self.frame;
            frame.origin.y -= 200;
            self.frame = frame;

        } completion:^(BOOL finished) {
        }];
        self.currentState = XUYMViewStateShowMore;
        [self callbackAction];
        return ; //直接返回了
    }
    
    if (self.currentState == XUYMViewStateShowMore)
    {
        [self.textView becomeFirstResponder];
    }
    else
    {
        self.currentState = XUYMViewStateShowMore;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0,superView.frame.size.height-200-self.frame.size.height,ScreenWidth,self.frame.size.height);
            [self.textView resignFirstResponder];
        } completion:^(BOOL finished) {
        }];
    }
    [self callbackAction];
    
}


//给根据isVoiceModel状态更新按钮
-(void)updateVoiceModel
{
    [self.voiceBtn setImage:[UIImage imageNamed:isVoiceModel?@"keyboard.png":@"voice.png"] forState:UIControlStateNormal];
    [self.recordBtn setHidden:!isVoiceModel];
    [self.textView setHidden:isVoiceModel];
}




@end
