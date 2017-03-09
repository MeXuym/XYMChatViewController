//
//  XYMChatViewController.m
//  healthcoming
//
//  Created by jack xu on 16/12/21.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "TestChatViewController.h"
#import "XYMMessageInputBar.h"
#import "XYMMessageItemAdaptor.h"
#import "XYMSessionManager.h"
#import "EMessagesDB.h"
#import "XYMChatTableViewCell.h"
#import "XYMSendManager.h"
#import "QBImagePickerController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
//#import "ExUserInfoViewController.h"
#import "RecordAudio.h"
#import "RecordSoundView.h"
#import "FileUtil.h"
//#import "QuestionViewController.h"
//#import "QuickReplyViewController.h"
#import "AFNHttpRequest.h"
//#import "EQuestion.h"
//#import "FollowQuestionViewController.h"
//#import "FollowDetailViewController.h"

//#import "HHMKHealthDetailController.h"
//#import "HHMKHealthContainerController.h"
//#import "HealthTipsO2OViewController.h"
//#import "RecommendationViewController.h"

//#import "MasterRecommendViewController.h"

#import "AFNHttpRequest.h"
#import "XYMSessionManager.h"
#import "CommonOperation.h"
//#import "MaskingView.h"
//#import "InfoDetailViewController.h"

#import "XYMSessionManager.h"
#import "XYMSendManager.h"

@interface TestChatViewController ()<XYMChatTableViewCellDelegate,RecordAudioDelegate,XYMMessageInputBarDelegate>
{
    UIActivityIndicatorView* loading_;
    BOOL isRoom;
    int page_;
    XYMMessageItemAdaptor* reSendItem_;
    BOOL currentType;
    RecordAudio* recordAudio;
    RecordSoundView* soundView;
    BOOL isShow;
    NSInteger curCellIndex;
}
@end

@implementation TestChatViewController

@synthesize isNoFirst,patientSex,age;

-(id)initWithUID:(NSString*)theUID
           myUID:(NSString *)myUID
        chatName:(NSString *)chatName
         isGroup:(BOOL)isGroup
{
    if(self = [super init])
    {
        currentType = isGroup;
        toUID = theUID;
        toName = chatName;
        currentUID = myUID;
        curCellIndex = -1;
    }
    return self;
}


-(void)loadView
{
    [super loadView];
    [self initParams];
    [self initView];
}

-(void)initParams
{
    /*
    开辟内存，初始在内存中开辟1个内存,如果之后数组元素多余1个,则会再开辟新的1*2个新的内存,[考虑到数组的连续内存的特性]
    单位是以5,把之前的1个元素的内容拷贝到新的内存里面,把第2个
    也放进去,然后释放初始状态创建的内存1个
    最后得到了一块够用的连续的内存1*2
     */
    currentArray_=[NSMutableArray arrayWithCapacity:1];
}

-(void)initView
{
    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    
    mainTable_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-XYMkTabHeight-XYMkNavHeight-20) style:UITableViewStylePlain];
    mainTable_.delegate = self;
    mainTable_.dataSource = self;
    mainTable_.scrollsToTop = YES;
    mainTable_.backgroundColor = [UIColor clearColor];
    mainTable_.separatorStyle = UITableViewCellSeparatorStyleNone;
    mainTable_.scrollsToTop = NO;
    [self.view addSubview:mainTable_];
    
    headerView_ = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    loading_ = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect rect=loading_.frame;
    rect.origin.x=(self.view.frame.size.width-loading_.frame.size.width)/2;
    rect.origin.y=5;
    loading_.frame=rect;
    [headerView_ addSubview:loading_];
    
    CGRect frame = CGRectMake(0, self.view.frame.size.height-XYMkTabHeight, ScreenWidth, XYMkTabHeight);
    inputBar_ = [[XYMMessageInputBar alloc] initWithFrame:frame superView:self.view];
    inputBar_.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    inputBar_.delegate = self;
    [self.view addSubview:inputBar_];
    
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [mainTable_ addGestureRecognizer:tap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBackButton];
    [self baseViewStyle];
    page_ = 0;
    [self initNotification];
    [self loadCacheWithAction:^(int count){
        [mainTable_ reloadData];
        if(count>0){
            mainTable_.tableHeaderView = headerView_;
        }
        [self scrollTableViewToBottom:NO];
    }];
    
