//
//  UIButton+Custom.m
//  TianyaQing
//
//  Created by gzty1 on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIButton+Custom.h"


@implementation UIButton (Custom)

+(UIButton*)buttonWithOrigin:(CGPoint)origin
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage
{
	return [UIButton buttonWithOrigin:origin
						 normalImage:aImage
				   hightlightedImage:aHightlightedImage
					   selectedImage:aSelectedImage
						asBackground:NO];
}

+(UIButton*)buttonWithOrigin:(CGPoint)origin
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage
				asBackground:(BOOL)aAsBackground
{
	int width=aImage.size.width;
	int height=aImage.size.height;
	CGRect frame=CGRectMake(origin.x,origin.y,width,height);
	
	return [UIButton buttonWithFrame:frame
						 normalImage:aImage
				   hightlightedImage:aHightlightedImage
					   selectedImage:aSelectedImage
						asBackground:aAsBackground];
}

+(UIButton*)buttonWithPosX:(int)posX
				parentHeight:(int)parentHeight
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage
{
	int width=aImage.size.width;
	int height=aImage.size.height;
	int y=(parentHeight-aImage.size.height)/2;
	CGRect frame=CGRectMake(posX,y,width,height);
	
	return [UIButton buttonWithFrame:frame
						 normalImage:aImage
				   hightlightedImage:aHightlightedImage
					   selectedImage:aSelectedImage];
}

+(UIButton*)buttonWithPosY:(int)posY
               parentWidth:(int)parentWidth
			   normalImage:(UIImage*)aImage
		 hightlightedImage:(UIImage*)aHightlightedImage
			 selectedImage:(UIImage*)aSelectedImage
{
    int width=aImage.size.width;
	int height=aImage.size.height;
	int x=(parentWidth-aImage.size.width)/2;
	CGRect frame=CGRectMake(x,posY,width,height);
	
	return [UIButton buttonWithFrame:frame
						 normalImage:aImage
				   hightlightedImage:aHightlightedImage
					   selectedImage:aSelectedImage];
}

+(UIButton*)buttonWithFrame:(CGRect)aFrame
				normalImage:(UIImage*)aImage
		  hightlightedImage:(UIImage*)aHightlightedImage
			  selectedImage:(UIImage*)aSelectedImage
{
	return [UIButton buttonWithFrame:aFrame
						 normalImage:aImage
				   hightlightedImage:aHightlightedImage
					   selectedImage:aSelectedImage
						asBackground:NO];
}

+(UIButton*)buttonWithFrame:(CGRect)aFrame
				normalImage:(UIImage*)aImage
		  hightlightedImage:(UIImage*)aHightlightedImage
			  selectedImage:(UIImage*)aSelectedImage
			   asBackground:(BOOL)aAsBackground
{
	UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:aFrame];
	if(aAsBackground)
	{
		[button setBackgroundImage:aImage forState:UIControlStateNormal];
		[button setBackgroundImage:aHightlightedImage forState:UIControlStateHighlighted];	
		[button setBackgroundImage:aSelectedImage forState:UIControlStateSelected];	
	}
	else
	{
		[button setImage:aImage forState:UIControlStateNormal];
		[button setImage:aHightlightedImage forState:UIControlStateHighlighted];	
		[button setImage:aSelectedImage forState:UIControlStateSelected];
	}
	
	return button;
}	

+(UIButton*)buttonWithOrigin:(CGPoint)origin
					   width:(int)aWidth
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage
{
	return [UIButton buttonWithOrigin:origin
								width:aWidth
						  parentWidth:0 
								title:aTitle
							titleFont:aFont
						   titleColor:aColor
						  normalImage:aImage
					hightlightedImage:aHightlightedImage
						selectedImage:aSelectedImage];
}

+(UIButton*)buttonWithOrigin:(CGPoint)origin
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage						  
{
	return [UIButton buttonWithOrigin:origin
						  parentWidth:0 
								title:aTitle
							titleFont:aFont
						   titleColor:aColor
						  normalImage:aImage
					hightlightedImage:aHightlightedImage
						selectedImage:aSelectedImage];
}

+(UIButton*)buttonWithOrigin:(CGPoint)origin
				 parentWidth:(int)aParentWidth 
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage						  
{
	return [UIButton buttonWithOrigin:origin
								width:0
						  parentWidth:aParentWidth 
								title:aTitle
							titleFont:aFont
						   titleColor:aColor
						  normalImage:aImage
					hightlightedImage:aHightlightedImage
						selectedImage:aSelectedImage];
}

