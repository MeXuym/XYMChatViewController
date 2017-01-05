//
//  WaitingWindow.h
//  test120107
//
//  Created by wangweike on 12-2-10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//  用作等待窗口

#import <Foundation/Foundation.h>
#import "IndicatorView.h"

@interface TransportationToolbar : UIToolbar 
@end

@class WaitingWindow;

@protocol PWaitingWindowDelegate
-(void)onCancelWaitingWindowClicked;
@end

@interface AViewController : UIViewController
@end


@interface WaitingWindow : UIWindow {
	IndicatorView* iIndicatorView;
    UIView* iCustomView;
    
	UIView* iBarView;//带交互的视图
    id<PWaitingWindowDelegate> iDelegate;
    
	BOOL iModal;//current modal state
    
    AViewController* viewController;//用来接收旋转事件，以让UIWindow的子view能够旋转
    
    int posOffsetXWhenHide_;//隐藏时，也把WaitingWindow的位置移到很远，防止一个怪异情况有时可能出现：把app切到后台，再切回前台，本来已经隐藏的window又显示了。
}

-(id)initWithIndicatorType:(IndicatorType)aIndicatorType;

-(void)showCustomView:(UIView*)customView;
-(void)showModalWithCustomView:(UIView*)customView;
-(void)showModalWithCustomView:(UIView*)customView masking:(BOOL)masking;
-(void)showModalWithDelegate:(id<PWaitingWindowDelegate>)aDelegate buttonTitle:(NSString*)aButtonTitle;
-(void)showModal;
-(void)show;
-(void)hide;
-(void)setMessage:(NSString*)newMsg;
-(void)setProgress:(float)aProgress;
@end
