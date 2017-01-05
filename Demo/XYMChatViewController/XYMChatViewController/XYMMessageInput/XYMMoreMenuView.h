//
//  MoreView.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMMoreMenuItem.h"

@protocol XYMMoreMenuViewDelegate <NSObject>

@optional
- (void)didSelecteMenuItem:(XYMMoreMenuItem *)shareMenuItem atIndex:(NSInteger)index;

@end

@interface XYMMoreMenuView : UIView

@property (nonatomic, strong) NSArray* moreMenuItems;

@property (nonatomic, weak) id<XYMMoreMenuViewDelegate> delegate;

- (void)reloadData;

@end
