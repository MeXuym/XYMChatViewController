//
//  MessageItemAdaptor.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-16.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMMessageItemAdaptor.h"
#import "NSDate+Custom.h"
#import "NSAttributedString+Attributes.h"
#import "RegexKitLite.h"
#import "XYMMessageInputManager.h"
#import "MarkupParser.h"
#import "UIImage+Custom.h"
#import "RecordAudio.h"
#import "FileUtil.h"

// |/:oY|/:#-0|/:hiphot|/:kiss|/:<&|/:&>
static NSString* const class_regex_emoji = @"/::\\)|/::~|/::B|/::\\||/:8-\\)|/::<|/::\\$|/::X|/::Z|/::'\\(|/::-\\||/::@|/::P|/::D|/::O|/::\\(|/::\\+|/:--b|/::Q|/::T|/:,@P|/:,@-D|/::d|/:,@o|/::g|/:\\|-\\)|/::!|/::L|/::>|/::,@|/:,@f|/::-S|/:\\?|/:,@x|/:,@@|/::8|/:,@!|/:!!!|/:xx|/:bye|/:wipe|/:dig|/:handclap|/:&-\\(|/:B-\\)|/:<@|/:@>|/::-O|/:>-\\||/:P-\\(|/::'\\||/:X-\\)|/::\\*|/:@x|/:8\\*|/:pd|/:<W>|/:beer|/:basketb|/:oo|/:coffee|/:eat|/:pig|/:rose|/:fade|/:showlove|/:heart|/:break|/:cake|/:li|/:bome|/:kn|/:footb|/:ladybug|/:shit|/:moon|/:sun|/:gift|/:hug|/:strong|/:weak|/:share|/:v|/:@\\)|/:jj|/:@@|/:bad|/:lvu|/:no|/:ok|/:love|/:<L>|/:jump|/:shake|/:<O>|/:circle|/:kotow|/:turn|/:skip";
static NSString* const regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";

@interface XYMMessageItemAdaptor()
{
    EMessage* messgae_;
    NSString* msgContent_;
    NSString* timeSpan_;
    CGSize contentSize_;
    int height_;
    NSMutableAttributedString* contentAttributedString_;
    NSMutableArray* emjios_;
    NSDate* timeInterval_;
    NSString* description_;
    NSString* headUrl_;
    double voiceSecond_;
}

@end

@implementation XYMMessageItemAdaptor

@synthesize msgContent=msgContent_;
@synthesize currentContentAttributedString=contentAttributedString_;
@synthesize timeSpan=timeSpan_;
@synthesize contentSize=contentSize_;
@synthesize height=height_;
@synthesize emjios=emjios_;
@synthesize timeInterval=timeInterval_;
@synthesize description=description_;
@synthesize headUrl=headUrl_;
@synthesize guId,userName,fromUID,groupID,picUrls,isGetInfo;

-(id)initWithMessage:(EMessage*)message
{
    if(self = [super init]){
        messgae_ = message;
        contentSize_ = CGSizeZero;
        height_ = 0;
        emjios_ = [NSMutableArray array];
        self.font = [UIFont systemFontOfSize:16.0];
        
        if(message)
        {
            [self getMessageContent];
        }
    }
    return self;
}

-(int)height
{
    if(height_ == 0)
    {
        switch (self.msgType)
        {
            case XYMMessageTypeText:
                height_ = self.contentSize.height + ChatContentTop + ChatContentBottom + ChatMargin;
                break;
            case XYMMessageTypeVoice:
                height_ = 20 + ChatContentTop + ChatContentBottom + ChatMargin;
                break;
            case XYMMessageTypePicture:
                height_ = self.contentSize.height + ChatContentTop + ChatContentBottom + ChatMargin;
                break;
            case XYMMessageTypeSystem:
                height_ = self.contentSize.height + ChatMargin;
                break;
            case XYMMessageTypeShare:
                height_ = self.contentSize.height + ChatContentTop + ChatContentBottom + ChatMargin;
            // 暂时与MessageTypeShare 一样
            case XYMMessageTypeShareHealthNews:
                height_ = self.contentSize.height + ChatContentTop + ChatContentBottom + ChatMargin;
            case XYMMessageTypeSharePublicClass:
                height_ = self.contentSize.height + ChatContentTop + ChatContentBottom + ChatMargin;
                //优惠券类型
            case XYMMessageTypeShareHealthTips:
                height_ = self.contentSize.height + ChatContentTop + ChatContentBottom + ChatMargin;
            default:
                break;
        }
        height_ += ChatMargin;
        height_ += self.isHideTime?0:CTimeMargin;
    }
    return height_;
}