#if OpenScoket
    if(currentArray_.count == 0)
    {
//        [SESSIONINSTANCE getMessageWithUserId:toUID completed:^(BOOL isSuccess, NSArray *array) {
            [SessionInstance getMessageWithUserId:toUID completed:^(BOOL isSuccess, NSArray *array) {
            if(isSuccess && array)
            {
                [currentArray_ removeAllObjects];
                [self loadCacheWithAction:^(int count){
                    [mainTable_ reloadData];
                    if(count>=15){
                        mainTable_.tableHeaderView = headerView_;
                    }
                    [self scrollTableViewToBottom:NO];
                }];
            }
        }];
    }
#else
    __weak PollingChatViewController *wself = self;
    [SESSIONINSTANCE openHeart:[toUID intValue] block:^int{
        return [wself getNextConsultId];
    }];
#endif
    
    //不是首次聊天？
    if (isNoFirst)
    {
        mainTable_.tableHeaderView = headerView_;
    }
    //拿到草稿
    [self getDraftContent];
    
}



-(void)getDraftContent
{
//    NSString* draft = [SESSIONINSTANCE getDraftContentWithUID:toUID];
//    if(draft)
//    {
//        [inputBar_ fitTextView:draft];
//    }
}

//点了返回按钮
-(void)onNavigationBackPressed
{
//    [SESSIONINSTANCE updateSessionWithUID:toUID draft:inputBar_.curText];
    [super onNavigationBackPressed];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    SESSIONINSTANCE.chatUID = toUID;
    [MobClick beginLogPageView:@"会话"];
}

-(void)sendInfo:(NSArray*)array type:(int)type
{
    if(type == 1)
    {
        for (NSString* str1 in array)
        {
            NSString* str2 = @"";
            if([str1 isEqualToString:@"pregnancy"])
            {
                str2 = @"(孕产)资料";
            }
            else if ([str1 isEqualToString:@"child"])
            {
                str2 = @"(儿童健康保健)资料";
            }
            else if ([str1 isEqualToString:@"chronicdisease"])
            {
                str2 = @"(高血压/糖尿病)资料";
            }
            else if ([str1 isEqualToString:@"baseInfo"])
            {
                str2 = @"您的(基础资料)";
            }
            
            //记录字段包括：1）档案名称（孕产档案\儿童健康保健档案\慢性病档案\基础资料） 2）医生id
            [MobClick event:@"h_dr_patient_chat_remind" attributes:@{@"dr_Id":[NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId],@"name":str1}];
        }
        //原来是发多条，现在整合为一条消息。
        NSString* str = [NSString stringWithFormat:@"您好，为更好的了解您的健康情况，请完善您的个人资料。"];
        [self sendTextAction2:str archivesType:array];
    }
    else
    {
        NSString* str = @"您好，为更好的了解您的健康情况，请完善您的个人资料。";
        [self sendTextAction2:str archivesType:@"all"];
        
        [MobClick event:@"h_dr_patient_record_remind" attributes:@{@"dr_Id":[NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId]}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(int)getNextConsultId
{
    int nextConsultId = 0;
    if(currentArray_.count > 0)
    {
        XYMMessageItemAdaptor* adaptor = currentArray_.lastObject;
        nextConsultId = adaptor.consultId;
    }
    return nextConsultId;
}

//加载消息记录相关
-(void)loadCacheWithAction1:(void (^)(int))action
{
    if(isNoFirst)
    {
        int lastConsultId = 0;
        if(currentArray_.count > 0)
        {
            XYMMessageItemAdaptor* adaptor = currentArray_.firstObject;
            lastConsultId = adaptor.consultId;
        }
        __weak TestChatViewController *wself = self;
//        [SESSIONINSTANCE getOldMessageWithUserId:[toUID intValue] consultId:lastConsultId completed:^(BOOL isSuccess, NSArray *array)
//         {
//             if(array && array.count)
//             {
//                 int count=(int)array.count;
//                 [wself adjustTimeInAdaptorArrays:array isTop:YES];
//                 if(action){
//                     action(count);
//                 }
//             }
//             else
//             {
//                 if(!isSuccess)
//                 {
//                     [DialogUtil postAlertWithMessage:@"网络出现问题，请稍后重试"];
//                 }
//                 if(action){
//                     action(0);
//                 }
//             }
//         }];
    }
    else
    {
        isNoFirst = YES;
        [self loadCacheWithAction:action];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"会话"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
#if !OpenScoket
    [SESSIONINSTANCE stopHeart];
#endif
}

-(void)clickSettingButton:(id)sender
{
}


-(void)initNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReceiveMessageNotice:) name:IMNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateMessageNotice:) name:IMMsgStatusNotifaction object:nil];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMMsgStatusNotifaction object:nil];
}


