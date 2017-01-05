//
//  NewsContentView.m
//  healthcoming
//
//  Created by Franky on 15/10/15.
//  Copyright © 2015年 Franky. All rights reserved.
//

#import "XYMNewsContentView.h"

@implementation XYMNewsContentView
{
    UILabel* descLabel;
}

@synthesize curTitle,curUrl,logoImage,titleLabel,statuslabel;

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-15, 20)];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 2;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 40, 117, 83)];
//        logoImage.image = [UIImage imageNamed:@"follow_cover.png"];
        logoImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:logoImage];
        
        statuslabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 70, frame.size.height - 30, 60, 25) text:@"点击查看" font:[UIFont systemFontOfSize:14.0] textColor:NormalGray shadowColor:nil shadowOffset:CGSizeZero textAlignment:NSTextAlignmentRight];
        [self addSubview:statuslabel];
    }
    return self;
}

-(void)fillWithTitle:(NSString*)title url:(NSString*)url
{
    curTitle = title;
    curUrl = url;
    
    titleLabel.text = curTitle;
}

-(void)cancelAndClean
{
    [self cleanData];
}

-(void)cleanData
{
    curTitle = nil;
    curUrl = nil;
    logoImage.image = nil;
}

@end
