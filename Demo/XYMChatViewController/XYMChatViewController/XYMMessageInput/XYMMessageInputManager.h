//
//  FaceManager.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMFaceView.h"
#import "XYMMoreMenuView.h"

typedef enum {
    XYMViewStateShowNone,//没显示的状态
    XYMViewStateShowNormal,//普通键盘状态
    XYMViewStateShowFace,//显示表情状态
    XYMViewStateShowMore,//显示更多的状态
}XYMMesssageBarState;

@interface XYMMessageInputManager : NSObject
{
    XYMFaceView* faceView_;
    XYMMoreMenuView* moreMenuView_;
}

+(XYMMessageInputManager *) sharedInstance;
-(void)initFaceWithFrame:(CGRect)frame superView:(const UIView*)superView delegate:(id<XYMFaceViewDelegate>)delegate;
-(void)initMoreMenuWithFrame:(CGRect)frame superView:(const UIView*)superView delegate:(id<XYMMoreMenuViewDelegate>)delegate;
-(void)clearDelegate;
#pragma 通过字符查找表情图片字符串
-(NSString *)emjioForRegex:(NSString *)regex;
#pragma 通过字符查找表情名字
-(NSString *)nameForRegex:(NSString *)regex;
#pragma 通过名字查找表情图片字符串
-(NSString*)emjioForKey:(NSString*)key;
#pragma 更新表情控件的Frame
-(void)updateFaceViewFrame:(CGRect)frame;
#pragma 更新更多栏的Frame
-(void)updateMoreMenuViewFrame:(CGRect)frame;

@end