-(void)UpdateMessageNotice:(NSNotification*)notifacation
{
    NSString* guid=(NSString*)notifacation.object;
    for (NSInteger i=currentArray_.count-1; i>=0; i--)
    {
        XYMMessageItemAdaptor* adaptor=[currentArray_ objectAtIndex:i];
        if([adaptor.guId isEqualToString:guid])
        {
            NSIndexPath* indexPath=[NSIndexPath indexPathForRow:i inSection:0];
            [mainTable_ reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}

-(void)ReceiveMessageNotice:(NSNotification *)notification
{
    XYMMessageItemAdaptor* adaptor = (XYMMessageItemAdaptor*)notification.object;
    if((adaptor.isGroup && [adaptor.groupID isEqualToString:toUID]) ||
       (!adaptor.isGroup && [adaptor.fromUID isEqualToString:toUID]))
    {
        CGFloat height = mainTable_.height;
        CGFloat offset = mainTable_.contentOffset.y;
        CGFloat distance = mainTable_.contentSize.height - offset;
        [self adjustTimeInAdaptorItem:adaptor];
        [mainTable_ reloadData];
        if(distance <= height || adaptor.isSelf)
        {
            [self scrollTableViewToBottom:NO];
        }
    }
}


-(void)adjustTimeInAdaptorArrays:(NSArray*)array isTop:(BOOL)isTop
{
    NSDate* last=[NSDate dateWithTimeIntervalSince1970:0];
    NSDate* frist=[NSDate dateWithTimeIntervalSince1970:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if(isTop)
    {
        if(currentArray_.count>0){
            last=((XYMMessageItemAdaptor*)currentArray_.firstObject).timeInterval;
        }
        for (NSInteger i=array.count-1; i>=0; i--) {
            EMessage* messgae=[array objectAtIndex:i];
            XYMMessageItemAdaptor* adaptor=[[XYMMessageItemAdaptor alloc] initWithMessage:messgae];
            if(i==array.count-1){
                frist=adaptor.timeInterval;
            }else{
                if(fabs([adaptor.timeInterval timeIntervalSinceDate:last])<=120||[adaptor.timeInterval timeIntervalSinceDate:frist]<=120){
                    adaptor.isHideTime=YES;
                }
                else{
                    last=adaptor.timeInterval;
                }
            }
            if(!adaptor.isSend&&!adaptor.isTimeOut&&adaptor.isSelf)
            {
                [self repeatMessage:adaptor];
            }
            [currentArray_ insertObject:adaptor atIndex:array.count-i-1];
        }
    }
    else
    {
        if(currentArray_.count>0){
            last=((XYMMessageItemAdaptor*)currentArray_.lastObject).timeInterval;
        }
        for (int i=0; i<array.count; i++) {
            EMessage* messgae=[array objectAtIndex:i];
            XYMMessageItemAdaptor* adaptor=[[XYMMessageItemAdaptor alloc] initWithMessage:messgae];
            if(fabs([adaptor.timeInterval timeIntervalSinceDate:last])<=120){
                adaptor.isHideTime=YES;
            }
            else{
                last=adaptor.timeInterval;
            }
            if(!adaptor.isSend && !adaptor.isTimeOut)
            {
                [self repeatMessage:adaptor];
            }
            [currentArray_ addObject:adaptor];
        }
    }
}

-(void)adjustTimeInAdaptorItem:(XYMMessageItemAdaptor*)adaptor
{
    NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    if(currentArray_.count>0){
        for (NSInteger i = currentArray_.count-1; i>=0; i--) {
            XYMMessageItemAdaptor* item=[currentArray_ objectAtIndex:i];
            if(!item.isHideTime){
                last=item.timeInterval;
                break;
            }
        }
    }
    if([adaptor.timeInterval timeIntervalSinceDate:last]<=120){
        adaptor.isHideTime=YES;
    }
    [currentArray_ addObject:adaptor];
}



-(void)repeatMessage:(XYMMessageItemAdaptor*)adaptor
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendMessage:[adaptor currentMessage] isRepeat:YES];
    });
}

#pragma mark - 发送消息
-(void)sendMessage:(EMessage*)message isRepeat:(BOOL)isRepeat
{
    if(!isRepeat)
    {
        //消息入库
        [[EMessagesDB shareInstance] insertWithMessage:message];
    }
    
    [self sendMessage:message];
}

