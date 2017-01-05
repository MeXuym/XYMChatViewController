//
//  TKAlertCenter.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum 
{
    TKAlertCenterVAlignmentTop,
    TKAlertCenterVAlignmentCenter,
    TKAlertCenterVAlignmentBottom
} TKAlertCenterVAlignment;

@interface TKAlertView : UIView {
	CGRect messageRect;
	NSString *text;
	UIImage *image;
	NSTextAlignment textAlignment;
}

//@property (nonatomic) CGRect messageRect;

- (id) initWithTextAlignment:(NSTextAlignment)textAlignment;
- (void) setMessageText:(NSString*)str;
- (void) setImage:(UIImage*)image;

@end

@interface TKAlertCenter : NSObject {

	NSMutableArray *alerts;
	BOOL active;
	TKAlertView *alertView;
	CGRect alertFrame;
	
	BOOL iSequenced;//默认  NO 清除覆盖队列, YES 添加到队列最后
	UIWindow* iWindow;
	NSTextAlignment textAlignment;
    
    UIColor* bgColor_;//
    UIColor* textColor_;
    float bgRadius_;//
    
    float duration_;
    
    TKAlertCenterVAlignment vAlignment_;
}

@property (nonatomic,retain) UIColor* bgColor;
@property (nonatomic,retain) UIColor* textColor;
@property (nonatomic,assign) float bgRadius;
@property (nonatomic) TKAlertCenterVAlignment vAlignment;


+ (TKAlertCenter*) defaultCenter;
+ (TKAlertCenter*) alertCenterWithBgColor:(UIColor*)color;
+ (TKAlertCenter*) alertCenterWithBgColor:(UIColor*)color textColor:(UIColor*)textColor;

//把弹出层添加到了keywindow当中了
- (void) postAlertWithMessage:(NSString*)message image:(UIImage*)image;
- (void) postAlertWithMessage:(NSString*)message;
- (void) postAlertWithMessage:(NSString*)message duration:(float)duration;
- (void) postAlertWithMessage:(NSString*)message textAlignment:(NSTextAlignment)textAlignment;
- (void) postAlertWithMessage:(NSString *)message sequenced:(BOOL)aSequenced;
@end