+(UIButton*)buttonWithOrigin:(CGPoint)origin
					   width:(int)aWidth
				 parentWidth:(int)aParentWidth 
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage						  
{
	UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
	
	[button setBackgroundImage:aImage forState:UIControlStateNormal];
	[button setBackgroundImage:aHightlightedImage forState:UIControlStateHighlighted];	
	[button setBackgroundImage:aSelectedImage forState:UIControlStateSelected];
	
    if(aTitle)
    {
        [button setTitle:aTitle forState:UIControlStateNormal];
    }
	if(aFont)
	{
		button.titleLabel.font=aFont;
	}
	if(aColor)
	{
		[button setTitleColor:aColor forState:UIControlStateNormal];
	}
	
	int height=aImage.size.height;
	if(aWidth<=0)
	{
		aWidth=aImage.size.width;
	}
	
	int x=origin.x;
	if(aParentWidth>0)
	{
		x+=(aParentWidth-aWidth)/2;
	}
	CGRect frame=CGRectMake(x,origin.y,aWidth,height);
	[button setFrame:frame];
	
	return button;
}

+(UIButton*)buttonWithOrigin:(CGPoint)origin
				 parentHeight:(int)aParentHeight
					   title:(NSString*)aTitle
				   titleFont:(UIFont*)aFont
				  titleColor:(UIColor*)aColor
				 normalImage:(UIImage*)aImage
		   hightlightedImage:(UIImage*)aHightlightedImage
			   selectedImage:(UIImage*)aSelectedImage						  
{
	UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
	
	[button setBackgroundImage:aImage forState:UIControlStateNormal];
	[button setBackgroundImage:aHightlightedImage forState:UIControlStateHighlighted];	
	[button setBackgroundImage:aSelectedImage forState:UIControlStateSelected];
	
	[button setTitle:aTitle forState:UIControlStateNormal];
	if(aFont)
	{
		button.titleLabel.font=aFont;
	}
	if(aColor)
	{
		[button setTitleColor:aColor forState:UIControlStateNormal];
	}
	
	int height=aImage.size.height;
	int width=aImage.size.width;
    
    if(width==0 && height==0)
    {
        CGSize size=[aTitle boundingRectWithSize:CGSizeMake(320, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:aFont} context:nil].size;
        width=size.width;
        height=size.height;
    }
	
	int x=origin.x;
	int y=origin.y;
	if(aParentHeight>0)
	{
        if(height>0)
        {
            y=(aParentHeight-height)/2+y;
        }
	}
	CGRect frame=CGRectMake(x,y,width,height);
	[button setFrame:frame];
	
	return button;
}

+(UIButton*)buttonWithOriginY:(int)originY
                  rightMargin:(int)margin
                      parentWidth:(int)parentWidth
                            title:(NSString*)aTitle
                        titleFont:(UIFont*)aFont
                       titleColor:(UIColor*)aColor
                      normalImage:(UIImage*)aImage
                hightlightedImage:(UIImage*)aHightlightedImage
                    selectedImage:(UIImage*)aSelectedImage
{
    CGPoint origin=CGPointMake(parentWidth-aImage.size.width-margin, originY);
    
    return [UIButton buttonWithOrigin:origin
                        title:aTitle
                        titleFont:aFont
                        titleColor:aColor
                        normalImage:aImage
                        hightlightedImage:aHightlightedImage
                         selectedImage:aSelectedImage];
}

- (void)centerImageAndTitle:(float)rightSpace wihtCenterSpace:(float)centerSpace
{
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + rightSpace);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width - self.frame.size.width/4 - centerSpace, - (totalHeight - titleSize.height),0.0);
}

-(void)centerImageAndTitleCreatedByHyWithSpace:(CGFloat)spacing {
    // the space between the image and text
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = self.imageView.image.size;
    self.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    self.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
//    // increase the content height to avoid clipping
//    CGFloat edgeOffset = fabsf(titleSize.height - imageSize.height) / 2.0;
//    self.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0);
}

- (void)centerImageAndTitle:(float)rightSpace
{
    [self centerImageAndTitle:rightSpace wihtCenterSpace:0];
} 

- (void)centerImageAndTitle  
{  
    const int DEFAULT_SPACING = 2.0f;
    [self centerImageAndTitle:DEFAULT_SPACING];
}  

-(void)expandWidthAsTitleWithPaddingH:(int)paddingH
{
    CGSize size=[self.titleLabel.text boundingRectWithSize:CGSizeMake(320, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    
	int titleWidth=size.width+paddingH*2;
	if (self.frame.size.width<titleWidth) 
	{
		CGRect frame=self.frame;
		frame.size.width=titleWidth;
		self.frame=frame;
	}
}

-(void)setTitleShadowColor:(UIColor*)color shadowOffset:(CGSize)offset
{
    self.titleLabel.shadowColor = color;
    self.titleLabel.shadowOffset = offset;
    [self setTitleShadowColor:color forState:UIControlStateNormal];
}

@end