-(void)sendMessage:(EMessage*)message
{
    //模拟发送的请求
    [XYMSendManager sendMessage:message completed:^(BOOL success, int sessionId, int consultId) {
        if(success)
        {
            message.sessionId = sessionId;
            message.consultId = consultId;
            message.isSend=YES;
            [[EMessagesDB shareInstance] updateWithMessage:message];
        }
        else
        {
            NSLog(@"发送失败");
        }
    } isQuestion:message.isQuestion];
}

-(void)sendShare:(NSDictionary*)dic
{
    EMessage* message = [XYMSendManager shareMessageCreater:dic toUID:toUID myUID:currentUID isGroup:currentType];
    [self sendMessage:message isRepeat:NO];
}

-(void)sendVoice:(NSString *)amrPath
{
    EMessage* message = [XYMSendManager voiceMessageCreater:amrPath toUID:toUID myUID:currentUID isGroup:currentType];
    [[EMessagesDB shareInstance] insertWithMessage:message];
}

#pragma mark 发送图片消息
-(void)sendImage:(UIImage *)image isScale:(BOOL)isScale
{
    EMessage* message = [XYMSendManager imageMessageCreater:image toUID:toUID myUID:currentUID isGroup:currentType isPng:NO isScale:isScale];
    [[EMessagesDB shareInstance] insertWithMessage:message];
}
#pragma mark 发送文本消息
-(void)sendText:(NSString*)text
{
    [self sendText:text isQuestion:0];
}

-(void)sendText:(NSString*)text isQuestion:(int)isQuestion
{
    EMessage* message = [XYMSendManager textMessageCreater:text toUID:toUID myUID:currentUID isGroup:currentType];
    message.isQuestion = isQuestion;
    [self sendMessage:message isRepeat:NO];
}


#pragma mark RecordAudioDelegate

- (void)RecordStatus:(int)status
{
    if(curCellIndex < 0)return;
    NSIndexPath* index = [NSIndexPath indexPathForRow:curCellIndex inSection:0];
    XYMChatTableViewCell* cell = (XYMChatTableViewCell *)[mainTable_ cellForRowAtIndexPath:index];
    if (status == 0) {
        NSLog(@"开始播放");
        [cell startVoicePlay];
    } else if (status == 1) {
        NSLog(@"播放完成");
        [cell stopVoicePlay];
    } else {
        NSLog(@"播放错误");
        [cell stopVoicePlay];
    }
}

- (void)UpdateRecordDegree:(CGFloat)degree
{
    float result  = 10 * (float)degree;
    NSLog(@"%f", result);
    int volume = 1;
    if (result > 0 && result <= 1.3) {
        volume = 1;
    } else if (result > 1.3 && result <= 2) {
        volume = 2;
    } else if (result > 2 && result <= 3.0) {
        volume = 3;
    } else if (result > 3.0 && result <= 3.0) {
        volume = 4;
    } else if (result > 5.0 && result <= 10) {
        volume = 5;
    } else if (result > 10 && result <= 40) {
        volume = 6;
    } else if (result > 40) {
        volume = 7;
    }
    if(soundView)
    {
        [soundView updateVolume:volume];
    }
}

