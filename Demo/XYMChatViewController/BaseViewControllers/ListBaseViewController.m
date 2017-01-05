//
//  ListBaseViewController.m
//  healthcoming
//
//  Created by Franky on 15/8/6.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "ListBaseViewController.h"
#import "MJRefresh.h"

@interface ListBaseViewController()
{
    UIView* emptyView_;
}

@end

@implementation ListBaseViewController

-(id)init
{
    if(self = [super init])
    {
        currentArray = [NSMutableArray array];
    }
    return self;
}

- (CGRect)getTableViewFrame
{
    return CGRectMake(0, 1, self.view.frame.size.width, self.view.frame.size.height);
}

- (UIView*)getTableHeaderView
{
    return nil;
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStylePlain;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect tableFrame = [self getTableViewFrame];
    mainTableView = [[UITableView alloc] initWithFrame:tableFrame style:[self tableViewStyle]];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    mainTableView.backgroundColor = [UIColor clearColor];
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mainTableView.tableHeaderView = [self getTableHeaderView];
    [self.view addSubview:mainTableView];
}

-(void)setHeaderRefresh
{
    mainTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
}

-(void)removeHeaderRefresh
{
    mainTableView.header = nil;
}

-(void)setFooterRefresh
{
    mainTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)];
}

-(void)startRefresh
{
    [mainTableView.header beginRefreshing];
}

-(void)refresh
{
    [self refreshWithCompleted:^{
        [mainTableView.header endRefreshing];
    }];
}

-(void)refreshWithCompleted:(void(^)(void))block
{
}

-(void)getMore
{
    [self getMoreWithCompleted:^{
        [mainTableView.footer endRefreshing];
    }];
}

-(void)getMoreWithCompleted:(void(^)(void))block
{
}

- (UIView *)createEmptyListView
{
    NSString* imageName = [self setEmptyListImageName];
    /**
     *  @author Bennett.Peng, 16-05-15 17:05:13
     *
     *  @brief #2627 iPhone4 在居民档案页面中，咨询记录列表中的默认图不能完整的显示出来，这个交互不是很好，请调整下默认图的大小尽量的让其完整显示出来；
     *
     *  @since <#1.3.2#>
     */
    if(imageName)
    {
        
        UIView* view = [[UIView alloc] initWithFrame:[self setEmptyImageFrame]];
        view.backgroundColor =  [UIColor clearColor];
        
        UIImage* image = [UIImage imageNamed:imageName];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGFloat scale = (CGFloat) [UIScreen mainScreen].bounds.size.height/580;
        imageView.frame = CGRectMake(0, 0, 100 * scale, 100 * scale);
        imageView.center = view.center;
        
        [view addSubview:imageView];
        return view;
    }
    else
    {
        return nil;
    }
}

- (CGRect)setEmptyImageFrame
{
    return CGRectMake(0, -140, mainTableView.frame.size.width, mainTableView.frame.size.height-mainTableView.tableHeaderView.frame.size.height);
}

- (NSString *)setEmptyListImageName
{
    return nil;
}

- (void)showEmptyViewInView:(UIView*)parentView
{
    if (emptyView_==nil)
    {
        emptyView_ = [self createEmptyListView];
        emptyView_.backgroundColor = parentView.backgroundColor;
//        [emptyView_ setCenter:parentView.center];
        [parentView insertSubview:emptyView_ atIndex:0];
    }
}

- (void)hideEmptyView
{
    if (emptyView_)
    {
        [emptyView_ removeFromSuperview];
        emptyView_=nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBottom" object:nil];
}

-(void)dealloc
{
    [currentArray removeAllObjects];
    currentArray = nil;
}

#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"BaseCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
