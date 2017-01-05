//
//  BaseViewController.m
//  EShoreJST
//
//  Created by Administrators on 15-5-4.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

-(void)loadView
{
    [super loadView];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        //一般为了不让tableView 不延伸到 navigationBar 下面
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BGGray;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [DialogUtil hideWaitingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)baseViewStyle
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    line.backgroundColor = [LightGreen colorWithAlphaComponent:0.5];
    [self.view addSubview:line];
       
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    //（导航控制器返回的时候，右上角黑块）给他一个背景色白色
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (void)setNavigationTitle:(NSString*)title
{
    [self setNavigationTitle:title textColor:UIColor.blackColor fontSize:17.0];
}

- (void)setNavigationTitle:(NSString *)title textColor:(UIColor *)textColor fontSize:(Size)fontSize
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)];
    label.backgroundColor=[UIColor clearColor];
    
    label.text = title;
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:fontSize];
    
    [label sizeToFit];
    self.title=title;
    self.navigationItem.titleView = label;
}

- (void)setNavigationBackButton
{
    [self setNavigationBackButtonWithImage:[UIImage imageNamed:@"back.png"] highlightImage:[UIImage imageNamed:@"back_h.png"]];
}

- (void)setNavigationBackButtonWithImage:(UIImage *)image highlightImage:(UIImage *)highlightImage
{
    [self setNavigationBackButton:CGRectMake(0, 0, 11, 18) Image:image highlightImage:highlightImage];
}

- (void)setNavigationBackButton:(CGRect)frame Image:(UIImage *)image highlightImage:(UIImage *)highlightImage
{
    UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
    if(image)
    {
        [button setImage:image forState:UIControlStateNormal];
    }
    if(highlightImage)
    {
        [button setImage:highlightImage forState:UIControlStateHighlighted];
    }
    [button setFrame:frame];
    [button addTarget:self action:@selector(onNavigationBackPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [[self navigationItem] setLeftBarButtonItems:[NSArray arrayWithObjects:buttonItem, nil]];
}

-(void)setNavigationLeftButton:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 60, 32);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:NormalGreen forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)setNavigationRightButton:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 70, 32);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:NormalGreen forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, rightItem, nil];
}

-(void)onNavigationBackPressed
{
    BOOL modal=NO;
    
    if(self.presentingViewController || self.navigationController.presentingViewController)
    {
        modal=YES;
    }
    
    if(modal && isModalBack)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