#pragma mark ----------QBImagePickerControllerDelegate 的代理方法-------------
- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if([imagePickerController.class isSubclassOfClass:UIImagePickerController.class])
    {
        UIImage *chosedImage=[info objectForKey:UIImagePickerControllerEditedImage];
        [self sendImage:chosedImage isScale:YES];
    }
    else if ([imagePickerController.class isSubclassOfClass:QBImagePickerController.class])
    {
        if(imagePickerController.allowsMultipleSelection) {
            //NSArray *mediaInfoArray = (NSArray *)info;
            //[self dismissViewControllerAnimated:YES completion:^{}];
        } else {
            UIImage *chosedImage=[info objectForKey:UIImagePickerControllerOriginalImage];
            [self sendImage:chosedImage isScale:NO];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    return [NSString stringWithFormat:@"照片%d张", (int)numberOfPhotos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:@"视频%d个", (int)numberOfVideos];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos numberOfVideos:(NSUInteger)numberOfVideos
{
    return [NSString stringWithFormat:@"照片%d张、视频%d个", (int)numberOfPhotos, (int)numberOfVideos];
}

#pragma mark 发送文本消息回调
-(void)sendTextAction:(NSString *)text
{
    NSString* text2 = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(text2.length == 0)
    {
        [DialogUtil postAlertWithMessage:@"不能输入空白消息"];
        return;
    }
    [self sendText:text];
}

-(void)sendTextAction2:(NSString *)text archivesType:(NSArray*)archivesType
{
    NSString* text2 = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(text2.length == 0)
    {
        [DialogUtil postAlertWithMessage:@"不能输入空白消息"];
        return;
    }
    EMessage* message = [XYMSendManager textMessageCreater:text toUID:toUID myUID:currentUID isGroup:currentType];
    message.isQuestion = 2;
    
    [[EMessagesDB shareInstance] insertWithMessage:message];
    
    [XYMSendManager sendMessage2:message archivesType:archivesType completed:^(BOOL success, int sessionId, int consultId) {
        if(success)
        {
            message.sessionId = sessionId;
            message.consultId = consultId;
            message.isSend=YES;
            [[EMessagesDB shareInstance] updateWithMessage:message];
            
        }
        else
        {
            NSLog(@"发送失败");
        }
    }];
}

//开始录音
-(void)startRecording:(XYMMessageInputBar *)toolbar
{
    if(!recordAudio)
    {
        recordAudio = [[RecordAudio alloc] init];
        recordAudio.delegate = self;
    }
    [recordAudio stopPlay];
    [recordAudio startRecord];
    if(!soundView)
    {
        soundView = [[RecordSoundView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    }
    [soundView show];
    
    XYMMessageItemAdaptor* adaptor = [currentArray_ lastObject];
    if(adaptor)
    {
        NSString* sessionId = [NSString stringWithFormat:@"%d",adaptor.sessionId];
        [MobClick event:@"h_dr_voice" attributes:@{@"dr_Id":[NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId],@"time":[[NSDate date] getDateString:@"yyyy-MM-dd HH:mm:ss"],@"patient_Id":toUID,@"type":@"3",@"session_Id":sessionId}];
    }
}

//结束录音
-(void)endRecording:(XYMMessageInputBar *)toolbar isSend:(BOOL)isSend
{
    if(soundView)
    {
        [soundView dimiss];
    }
    
    NSURL *url = [recordAudio stopRecord];
    if (isSend == NO || url == nil)
    {
        return ;
    }
    NSTimeInterval interval = [RecordAudio getAudioTime:[url path]];
    if (interval < 0.8f) {
        [DialogUtil postAlertWithMessage:@"录音时间太短"];
        return ;
    }
    
    NSString* amrFilePath = [RecordAudio encodeToAMR:[url path]];
    if (amrFilePath)
    {
        //写入文件成功后,将语音文件发送出去
        [self sendVoice:amrFilePath];
    }
    
}

#pragma mark 打开照相机
-(void)openCamera:(XYMMessageInputBar *)toolbar
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied)
    {
        [DialogUtil postAlertWithMessage:@"当前设备不支持相机"];
        NSLog(@"相机不可用");
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
        picker.delegate = self;
        picker.allowsEditing = YES;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:^{}];//进入照相界面
    }else{
        [DialogUtil postAlertWithMessage:@"当前设备不支持相机"];
        NSLog(@"相机不可用");
    }
    
    XYMMessageItemAdaptor* adaptor = [currentArray_ lastObject];
    if(adaptor)
    {
        NSString* sessionId = [NSString stringWithFormat:@"%d",adaptor.sessionId];
        [MobClick event:@"h_dr_photo" attributes:@{@"dr_Id":[NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId],@"time":[[NSDate date] getDateString:@"yyyy-MM-dd HH:mm:ss"],@"patient_Id":toUID,@"type":@"2",@"session_Id":sessionId}];
    }
}

#pragma mark 发送照片
-(void)pickPhoto:(XYMMessageInputBar *)toolbar
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    XYMMessageItemAdaptor* adaptor = [currentArray_ lastObject];
    if(adaptor)
    {
        NSString* sessionId = [NSString stringWithFormat:@"%d",adaptor.sessionId];
        [MobClick event:@"h_dr_picture" attributes:@{@"dr_Id":[NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId],@"time":[[NSDate date] getDateString:@"yyyy-MM-dd HH:mm:ss"],@"patient_Id":toUID,@"type":@"1",@"session_Id":sessionId}];
    }
    
}

-(void)sendFollow:(XYMMessageInputBar *)toolbar
{
//    FollowQuestionViewController* view = [[FollowQuestionViewController alloc] init];
//    view.delegate = self;
//    view.isModal = YES;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:view];
//    [self presentViewController:nav animated:YES completion:nil];
//    
//    [MobClick event:@"h_dr_follow_action"];
//    [MobClick beginLogPageView:@"点击－随访问卷"];
//    [MobClick endLogPageView:@"点击－随访问卷"];
}