-(NSString *)msgContent
{
    if(!msgContent_){
        msgContent_ = messgae_.content;
    }
    return msgContent_;
}

-(CGSize)contentSize
{
    if(CGSizeEqualToSize(contentSize_, CGSizeZero))
    {
        contentSize_ = [self calculateContentSize];
    }
    return contentSize_;
}

-(NSString *)timeSpan
{
    if(!timeSpan_||timeSpan_.length==0)
    {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:messgae_.time];
        timeSpan_=[date dateStringForChatShow];
    }
    return timeSpan_;
}

-(NSDate *)timeInterval
{
    if(!timeInterval_)
    {
        timeInterval_=[NSDate dateWithTimeIntervalSince1970:messgae_.time];
    }
    return timeInterval_;
}

-(NSMutableAttributedString*)currentContentAttributedString
{
    if(!messgae_) return nil;
    if(!contentAttributedString_)
    {
        [self getMessageContent];
    }
    return contentAttributedString_;
}

-(BOOL)isSelf
{
    return messgae_.isSelf;
}

-(BOOL)isSend
{
    return messgae_.isSend;
}

-(BOOL)isGroup
{
    return messgae_.isGroup;
}

-(NSString *)guId
{
    return messgae_.guid;
}

-(NSString *)fromUID
{
    return messgae_.friends_UID;
}

-(NSString *)groupID
{
    return messgae_.group_ID;
}

-(NSDictionary *)picUrls
{
    return messgae_.picUrls;
}

-(XYMMessageType)msgType
{
    switch (messgae_.messageType)
    {
        case 4:
        default:
            return XYMMessageTypeText;
        case 1:
            return XYMMessageTypePicture;
        case 2:
            return XYMMessageTypeVoice;
        case 6:
            return XYMMessageTypeShare;
        case 7:
            return XYMMessageTypeShareHealthNews;
        case 8:
            return XYMMessageTypeSharePublicClass;
            
            //加上优惠券的
        case 9:
            return XYMMessageTypeShareHealthTips;
        
        case 99:
            return XYMMessageTypeSystem;
    }
}

- (CGSize)calculateContentSize
{
    CGSize size=CGSizeZero;
    if(self.msgType == XYMMessageTypeSystem)
    {
        size = [self.msgContent boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size;
    }
    else if (self.msgType == XYMMessageTypeText)
    {
        size = [self.currentContentAttributedString sizeConstrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)];
    }
    else if (self.msgType == XYMMessageTypePicture)
    {
        size = CGSizeMake(ChatPicWH,ChatPicWH);
    }
    else if (self.msgType == XYMMessageTypeVoice)
    {
        size = CGSizeMake(80,20);
    }
    else if (self.msgType == XYMMessageTypeShare)
    {
        size = CGSizeMake(ChatContentW, 114);
    }else if(self.msgType == XYMMessageTypeShareHealthNews || self.msgType == XYMMessageTypeSharePublicClass || self.msgType == XYMMessageTypeShareHealthTips) {
        //分享cell内容的高度 (加多一个优惠券)
        size = CGSizeMake(ChatContentW, 114);
    }
    return size;
}

