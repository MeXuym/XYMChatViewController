//
//  ChatLogViewCell.m
//  healthcoming
//
//  Created by Franky on 15/8/18.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "ChatLogViewCell.h"
#import "XYMVoiceContentView.h"
#import "XYMMessageContentButton.h"
#import "XYMNewsContentView.h"
#import "XYMHealthShareContentView.h"
@implementation ChatLogViewCell
{
    UILabel* nameLabel;
    UILabel* timeLabel;
    UILabel* contentLabel;
    UIImageView* contenImage;
    
    XYMMessageItemAdaptor* adaptor;
    
    XYMVoiceContentView* voiceContent;
    XYMMessageContentButton *contentBgBtn;
    XYMNewsContentView* newsView;
    XYMHealthShareContentView *healthShareView;
}

@synthesize delegate;

+(CGFloat)heightForLogCell:(XYMMessageItemAdaptor *)adaptor
{
    CGFloat cellHeight = 0;
    if(adaptor.msgType == XYMMessageTypeText)
    {
        NSString* msgContent = adaptor.msgContent;
        CGSize contentSize = [msgContent boundingRectWithSize:CGSizeMake(ScreenWidth - 40, 1000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:@{NSFontAttributeName:Font15Size}
                                                      context:nil].size;
        cellHeight = contentSize.height + 40 + 10*2;
    }
    else if (adaptor.msgType == XYMMessageTypePicture)
    {
        cellHeight = 120 + 40 + 10;
    }
    else if (adaptor.msgType == XYMMessageTypeVoice)
    {
        cellHeight = 20 + ChatContentTop + ChatContentBottom + 40 + 10*2;
    }
    else if (adaptor.msgType == XYMMessageTypeShare)
    {
        cellHeight = 20 + 90 + 10*2;
        
        //加了一个优惠券类型
    }else if(adaptor.msgType == XYMMessageTypeShareHealthNews || adaptor.msgType == XYMMessageTypeSharePublicClass || adaptor.msgType == XYMMessageTypeShareHealthTips) {
        
        cellHeight = 20 + 90 + 10*2;
    }
    return cellHeight;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 120, 20)];
        nameLabel.textColor = LightGreen;
        nameLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 130, 10, 120, 20)];//(ScreenWidth - 100, 10, 80, 20)
        timeLabel.textColor = LightGray;
        timeLabel.font = [UIFont systemFontOfSize:15];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:timeLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, ScreenWidth - 40, 30)];
        contentLabel.numberOfLines = 0;
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.font = Font15Size;
        [self.contentView addSubview:contentLabel];
        
        contenImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 40, 120, 120)];
        contenImage.contentMode = UIViewContentModeScaleAspectFill;
        contenImage.clipsToBounds = YES;
        contenImage.userInteractionEnabled = YES;
        [contenImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)]];
        [self.contentView addSubview:contenImage];
        
        contentBgBtn = [XYMMessageContentButton buttonWithType:UIButtonTypeCustom];
        [contentBgBtn addTarget:self action:@selector(voiceTapped:)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:contentBgBtn];
    }
    return self;
}