//#pragma mark - FollowQuestionControllerDelegate
//-(void)followQuestionController:(FollowQuestionViewController *)controller didFinishPickFollow:(NSDictionary *)modelDic
//{
//    [self sendShare:modelDic];
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//}

#pragma mark - ------------ChatTableViewCellDelegate 的代理方法------------
-(void)didClickedMsgImage:(XYMMessageItemAdaptor *)item
{
    NSMutableArray *photos = [NSMutableArray array];
    int currentIndex=0;
    int sum=0;
    BOOL isLocal=NO;
    for (int i = 0; i<currentArray_.count; i++)
    {
        XYMMessageItemAdaptor* itemAdaptor=[currentArray_ objectAtIndex:i];
        if(itemAdaptor.msgType == XYMMessageTypePicture)
        {
            NSString* picUrl = nil;
            if(itemAdaptor.isSelf)
            {
                isLocal = YES;
                picUrl = [itemAdaptor.picUrls objectForKey:DSelfUpLoadImg];
            }
            if(!picUrl)
            {
                isLocal = NO;
                picUrl = [itemAdaptor.picUrls objectForKey:DLargePic];
                if(!picUrl)
                {
                    picUrl = [itemAdaptor.picUrls objectForKey:DSamllPic];
                }
            }
            if(picUrl)
            {
                MJPhoto *photo = [[MJPhoto alloc] init];
                UITableViewCell* cell = [mainTable_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                UIImageView* imageView = [cell viewWithTag:6666];
                photo.srcImageView = imageView;
                if(isLocal)
                {
                    photo.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:QN_URL_FOR_KEY(picUrl)];//本地路径
                }
                else
                {
                    photo.url = [NSURL URLWithString:picUrl]; //图片路径
                }
                [photos addObject:photo];
                if([itemAdaptor.guId isEqualToString:item.guId])
                {
                    currentIndex = sum;
                }
                sum++;
            }
        }
    }
    if(photos.count > 0)
    {
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.photos = photos; // 设置所有的图片
        browser.currentPhotoIndex = currentIndex;
        [browser show];
    }
    else
    {
        [DialogUtil postAlertWithMessage:@"查看图片失败"];
    }
}

-(void)didClickedMsgVoice:(XYMMessageItemAdaptor *)item
{
    if(curCellIndex >= 0)
    {
        NSIndexPath* index = [NSIndexPath indexPathForRow:curCellIndex inSection:0];
        XYMChatTableViewCell* cell = (XYMChatTableViewCell *)[mainTable_ cellForRowAtIndexPath:index];
        [cell stopVoicePlay];
    }
    curCellIndex = [currentArray_ indexOfObject:item];
    NSString* tmpFile = [item.mediaData objectForKey:DVoicePath];
    if(!tmpFile)
    {
        NSString* url = [item.mediaData objectForKey:DVoiceUrl];
        tmpFile = [FileUtil tempPathWithFileName:url.lastPathComponent];
    }
    else
    {
        tmpFile = [FileUtil tempPathWithFileName:tmpFile];
    }
    
    BOOL bExist = [FileUtil fileExists:tmpFile];
    if (bExist) {
        if (!recordAudio) { //初始化录音播音器
            recordAudio = [[RecordAudio alloc] init];
            recordAudio.delegate = self;
        }
        [recordAudio stopPlay];
        [recordAudio playOfFile:tmpFile];
    } else {
        [DialogUtil postAlertWithMessage:@"语音文件出错"];
    }
}

-(void)didClickedMsgShare:(XYMMessageItemAdaptor *)item
{
    NSDictionary* question = item.mediaData;
    NSString* title = [question objectWithKey:@"modelTitel"];
    NSString* url = [question objectWithKey:@"modelUrl"];
    
//    FollowDetailViewController* view = [[FollowDetailViewController alloc] init];
//    view.noticeTitle = title;
//    view.url = url;
//    view.isReadOnly = YES;
//    [self.navigationController pushViewController:view animated:YES];
    
    if(!item.isSelf)
    {
        [MobClick event:@"h_dr_follow_done"];
    }
}


