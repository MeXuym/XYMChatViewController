//
//  ContentTableViewCell.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMChatTableViewCell.h"
#import "OHAttributedLabel.h"
#import "XYMImageContentView.h"
#import "XYMMessageContentButton.h"
#import "XYMVoiceContentView.h"
#import "XYMNewsContentView.h"
#import "XYMSessionManager.h"
#import "EUserInfo.h"
#import "XYMHealthShareContentView.h"

static const int kVoiceUL = 810;//语音上传Tag
static const int kVoiceDL = 811;//语音下载Tag
static const int kImageUL = 812;//图片上传Tag
static const int kImageDL = 813;//图片下载Tag

@interface XYMChatTableViewCell()<OHAttributedLabelDelegate>
{
    UIImageView* headImageView_;
    UILabel* systemLabel_;
    UILabel* userNameLabel_;
    XYMHealthShareContentView *shareContentView;
    XYMRequestContentView* requestContentView_;
    OHAttributedLabel* contentLabel_;
    
    XYMMessageContentButton *contentBgBtn;
}

@end

@implementation XYMChatTableViewCell

@synthesize delegate;

+(int)currentCellHeight:(XYMMessageItemAdaptor *)adaptor
{
    return adaptor.height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        headImageView_=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [headImageView_ setRoundHead];
        UITapGestureRecognizer* tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(UserImageClick:)];
        headImageView_.userInteractionEnabled=YES;
        [headImageView_ addGestureRecognizer:tap];
        [self.contentView addSubview:headImageView_];
        
        userNameLabel_=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
        userNameLabel_.textColor=[UIColor whiteColor];
        userNameLabel_.font=[UIFont systemFontOfSize:12];
        userNameLabel_.textAlignment=NSTextAlignmentLeft;
        [self.contentView addSubview:userNameLabel_];
        
        contentBgBtn = [XYMMessageContentButton buttonWithType:UIButtonTypeCustom];
        [contentBgBtn addTarget:self action:@selector(handleTap:)  forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer* bgLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [contentBgBtn addGestureRecognizer:bgLongPress];
        [self.contentView addSubview:contentBgBtn];
        
        contentLabel_ = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
        contentLabel_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        contentLabel_.centerVertically = YES;
        contentLabel_.automaticallyAddLinksForType = 0;//NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber;
        contentLabel_.onlyCatchTouchesOnLinks=NO;
        contentLabel_.delegate = self;
        [contentBgBtn addSubview:contentLabel_];
    }
    return self;
}

