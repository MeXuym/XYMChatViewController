//
//  JRMessageView.m
//  JRMessage-Demo
//
//  Created by wxiao on 15/12/28.
//  Copyright © 2015年 wxiao. All rights reserved.
//

#import "JRMessageView.h"

#define SCREEN_W ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_H ([UIScreen mainScreen].bounds.size.height)
#define MESSAGE_H 60

@interface JRMessageView ()
{
    void (^block)(void);
}

@property (nonatomic, strong) UILabel		*titleLabel;
@property (nonatomic, strong) UIView        *iconView;
@property (nonatomic, assign) CGFloat		messageHeight;
@property (nonatomic, assign) CGFloat		iconWidth;

@property (nonatomic, strong) NSTimer		*timer;
@property (nonatomic, assign) NSTimeInterval timerInt;

@property (nonatomic, assign) CGFloat		messageOriginY;

@property (nonatomic, assign) CGPoint		startLoaction;
@property (nonatomic, assign) CGPoint		nowLoaction;
@property (nonatomic, assign) CGPoint		endLoaction;

@property (nonatomic, assign) CGFloat		messageMaxY;
@property (nonatomic, assign) CGFloat		messageSimY;
@property (nonatomic, assign) CGFloat		proPoint;

@end

@implementation JRMessageView

- (instancetype)init {
	if (self = [super init]) {
        self.messageHeight = 60;
		self.messageLeft	= 15;
		self.messageTop		= 5;
		self.messageBottom	= 10;
		self.messageRight	= 10;
		self.iconWidth		= 50;
		self.messageHMargin = 10;
		self.messageVMargin = 2;
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleDeviceOrientationDidChange:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil
		 ];
	}
	return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     position:(JRMessagePosition)position
                      superVC:(UIViewController *)superVC
                     duration:(CGFloat)duration
{
	
	self.title = title;
	self.viewController = superVC;
	self.duration = duration;
	self.messagePosition = position;
	
	if (self = [self init])
    {
        UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_W - 20, self.messageHeight - 20)];
        bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        bgView.layer.cornerRadius = 8;
        [self addSubview:bgView];
        
        self.iconView = [[UIView alloc] initWithFrame:CGRectMake(self.messageLeft, self.messageTop, self.iconWidth, self.iconWidth)];
        [self addSubview:self.iconView];
        
        self.titleLabel	= [[UILabel alloc] init];
        self.titleLabel.text = title;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        
        CGRect frame = CGRectMake(self.messageRight + self.iconWidth + self.messageHMargin, self.messageTop, bgView.width - (self.iconWidth + self.messageRight + self.messageHMargin * 2), 25);
        self.titleLabel.frame = frame;
        self.titleLabel.textColor = [UIColor whiteColor];
        [bgView addSubview:self.titleLabel];
		
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
		[self addGestureRecognizer:pan];
	
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
		[self addGestureRecognizer:tap];

        self.userInteractionEnabled = YES;
	}
	return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     position:(JRMessagePosition)position
					 duration:(CGFloat)duration
{
    return [self initWithTitle:title position:position superVC:nil duration:duration];
}

-(instancetype)initWithPosition:(JRMessagePosition)position duration:(CGFloat)duration
{
    return [self initWithTitle:nil position:position duration:duration];
}

-(void)setMessageText:(NSString *)aText
{
    self.title = aText;
    self.titleLabel.text = aText;
}

// 屏幕方向监听
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
	[self layoutIfNeeded];
}

// 刷新布局
- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (self.messagePosition != JRMessagePositionBottom) {
		self.frame = CGRectMake(0, -self.messageHeight, SCREEN_W, self.messageHeight);
	} else {
		self.frame = CGRectMake(0, SCREEN_H, SCREEN_W, self.messageHeight);
	}
	
	if (self.messagePosition == JRMessagePositionTop) {
		self.messageOriginY = 64;
		self.messageSimY = -self.messageHeight;
		self.messageMaxY = 64;
	} else if(self.messagePosition == JRMessagePositionNavBarOverlay) {
		self.messageOriginY = 0;
		self.messageSimY = -self.messageHeight;
		self.messageMaxY = 0;
	} else if(self.messagePosition == JRMessagePositionBottom) {
		if (self.viewController.tabBarController) {
			self.messageOriginY = SCREEN_H - 49 - self.messageHeight;
			self.messageSimY	= SCREEN_H - 49 - self.messageHeight;
			self.messageMaxY	= SCREEN_H;
		} else {
			self.messageOriginY = SCREEN_H - self.messageHeight;
			self.messageSimY	= SCREEN_H - self.messageHeight;
			self.messageMaxY	= SCREEN_H;
		}
	}
}

- (void)didClicked {
	[self hidedMessageView];
}

