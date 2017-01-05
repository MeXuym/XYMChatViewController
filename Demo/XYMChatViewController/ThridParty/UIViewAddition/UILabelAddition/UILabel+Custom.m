//
//  UILabel+Custom.m
//  TianyaQing
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UILabel+Custom.h"


@implementation UILabel (Custom)

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
		   textAlignment:(NSTextAlignment)aTextAlignment
{
	return [self initWithFrame:aFrame
						  text:aText
						  font:aFont
					 textColor:aTextColor
				   shadowColor:nil
				  shadowOffset:CGSizeMake(0, 0)
				 textAlignment:aTextAlignment];
}

-(UILabel*)initWithFrame:(CGRect)aFrame
					text:(NSString*)aText
					font:(UIFont*)aFont
			   textColor:(UIColor*)aTextColor
			 shadowColor:(UIColor*)shadowColor
			shadowOffset:(CGSize)shadowOffset
		   textAlignment:(NSTextAlignment)aTextAlignment
{
	if(self=[self initWithFrame:aFrame])//不能用 [super initWithFrame:aFrame]，会导致颜色失效。
	{
		if(aTextColor)
		{
			self.textColor=aTextColor;
		}
		if(aFont)
		{
			self.font=aFont; 
		}
		self.textAlignment=aTextAlignment;//UITextAlignmentCenter;
		self.backgroundColor=[UIColor clearColor];
		self.text=aText;
		self.numberOfLines=0;
		if(shadowColor)
		{
			self.shadowColor = shadowColor;
			self.shadowOffset = shadowOffset;
		}
	}
	return self;
}

-(void)resizeHeightWithAllowReduce:(BOOL)aAllowRecuce
{
	[self setNumberOfLines:0];//设置行0
    
    CGSize autoResize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;

    CGRect rect=self.frame;
    if(autoResize.height>rect.size.height || aAllowRecuce)
    {
        rect.size.height=autoResize.height;
        [self setFrame:rect];
    }
}

-(void)resizeHeightWithAllowReduce:(BOOL)aAllowRecuce  replaceFrameHeihgt:(CGFloat)customHeight
{
    [self setNumberOfLines:0];//设置行0
    
    CGSize autoResize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    
    CGRect rect=self.frame;
    if(autoResize.height>rect.size.height || aAllowRecuce)
    {
        if (autoResize.height >customHeight) {
            rect.size.height= MIN(customHeight, autoResize.height);
            [self setFrame:rect];
        }

    }
}


-(void)setShadowColor:(UIColor*)color shadowOffset:(CGSize)offset
{
    self.shadowColor = color;
    self.shadowOffset = offset;
}

-(void)setTagUnSelectedStyle:(BOOL)limit
{
    [self setTagUnSelectedStyle:UIColorFromRGB(0xdadada).CGColor limit:limit];
}

-(void)setTagUnSelectedStyle:(CGColorRef)CGColor limit:(BOOL)limit
{
    self.font = [UIFont systemFontOfSize:15.0];
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    if(size.width > 80 && limit)
    {
        size.width = 80;
    }
    size.width += 10;
    size.height += 8;
    CGRect rect = self.frame;
    rect.size.width = size.width;
    rect.size.height = size.height;
    self.frame = rect;
    self.layer.cornerRadius = 4.0;
    self.layer.backgroundColor = CGColor;
    self.layer.borderWidth = 0;
    //    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor blackColor];
}

-(void)setTagUnSelectedStyle
{
    [self setTagUnSelectedStyle:UIColorFromRGB(0xdadada).CGColor limit:YES];
}

-(void)setFilterSelectedStyle
{
    self.font = [UIFont systemFontOfSize:16.0];
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    if(size.width < 60)
    {
        size.width = 60;
    }
    else
    {
        size.width = 80;
    }
    CGRect rect = self.frame;
    rect.size.width = size.width;
    rect.size.height = 30;
    self.frame = rect;
    self.layer.cornerRadius = 4.0;
    self.layer.backgroundColor = UIColorFromRGB(0x93c82b).CGColor;
    self.layer.borderWidth = 0;
    self.layer.borderColor = UIColorFromRGB(0x93c82b).CGColor;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
}

-(void)setFilterUnSelectedStyle
{
    self.font = [UIFont systemFontOfSize:16.0];
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    if(size.width < 60)
    {
        size.width = 60;
    }
    else
    {
        size.width = 80;
    }
    CGRect rect = self.frame;
    rect.size.width = size.width;
    rect.size.height = 30;
    self.frame = rect;
    self.layer.cornerRadius = 4.0;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 0.1;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor blackColor];
}

-(void)setTagSelectedStyle:(CGColorRef)CGColor font:(UIFont*)font limit:(BOOL)limit
{
    self.font = font;
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    if(size.width > 80 && limit)
    {
        size.width = 80;
    }
    size.width += 10;
    size.height += 8;
    CGRect rect = self.frame;
    rect.size.width = size.width;
    rect.size.height = size.height;
    self.frame = rect;
    self.layer.cornerRadius = 4.0;
    self.layer.backgroundColor = CGColor;
    self.layer.borderWidth = 0;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
}

-(void)setTagSelectedStyle:(CGColorRef)CGColor limit:(BOOL)limit
{
    [self setTagSelectedStyle:CGColor font:[UIFont systemFontOfSize:15.0] limit:limit];
}

-(void)setTagSelectedStyle:(CGColorRef)CGColor font:(UIFont*)font
{
    [self setTagSelectedStyle:CGColor font:font limit:YES];
}

-(void)setTagSelectedStyle:(CGColorRef)CGColor
{
    [self setTagSelectedStyle:CGColor limit:YES];
}

//-(void)setTag1Style:(UIColor *)Color
//{
//    self.font = [UIFont systemFontOfSize:15.0];
//    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
//    if(size.width > 80)
//    {
//        size.width = 80;
//    }
//    size.width += 10;
//    size.height += 8;
//    CGRect rect = self.frame;
//    rect.size.width = size.width;
//    rect.size.height = size.height;
//    self.frame = rect;
//    self.layer.cornerRadius = 4.0;
//    self.layer.borderWidth = 0.5;
//    self.layer.borderColor = Color.CGColor;
//    self.textAlignment = NSTextAlignmentCenter;
//    self.textColor = Color;
//}

-(void)setTag1Style:(UIColor *)Color
{
    self.font = [UIFont systemFontOfSize:14.0];
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    if(size.width > 80)
    {
        size.width = 80;
    }
    size.width += 5;
    size.height += 3;
    CGRect rect = self.frame;
    rect.size.width = size.width;
    rect.size.height = size.height;
    self.frame = rect;
    self.layer.cornerRadius = 3.0;
    self.layer.borderWidth = 1;
    self.layer.borderColor = Color.CGColor;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = Color;
}

-(void)adjustTagStyleWidth
{
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    size.width += 10;
    size.height += 8;
    CGRect rect = self.frame;
    rect.size.width = size.width;
    rect.size.height = size.height;
    self.frame = rect;
}

@end
