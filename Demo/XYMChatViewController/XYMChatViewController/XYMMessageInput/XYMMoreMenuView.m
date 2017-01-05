//
//  MoreView.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMMoreMenuView.h"

// 每行有4个
#define KMoreMenuPerRowItemCount 5
#define KMoreMenuPerColum 2

#define KMoreMenuItemIconSize 50
#define KMoreMenuItemHeight 70


@interface XYMMoreMenuItemView : UIView

@property (nonatomic, weak) UIButton *moreMenuItemButton;
@property (nonatomic, weak) UILabel *moreMenuItemTitleLabel;

@end

@implementation XYMMoreMenuItemView

- (void)setup {
    if (!_moreMenuItemButton) {
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        itemButton.frame = CGRectMake(0, 0, KMoreMenuItemIconSize, KMoreMenuItemIconSize);
        itemButton.backgroundColor = [UIColor clearColor];
        [self addSubview:itemButton];
        
        self.moreMenuItemButton = itemButton;
    }
    
    if (!_moreMenuItemTitleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moreMenuItemButton.frame), KMoreMenuItemIconSize, KMoreMenuItemHeight - KMoreMenuItemIconSize)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        self.moreMenuItemTitleLabel = titleLabel;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

@end

@interface XYMMoreMenuView ()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *moreMenuScrollView;
@property (nonatomic, weak) UIPageControl *moreMenuPageControl;

@end

@implementation XYMMoreMenuView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)initView
{
    self.backgroundColor=UIColorFromRGB(0xf0f0f0);
    if (!_moreMenuScrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
        scrollView.delegate = self;
        scrollView.canCancelContentTouches = NO;
        scrollView.delaysContentTouches = YES;
        scrollView.backgroundColor = self.backgroundColor;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [scrollView setScrollsToTop:NO];
        scrollView.pagingEnabled = YES;
        [self addSubview:scrollView];
        
        self.moreMenuScrollView = scrollView;
    }
    
    if (!_moreMenuPageControl) {
        UIPageControl* pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moreMenuScrollView.frame), CGRectGetWidth(self.bounds), 30)];
        pageControl.backgroundColor = self.backgroundColor;
        pageControl.hidesForSinglePage = YES;
        pageControl.defersCurrentPageDisplay = YES;
        [self addSubview:pageControl];
        
        self.moreMenuPageControl=pageControl;
    }
    [self reloadData];
}

-(void)reloadData
{
    
    
    if(!_moreMenuItems.count) return;
    [self.moreMenuScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat paddingX = (CGRectGetWidth(self.bounds)/KMoreMenuPerRowItemCount - KMoreMenuItemIconSize)/2;
    CGFloat paddingY = 10;
    CGFloat widthMargin = CGRectGetWidth(self.bounds)/KMoreMenuPerRowItemCount;// ((CGRectGetWidth(self.bounds) - paddingX)/KMoreMenuPerRowItemCount - KMoreMenuItemIconSize)/2;
    for (XYMMoreMenuItem *item in self.moreMenuItems) {
        NSInteger index = [self.moreMenuItems indexOfObject:item];
        NSInteger page = index / (KMoreMenuPerRowItemCount * KMoreMenuPerColum);
        CGRect shareMenuItemViewFrame = CGRectMake((index % KMoreMenuPerRowItemCount + 1) * widthMargin - KMoreMenuItemIconSize - paddingX + (page * CGRectGetWidth(self.bounds)), ((index / KMoreMenuPerRowItemCount) - KMoreMenuPerColum * page) * (KMoreMenuItemHeight + paddingY) + paddingY, KMoreMenuItemIconSize, KMoreMenuItemHeight);
        XYMMoreMenuItemView *itemView = [[XYMMoreMenuItemView alloc] initWithFrame:shareMenuItemViewFrame];
        itemView.moreMenuItemButton.tag = index;
        [itemView.moreMenuItemButton addTarget:self action:@selector(moreMenuItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [itemView.moreMenuItemButton setImage:item.normalIconImage forState:UIControlStateNormal];
        [itemView.moreMenuItemButton setImage:item.highlightIconImage forState:UIControlStateHighlighted];
        itemView.moreMenuItemTitleLabel.text = item.title;
        
        [self.moreMenuScrollView addSubview:itemView];
    }
    
    self.moreMenuPageControl.numberOfPages = (self.moreMenuItems.count / (KMoreMenuPerRowItemCount * 2) + (self.moreMenuItems.count % (KMoreMenuPerRowItemCount * 2) ? 1 : 0));
    [self.moreMenuScrollView setContentSize:CGSizeMake(((self.moreMenuItems.count / (KMoreMenuPerRowItemCount * 2) + (self.moreMenuItems.count % (KMoreMenuPerRowItemCount * 2) ? 1 : 0)) * CGRectGetWidth(self.bounds)), CGRectGetHeight(self.moreMenuScrollView.bounds))];
}

- (void)moreMenuItemButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelecteMenuItem:atIndex:)]) {
        NSInteger index = sender.tag;
        if (index < self.moreMenuItems.count) {
            [self.delegate didSelecteMenuItem:[self.moreMenuItems objectAtIndex:index] atIndex:index];
        }
    }
}

- (void)dealloc {
    self.moreMenuItems = nil;
    self.moreMenuScrollView.delegate = self;
    self.moreMenuScrollView = nil;
    self.moreMenuPageControl = nil;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.moreMenuPageControl setCurrentPage:currentPage];
}

@end
