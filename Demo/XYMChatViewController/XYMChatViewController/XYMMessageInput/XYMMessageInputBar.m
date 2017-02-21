//
//  MessageInputBar.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMMessageInputBar.h"
#import <AVFoundation/AVFoundation.h>
#import "MyUserInfo.h"

@interface XYMMessageInputBar()
{
    CGRect oldRect;
    CGRect curRect;
    BOOL isGetRect;
    BOOL isAudioGranted_;     //纪录麦克风权限
}

@end

@implementation XYMMessageInputBar

@synthesize currentState=currentState_;

- (id)initWithFrame:(CGRect)frame superView:(const UIView*)view
{
    self = [super initWithFrame:frame];
    if (self) {
        currentState_ = XYMViewStateShowNone;
        isVoiceModel = NO;
        superView = view;
        isAudioGranted_ = YES;
        
        self.backgroundColor = UIColorFromRGB(0xe1e1e1);
        
        //可以自适应高度的文本输入框
        textView_ = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(45, 8, SCREENWIDTH - 125, 30)];
        textView_.isScrollable = NO;
        textView_.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        textView_.minNumberOfLines = 1;
        textView_.maxNumberOfLines = 4;

        textView_.font = [UIFont systemFontOfSize:15.0f];
        textView_.delegate = self;
        textView_.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        textView_.backgroundColor = [UIColor whiteColor];
        textView_.placeholder = @"请输入消息";
        textView_.returnKeyType = UIReturnKeySend;
        textView_.layer.cornerRadius=5;
        textView_.enablesReturnKeyAutomatically = YES;
        [self addSubview:textView_];
        
        recordBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [recordBtn_ setFrame:CGRectMake(45, 9, SCREENWIDTH - 125, 30)];
        [recordBtn_ setBackgroundImage:[UIImage imageNamed:@"voice_bg.png"] forState:UIControlStateNormal];

        [recordBtn_ setTitle:@"按住说话" forState:UIControlStateNormal];
        [recordBtn_ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [recordBtn_ addTarget:self action:@selector(onStartRecord) forControlEvents:UIControlEventTouchDown];
        [recordBtn_ addTarget:self action:@selector(onEndRecord) forControlEvents:UIControlEventTouchUpInside];
        [recordBtn_ addTarget:self action:@selector(onStopRecord) forControlEvents:UIControlEventTouchUpOutside]; //添加按下后向上滑动取消语音操作
        [recordBtn_ setHidden:YES];
        [self addSubview:recordBtn_];
        
        //音频按钮
        voiceBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [voiceBtn_ setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
        [voiceBtn_ setImage:[UIImage imageNamed:@"voice_h.png"] forState:UIControlStateHighlighted];
        [voiceBtn_ addTarget:self action:@selector(onVoiceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        voiceBtn_.frame = CGRectMake(0,4.5,40,40);
        [self addSubview:voiceBtn_];
        
        //表情按钮
        faceBtn_ = [UIButton buttonWithType:UIButtonTypeCustom];
        faceBtn_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [faceBtn_ setImage:[UIImage imageNamed:@"emoji.png"] forState:UIControlStateNormal];
        [faceBtn_ setImage:[UIImage imageNamed:@"emoji_h.png"] forState:UIControlStateHighlighted];
        [faceBtn_ addTarget:self action:@selector(onFaceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        faceBtn_.frame = CGRectMake(SCREENWIDTH - 75,4.5,40,40);
        [self addSubview:faceBtn_];
        
        //更多按钮
        moreBtn_=[UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [moreBtn_ setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        [moreBtn_ setImage:[UIImage imageNamed:@"add_green.png"] forState:UIControlStateHighlighted];
        [moreBtn_ addTarget:self action:@selector(onMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        moreBtn_.frame = CGRectMake(SCREENWIDTH - 40,4.5,40,40);
        [self addSubview:moreBtn_];
        
        CGRect faceRect = CGRectMake(0, CGRectGetMaxY(self.frame),SCREENWIDTH,keyboardHeight);
        [[XYMMessageInputManager sharedInstance] initFaceWithFrame:faceRect superView:superView delegate:self];

        CGRect moreRect = CGRectMake(0, CGRectGetMaxY(self.frame),SCREENWIDTH,MoreMenuHeight);
        
        //“+”更多选项
        [[XYMMessageInputManager sharedInstance] initMoreMenuWithFrame:moreRect superView:superView delegate:self];

        [self initNotification];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if(!isGetRect)
    {
        isGetRect = YES;
        curRect = oldRect = self.frame;
    }
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

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)cleanData
{
    superView=nil;
    self.delegate=nil;
    [[XYMMessageInputManager sharedInstance] clearDelegate];
    [self removeNotification];
}

-(void)dealloc
{
    [self cleanData];
}

-(NSString *)curText
{
    return textView_.text;
}

-(void)updateVoiceModel
{
    [voiceBtn_ setImage:[UIImage imageNamed:isVoiceModel?@"keyboard.png":@"voice.png"] forState:UIControlStateNormal];
    [recordBtn_ setHidden:!isVoiceModel];
    [textView_ setHidden:isVoiceModel];
}

#pragma mark 填充初始文字
- (void)fitTextView:(NSString *)text
{
    textView_.text = text;
}

- (void)addToTextView:(NSString *)aText
{
    NSMutableString* string=[NSMutableString stringWithString:textView_.text];
    NSRange rang=textView_.selectedRange;
    [string insertString:aText atIndex:rang.location];
    textView_.text=string;
    rang.location+=aText.length;
    textView_.selectedRange=rang;
    [textView_ setNeedsDisplay];
}

#pragma mark 点击发送
- (void)sendAction
{
    NSLog(@"点击键盘上的发送按钮");
    if (textView_.text.length > 0) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendTextAction:)])
        {
            [self.delegate sendTextAction:textView_.text];
        }
        textView_.text = @"";
    }
}

#pragma mark 隐藏键盘
-(void)hideKeyBoard
{
    if(currentState_!=XYMViewStateShowNone)
    {
        [UIView animateWithDuration:Time animations:^{
            CGRect frame=self.frame;
            if (self.frame.size.height>XYMkTabHeight) {
                frame.origin.y=superView.frame.size.height-self.frame.size.height;
            } else {
                frame.origin.y=superView.frame.size.height-XYMkTabHeight;
            }
            self.frame = frame;
            [[XYMMessageInputManager sharedInstance] updateFaceViewFrame:CGRectMake(0, CGRectGetMaxY(self.frame),SCREENWIDTH,keyboardHeight)];
            [[XYMMessageInputManager sharedInstance] updateMoreMenuViewFrame:CGRectMake(0, CGRectGetMaxY(self.frame),SCREENWIDTH,MoreMenuHeight)];
        } completion:^(BOOL finished) {
        }];
        [self resetFaceBtn:YES];
        [textView_ resignFirstResponder];
        currentState_=XYMViewStateShowNone;
        [self callbackAction];
    }
}

#pragma mark 键盘高度回调事件
-(void)callbackAction
{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(keyboardAction:)])
    {
        [self.delegate keyboardAction:self.frame.origin.y];
    }
}

#pragma mark 弹出键盘事件
-(void)inputKeyboardWillShow:(NSNotification *)notification
{
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

            self.frame = CGRectMake(0, keyBoardFrame.origin.y-self.frame.size.height-XYMkNavHeight-XYMkStatusHeight,SCREENWIDTH,self.frame.size.height);

    } completion:^(BOOL finished) {
    }];
    currentState_=XYMViewStateShowNormal;
    [textView_ becomeFirstResponder];
    //回调
    [self callbackAction];
}

#pragma mark 隐藏键盘事件
-(void)inputKeyboardWillHide:(NSNotification *)notification
{
    if(currentState_ == XYMViewStateShowNormal)
    {
        [self hideKeyBoard];
    }
}

- (void)onStartRecord
{
    if (!isAudioGranted_)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请开启设备麦克风功能[设置->隐私->麦克风]" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alertView show];
    }
    else
    {
        NSLog(@"onStartRecord");
        if (self.delegate && [self.delegate respondsToSelector:@selector(startRecording:)]){
            [self.delegate startRecording:self];
        }
        //60秒后,自动执行结束录音操作
        [self performSelector:@selector(noticeEndRecord:) withObject:nil afterDelay:55];
    }
}

- (void)noticeEndRecord:(id)sender
{
    //向按钮录音按钮发送抬起消息
    [recordBtn_ sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)onEndRecord
{
    NSLog(@"onEndRecord");
    if (self.delegate && [self.delegate respondsToSelector:@selector(endRecording:isSend:)]) {
        [self.delegate endRecording:self isSend:YES];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)onStopRecord
{
    NSLog(@"onStopRecord");
    if (self.delegate && [self.delegate respondsToSelector:@selector(endRecording:isSend:)]) {
        [self.delegate endRecording:self isSend:NO];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)onVoiceBtnClick
{
    isVoiceModel=!isVoiceModel;
    [self hideKeyBoard];
    [self updateVoiceModel];
    
    if(isVoiceModel)
    {
        CGRect rect = self.frame;
        self.frame = oldRect;
        curRect = rect;
    }
    else
    {
        self.frame = curRect;
    }
    
    if ([textView_ isHidden] == NO) {
        [textView_ becomeFirstResponder];
    } else {
        [faceBtn_ setImage:[UIImage imageNamed:@"emoji.png"] forState:UIControlStateNormal];
    }
    
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            isAudioGranted_ = granted;
        }];
    }
}

- (void)hideFaceView:(BOOL)hidden
{
    CGRect frame=CGRectMake(0, hidden?SCREENHEIGHT:CGRectGetMaxY(self.frame),SCREENWIDTH,keyboardHeight);
    [[XYMMessageInputManager sharedInstance] updateFaceViewFrame:frame];
}

- (void)hideMoreMenuView:(BOOL)hidden
{
    CGRect frame=CGRectMake(0, hidden?SCREENHEIGHT:CGRectGetMaxY(self.frame),SCREENWIDTH,MoreMenuHeight);
    [[XYMMessageInputManager sharedInstance] updateMoreMenuViewFrame:frame];
}

-(void)resetFaceBtn:(BOOL)flag
{
    if(faceBtn_){
        [faceBtn_ setImage:[UIImage imageNamed:flag?@"emoji.png":@"keyboard.png"] forState:UIControlStateNormal];
    }
}

- (void)onMoreBtnClick
{
    isVoiceModel = NO;
    [self updateVoiceModel];
    
    if (self.frame.origin.y==superView.bounds.size.height-self.frame.size.height)
    {
        [UIView animateWithDuration:Time animations:^{
            CGRect frame=self.frame;
            frame.origin.y-=MoreMenuHeight;
            self.frame=frame;
            [self hideMoreMenuView:NO];
            [self hideFaceView:YES];
        } completion:^(BOOL finished) {
        }];
        currentState_=XYMViewStateShowMore;
        [self callbackAction];
        return ; //直接返回了
    }
    
    if (currentState_==XYMViewStateShowMore)
    {
        [self hideMoreMenuView:YES];
        [textView_ becomeFirstResponder];
    }
    else
    {
        currentState_=XYMViewStateShowMore;
        [UIView animateWithDuration:Time animations:^{
            self.frame = CGRectMake(0,superView.frame.size.height-MoreMenuHeight-self.frame.size.height,SCREENWIDTH,self.frame.size.height);
            [textView_ resignFirstResponder];
            [self hideMoreMenuView:NO];
            [self hideFaceView:YES];
        } completion:^(BOOL finished) {
            [self resetFaceBtn:YES];
        }];
    }
    [self callbackAction];
    
}

- (void)onFaceBtnClick
{
    isVoiceModel = NO;
    [self updateVoiceModel];
    if (isVoiceModel) {
        isVoiceModel = NO;
        [voiceBtn_ setImage:[UIImage imageNamed:isVoiceModel?@"keyboard.png":@"voice.png"] forState:UIControlStateNormal];
        [recordBtn_ setHidden:!isVoiceModel];
        [textView_ setHidden:isVoiceModel];
    }
    if (self.frame.origin.y==superView.bounds.size.height-self.frame.size.height)
    {
        [UIView animateWithDuration:Time animations:^{
            CGRect frame=self.frame;
            frame.origin.y-=keyboardHeight;
            self.frame=frame;
            [self hideMoreMenuView:YES];
            [self hideFaceView:NO];
        } completion:^(BOOL finished) {
            
        }];
        currentState_=XYMViewStateShowFace;
        [self resetFaceBtn:NO];
        [self callbackAction];
        return ; //直接返回了
    }
    
    if (currentState_==XYMViewStateShowFace)
    {
        [self hideFaceView:YES];
        [textView_ becomeFirstResponder];
        [self resetFaceBtn:YES];
    }
    else
    {
        currentState_=XYMViewStateShowFace;
        [UIView animateWithDuration:Time animations:^{
            self.frame = CGRectMake(0,superView.frame.size.height-keyboardHeight-self.frame.size.height,SCREENWIDTH,self.frame.size.height);
            [textView_ resignFirstResponder];
            [self hideMoreMenuView:YES];
            [self hideFaceView:NO];
        } completion:^(BOOL finished) {
            [self resetFaceBtn:NO];
        }];
    }
    [self callbackAction];
}

#pragma mark - ------------FaceViewDelegate 的代理方法----------------

-(void)itemClickEvent:(NSString *)content
{
    [self addToTextView:content];
}

-(void)deleteClickEvent
{
    NSString* str=textView_.text;
    if(str.length<=0)
        return;
    NSInteger n=-1;
    if( [str characterAtIndex:str.length-1] == ']'){
        for(NSInteger i=str.length-1;i>=0;i--){
            if( [str characterAtIndex:i] == '[' ){
                n = i;
                break;
            }
        }
    }
    if(n>=0)
        textView_.text = [str substringWithRange:NSMakeRange(0,n)];
    else
        textView_.text = [str substringToIndex:str.length-1];
}

-(void)sendClickEvent
{
    [self sendAction];
}

#pragma mark - ------------MoreMenuViewDelegate 的代理方法----------------
//“+”号按钮弹出的更多选项点击的时候
-(void)didSelecteMenuItem:(XYMMoreMenuItem *)shareMenuItem atIndex:(NSInteger)index
{
    MyUserInfo *myInfo = [MyUserInfo myInfo];
    switch (index) {
        case 0:
            if(self.delegate&&[self.delegate respondsToSelector:@selector(pickPhoto:)])
            {
                [self.delegate pickPhoto:self];
            }
            break;
        case 1:
            if(self.delegate&&[self.delegate respondsToSelector:@selector(openCamera:)])
            {
                [self.delegate openCamera:self];
            }
            break;
        case 2:
            if(self.delegate && [self.delegate respondsToSelector:@selector(sendFollow:)])
            {
                [self.delegate sendFollow:self];
            }
            break;
            //加了一个健教育的按钮响应
            default:
            break;
    }
}

#pragma mark - ------------HPGrowingTextViewDelegate 的代理方法----------------

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self resetFaceBtn:YES];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = growingTextView.frame.size.height-height;
	CGRect rect = self.frame;
    rect.size.height -= diff;
    rect.origin.y += diff;
	self.frame = rect;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self sendAction];
    return YES;
}

@end
