//
//  TKAlertCenter.m
//  Created by Devin Ross on 9/29/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKAlertCenter.h"
#import "UIView+TKCategory.h"
//#import "UIColor+HTML.h"

CGRect subtractRect(CGRect wf,CGRect kf);
const float KDefaultAlertDuration=3.15;

@interface TKAlertCenter()
@property (nonatomic,retain) NSMutableArray *alerts;
@end


@implementation TKAlertCenter
@synthesize alerts;
@synthesize bgColor=bgColor_;
@synthesize bgRadius=bgRadius_;
@synthesize textColor=textColor_;
@synthesize vAlignment=vAlignment_;

+ (TKAlertCenter*) defaultCenter {
	static TKAlertCenter *defaultCenter = nil;
	if (!defaultCenter) {
		defaultCenter = [[TKAlertCenter alloc] init];
        defaultCenter.bgRadius=10;
        defaultCenter.bgColor=[UIColor colorWithWhite:0 alpha:0.8];
        defaultCenter.textColor=[UIColor whiteColor];
        defaultCenter.vAlignment=TKAlertCenterVAlignmentCenter;
	}
	return defaultCenter;
}

+ (TKAlertCenter*) alertCenterWithBgColor:(UIColor*)color
{
	TKAlertCenter *defaultCenter = [TKAlertCenter defaultCenter];
    defaultCenter.bgRadius=0;
    defaultCenter.bgColor=color;
    return defaultCenter;
}

+ (TKAlertCenter*) alertCenterWithBgColor:(UIColor*)color textColor:(UIColor*)textColor
{
	TKAlertCenter *defaultCenter = [TKAlertCenter defaultCenter];
    defaultCenter.bgRadius=0;
    defaultCenter.bgColor=color;
    defaultCenter.textColor=textColor;
    return defaultCenter;
}

- (id) init {
	if(!(self=[super init])) return nil;
	
	self.alerts = [NSMutableArray array];
	alertView = [[TKAlertView alloc] initWithTextAlignment:textAlignment];
	active = NO;
    duration_=KDefaultAlertDuration;
	
	iWindow=[[UIApplication sharedApplication].windows objectAtIndex:0];//[UIApplication sharedApplication].keyWindow
	alertFrame = iWindow.bounds;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

	return self;
}
- (void) showAlerts
{
	if(iSequenced)
	{
		if([self.alerts count] < 1) 
		{
			active = NO;
			return;
		}
		
		active = YES;
		
		NSArray *ar = [self.alerts objectAtIndex:0];
		
		UIImage *img = nil;
		if([ar count] > 1) 
			img = [[self.alerts objectAtIndex:0] objectAtIndex:1];
		
		[alertView setImage:img];

		if([ar count] > 0) 
			[alertView setMessageText:[[self.alerts objectAtIndex:0] objectAtIndex:0]];
	}
	else
	{
		[alertView removeFromSuperview];
		alertView = [[TKAlertView alloc] initWithTextAlignment:textAlignment];
		NSArray *ar = [self.alerts lastObject];
		
		UIImage *img=nil;
		if([ar count] > 1) 
			img = [ar objectAtIndex:1];
		[alertView setImage:img];
		
		if([ar count] > 0) 
			[alertView setMessageText:[ar objectAtIndex:0]];
	
	}
	
	alertView.transform = CGAffineTransformIdentity;
	alertView.alpha = 0;
	[iWindow addSubview:alertView];

    switch ([TKAlertCenter defaultCenter].vAlignment)
    {
        case TKAlertCenterVAlignmentTop:
             alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+20+44/2);
            break;
        case TKAlertCenterVAlignmentBottom:
            alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+iWindow.frame.size.height-44-20-5);
            break;
        default:
            alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);
            break;
    }
   
	/*
	CGRect rr = alertView.frame;
	rr.origin.x = (int)rr.origin.x;
	rr.origin.y = (int)rr.origin.y;
	alertView.frame = rr;
	 */
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
        alertView.transform = CGAffineTransformScale(alertView.transform, 2, 2);
    }

	//[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep2)];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    }
	//CGRect rect = CGRectMake((int)alertView.frame.origin.x, (int)alertView.frame.origin.y, alertView.frame.size.width, alertView.frame.size.height);
	//alertView.frame=rect;
	alertView.alpha = 1;
	
	[UIView commitAnimations];
}
- (void) animationStep2{
	[UIView beginAnimations:nil context:nil];

	// depending on how many words are in the text
	// change the animation duration accordingly
	// avg person reads 200 words per minute
	
	/*
	 NSArray * words = [[[self.alerts objectAtIndex:0] objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	 double duration = 3.0;//MAX(((double)[words count]*60.0/200.0),1);
	 */
	double duration = duration_-0.15;
    if(duration<0)
    {
        duration=0;
    }
	
	[UIView setAnimationDelay:duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep3)];
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
        alertView.transform = CGAffineTransformScale(alertView.transform, 0.5, 0.5);
    }
	
	alertView.alpha = 0;
	[UIView commitAnimations];
}

- (void) animationStep3{
	if(iSequenced)
	{
		[alertView removeFromSuperview];
		[alerts removeObjectAtIndex:0];
		[self showAlerts];
	}
    duration_=KDefaultAlertDuration;
}
- (void) postAlertWithMessage:(NSString*)message image:(UIImage*)image{
	[self.alerts addObject:[NSArray arrayWithObjects:message,image,nil]];
	if(iSequenced)
	{
		[self showAlerts];
	}
	else
	{
		if(!active) 
			[self showAlerts];
	}
}