-(void)fillWithData:(XYMMessageItemAdaptor*)adaptor
{
    [super fillWithData:adaptor];
    
    BOOL isSelf = adaptor_.isSelf;
    
    CGPoint point = CGPointZero;
    point.y = adaptor_.isHideTime ? 0:CTimeMargin;
    CGSize contentSize = adaptor_.contentSize;
    
    if(adaptor_.msgType == XYMMessageTypeSystem)
    {
        systemLabel_=[[UILabel alloc]init];
        systemLabel_.textColor=[UIColor whiteColor];
        systemLabel_.font=[UIFont systemFontOfSize:14];
        systemLabel_.textAlignment=NSTextAlignmentCenter;
        systemLabel_.numberOfLines=0;
        systemLabel_.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByCharWrapping;
        systemLabel_.layer.cornerRadius=5;
        systemLabel_.layer.backgroundColor=[UIColor grayColor].CGColor;
        systemLabel_.alpha=0.5;
        systemLabel_.text=adaptor_.msgContent;
        systemLabel_.frame = CGRectMake((ScreenWidth-contentSize.width-10)/2, point.y+ChatMargin, contentSize.width+10, contentSize.height+5);
        [self.contentView addSubview:systemLabel_];
        
        headImageView_.hidden = YES;
    }
    else
    {
        CGFloat headX = ChatMargin;
        if(adaptor_.isSelf)
        {
            headX = ScreenWidth - ChatMargin - ChatHeadWH;
            
        }
        
        CGFloat headY = point.y + ChatMargin;
        CGRect headFrame = CGRectMake(headX, headY, ChatHeadWH, ChatHeadWH);
        CGRect nameFrame = CGRectMake(headX, headY + ChatHeadWH, ChatHeadWH, 20);
        
        CGFloat contentX = CGRectGetMaxX(headFrame) + ChatMargin;
        CGFloat contentY = headY;
        if(adaptor_.isSelf)
        {
            contentX = headX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
        }
        CGRect contentFrame = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
        
        contentBgBtn.isSelf = isSelf;
        if(isSelf)
        {
            contentBgBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
            [contentBgBtn setBackgroundImage:[[UIImage imageNamed:@"message_bg_self.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 22)] forState:UIControlStateNormal];
        }
        else
        {
            contentBgBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
            [contentBgBtn setBackgroundImage:[[UIImage imageNamed:@"message_bg_other.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 22)] forState:UIControlStateNormal];
            if(adaptor_.isGroup)
            {
                //            userNameLabel_.text=adaptor_.userName;
                //            [self.contentView addSubview:userNameLabel_];
            }
        }
        userNameLabel_.frame = nameFrame;
        headImageView_.frame = headFrame;
        NSLog(@"头像headIamgeView.frame=====%@",NSStringFromCGRect(headImageView_.frame));
        headImageView_.hidden = NO;
        if(!adaptor_.headUrl)
        {
            headImageView_.image = [UIImage imageNamed:isSelf?@"face_dr.png":@"face_patient.png"];
//            [SessionInstance getIMUserInfo:adaptor_ success:^() {
//                [headImageView_ sd_setImageWithURL:[NSURL URLWithString:adaptor_.headUrl] placeholderImage:[UIImage imageNamed:isSelf?@"face_dr.png":@"face_patient.png"]];
//            }];
        }
        else
        {
            [headImageView_ sd_setImageWithURL:[NSURL URLWithString:adaptor_.headUrl] placeholderImage:[UIImage imageNamed:isSelf?@"face_dr.png":@"face_patient.png"]];
        }
        
        contentBgBtn.frame = contentFrame;
        if(adaptor_.msgType == XYMMessageTypeText)
        {
            contentLabel_.attributedText = adaptor_.currentContentAttributedString;
            if(adaptor_.emjios.count>0)
            {
                [contentLabel_ setImages:adaptor_.emjios];
            }
            if(isSelf)
            {
                contentLabel_.frame = CGRectMake(ChatContentLeft - 10, ChatContentTop, contentSize.width, contentSize.height);
            }
            else
            {
                contentLabel_.frame = CGRectMake(ChatContentLeft, ChatContentTop, contentSize.width, contentSize.height);
            }
        }
        else if(adaptor_.msgType == XYMMessageTypePicture)
        {
            if(!requestContentView_ && adaptor_.picUrls)
            {
                void (^completed)(XYMRequestContentView*, NSString*) = ^(XYMRequestContentView *view, NSString* url)
                {
                    NSInteger tag = view.tag;
                    if(tag == kImageUL && url)
                    {
                        [adaptor_ updateImageUrl:url];
                        if(delegate&&[delegate respondsToSelector:@selector(didUpLoadImgComplete:)])
                        {
                            [delegate didUpLoadImgComplete:adaptor_];
                        }
                    }
                };
                if(isSelf)
                {
                    requestContentView_ = [[XYMImageContentView alloc] initWithFrame:CGRectMake(4, 5, contentBgBtn.width-15, contentBgBtn.height-10)
                                                                         imageDic:adaptor_.picUrls
                                                                         isUpLoad:!adaptor_.isSend&&!adaptor_.isMediaUploaded];
                    requestContentView_.tag = kImageUL;
                }
                else
                {
                    requestContentView_ = [[XYMImageContentView alloc] initWithFrame:CGRectMake(11, 5, contentBgBtn.width-15, contentBgBtn.height-10)
                                                                         imageDic:adaptor_.picUrls
                                                                         isUpLoad:NO];
                    requestContentView_.tag = kImageDL;
                }
                [requestContentView_ startRequestWithCompleted:completed];
                [contentBgBtn addSubview:requestContentView_];
            }
        }
        else if (adaptor_.msgType == XYMMessageTypeVoice)
        {
            if(!requestContentView_ && adaptor_.mediaData)
            {
                void (^completed)(XYMRequestContentView*, NSString*) = ^(XYMRequestContentView *view, NSString* url)
                {
                    NSInteger tag = view.tag;
                    if(tag == kVoiceUL && url)
                    {
                        [adaptor_ updateVoiceUrl:url isLocal:NO];
                        if(delegate && [delegate respondsToSelector:@selector(didUpLoadVoiceComplete:)])
                        {
                            [delegate didUpLoadVoiceComplete:adaptor_];
                        }
                    }
                    else if(tag == kVoiceDL && url)
                    {
                        [adaptor_ updateVoiceUrl:url isLocal:YES];
                        int second = adaptor_.voiceSecond;
                        [((XYMVoiceContentView*)requestContentView_) voiceLength:second];
                        if(delegate && [delegate respondsToSelector:@selector(didDownLoadVoiceComplete:)])
                        {
                            [delegate didDownLoadVoiceComplete:adaptor_];
                        }
                        [self updateVoiceWidth:second];
                    }
                };
                
                BOOL isUpload = isSelf&&!adaptor_.isSend&&!adaptor_.isMediaUploaded;
                requestContentView_ = [[XYMVoiceContentView alloc] initDownLoadWithFrame:CGRectMake(15, 10, contentSize.width, contentSize.height)
                                                                             mediaDic:adaptor_.mediaData
                                                                               isSelf:isSelf
                                                                             isUpload:isUpload];
                if(isUpload)
                {
                    requestContentView_.tag = kVoiceUL;
                }
                else
                {
                    requestContentView_.tag = kVoiceDL;
                }
                int second = adaptor_.voiceSecond;
                [((XYMVoiceContentView*)requestContentView_) voiceLength:second];
                [requestContentView_ startRequestWithCompleted:completed];
                [contentBgBtn addSubview:requestContentView_];
                [self updateVoiceWidth:second];
            }
        }
        else if (adaptor_.msgType == XYMMessageTypeShare)
        {
            NSDictionary* follow = adaptor_.mediaData;
            if(!requestContentView_ && follow)
            {
                requestContentView_ = [[XYMNewsContentView alloc] initWithFrame:CGRectMake(isSelf?4:11, 5, contentBgBtn.width-15, contentBgBtn.height-10)];
                NSString* title = [follow objectWithKey:@"modelTitel"];
                NSString* url = [follow objectWithKey:@"modelUrl"];
                NSString* typePhoto = [follow objectWithKey:@"typePhoto"];
                
                XYMNewsContentView* newsView = (XYMNewsContentView*)requestContentView_;
                
                [newsView fillWithTitle:title url:url];
                if(adaptor_.isSelf)
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
                    newsView.logoImage.frame = CGRectMake(10, 40, 80, 80);
                }];
                [contentBgBtn addSubview:requestContentView_];
            }
        }else if (adaptor_.msgType == XYMMessageTypeShareHealthNews ||
                  adaptor_.msgType == XYMMessageTypeSharePublicClass) { // 健教分享
            
            NSDictionary* share = adaptor_.mediaData;
            // 暂时让他和随访share模块一样
            shareContentView = [[XYMHealthShareContentView alloc] initWithFrame:CGRectMake(isSelf?4:11, 5, contentBgBtn.width-15, contentBgBtn.height-10)];
            NSString *shareContent = share[@"shareContent"];
//            int shareId = [share[@"shareId"]intValue];
            NSString *shareLogo = share[@"shareLogo"];
            NSString *shareTitle = share[@"shareTitle"];
            NSString *shareUrl = share[@"shareUrl"];
            
            XYMHealthShareContentView* newsView = (XYMHealthShareContentView*)shareContentView;
            
            [newsView fillWithTitle:shareTitle url:shareUrl content:shareContent];
            [newsView.logoImage sd_setImageWithURL:[NSURL URLWithString:shareLogo] placeholderImage:[UIImage imageNamed:@"follow_cover.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                newsView.logoImage.frame = CGRectMake(10, 40, 80, 80);
            }];
            [contentBgBtn addSubview:shareContentView];
        }else if (adaptor_.msgType == XYMMessageTypeShareHealthTips) { // 优惠券分享
            
            NSDictionary* share = adaptor_.mediaData;
            // 暂时让他和随访share模块一样
            shareContentView = [[XYMHealthShareContentView alloc] initWithFrame:CGRectMake(isSelf?4:11, 5, contentBgBtn.width-15, contentBgBtn.height-10)];
            NSString *shareContent = share[@"shareContent"];
            // int shareId = [share[@"shareId"]intValue];
            NSString *shareLogo = share[@"shareLogo"];
            NSString *shareTitle = share[@"shareTitle"];
            NSString *shareUrl = share[@"shareUrl"];
            
            XYMHealthShareContentView* newsView = (XYMHealthShareContentView*)shareContentView;
            
            [newsView fillWithTitle:shareTitle url:shareUrl content:shareContent];
            [newsView.logoImage sd_setImageWithURL:[NSURL URLWithString:shareLogo] placeholderImage:[UIImage imageNamed:@"follow_cover.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                newsView.logoImage.frame = CGRectMake(10, 40, 80, 80);
            }];
            [contentBgBtn addSubview:shareContentView];
        }

    }
}

-(void)updateVoiceWidth:(int)second
{
    CGRect rect = contentBgBtn.frame;
    if(second <= 3)
    {
        rect.size.width = 30 + ChatContentLeft + ChatContentRight;
    }
    else if (second <= 60)
    {
        rect.size.width = 30 + (ChatContentW)/60*second + ChatContentLeft + ChatContentRight;
    }
    else
    {
        rect.size.width = ChatContentW + ChatContentLeft + ChatContentRight;
    }
    if(rect.size.width > ScreenWidth - 120)
    {
        rect.size.width = ScreenWidth - 120;
    }
    if(adaptor_.isSelf)
    {
        CGSize contentSize = adaptor_.contentSize;
        
        CGFloat headX = ScreenWidth - ChatMargin - ChatHeadWH;
        rect.origin.x = headX - rect.size.width - ChatMargin;
        
        CGRect rect2 = requestContentView_.frame;
        rect2.origin.x = rect.size.width - contentSize.width;
        requestContentView_.frame = rect2;
    }
    contentBgBtn.frame = rect;
}

-(void)cleanData
{
    [super cleanData];
    adaptor_ = nil;
    if (systemLabel_)
    {
        [systemLabel_ removeFromSuperview];
        systemLabel_=nil;
    }

    contentLabel_.attributedText = nil;
    
    [contentBgBtn clean];
    
    if(requestContentView_)
    {
        [requestContentView_ cancelAndClean];
        [requestContentView_ removeFromSuperview];
        requestContentView_=nil;
    }
    
    if (shareContentView) {
        [shareContentView cancelAndClean];
        [shareContentView removeFromSuperview];
        shareContentView = nil;
    }
    
}

-(void)dealloc
{
    delegate = nil;
    [self cleanData];
}

-(CGRect)getContentFrame
{
    if(adaptor_.isSelf)
    {
        return CGRectMake(CGRectGetMinX(contentBgBtn.frame) - 30, CGRectGetMidY(contentBgBtn.frame) - 10, 20, 20);
    }
    else
    {
        return CGRectMake(CGRectGetMaxX(contentBgBtn.frame) + 10, CGRectGetMidY(contentBgBtn.frame) - 10, 20, 20);
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

//-(BOOL)canBecomeFirstResponder
//{
//    return YES;
//}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action==@selector(copyAction:)||action==@selector(deleteAction:))
    {
        return YES;
    }
    return NO;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point=[recognizer locationInView:self];
        if(delegate && [delegate respondsToSelector:@selector(didLongPress:cellRect:showPoint:)])
        {
            [delegate didLongPress:adaptor_ cellRect:self.frame showPoint:CGPointMake(contentBgBtn.center.x, point.y)];
        }
        [contentBgBtn becomeFirstResponder];
        if(adaptor_.msgType == XYMMessageTypeText)
        {
            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(copyAction:)];
//                    UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(deleteAction:)];
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:@[copy/*, delete]*/]];
            [menu setTargetRect:contentBgBtn.frame inView:contentBgBtn.superview];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}

- (void)copyAction:(id)sender
{
    if(delegate&&[delegate respondsToSelector:@selector(didCopyMsg:)])
    {
        [delegate didCopyMsg:adaptor_];
    }
}

- (void)deleteAction:(id)sender
{
    if(delegate&&[delegate respondsToSelector:@selector(didDeleteMsg:)])
    {
        [delegate didDeleteMsg:adaptor_];
    }
}

-(void)handleTap:(id)recognizer
{
    if(adaptor_.msgType == XYMMessageTypePicture)
    {
        if(delegate && [delegate respondsToSelector:@selector(didClickedMsgImage:)])
        {
            [delegate didClickedMsgImage:adaptor_];
        }
    }
    else if (adaptor_.msgType == XYMMessageTypeVoice)
    {
        if(delegate && [delegate respondsToSelector:@selector(didClickedMsgVoice:)])
        {
            [delegate didClickedMsgVoice:adaptor_];
        }
    }
    else if (adaptor_.msgType == XYMMessageTypeShare)
    {
        if(delegate && [delegate respondsToSelector:@selector(didClickedMsgShare:)])
        {
            [delegate didClickedMsgShare:adaptor_];
        }
    }
    else if (adaptor_.msgType == XYMMessageTypeShareHealthNews || adaptor_.msgType == XYMMessageTypeSharePublicClass){
        
        if (delegate && [delegate respondsToSelector:@selector(didClickedMsgHealthNewsShare:)]) {
            
            [delegate didClickedMsgHealthNewsShare:adaptor_];
        }
    }
    
    else if (adaptor_.msgType == XYMMessageTypeShareHealthTips){
        
        if (delegate && [delegate respondsToSelector:@selector(didClickedMsgHealthTipsShare:)]) {
            
            [delegate didClickedMsgHealthTipsShare:adaptor_];
        }
    }

    
    else
    {
        if(delegate && [delegate respondsToSelector:@selector(didClickNomarl:)])
        {
            [delegate didClickNomarl:adaptor_];
        }
    }
    
}

//点击用户的头像的时候
-(void)UserImageClick:(id)sender
{
    if(delegate&&[delegate respondsToSelector:@selector(didClickedUserImage:)])
    {
        [delegate didClickedUserImage:adaptor_];
    }
    
    //一对一聊天页，点击联系人头像跳转到居民档案页次数
    [MobClick event:@"h_dr_1to1_photo_information"];
}

-(void)reSendAction
{
    if(delegate&&[delegate respondsToSelector:@selector(didClickedReSend:)])
    {
        [delegate didClickedReSend:adaptor_];
    }
}

-(void)startVoicePlay
{
    if([requestContentView_ isKindOfClass:[XYMVoiceContentView class]])
    {
        [((XYMVoiceContentView*)requestContentView_) startPlay];
    }
}

-(void)stopVoicePlay
{
    if([requestContentView_ isKindOfClass:[XYMVoiceContentView class]])
    {
        [((XYMVoiceContentView*)requestContentView_) stopPlay];
    }
}

#pragma mark - ------------OHAttributedLabelDelegate 的代理方法----------------

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    if(delegate&&[delegate respondsToSelector:@selector(didClickedURL:)])
    {
        [delegate didClickedURL:linkInfo];
    }
    return NO;
}

@end