-(void)didClickedUserImage:(XYMMessageItemAdaptor *)item
{
    if(item.fromUID && !item.isSelf)
    {
//        // 根据用户id 找到用户信息;
//        ExUserInfoViewController* view = [[ExUserInfoViewController alloc] init];
//        EUserInfo *info = [[XYMSessionManager instance]getUserCacheInfo:item.fromUID];
//        view.curInfo = info;
//        view.showInfo = YES;
//        view.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:view animated:YES];
    }
}

-(void)didUpLoadImgComplete:(XYMMessageItemAdaptor*)item
{
    EMessage* message = item.currentMessage;
    [[EMessagesDB shareInstance] updateWithMessage:message isNotifaction:NO];
    [self sendMessage:message];
}

-(void)didUpLoadVoiceComplete:(XYMMessageItemAdaptor *)item
{
    EMessage* message = item.currentMessage;
    [[EMessagesDB shareInstance] updateWithMessage:message isNotifaction:NO];
    [self sendMessage:message];
}

-(void)didDownLoadVoiceComplete:(XYMMessageItemAdaptor *)item
{
    EMessage* message = item.currentMessage;
    [[EMessagesDB shareInstance] updateWithMessage:message isNotifaction:NO];
}

-(void)didClickedReSend:(XYMMessageItemAdaptor *)item
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否重发消息？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alert.tag=1001;
    [alert show];
    reSendItem_=item;
}

-(void)didCopyMsg:(XYMMessageItemAdaptor *)item
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = item.msgContent;
}

-(void)didDeleteMsg:(XYMMessageItemAdaptor *)item
{
    [currentArray_ removeObject:item];
    if(mainTable_)
    {
        [mainTable_ reloadData];
    }
    [[EMessagesDB shareInstance] deleteMessage:toUID guid:item.guId];
}

-(void)didClickNomarl:(XYMMessageItemAdaptor *)item
{
    [self hideKeyBoardAndPopup];
}

-(void)didLongPress:(XYMMessageItemAdaptor *)item cellRect:(CGRect)rect showPoint:(CGPoint)point
{
}

-(void)didClickedURL:(NSTextCheckingResult *)linkInfo
{
    if(linkInfo.resultType==NSTextCheckingTypeLink)
    {
        
    }
}

-(NSString*)getCurrentInfo
{
    return [NSString stringWithFormat:@"%@ %d岁 %@",patientSex == 1?@"男":@"女",age,self.tagStr];
}


-(void)cleanData
{
    [inputBar_ cleanData];
    inputBar_ = nil;
    [currentArray_ removeAllObjects];
    currentArray_ = nil;
    mainTable_.delegate = nil;
    mainTable_ = nil;
//    SESSIONINSTANCE.chatUID = nil;
    [self removeNotification];
}

-(void)loadCacheWithAction:(void (^)(int count))action
{
    NSArray* array = [[EMessagesDB shareInstance] selectMessageWithPage:toUID page:page_];
    int count=(int)array.count;
    [self adjustTimeInAdaptorArrays:array isTop:YES];
    if(action){
        action(count);
    }
}

////加载假的缓存数据
//-(void)loadCacheWithAction:(void (^)(int count))action
//{
//    EMessage* message = [[EMessage alloc] init];
//    message.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
//    message.isSelf = YES;
//    message.isSend = YES;
//    message.friends_UID = @"6990";
//    message.isRead = YES;
//    message.content = @"测试会话";
//    message.createTime = @"2016-11-30 09:58:42";
//    message.sessionId = 240508;
//    message.messageType = 4;
//    
//    EMessage* message1 = [[EMessage alloc] init];
//    message1.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
//    message1.isSelf = YES;
//    message1.isSend = YES;
//    message1.friends_UID = @"6990";
//    message1.isRead = YES;
//    message1.content = @"测试会话1";
//    message1.createTime = @"2016-11-30 09:59:42";
//    message1.sessionId = 240508;
//    message1.messageType = 4;
//    
//    EMessage* message2 = [[EMessage alloc] init];
//    message2.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
//    message2.isSelf = NO;
//    message2.isSend = YES;
//    message2.friends_UID = @"6990";
//    message2.isRead = YES;
//    message2.content = @"测试会话2";
//    message2.createTime = @"2016-11-30 09:59:42";
//    message2.sessionId = 240508;
//    message2.messageType = 4;
//    
//    EMessage* message3 = [[EMessage alloc] init];
//    message3.myUID = [NSString stringWithFormat:@"%d",[MyUserInfo myInfo].userId];
//    message3.isSelf = NO;
//    message3.isSend = YES;
//    message3.friends_UID = @"6990";
//    message3.isRead = YES;
//    message3.content = @"测试会话3";
//    message3.createTime = @"2016-11-30 09:59:42";
//    message3.sessionId = 240508;
//    message3.messageType = 4;
//    
//    NSMutableArray *messageArray = [NSMutableArray array];
//    [messageArray addObject:message];
//    [messageArray addObject:message1];
//    [messageArray addObject:message2];
//    [messageArray addObject:message3];
//
//    int count=(int)messageArray.count;
//    [self adjustTimeInAdaptorArrays:messageArray isTop:YES];
//    if(action){
//        action(count);
//    }
//}