-(void)fillWithData:(XYMMessageItemAdaptor *)data
{
    [self cleanData];
    
    adaptor = data;
    
    CGSize contentSize = CGSizeZero;
    
    nameLabel.text = data.userName;
    timeLabel.text = data.timeSpan;
    
    if(data.msgType == XYMMessageTypePicture)
    {
        contentSize = CGSizeMake(ChatPicWH, ChatPicWH);
        NSString* url = [data.picUrls objectWithKey:DSamllPic];
        contenImage.hidden = NO;
        [contenImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"img_load_100.png"]];
    }
    else if (data.msgType == XYMMessageTypeVoice)
    {
        contentSize = CGSizeMake(80, 20);
        
        contentBgBtn.hidden = NO;
        [contentBgBtn setContentEdgeInsets:UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight)];
        [contentBgBtn setBackgroundImage:[[UIImage imageNamed:@"message_bg_other.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 22)] forState:UIControlStateNormal];
        contentBgBtn.frame = CGRectMake(15, 40, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
        
        if(!voiceContent && adaptor.mediaData)
        {
            void (^completed)(XYMRequestContentView*, NSString*) = ^(XYMRequestContentView *view, NSString* url)
            {
                [adaptor updateVoiceUrl:url isLocal:YES];
                int second = adaptor.voiceSecond;
                [voiceContent voiceLength:second];
                [self updateVoiceWidth:second];
            };
            
            voiceContent = [[XYMVoiceContentView alloc] initDownLoadWithFrame:CGRectMake(15, 10, contentSize.width, contentSize.height)
                                                                  mediaDic:adaptor.mediaData
                                                                    isSelf:NO
                                                                  isUpload:NO];
            int second = adaptor.voiceSecond;
            [voiceContent voiceLength:second];
            [voiceContent startRequestWithCompleted:completed];
            [contentBgBtn addSubview:voiceContent];
            [self updateVoiceWidth:second];
        }
    }
    else if (data.msgType == XYMMessageTypeShare)
    {
        contentSize = CGSizeMake(185, 85);
        NSDictionary* follow = adaptor.mediaData;
        if(!newsView && follow)
        {
            newsView = [[XYMNewsContentView alloc] initWithFrame:CGRectMake(20, 40, contentSize.width, contentSize.height)];
            newsView.backgroundColor = UIColorFromRGB(0xf6f6f6);
            newsView.titleLabel.frame = CGRectMake(10, 5, self.frame.size.width-15, 20);
            newsView.logoImage.frame = CGRectMake(10, 30, 75, 48);
            NSString* title = [follow objectWithKey:@"modelTitel"];
            NSString* url = [follow objectWithKey:@"modelUrl"];
            NSString* typePhoto = [follow objectWithKey:@"typePhoto"];
            [newsView fillWithTitle:title url:url];
            if(data.isSelf)
            {
                newsView.statuslabel.text = @"点击查看";
                newsView.statuslabel.textColor = NormalGray;
            }
            else
            {
                newsView.statuslabel.text = @"已完成";
                newsView.statuslabel.textColor = NormalGreen;
            }
            [newsView.logoImage sd_setImageWithURL:[NSURL URLWithString:typePhoto] placeholderImage:[UIImage imageNamed:@"follow_cover.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                newsView.logoImage.frame = CGRectMake(10, 30, 50, 50);
            }];
            
            
            [self.contentView addSubview:newsView];
        }
    }
    
    else if (data.msgType == XYMMessageTypeShareHealthNews || data.msgType == XYMMessageTypeSharePublicClass || data.msgType == XYMMessageTypeShareHealthTips)
    {
        contentSize = CGSizeMake(185, 85);
        NSDictionary* follow = adaptor.mediaData;
        if(!healthShareView && follow)
        {
            healthShareView = [[XYMHealthShareContentView alloc] initWithFrame:CGRectMake(20, 40, contentSize.width, contentSize.height)];
            healthShareView.backgroundColor = UIColorFromRGB(0xf6f6f6);
            healthShareView.titleLabel.frame = CGRectMake(10, 5, self.frame.size.width-15, 20);
            healthShareView.logoImage.frame = CGRectMake(10, 30, 75, 48);
            NSString* title = [follow objectWithKey:@"shareTitle"];
            if (title.length >10) {
                NSString *nextTitle = [title substringToIndex:10];
                NSString *last = [nextTitle stringByAppendingString:@"..."];
                title = last; 
            }
            
            NSString* url = [follow objectWithKey:@"shareUrl"];
            NSString* typePhoto = [follow objectWithKey:@"shareLogo"];
            NSString *content = [follow objectForKey:@"shareContent"];
            [healthShareView fillWithTitle:title url:url content:content];
            
            [healthShareView.logoImage sd_setImageWithURL:[NSURL URLWithString:typePhoto] placeholderImage:[UIImage imageNamed:@"follow_cover.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                healthShareView.logoImage.frame = CGRectMake(10, 30, 50, 50);
                CGRect contentFrame = healthShareView.statuslabel.frame;
                
                contentFrame.size.height = 50;
                contentFrame.origin.y = 30;
                contentFrame.origin.x = CGRectGetMaxX(healthShareView.logoImage.frame)+10;
                contentFrame.size.width = contentSize.width - 50 -10-10-10;
                healthShareView.statuslabel.frame = contentFrame;
                
                CGRect titleRect = healthShareView.titleLabel.frame;
                titleRect.size.width = contentSize.width-10;
                healthShareView.titleLabel.numberOfLines = 0;
                healthShareView.titleLabel.frame = titleRect;
                
            }];
            
            
            [self.contentView addSubview:healthShareView];
        }
    }
    
    else
    {
        contentSize = [data.msgContent boundingRectWithSize:CGSizeMake(ScreenWidth - 40, 1000)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName:Font15Size}
                                               context:nil].size;
        contentLabel.hidden = NO;
        contentLabel.text = data.msgContent;
        CGRect frame = contentLabel.frame;
        frame.size = contentSize;
        contentLabel.frame = frame;
    }
}

-(void)updateVoiceWidth:(int)second
{
    CGRect rect = contentBgBtn.frame;
    if(second <= 3)
    {
        rect.size.width = 30 + ChatContentLeft + ChatContentRight;
    }
    else if (second <= 16)
    {
        rect.size.width = ChatContentW/16*second + ChatContentLeft + ChatContentRight;
    }
    else
    {
        rect.size.width = ChatContentW + ChatContentLeft + ChatContentRight;
    }
    contentBgBtn.frame = rect;
}

-(void)imageTapped:(UIGestureRecognizer *)gesture
{
    UIImageView* view = (UIImageView*)gesture.view;
    if(view && adaptor.picUrls)
    {
       if(delegate && [delegate respondsToSelector:@selector(imageClick:imageView:)])
       {
           [delegate imageClick:adaptor.picUrls imageView:view];
       }
    }
}

-(void)voiceTapped:(UIGestureRecognizer *)gesture
{
    if(adaptor.msgType == XYMMessageTypeVoice && voiceContent)
    {
        if(delegate && [delegate respondsToSelector:@selector(voiceClick:)])
        {
            [delegate voiceClick:adaptor];
        }
    }
}

-(void)startVoicePlay
{
    if(voiceContent)
    {
        [voiceContent startPlay];
    }
}

-(void)stopVoicePlay
{
    if(voiceContent)
    {
        [voiceContent stopPlay];
    }
}

-(void)cleanData
{
    adaptor = nil;
    contenImage.hidden = YES;
    contentLabel.hidden = YES;
    contentBgBtn.hidden = YES;
    
    [contentBgBtn clean];
    
    if(voiceContent)
    {
        [voiceContent cancelAndClean];
        [voiceContent removeFromSuperview];
        voiceContent = nil;
    }
    if(newsView)
    {
        [newsView cancelAndClean];
        [newsView removeFromSuperview];
        newsView = nil;
    }
    if(healthShareView)
    {
        [healthShareView cancelAndClean];
        [healthShareView removeFromSuperview];
        healthShareView = nil;
    }
}

-(void)dealloc
{
    delegate = nil;
    [self cleanData];
}

@end
