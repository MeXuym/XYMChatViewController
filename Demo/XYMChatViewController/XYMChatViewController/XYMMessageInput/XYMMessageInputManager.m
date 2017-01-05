
//
//  FaceManager.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//  键盘工具条点“+”的时候弹出的选择项

#import "XYMMessageInputManager.h"
#import "MyUserInfo.h"

static XYMMessageInputManager* sharedInstance_=nil;

@implementation XYMMessageInputManager

+(XYMMessageInputManager *)sharedInstance
{
    @synchronized(self){
        if(sharedInstance_ == nil){
           sharedInstance_ = [[XYMMessageInputManager alloc] init];
        }
    }
    return sharedInstance_;
}

-(void)initFaceWithFrame:(CGRect)frame superView:(const UIView*)superView delegate:(id<XYMFaceViewDelegate>)delegate
{
    if(!faceView_)
    {
        faceView_=[[XYMFaceView alloc] init];
    }
    faceView_.frame = frame;
    [faceView_ initViews];
    faceView_.delegate = delegate;
    [superView addSubview:faceView_];
}

-(void)initMoreMenuWithFrame:(CGRect)frame superView:(const UIView *)superView delegate:(id<XYMMoreMenuViewDelegate>)delegate
{
    if(!moreMenuView_)
    {
        moreMenuView_ = [[XYMMoreMenuView alloc] initWithFrame:frame];
        XYMMoreMenuItem *sharePicItem = [[XYMMoreMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"add_photo_nor"]
                                                                highlightIconImage:[UIImage imageNamed:@"add_photo_sel"]
                                                                             title:@"照片"];
        XYMMoreMenuItem *shareCamaraItem = [[XYMMoreMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"add_camara_nor"]
                                                                  highlightIconImage:[UIImage imageNamed:@"add_camara_sel"]
                                                                               title:@"拍照"];
        XYMMoreMenuItem *followItem = [[XYMMoreMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"add_interview_nor"]
                                                             highlightIconImage:[UIImage imageNamed:@"add_interview_sel"]
                                                                          title:@"随访问卷"];
        moreMenuView_.moreMenuItems = @[sharePicItem,shareCamaraItem,followItem];
        [moreMenuView_ reloadData];
    }
    else
    {
        moreMenuView_.frame=frame;
    }
    moreMenuView_.delegate = delegate;
    [superView addSubview:moreMenuView_];
}

-(NSString *)emjioForRegex:(NSString *)regex
{
    if(!faceView_)
    {
        faceView_ = [[XYMFaceView alloc] init];
    }
    
    return [faceView_ imageNameForEmotionRegex:regex];
}

-(NSString *)emjioForKey:(NSString *)key
{
    if(!faceView_)
    {
        faceView_ = [[XYMFaceView alloc] init];
    }

    return [faceView_ imageNameForEmotionName:key];
}

-(NSString *)nameForRegex:(NSString *)regex
{
    if(!faceView_)
    {
        faceView_ = [[XYMFaceView alloc] init];
    }
    
    return [faceView_ faceNameForEmotionRegex:regex];
}

-(void)updateFaceViewFrame:(CGRect)frame
{
    if(faceView_)
    {
        faceView_.hidden=NO;
        faceView_.frame=frame;
    }
}

-(void)updateMoreMenuViewFrame:(CGRect)frame
{
    if(moreMenuView_)
    {
        //根据医生的分享权限来变
        XYMMoreMenuItem *sharePicItem = [[XYMMoreMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"add_photo_nor"]
                                                                highlightIconImage:[UIImage imageNamed:@"add_photo_sel"]
                                                                             title:@"照片"];
        XYMMoreMenuItem *shareCamaraItem = [[XYMMoreMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"add_camara_nor"]
                                                                   highlightIconImage:[UIImage imageNamed:@"add_camara_sel"]
                                                                                title:@"拍照"];
        XYMMoreMenuItem *followItem = [[XYMMoreMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"add_interview_nor"]
                                                              highlightIconImage:[UIImage imageNamed:@"add_interview_sel"]
                                                                           title:@"随访问卷"];
        
        MyUserInfo *myInfo = [MyUserInfo myInfo];
        if(myInfo.isActivityDrShare){
            moreMenuView_.moreMenuItems = @[sharePicItem,shareCamaraItem,followItem];
            [moreMenuView_ reloadData];
        }else{
            moreMenuView_.moreMenuItems = @[sharePicItem,shareCamaraItem,followItem];
            [moreMenuView_ reloadData];
        }
        moreMenuView_.hidden=NO;
        moreMenuView_.frame=frame;
    }
}

-(void)clearDelegate
{
    faceView_.delegate=nil;
    moreMenuView_.delegate=nil;
}

@end
