#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WaitingWindow.h"
#import "TKAlertCenter.h"

@interface DialogUtil : NSObject

//post
+(void)initAlertCenter;
+(void)initAlertCenterWithBgColor:(UIColor*)color;
+(void)initAlertCenterWithBgColor:(UIColor*)color textColor:(UIColor*)textColor;
+(void)setAlertCenterTextColor:(UIColor*)textColor;
+(void)setAlertCenterVAligment:(TKAlertCenterVAlignment)vAlignment;
+(void)postAlertWithMessage:(NSString *)aText;
+(void)postAlertWithMessage:(NSString *)aText duration:(float)duration;
+(void)postAlertWithMessage:(NSString *)aText textAlignment:(NSTextAlignment)aTextAlignment;
+(void)postAlertWithMessage:(NSString *)aText sequenced:(BOOL)aSequenced;
+(void)postAlertWithMessage:(NSString *)aText afterDelay:(NSTimeInterval)delay;

//WaitingView
+(void)initWaitingView;
+(void)showWaitingViewWithMessage:(NSString*)aText;
//+(void)showModalWaitingViewWithMessage:(NSString*)aText;
//+(void)showModalWaitingViewWithMessage:(NSString*)aText delegate:(id<PWaitingWindowDelegate>)aDelegate buttonTitle:(NSString*)aButtonTitle;
//+(void)showModalWaitingViewWithCustomView:(UIView*)customView;
//+(void)showModalWaitingViewWithCustomView:(UIView*)customView masking:(BOOL)masking;
+(void)showWaitingViewWithCustomView:(UIView*)customView;
+(void)setWaitingViewProgress:(float)aProgress;
+(void)hideWaitingView;

+(void)initTopMessageView;
+(void)showTopMessageViewWithMessage:(NSString*)aText customView:(UIView*)customView tapAction:(void (^)(void))action;
+(void)showTopMessageViewWithMessage:(NSString*)aText customView:(UIView*)customView;
+(void)showTopMessageViewWithMessage:(NSString*)aText;

@end