-(void)loadCacheWithPage
{
    page_++;
    [self loadCacheWithAction:^(int count){
        [mainTable_ reloadData];
        [self stopLoading];
        if(count>0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
            [mainTable_ scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            CGFloat _currentY = mainTable_.contentOffset.y;
            CGFloat _currentX = mainTable_.contentOffset.x;
            _currentY += 30;
            [mainTable_ setContentOffset:CGPointMake(_currentX, _currentY)];
            
        }
        else
        {
            page_--;
        }
        if(count<15)
        {
            mainTable_.tableHeaderView = nil;
        }
    }];
    
}

-(void)tapGestureRecognizer:(UITapGestureRecognizer*)getstureRecognizer
{
    if(getstureRecognizer.state==UIGestureRecognizerStateEnded)
    {
        [self hideKeyBoardAndPopup];
    }
}

-(void)hideKeyBoardAndPopup
{
    [inputBar_ hideKeyBoard];
}

-(void)tapTopAction:(UITapGestureRecognizer*)recognizer
{
    [self hideKeyBoardAndPopup];
    UIView* view = recognizer.view;
    [self tapTopActionWithView:view];
}

-(void)tapTopActionWithView:(UIView*)tapView
{
//    ExUserInfoViewController* view = [[ExUserInfoViewController alloc] init];
//    view.nUID = toUID;
//    view.showInfo = YES;
//    [self.navigationController pushViewController:view animated:YES];
//    //一对一聊天页，点击联系人姓名跳转到居民档案页次数
//    [MobClick event:@"h_dr_1to1_name_information"];
}

#pragma mark UITableView滚动到最底
-(void)scrollTableViewToBottom:(BOOL)animated
{
    if (currentArray_.count>0)
    {
        [mainTable_ scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentArray_.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(void)startLoading
{
    if(headerView_){
        isLoading=YES;
        headerView_.hidden=NO;
        [loading_ startAnimating];
    }
}

-(void)stopLoading
{
    if(headerView_){
        isLoading=NO;
        headerView_.hidden=YES;
        [loading_ stopAnimating];
    }
}

#pragma mark - ------------UIScrollViewDelegate 的代理方法------------

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyBoardAndPopup];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat y = scrollView.contentOffset.y;
    if (y <= 0 && !isLoading && mainTable_.tableHeaderView!=nil) {
        [self startLoading];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadCacheWithPage) object:nil];
        [self performSelector:@selector(loadCacheWithPage) withObject:nil afterDelay:0.5];
    }
}

#pragma mark - ------------UITableView 的代理方法------------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return currentArray_.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XYMMessageItemAdaptor* adaptor=[currentArray_ objectAtIndex:indexPath.row];
    return [XYMChatTableViewCell currentCellHeight:adaptor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier=@"ChatContentCell";
    XYMChatTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell=[[XYMChatTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.delegate=self;
    }
    XYMMessageItemAdaptor* adaptor=[currentArray_ objectAtIndex:indexPath.row];
    [cell fillWithData:adaptor];
    
    return cell;
}

#pragma mark - --------------------UIAlertView的代理方法----------------------
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //是否重发消息的确认框
    if(alertView.tag==1001)
    {
        if(buttonIndex==1)
        {
            [currentArray_ removeObject:reSendItem_];
            [reSendItem_ updateRepeatTime];
            [self adjustTimeInAdaptorItem:reSendItem_];
            [mainTable_ reloadData];
            [self repeatMessage:reSendItem_];
        }
        reSendItem_=nil;
    }
}


#pragma mark - ------------MessageInputBar 的代理方法------------
-(void)keyboardAction:(CGFloat)height
{
    CGRect frame=mainTable_.frame;
    frame.size.height=height;
    mainTable_.frame=frame;
    if(inputBar_.currentState!=XYMViewStateShowNone)
    {
        [self scrollTableViewToBottom:YES];
    }
}
@end
