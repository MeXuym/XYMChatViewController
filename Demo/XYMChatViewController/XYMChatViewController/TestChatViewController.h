//
//  TestChatViewController.h
//  healthcoming
//
//  Created by jack xu on 16/12/21.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "BaseViewController.h"
#import "XYMMessageInputBar.h"
#import "XYMMessageItemAdaptor.h"



@interface TestChatViewController : BaseViewController<XYMMessageInputBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    XYMMessageInputBar* inputBar_;
    NSMutableArray* currentArray_;
    UITableView* mainTable_;
    UIView* headerView_;
    BOOL isLoading;
    
    NSString* toUID;
    NSString* toName;
    NSString* currentUID;
}

-(void)loadCacheWithPage;
-(void)hideKeyBoardAndPopup;
-(void)cleanData;
-(void)startLoading;
-(void)stopLoading;
-(void)tapTopActionWithView:(UIView*)tapView;
-(void)scrollTableViewToBottom:(BOOL)animated;

-(id)initWithUID:(NSString*)theUID myUID:(NSString*)myUID chatName:(NSString*)chatName isGroup:(BOOL)isGroup;
-(void)loadCacheWithAction1:(void (^)(int count))action;
-(void)adjustTimeInAdaptorItem:(XYMMessageItemAdaptor*)adaptor;
-(void)adjustTimeInAdaptorArrays:(NSArray*)array isTop:(BOOL)isTop;
-(void)sendTextAction2:(NSString *)text archivesType:(NSString*)archivesType;
//传给友盟统计的用户名
@property (nonatomic,strong) NSString *chatName;

@property (nonatomic,assign) BOOL isNoFirst;
@property (nonatomic,assign) int age;
@property (nonatomic,assign) int patientSex;
@property (nonatomic,strong) NSString *tagStr;

@end