-(NSString*)transAttributedfromString:(NSString*)originalStr
{
    //匹配表情，将表情转化为html格式
    NSMutableString *text = [NSMutableString stringWithString:originalStr];
    NSArray *array_emoji = [text componentsMatchedByRegex:regex_emoji];
    NSString *imgStr = @"\U0001F391";
    if (array_emoji.count > 0)
    {
        for (NSString *str in array_emoji)
        {
            NSRange range1 = [text rangeOfRegex:regex_emoji];
            if([str hasPrefix:@"http:"])
            {
                [text replaceOccurrencesOfRegex:regex_emoji
                                     withString:imgStr
                                          range:range1];
            }
            else
            {
                NSString *url =[[XYMMessageInputManager sharedInstance] emjioForKey:str.lastPathComponent];
                if (url)
                {
                    imgStr = [NSString stringWithFormat:@"<img src='%@' width='28' height='28'>",url];
                }
                [text replaceOccurrencesOfRegex:regex_emoji
                                     withString:imgStr
                                          range:range1];
            }
        }
    }
    
    NSArray *class_array_emoji = [text componentsMatchedByRegex:class_regex_emoji];
    if(class_array_emoji.count > 0)
    {
        for (NSString *str in class_array_emoji)
        {
            NSRange range1 = [text rangeOfRegex:class_regex_emoji];
            NSString *url =[[XYMMessageInputManager sharedInstance] emjioForRegex:str];
            if (url)
            {
                imgStr = [NSString stringWithFormat:@"<img src='%@' width='28' height='28'>",url];
            }
            [text replaceOccurrencesOfRegex:class_regex_emoji
                                 withString:imgStr
                                      range:range1];
        }
    }
    
    //返回转义后的字符串
    return text;
}

-(NSString*)transFaceNamefromString:(NSString*)originalStr
{
    NSMutableString *text = [NSMutableString stringWithString:originalStr];
    NSArray *class_array_emoji = [text componentsMatchedByRegex:class_regex_emoji];
    if(class_array_emoji.count > 0)
    {
        for (NSString *str in class_array_emoji)
        {
            NSRange range1 = [text rangeOfRegex:class_regex_emoji];
            NSString *strName =[[XYMMessageInputManager sharedInstance] nameForRegex:str];
            [text replaceOccurrencesOfRegex:class_regex_emoji
                                 withString:strName
                                      range:range1];
        }
    }
    
    //返回转义后的字符串
    return text;
}

-(void)getMessageContent
{
    if(self.msgType == XYMMessageTypeText)
    {
        if(!messgae_.content)
            messgae_.content = @"";
        
        NSString* text = [self transAttributedfromString:messgae_.content];
        MarkupParser* parser = [[MarkupParser alloc]init];
        contentAttributedString_ = [parser attrStringFromMarkup:text images:emjios_];
        [contentAttributedString_ modifyParagraphStylesWithBlock:^(OHParagraphStyle *paragraphStyle) {
            paragraphStyle.textAlignment = kCTTextAlignmentLeft;
            paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
            paragraphStyle.paragraphSpacing = 8.f;
            paragraphStyle.lineSpacing = 3.f;
        }];
        [contentAttributedString_ setFont:self.font];
        [contentAttributedString_ setTextColor:[UIColor blackColor]];
        
        messgae_.content = [self transFaceNamefromString:messgae_.content];
    }
    else if (self.msgType == XYMMessageTypePicture)
    {
        msgContent_ = @"[图片]";
    }
    else if (self.msgType == XYMMessageTypeVoice)
    {
        msgContent_ = @"[语音]";
    }
    else if (self.msgType == XYMMessageTypeShare)
    {
        NSString* content = [self.mediaData objectWithKey:@"modelTitel"];
        msgContent_ = [NSString stringWithFormat:@"[%@]%@",content,self.isSelf?@"":@"已完成，请查阅"];
    }else if (self.msgType == XYMMessageTypeSharePublicClass || self.msgType ==XYMMessageTypeShareHealthNews || self.msgType ==XYMMessageTypeShareHealthTips) { // 健康教育分享  (加多一个优惠券类型)
        
        NSString *shareContent = self.mediaData[@"shareTitle"];
//        int shareId = [self.mediaData[@"shareId"]intValue];
//        NSString *shareLogo = self.mediaData[@"shareLogo"];
//        NSString *shareTitle = self.mediaData[@"shareTitle"];
//        NSString *shareUrl = self.mediaData[@"shareUrl"];
        msgContent_ = shareContent;

    }
    
}