-(void)addLeftView:(UIView *)view
{
    CGRect frame = self.titleLabel.frame;
    if(!view)
    {
        frame.origin.x = self.iconView.left;
        self.titleLabel.frame = frame;
        return;
    }
    else
    {
        frame.origin.x = self.messageRight + self.iconWidth + self.messageHMargin;
        self.titleLabel.frame = frame;
    }
    
    [self.iconView addSubview:view];
}

-(void)setTapAction:(void (^)(void))action
{
    if(action)
    {
        block = nil;
        block = action;
    }
}

#pragma mark - Show/Hided Methond
- (void)showMessageView
{
	self.startLoaction	= CGPointZero;
	self.endLoaction	= CGPointZero;
	self.nowLoaction	= CGPointZero;
	self.proPoint		= 0.0;

	if (self.isShow == NO)
    {
        if(self.viewController)
        {
            [self.viewController.view addSubview:self];
        }
        else
        {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
        }
        
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calc) userInfo:nil repeats:YES];
		self.timerInt = 0;
		[self.timer fire];
		[UIView animateWithDuration:0.6
							  delay:0
			 usingSpringWithDamping:0.8
			  initialSpringVelocity:0.0
							options:UIViewAnimationOptionShowHideTransitionViews
						 animations:^{
							 CGRect frame	= self.frame;
							 frame.origin.y = self.messageOriginY;
							 self.frame		= frame;
						 } completion:^(BOOL finished) {
							 self.isShow	= YES;
						 }];
	}
}

- (void)showMessageViewAuto {
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calc) userInfo:nil repeats:YES];
	self.timerInt = 0;
	[self.timer fire];
	//		self.hidden = NO;
	[UIView animateWithDuration:0.6
						  delay:0
		 usingSpringWithDamping:0.8
		  initialSpringVelocity:0.0
						options:UIViewAnimationOptionShowHideTransitionViews
					 animations:^{
						 CGRect frame	= self.frame;
						 frame.origin.y = self.messageOriginY;
						 self.frame		= frame;
					 } completion:^(BOOL finished) {
						 self.isShow	= YES;
					 }];
}

- (void)hidedMessageView {
	
	if (self.isShow)
    {
		[self.timer invalidate];
		self.timer = nil;
		self.timerInt = 0;
		[UIView animateWithDuration:0.5
							  delay:0
			 usingSpringWithDamping:0.5
			  initialSpringVelocity:0
							options:UIViewAnimationOptionShowHideTransitionViews
						 animations:^{
							 CGRect frame = self.frame;
							 if (self.messagePosition != JRMessagePositionBottom) {
								 frame.origin.y = -self.messageHeight;
							 } else {
								 frame.origin.y = SCREEN_H + self.messageHeight;
							 }
							 self.frame		= frame;
						 } completion:^(BOOL finished) {
                             self.isShow = NO;
                             [self removeFromSuperview];
						 }];
	}
}

- (void)hidedMessageViewAuto
{
	if (self.isShow && self.timerInt >= self.duration) {
		[self.timer invalidate];
		self.timer = nil;
		self.timerInt = 0;
		[UIView animateWithDuration:0.8
							  delay:0
			 usingSpringWithDamping:0.8
			  initialSpringVelocity:0
							options:UIViewAnimationOptionShowHideTransitionViews
						 animations:^{
							 CGRect frame = self.frame;
							 if (self.messagePosition != JRMessagePositionBottom) {
								 frame.origin.y = -self.messageHeight;
							 } else {
								 frame.origin.y = SCREEN_H + self.messageHeight;
							 }
							 self.frame		= frame;
						 } completion:^(BOOL finished) {
                             self.isShow = NO;
                             [self removeFromSuperview];
						 }];
	}
}

- (void)calc
{
	self.timerInt += 1;
	[self hidedMessageViewAuto];
}

#pragma mark - Did Some Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	
}

- (void)tapAction:(id)sender
{
    if(block)
    {
        block();
        block = nil;
    }
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer {
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.startLoaction = [recognizer locationInView:self.viewController.view];
		self.proPoint = self.startLoaction.y;
		[self.timer invalidate];
		self.timer = nil;
	}
	
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		self.nowLoaction = [recognizer locationInView:self.viewController.view];
		
		self.proPoint = self.nowLoaction.y - self.proPoint;
		CGRect frame = self.frame;
		frame.origin.y = frame.origin.y + self.proPoint;
		
		if (frame.origin.y < self.messageMaxY && frame.origin.y > self.messageSimY) {
			self.frame = frame;
		}
		self.proPoint = self.nowLoaction.y;
	}
	
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		self.endLoaction = [recognizer locationInView:self.viewController.view];
		CGFloat longPan = self.endLoaction.y - self.startLoaction.y;
		if (longPan < 0) {
			longPan = -longPan;
		}
		if (longPan >= self.messageHeight * 0.35) {
			[self hidedMessageView];
		} else {
			[self showMessageViewAuto];
		}
	}
}

#pragma mark - Message View Dealloc
- (void)dealloc
{
    block = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIDeviceOrientationDidChangeNotification
												  object:nil
	];
}

@end