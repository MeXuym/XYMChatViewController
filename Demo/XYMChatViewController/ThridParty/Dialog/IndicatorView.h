//
//  IndicatorView.h
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	ActivityIndicator,
	ProgressIndicator
} IndicatorType;

@interface IndicatorView : UIView 
{
	UIActivityIndicatorView* iActivityIndicatorView;
	UIProgressView* iProgressView;
	UILabel* iLabel;
	
	IndicatorType iIndicatorType;
}

-(id)initWithIndicatorType:(IndicatorType)aIndicatorType;
-(void)setMessage:(NSString*)newMsg;
-(void)setProgress:(float)aProgress;

@end
