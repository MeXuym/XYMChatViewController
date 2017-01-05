//
//  UILabel+Custom.h
//  TianyaQing
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UILabel (Custom)

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
		   textAlignment:(NSTextAlignment)aTextAlignment;

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
			 shadowColor:(UIColor*)shadowColor
			shadowOffset:(CGSize)shadowOffset
		   textAlignment:(NSTextAlignment)aTextAlignment;
-(void)resizeHeightWithAllowReduce:(BOOL)aAllowRecuce;//根据文字，自适应高度。
-(void)resizeHeightWithAllowReduce:(BOOL)aAllowRecuce  replaceFrameHeihgt:(CGFloat)customHeight; //根据文字，自适应高度,不替换原有frame;
-(void)setShadowColor:(UIColor*)color shadowOffset:(CGSize)offset;
-(void)setFilterSelectedStyle;
-(void)setFilterUnSelectedStyle;

-(void)setTagUnSelectedStyle;
-(void)setTagUnSelectedStyle:(BOOL)limit;
-(void)setTagUnSelectedStyle:(CGColorRef)CGColor limit:(BOOL)limit;
-(void)setTagSelectedStyle:(CGColorRef)CGColor;
-(void)setTag1Style:(UIColor *)Color;
-(void)setTagSelectedStyle:(CGColorRef)CGColor font:(UIFont*)font;
-(void)setTagSelectedStyle:(CGColorRef)CGColor font:(UIFont*)font limit:(BOOL)limit;
-(void)setTagSelectedStyle:(CGColorRef)CGColor limit:(BOOL)limit;
-(void)adjustTagStyleWidth;

@end
