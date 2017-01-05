//
//  WaitingWindow.m
//  test120107
//
//  Created by wangweike on 12-2-10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WaitingWindow.h"

@implementation TransportationToolbar
- (void)drawRect:(CGRect)rect
{
	// do nothing
}

- (id)initWithFrame:(CGRect)aRect
{
	if ((self = [super initWithFrame:aRect]))
	{
		//self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.clearsContextBeforeDrawing = YES;
	}
	return self;
}
@end

@implementation AViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    UIView* view=nil;
    for (view in [self.view subviews]) 
    {
        if([view isKindOfClass:[IndicatorView class]])
        {
            //居中
            CGPoint center=CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMidY(self.view.bounds));
            view.center=center;
            
            break;
        }
    }
}

#ifdef __IPHONE_6_0
//for ios6
- (BOOL)shouldAutorotate
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}
#endif

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIWindow* window = [[UIApplication sharedApplication].delegate window];
    if (![window isKeyWindow])
    {
        [window becomeKeyWindow];
        [window makeKeyAndVisible];
    }
    
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

@interface WaitingWindow(private)
-(void)setNoModalFrame;
-(void)createBarViewWithButtonTitle:(NSString*)aTitle;
-(void)releaseBarView;
-(void)onButtonPressed;
@end

@implementation WaitingWindow

-(id)init
{
	return [self initWithIndicatorType:ActivityIndicator];
}

-(id)initWithIndicatorType:(IndicatorType)aIndicatorType
{
	if(self = [super init])
	{
		self.windowLevel = UIWindowLevelAlert;
		self.hidden=YES;
		//self.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
        iIndicatorView=[[IndicatorView alloc] initWithIndicatorType:aIndicatorType];
        
        viewController=[[AViewController alloc] init];
        self.rootViewController=viewController;
	}
	return self ;
}

-(void)dealloc
{
}

-(void)showIndicatorView
{
    if(!iIndicatorView.superview)
    {
        [viewController.view addSubview:iIndicatorView];
    }
    else 
    {
        iIndicatorView.hidden=NO;
    }
    
    //居中
    CGRect superBounds=iIndicatorView.superview.bounds;
    CGPoint center=CGPointMake(CGRectGetMidX(superBounds),CGRectGetMidY(superBounds));
    iIndicatorView.center=center;
}

-(void)setNoModalFrame
{
    //WaitingWindow以小尺寸居于窗口中间
    
	CGRect appframe=[[UIScreen mainScreen] bounds];
    UIView* view=iCustomView?iCustomView:iIndicatorView;
	int waitWidth=view.bounds.size.width;
	CGRect frame= CGRectMake((appframe.size.width-waitWidth)/2, 
							 (appframe.size.height-waitWidth)/2, 
							 waitWidth, waitWidth);
	self.frame=frame;
	posOffsetXWhenHide_=0;
    
	self.backgroundColor=UIColor.clearColor;
    self.hidden=NO;
    iModal=NO;
    
    frame.origin=CGPointZero;
    viewController.view.frame=frame;
}

-(void)createBarViewWithButtonTitle:(NSString*)aTitle
{
	if(!iBarView)
	{
		const int KBarHeight=45;
		CGRect rect=self.frame;
		rect.origin.y=rect.size.height-KBarHeight;
		rect.size.height=KBarHeight;
		iBarView=[[UIView alloc] initWithFrame:rect];
		iBarView.backgroundColor=[UIColor colorWithRed:0xf5/255.f green:0xf5/255.f blue:0xf5/255.f alpha:1.0f];
		[self addSubview:iBarView];
		
		/*
		UIImage* image=[UIImage imageNamed:@"editbutton.png"];
		UIImage* imagePress=[UIImage imageNamed:@"editbutton_press.png"];
		if(image && imagePress)
		{
			int width=image.size.width;
			int height=image.size.height;
			int y=(KBarHeight-height)/2;
			UIButton* button=[[UIButton alloc] initWithFrame:CGRectMake(5, y, width, height)];
			[button setBackgroundImage:imagePress forState:UIControlStateHighlighted];
			[button setBackgroundImage:image forState:UIControlStateNormal];
			[iBarView addSubview:button];
			[button release];
			[button setTitle:@"cancel" forState:UIControlStateNormal];
		}
		 */
		

		UIToolbar* toolbar=[[TransportationToolbar alloc] initWithFrame:CGRectMake(5, 0, 50, KBarHeight)];
		toolbar.tag=999;
		UIBarButtonItem* button=[[UIBarButtonItem alloc] initWithTitle:aTitle
																  style:UIBarButtonItemStyleBordered
																 target:self
																 action:@selector(onButtonPressed)];
		[toolbar setItems:[NSArray arrayWithObject:button]];
		[iBarView addSubview:toolbar];
	}
	else
	{
		UIToolbar* toolbar=(UIToolbar*)[iBarView viewWithTag:999];
		UIBarButtonItem* button=[[UIBarButtonItem alloc] initWithTitle:aTitle
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(onButtonPressed)];
		[toolbar setItems:[NSArray arrayWithObject:button]];
	}
}

