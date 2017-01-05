//
//  RequestContentView.h
//  21cbh_iphone
//
//  Created by Franky on 14-7-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperation.h"

@interface XYMRequestContentView : UIView
{
    AFHTTPRequestOperation* currentRequest;
}

#pragma 开始数据请求
-(void)startRequestWithCompleted:(void(^)(XYMRequestContentView* view, NSString* key))block;
#pragma 清空数据
-(void)cancelAndClean;

@end
