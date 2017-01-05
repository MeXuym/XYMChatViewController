//
//  IndicatorView.m
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation IndicatorView

-(id)initWithIndicatorType:(IndicatorType)aIndicatorType
{
	iIndicatorType=aIndicatorType;
	
	CGRect frame=CGRectZero;//CGRectMake(0, 0, 120, 120);
	if(iIndicatorType==ActivityIndicator)
	{
		frame=CGRectMake(0, 0, 120, 120);
	}
	else
	{
		frame=CGRectMake(0, 0, 200, 120);
	}
	
    if (self=[super initWithFrame:frame])
	{
		self.layer.cornerRadius = 10.0;
		self.layer.masksToBounds = YES;
		self.opaque = NO;
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
		
		double widthUnit=round(frame.size.width/12);
		double heightUnit=round(frame.size.height/12);

		if(iIndicatorType==ActivityIndicator)
		{
			iActivityIndicatorView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			iActivityIndicatorView.frame=CGRectMake(3*widthUnit,2*heightUnit,6*widthUnit,6*heightUnit);
			[self addSubview:iActivityIndicatorView];
			[iActivityIndicatorView startAnimating];
		}
		else
		{
			iProgressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
			iProgressView.frame=CGRectMake(2*widthUnit,2*heightUnit,8*widthUnit,6*heightUnit);
			[self addSubview:iProgressView];
		}
		
		iLabel=[[UILabel alloc] initWithFrame:CGRectMake(1*widthUnit,9*heightUnit,10*widthUnit, 2*heightUnit)];
		[self addSubview:iLabel];
		iLabel.backgroundColor=[UIColor clearColor];
		iLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
		iLabel.textAlignment=NSTextAlignmentCenter;
		iLabel.textColor=[UIColor whiteColor];
		iLabel.adjustsFontSizeToFitWidth=YES;
	}
	
    return self;
}

-(void)dealloc{

}

-(void)setMessage:(NSString*)newMsg
{
	iLabel.text=newMsg;

    if([newMsg length]>0)
    {
        CGRect frame=self.frame;
        double widthUnit=round(frame.size.width/12);
		double heightUnit=round(frame.size.height/12);
        iActivityIndicatorView.frame=CGRectMake(3*widthUnit,2*heightUnit,6*widthUnit,6*heightUnit);
    }
    else
    {
       iActivityIndicatorView.center=CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

-(void)setProgress:(float)aProgress
{
	if(iProgressView)
	{
		iProgressView.progress=aProgress;
	}
}

@end
