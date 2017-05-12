//
//  XUYMMessageInputBar.h
//  XYMChatViewController
//
//  Created by xuym on 2017/5/10.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XUYMMessageInputManager.h"

@protocol XUYMMessageInputBarDelegate <NSObject>

@optional
#pragma 键盘高度变化代理
- (void)keyboardAction:(CGFloat)height;

@end


@interface XUYMMessageInputBar : UIView
{
    //成员变量
    BOOL isVoiceModel;//用来表示正在发语音的状态
    const UIView* superView;
}

@property (nonatomic,assign) XUYMMesssageBarState currentState; //表示现在的输出工具条的状态
@property (nonatomic,assign) id<XUYMMessageInputBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame superView:(const UIView*)view;//提供一个自定义的初始化方法
- (void)hideKeyBoard;//隐藏或缩下键盘

@end
