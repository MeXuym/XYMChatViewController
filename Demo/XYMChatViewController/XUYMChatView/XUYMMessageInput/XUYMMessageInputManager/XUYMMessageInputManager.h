//
//  XUYMMessageInputManager.h
//  XYMChatViewController
//
//  Created by xuym on 2017/5/11.
//  Copyright © 2017年 jack xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    XUYMViewStateShowNone,//没显示的状态
    XUYMViewStateShowNormal,//普通键盘状态
    XUYMViewStateShowFace,//显示表情状态
    XUYMViewStateShowMore,//显示更多的状态
}XUYMMesssageBarState;

@interface XUYMMessageInputManager : NSObject

@end