-(void)releaseBarView
{
	if(iBarView)
	{
		[iBarView removeFromSuperview];
		iBarView=nil;
	}
}

-(void)setModelBgWithColored:(BOOL)colored
{
	if(!iModal)
	{
        self.frame=[[UIScreen mainScreen] bounds];
        posOffsetXWhenHide_=0;
        if(colored)
        {
            self.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
        }
        else
        {
            self.backgroundColor=[[UIColor whiteColor] colorWithAlphaComponent:0.01];;//[UIColor clearColor]; clearColor也不能阻止键盘，必须赋值一个颜色
        }
		iModal=YES;
	}
	self.hidden=NO;
    
    CGRect frame=self.frame;
    frame.origin.x-=posOffsetXWhenHide_;
    self.frame=frame;
    posOffsetXWhenHide_=0;
    
    frame.origin=CGPointZero;
    viewController.view.frame=frame;
}

-(void)showModalWithCustomView:(UIView*)customView 
{
    [self showModalWithCustomView:customView masking:YES];
}

-(void)showModalWithCustomView:(UIView*)customView masking:(BOOL)masking
{
    iIndicatorView.hidden=YES;
    [self releaseBarView];
    
    [iCustomView removeFromSuperview];
    iCustomView=customView;
    
    [viewController.view addSubview:iCustomView];
    
	[self setModelBgWithColored:masking];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        self.rootViewController=viewController;
    }
    else
    {
        [self addSubview:viewController.view];
    }
}

-(void)showCustomView:(UIView*)customView
{
	iIndicatorView.hidden=YES;
    [self releaseBarView];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [iCustomView removeFromSuperview];
    iCustomView=customView;

    [viewController.view addSubview:iCustomView];
    
	[self setNoModalFrame];
    
    CGRect customViewFrame=iCustomView.frame;
    customViewFrame.origin=CGPointMake(0, 0);
    iCustomView.frame=customViewFrame;
    
	[self addSubview:iCustomView];
}

-(void)showModalWithDelegate:(id<PWaitingWindowDelegate>)aDelegate buttonTitle:(NSString*)aButtonTitle
{
    [iCustomView removeFromSuperview];
    iCustomView=nil;
    
	[self setModelBgWithColored:YES];
    [self showIndicatorView];
	
	iDelegate=aDelegate;
	if(iDelegate)
	{
		[self createBarViewWithButtonTitle:aButtonTitle];
	}
	else 
	{
		[self releaseBarView];
	}
}

-(void)showModal
{
	[self showModalWithDelegate:nil buttonTitle:nil];
}

-(void)show
{
	[self releaseBarView];
    [self setNoModalFrame];
    [self showIndicatorView];
}

-(void)hide
{
    if(!self.hidden)
    {
        posOffsetXWhenHide_=1000;
        CGRect frame=self.frame;
        frame.origin.x+=posOffsetXWhenHide_;
        self.frame=frame;
        
        self.hidden=YES;
        iDelegate=nil;
        
        [iIndicatorView setProgress:0];
        [iIndicatorView removeFromSuperview];
        
        [iCustomView removeFromSuperview];
        iCustomView=nil;
    }
}

-(void)setMessage:(NSString*)newMsg
{
	[iIndicatorView setMessage:newMsg];
}

-(void)setProgress:(float)aProgress
{
	[iIndicatorView setProgress:aProgress];
}

-(void)onButtonPressed
{
	if(iDelegate)
	{
		[iDelegate onCancelWaitingWindowClicked];
	}
}

@end
