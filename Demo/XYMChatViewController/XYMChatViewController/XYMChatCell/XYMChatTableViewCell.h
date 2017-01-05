//
//  ContentTableViewCell.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMBaseChatTableViewCell.h"

@protocol XYMChatTableViewCellDelegate;

@interface XYMChatTableViewCell : XYMBaseChatTableViewCell

@property (nonatomic, assign) id<XYMChatTableViewCellDelegate> delegate;

-(void)startVoicePlay;
-(void)stopVoicePlay;

@end

@protocol XYMChatTableViewCellDelegate <XYMBaseChatTableViewCellDelegate>
@optional
#pragma mark 图片上传成功后回调
-(void)didUpLoadImgComplete:(XYMMessageItemAdaptor*)item;
#pragma mark 图片点击回调
-(void)didClickedMsgImage:(XYMMessageItemAdaptor*)item;


-(void)didDownLoadVoiceComplete:(XYMMessageItemAdaptor*)item;
-(void)didUpLoadVoiceComplete:(XYMMessageItemAdaptor*)item;


-(void)didClickedMsgVoice:(XYMMessageItemAdaptor*)item;
-(void)didClickedMsgShare:(XYMMessageItemAdaptor*)item;
-(void)didClickedMsgHealthNewsShare:(XYMMessageItemAdaptor*)item; //健康教育

-(void)didClickedMsgHealthTipsShare:(XYMMessageItemAdaptor*)item; //优惠券

#pragma 以下备用
-(void)didCopyMsg:(XYMMessageItemAdaptor*)item;
-(void)didDeleteMsg:(XYMMessageItemAdaptor*)item;
-(void)didClickedURL:(NSTextCheckingResult *)linkInfo;



@end