-(NSDictionary*)getCurrentIdDic
{
    NSMutableDictionary* dic=[NSMutableDictionary dictionary];
   
    return dic;
}

-(void)updateRepeatTime
{
    timeInterval_ = [NSDate date];
    messgae_.time = timeInterval_.timeIntervalSince1970;
}

-(void)updateImageUrl:(NSString *)key
{
    messgae_.content = key;
    NSMutableDictionary* dic = nil;
    if(messgae_.picUrls)
    {
        dic = [NSMutableDictionary dictionaryWithDictionary:messgae_.picUrls];
    }
    else
    {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setObject:QN_URL_FOR_KEY(key) forKey:DSamllPic];
    [dic setObject:QN_URL_FOR_KEY(key) forKey:DLargePic];
    messgae_.picUrls = dic;
}

-(void)updateVoiceUrl:(NSString*)key isLocal:(BOOL)isLocal
{
    NSMutableDictionary* dic = nil;
    if(messgae_.otherData)
    {
        dic = [NSMutableDictionary dictionaryWithDictionary:messgae_.otherData];
    }
    else
    {
        dic = [NSMutableDictionary dictionary];
    }
    if(isLocal)
    {
        NSString* localPath = key.lastPathComponent;
        [dic setObject:localPath forKey:DVoicePath];
    }
    else
    {
        messgae_.content = key;
        [dic setObject:QN_URL_FOR_KEY(key) forKey:DVoiceUrl];
        
    }
    messgae_.otherData = dic;
}

-(void)updateUserInfo:(EUserInfo *)info
{
    messgae_.userName = info.userName;
    NSMutableDictionary* dic = nil;
    if(messgae_.otherData)
    {
        dic = [NSMutableDictionary dictionaryWithDictionary:messgae_.otherData];
    }
    else
    {
        dic = [NSMutableDictionary dictionary];
    }
    [dic setObject:info.userPhoto forKeyedSubscript:@"userPhoto"];
    [dic setObject:info.userPhotobag forKeyedSubscript:@"userPhotobag"];
    messgae_.otherData = dic;
}

-(BOOL)isTimeOut
{
    NSDate* now=[NSDate date];
    NSTimeInterval time=fabs([self.timeInterval timeIntervalSinceDate:now]);
    return (time>=240&&!self.isSend);
}

-(NSString *)headUrl
{
    if(!headUrl_)
    {
        if(self.isSelf)
        {
            headUrl_ = [MyUserInfo myInfo].userPhoto;
        }
        else
        {
            headUrl_ = [messgae_.otherData objectWithKey:@"userPhoto"];
        }
    }
    return headUrl_;
}

-(int)voiceSecond
{
    if(voiceSecond_ == 0.0 && self.msgType == XYMMessageTypeVoice)
    {
        if(self.mediaData)
        {
            NSString* tmpFile;
            NSString* localPath = [self.mediaData objectForKey:DVoicePath];
            NSString* urlPath = [self.mediaData objectForKey:DVoiceUrl];
            if(localPath)
            {
                tmpFile = [FileUtil tempPathWithFileName:localPath];
            }
            else if(urlPath)
            {
                tmpFile = [FileUtil tempPathWithFileName:urlPath.lastPathComponent];
            }
            voiceSecond_ = [RecordAudio getAudioTime:tmpFile];
            if(voiceSecond_ < 1.0 && voiceSecond_ > 0.0)
            {
                voiceSecond_ = 1.0;
            }
        }
    }
    return voiceSecond_;
}

-(NSDictionary *)mediaData
{
    return messgae_.otherData;
}

-(BOOL)isMediaUploaded
{
    BOOL flag = NO;
    if(messgae_.isSelf && messgae_.messageType < 4)
    {
        flag = messgae_.content != nil;
    }
    return flag;
}

-(int)sessionId
{
    return messgae_.sessionId;
}

-(int)consultId
{
    return messgae_.consultId;
}

-(NSString *)userName
{
    return messgae_.showName;
}

-(BOOL)isGetInfo
{
    return messgae_.userName != nil;
}

-(EMessage *)currentMessage
{
    return messgae_;
}

@end
