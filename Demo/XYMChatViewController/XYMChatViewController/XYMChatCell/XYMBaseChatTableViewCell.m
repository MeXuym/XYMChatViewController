//
//  CWPTableViewCell.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-12.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMBaseChatTableViewCell.h"

@interface XYMBaseChatTableViewCell()
{
    UIActivityIndicatorView* loadView_;
    UIButton* timeout_;
}

@end

@implementation XYMBaseChatTableViewCell

+(int)currentCellHeight:(XYMMessageItemAdaptor*)adaptor
{
    return 0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        timeLabel_ = [[UILabel alloc] init];
        timeLabel_.textColor = [UIColor whiteColor];
        timeLabel_.font = [UIFont systemFontOfSize:12];
        timeLabel_.textAlignment = NSTextAlignmentCenter;
        timeLabel_.layer.cornerRadius = 5;
        timeLabel_.layer.backgroundColor = [UIColorFromRGB(0x262626) colorWithAlphaComponent:0.3].CGColor;
        timeLabel_.alpha = 0.5;
        [self.contentView addSubview:timeLabel_];
        
        loadView_ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        //        timeout_=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeout_icon.png"]];
        timeout_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [timeout_ setBackgroundImage:[UIImage imageNamed:@"chat_error.png"] forState:UIControlStateNormal];
        [timeout_ setBackgroundImage:[UIImage imageNamed:@"chat_error_h.png"] forState:UIControlStateHighlighted];
        [timeout_ addTarget:self action:@selector(TimeOutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)reloadTimeWithString:(NSString *)time hidden:(BOOL)hidden
{
    timeLabel_.text = time;
    timeLabel_.hidden = hidden;
    
    CGSize size=[adaptor_.timeSpan sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:adaptor_.font, NSFontAttributeName, nil]];
    timeLabel_.frame = CGRectMake((ScreenWidth-size.width)/2, 5, size.width, 25);
}

-(void)updateStauts:(BOOL)hidden
{
    if(loadView_){
        hidden?[loadView_ stopAnimating]:[loadView_ startAnimating];
        loadView_.hidden=hidden;
    }
}

-(void)fillWithData:(XYMMessageItemAdaptor*)adaptor
{
    [self cleanData];
    adaptor_=adaptor;
    [self reloadTimeWithString:adaptor_.timeSpan hidden:adaptor_.isHideTime];
    
    if(adaptor_.msgType != XYMMessageTypeSystem)
    {
        if(adaptor_.isSelf)
        {
            if(adaptor_.isTimeOut)
            {
                [self.contentView addSubview:timeout_];
            }
            else if(!adaptor_.isSend)
            {
                [self.contentView addSubview:loadView_];
                [self updateStauts:adaptor_.isSend];
            }
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = [self getContentFrame];
    loadView_.frame=CGRectMake(frame.origin.x, CGRectGetMidY(frame)-10, 20, 20);
    timeout_.frame=CGRectMake(frame.origin.x, CGRectGetMidY(frame)-10, 20, 20);
}

-(CGRect)getContentFrame
{
    return CGRectZero;
}

-(void)reSendAction
{
}

-(void)cleanData
{
    if(loadView_){
        [loadView_ removeFromSuperview];
    }
    if(timeout_){
        [timeout_ removeFromSuperview];
    }
}

-(void)dealloc
{
    timeLabel_=nil;
    [self cleanData];
}

-(void)TimeOutBtnClick:(id)sender
{
    [self reSendAction];
}

@end