- (void) postAlertWithMessage:(NSString*)message
{
	textAlignment=NSTextAlignmentCenter;
	[self postAlertWithMessage:message image:nil];
}

- (void) postAlertWithMessage:(NSString*)message duration:(float)duration
{
    duration_=duration;
	textAlignment=NSTextAlignmentCenter;
	[self postAlertWithMessage:message image:nil];
}


- (void) postAlertWithMessage:(NSString*)message textAlignment:(NSTextAlignment)aTextAlignment
{
	textAlignment=aTextAlignment;
	[self postAlertWithMessage:message image:nil];
}

- (void) postAlertWithMessage:(NSString *)message sequenced:(BOOL)aSequenced
{
	iSequenced=aSequenced;
	[self postAlertWithMessage:message];
}

- (void) dealloc{

}


CGRect subtractRect(CGRect wf,CGRect kf)
{
	if(!CGPointEqualToPoint(CGPointZero,kf.origin)){
		
		if(kf.origin.x>0) kf.size.width = kf.origin.x;
		if(kf.origin.y>0) kf.size.height = kf.origin.y;
		kf.origin = CGPointZero;
		
	}else{
		
		
		kf.origin.x = abs(kf.size.width - wf.size.width);
		kf.origin.y = abs(kf.size.height -  wf.size.height);
		
		
		if(kf.origin.x > 0){
			CGFloat temp = kf.origin.x;
			kf.origin.x = kf.size.width;
			kf.size.width = temp;
		}else if(kf.origin.y > 0){
			CGFloat temp = kf.origin.y;
			kf.origin.y = kf.size.height;
			kf.size.height = temp;
		}
		
	}
	return CGRectIntersection(wf, kf);
	
	
	
}

- (void) keyboardWillAppear:(NSNotification *)notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect kf = [aValue CGRectValue];
	CGRect wf = iWindow.bounds;
	
	[UIView beginAnimations:nil context:nil];
	alertFrame = subtractRect(wf,kf);
	alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);

	[UIView commitAnimations];

}
- (void) keyboardWillDisappear:(NSNotification *) notification {
	alertFrame = iWindow.bounds;
    
    [UIView beginAnimations:nil context:nil];
	alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);
	[UIView commitAnimations];

}
- (void) orientationWillChange:(NSNotification *) notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
	UIInterfaceOrientation o = [v intValue];
	
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	
    alertFrame = iWindow.bounds;
    
	[UIView beginAnimations:nil context:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    }
//	alertView.frame = CGRectMake((int)alertView.frame.origin.x, (int)alertView.frame.origin.y, (int)alertView.frame.size.width, (int)alertView.frame.size.height);
    alertView.center = CGPointMake(alertFrame.origin.x+alertFrame.size.width/2, alertFrame.origin.y+alertFrame.size.height/2);
	[UIView commitAnimations];
}

@end

@implementation TKAlertView
//@synthesize messageRect;

- (id) initWithTextAlignment:(NSTextAlignment)aTextAlignment
{
	
	if(!(self = [super initWithFrame:CGRectMake(0, 0, 100, 100)])) 
		return nil;
	
	textAlignment=aTextAlignment;
	messageRect = CGRectInset(self.bounds, 10, 10);
	self.backgroundColor = [UIColor clearColor];
    self.tag=-1;
	
	return self;
	
}
- (void) adjust{
	const int KConstrainedWidth=270;
	const int KConstrainedHeight=430;
	const int KWidth=300;
	const int KHeight=460;
	const int KPaddingTop=10;
	const int KPaddingLeft=10;
	
	CGSize s = [text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(KConstrainedWidth,KConstrainedHeight) lineBreakMode:NSLineBreakByWordWrapping];
	s.width+=20;
	
	//float imageAdjustment = 0;
	//if (image) 
	//{
	//	imageAdjustment = 7+image.size.height;
	//}
	
	int width=s.width+KPaddingLeft*2;
	if (width>KWidth) 
	{
		width=KWidth;
	}
	int height=s.height+KPaddingTop*2;
	if (height>KHeight) 
	{
		height=KHeight;
	}
	
	//CGRect rect = CGRectMake(0, 0, s.width+40, s.height+15+15+imageAdjustment);
	CGRect rect = CGRectMake(0, 0, width,height);
	self.bounds=rect;

	messageRect.size = s;
	messageRect.origin.x = (rect.size.width-messageRect.size.width)/2;
	messageRect.origin.y = (rect.size.height-messageRect.size.height)/2;

	[self setNeedsLayout];
	[self setNeedsDisplay];
	
}
- (void) setMessageText:(NSString*)str{
	text = str;
	[self adjust];
}
- (void) setImage:(UIImage*)img{
	image = img;
	if(image)
		[self adjust];
}
- (void) drawRect:(CGRect)rect{
    UIFont* font=[UIFont boldSystemFontOfSize:14];
    
	[UIView drawRoundRectangleInRect:rect withRadius:[TKAlertCenter defaultCenter].bgRadius color:[TKAlertCenter defaultCenter].bgColor];
	//[[UIColor whiteColor] set];
    [[TKAlertCenter defaultCenter].textColor set];
	[text drawInRect:messageRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:textAlignment];
	
	if(image)
	{
		CGRect r = CGRectZero;
		r.origin.y = 15;
		r.origin.x = (rect.size.width-image.size.width)/2;
		r.size = image.size;
		
		[image drawInRect:r];
	}
}
- (void) dealloc{

}

@end