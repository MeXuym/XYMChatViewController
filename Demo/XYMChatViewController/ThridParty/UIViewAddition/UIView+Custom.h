//
//  UIView+Custom.h
//  TianyaQing
//
//  Created by gzty1 on 12-3-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+HTML.h"
#import "UIImageView+Custom.h"
#import "UILabel+Custom.h"
#import "UITextField+Custom.h"
#import "UIButton+Custom.h"
#import "UIImage+Custom.h"
#import "UIWebView+Clean.h"

@interface UIView (Custom)
-(CGRect)setFrameOffsetX:(CGFloat)dx y:(CGFloat)dy;
-(CGRect)setFrameSizeInsetWidth:(CGFloat)dx height:(CGFloat)dy;

-(BOOL)getOriginInSuperView:(UIView*)theSuperView resultOrigin:(CGPoint*)resultOrigin;
-(void)setBoundsPathShadowColor:(UIColor*)color radius:(float)radius;
-(void)setBoundsPathShadow;//默认的四周阴影渐变处理
-(void)clearBoundsPathShadow;
-(UIImage*)imageInRect:(CGRect)rect;//给UIView照相
- (NSMutableArray*) allSubViews;//取得所有的子view
- (CGFloat)left;
- (CGFloat)top;
- (CGFloat)right;
- (CGFloat)bottom;
- (CGFloat)width;
- (CGFloat)height;
- (void)removeAllSubviews;

@end