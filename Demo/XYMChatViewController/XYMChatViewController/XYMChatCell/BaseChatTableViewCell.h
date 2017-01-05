//
//  CWPTableViewCell.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMMessageItemAdaptor.h"

@interface XYMBaseChatTableViewCell : UITableViewCell
{
    UILabel* timeLabel_;
    XYMMessageItemAdaptor* adaptor_;
}

#pragma 计算Cell的高度
+(int)currentCellHeight:(XYMMessageItemAdaptor*)adaptor;
#pragma 填充数据
-(void)fillWithData:(XYMMessageItemAdaptor*)adaptor;
#pragma 清空数据
-(void)cleanData;

-(CGRect)getContentFrame;
-(void)reSendAction;

@end

@protocol XYMBaseChatTableViewCellDelegate <NSObject>

#pragma mark 头像点击回调
-(void)didClickedUserImage:(XYMMessageItemAdaptor*)item;
#pragma mark 重新发送回调
-(void)didClickedReSend:(XYMMessageItemAdaptor*)item;
#pragma mark cell点击回调
-(void)didClickNomarl:(XYMMessageItemAdaptor*)item;
#pragma mark cell长按回调
-(void)didLongPress:(XYMMessageItemAdaptor*)item cellRect:(CGRect)rect showPoint:(CGPoint)point;

@end
