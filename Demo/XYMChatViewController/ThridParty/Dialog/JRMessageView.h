//
//  JRMessageView.h
//  JRMessage-Demo
//
//  Created by wxiao on 15/12/28.
//  Copyright © 2015年 wxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

///  Message Position
typedef NS_ENUM(NSInteger, JRMessagePosition) {
	JRMessagePositionTop = 0,
	JRMessagePositionNavBarOverlay,
	JRMessagePositionBottom
};

@interface JRMessageView : UIView


@property (nonatomic, assign)	BOOL				isShow;						//
@property (nonatomic, retain)	NSString			*title;						// 标题
@property (nonatomic, strong)	UIViewController	*viewController;			// 控制器
@property (nonatomic, assign)	CGFloat				duration;					// 显示时间

@property (nonatomic, assign)	CGFloat				messageTop;					//
@property (nonatomic, assign)	CGFloat				messageLeft;
@property (nonatomic, assign)	CGFloat				messageBottom;
@property (nonatomic, assign)	CGFloat				messageRight;
@property (nonatomic, assign)	CGFloat				messageHMargin;
@property (nonatomic, assign)	CGFloat				messageVMargin;

@property (nonatomic, assign)	JRMessagePosition	messagePosition;			// 位置

- (instancetype)initWithTitle:(NSString *)title
			         position:(JRMessagePosition)position
					  superVC:(UIViewController *)superVC
					 duration:(CGFloat)duration;

- (instancetype)initWithTitle:(NSString *)title
			         position:(JRMessagePosition)position
					 duration:(CGFloat)duration;

- (instancetype)initWithPosition:(JRMessagePosition)position
                        duration:(CGFloat)duration;

- (void)setMessageText:(NSString *)aText;
- (void)addLeftView:(UIView*)view;
- (void)setTapAction:(void (^)(void))action;

- (void)showMessageView;

- (void)hidedMessageView;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com