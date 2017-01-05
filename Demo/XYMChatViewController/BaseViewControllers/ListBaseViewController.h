//
//  ListBaseViewController.h
//  healthcoming
//
//  Created by Franky on 15/8/6.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "BaseViewController.h"

@interface ListBaseViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* mainTableView;
    NSMutableArray* currentArray;
}

-(void)setHeaderRefresh;
-(void)removeHeaderRefresh;
-(void)setFooterRefresh;
-(void)startRefresh;
-(void)refreshWithCompleted:(void(^)(void))block;
-(void)getMoreWithCompleted:(void(^)(void))block;

-(CGRect)getTableViewFrame;
-(UIView*)getTableHeaderView;
-(UITableViewStyle)tableViewStyle;

-(CGRect)setEmptyImageFrame;
-(UIView *)createEmptyListView;
-(NSString *)setEmptyListImageName;
-(void)showEmptyViewInView:(UIView*)parentView;
-(void)hideEmptyView;

@end
