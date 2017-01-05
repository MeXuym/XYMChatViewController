#import "DialogUtil.h"
#import "JRMessageView.h"

static WaitingWindow* gWaitingWindow = nil;
static JRMessageView* topMessageView = nil;

@implementation DialogUtil

+(void)initAlertCenter
{
	[TKAlertCenter defaultCenter];
}

+(void)initAlertCenterWithBgColor:(UIColor*)color
{
	[TKAlertCenter alertCenterWithBgColor:color];
}

+(void)initAlertCenterWithBgColor:(UIColor*)color textColor:(UIColor*)textColor
{
    [TKAlertCenter alertCenterWithBgColor:color textColor:textColor];
}

+(void)setAlertCenterTextColor:(UIColor*)textColor
{
    TKAlertCenter *defaultCenter = [TKAlertCenter defaultCenter];
    defaultCenter.textColor=textColor;
}

+(void)setAlertCenterVAligment:(TKAlertCenterVAlignment)vAlignment
{
    TKAlertCenter *defaultCenter = [TKAlertCenter defaultCenter];
    defaultCenter.vAlignment=vAlignment;
}

+(void)postAlertWithMessage:(NSString *)aText
{
	[[TKAlertCenter defaultCenter] postAlertWithMessage:aText];
}

+(void)postAlertWithMessage:(NSString *)aText duration:(float)duration
{
	[[TKAlertCenter defaultCenter] postAlertWithMessage:aText duration:duration];
}

+(void)postAlertWithMessage:(NSString *)aText textAlignment:(NSTextAlignment)aTextAlignment
{
	[[TKAlertCenter defaultCenter] postAlertWithMessage:aText textAlignment:aTextAlignment];
}

+(void)postAlertWithMessage:(NSString *)aText afterDelay:(NSTimeInterval)delay
{
	[[TKAlertCenter defaultCenter] performSelector:@selector(postAlertWithMessage:) withObject:aText afterDelay:delay];
}

+(void)postAlertWithMessage:(NSString *)aText sequenced:(BOOL)aSequenced
{
	[[TKAlertCenter defaultCenter] postAlertWithMessage:aText sequenced:aSequenced];
}

+(void)initWaitingView
{
	if (!gWaitingWindow) 
	{
		gWaitingWindow = [[WaitingWindow alloc] initWithIndicatorType:ActivityIndicator];
	}
}

+(void)showWaitingViewWithMessage:(NSString*)aText
{
	[gWaitingWindow setMessage:aText];
	[gWaitingWindow show];
}

+(void)showModalWaitingViewWithMessage:(NSString*)aText
{
	[gWaitingWindow setMessage:aText];
	[gWaitingWindow showModal];
}

+(void)showModalWaitingViewWithMessage:(NSString*)aText delegate:(id<PWaitingWindowDelegate>)aDelegate buttonTitle:(NSString*)aButtonTitle
{
	[gWaitingWindow setMessage:aText];
	[gWaitingWindow showModalWithDelegate:aDelegate buttonTitle:aButtonTitle];
}

+(void)showModalWaitingViewWithCustomView:(UIView*)customView
{
	[DialogUtil showModalWaitingViewWithCustomView:customView masking:YES];
}
+(void)showModalWaitingViewWithCustomView:(UIView*)customView masking:(BOOL)masking
{
	[gWaitingWindow setMessage:nil];
	[gWaitingWindow showModalWithCustomView:customView masking:masking];
}

+(void)showWaitingViewWithCustomView:(UIView*)customView
{
    [gWaitingWindow setMessage:nil];
	[gWaitingWindow showCustomView:customView];
}

+(void)setWaitingViewProgress:(float)aProgress
{
    [gWaitingWindow setProgress:aProgress];
}

+(void)hideWaitingView
{
    [gWaitingWindow hide];
}

+(void)initTopMessageView
{
    if(!topMessageView)
    {
        topMessageView = [[JRMessageView alloc] initWithPosition:JRMessagePositionTop duration:5];
    }
}

+(void)showTopMessageViewWithMessage:(NSString*)aText customView:(UIView*)customView tapAction:(void (^)(void))action
{
    [topMessageView setMessageText:aText];
    [topMessageView addLeftView:customView];
    [topMessageView setTapAction:action];
    [topMessageView showMessageView];
}

+(void)showTopMessageViewWithMessage:(NSString*)aText customView:(UIView*)customView
{
    [self showTopMessageViewWithMessage:aText customView:customView tapAction:nil];
}

+(void)showTopMessageViewWithMessage:(NSString*)aText
{
    [self showTopMessageViewWithMessage:aText customView:nil];
}

@end


