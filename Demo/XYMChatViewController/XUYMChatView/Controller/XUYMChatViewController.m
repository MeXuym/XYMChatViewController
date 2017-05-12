//
//  XUYMChatViewController.m
//  XYMChatViewController
//
//  Created by xuym on 2017/5/10.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import "XUYMChatViewController.h"
#import "XUYMMessageInputBar.h"
#import "XUYMSendMsgManager.h"
#import "XUYMMessage.h"
#import "XUYMMessageDB.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface XUYMChatViewController ()<UITableViewDelegate,UITableViewDataSource,XUYMMessageInputBarDelegate>

@property (nonatomic,weak) XUYMMessageInputBar *inputBar;//底部的输入工具条
@property (nonatomic,strong) NSMutableArray *currentArray;//数据源数组
@property (nonatomic,weak) UITableView *chatLogTableView;//展示消息记录的tableView

@end

@implementation XUYMChatViewController

#pragma mark - life cycle
- (void)loadView {
    [super loadView];
    
    //做一些基础加载工作
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        //一般为了不让tableView 不延伸到 navigationBar 下面
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    //chatLogTableView加载
    UITableView *chatLogTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49-44-20) style:UITableViewStylePlain];
    chatLogTableView.delegate = self;
    chatLogTableView.dataSource = self;
    chatLogTableView.scrollsToTop = YES;
    chatLogTableView.backgroundColor = [UIColor clearColor];
    chatLogTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    chatLogTableView.scrollsToTop = NO;
    self.chatLogTableView = chatLogTableView;
    [self.view addSubview:self.chatLogTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //具体的子视图的加载
    
    //底部的输入条
    CGRect frame = CGRectMake(0, self.view.frame.size.height-49, ScreenWidth, 49);
    XUYMMessageInputBar *inputBar = [[XUYMMessageInputBar alloc] initWithFrame:frame superView:self.view];
    inputBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    inputBar.delegate = self;//设置代理
    self.inputBar = inputBar;
    [self.view addSubview:self.inputBar];
    
    //给tableView一个手势响应
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [self.chatLogTableView addGestureRecognizer:tap];

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"滚动准备开始");
    [self.inputBar hideKeyBoard];//让工具条把键盘缩下去
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

}


#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.currentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = @"test";
    cell.textLabel.textColor = [UIColor grayColor];
    cell.backgroundColor = [UIColor colorWithRed:233/255.f green:233/255.f blue:233/255.f alpha:1];
    return cell;
}

#pragma mark - XUYMMessageInputBarDelegate
//键盘高度
- (void)keyboardAction:(CGFloat)height {
    
    CGRect frame = self.chatLogTableView.frame;
    frame.size.height = height;
    self.chatLogTableView.frame = frame;
    if(self.inputBar.currentState != XUYMViewStateShowNone) {
        
        [self scrollTableViewToBottom:YES];
    }

}

//发送文本消息
- (void)sendTextAction:(NSString *)text {
    
    NSString* textContent = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(textContent.length == 0) {
        
        [DialogUtil postAlertWithMessage:@"不能输入空白消息"];
        return;
    }
    [self sendText:text];
}



#pragma mark - private methods

//发送消息具体处理
- (void)sendText:(NSString *)text {
    
    XUYMMessage* message = [XUYMSendMsgManager textMessageCreater:text toUID:@"test" myUID:@"test" isGroup:YES];
    [self sendMessage:message isRepeat:NO];
}

//发送消息
-(void)sendMessage:(XUYMMessage *)message isRepeat:(BOOL)isRepeat {
    
    if(!isRepeat) {
        //消息入库
        [[XUYMMessageDB shareInstance] insertWithMessage:message];
    }
    [self sendMessage:message];
}

//模拟消息发送
-(void)sendMessage:(XUYMMessage *)message {
    
    NSLog(@"模拟消息发送");
}


//tableView滑动键盘回收
-(void)tapGestureRecognizer:(UITapGestureRecognizer*)getstureRecognizer {
    
    if(getstureRecognizer.state==UIGestureRecognizerStateEnded){
        
        [self hideKeyBoardAndPopup];
    }
}

-(void)hideKeyBoardAndPopup {
    
    [self.inputBar hideKeyBoard];
}

#pragma mark UITableView滚动到最底
-(void)scrollTableViewToBottom:(BOOL)animated {
    
    if (self.currentArray.count>0) {
        
        [self.chatLogTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentArray.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
