//
//  RootViewController.m
//  XYMScan
//
//  Created by jack xu on 16/11/17.
//  Copyright © 2016年 jack xu. All rights reserved.
//

#import "RootViewController.h"
#import "TestChatViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 80, 40);
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"开始聊天" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startScan) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

-(void)startScan{
    
    TestChatViewController* viewController = [[TestChatViewController alloc] initWithUID:@"6990" myUID:@"6991" chatName:@"测试聊天" isGroup:NO];
    viewController.patientSex = 1;
    viewController.age = 15;
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.chatName = @"测试聊天";
    viewController.tagStr = @"测试聊天";
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
