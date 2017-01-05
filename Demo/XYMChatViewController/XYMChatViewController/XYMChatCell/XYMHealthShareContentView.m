//
//  HealthShareContentView.m
//  healthcoming
//
//  Created by Young on 16/6/14.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "XYMHealthShareContentView.h"

@implementation XYMHealthShareContentView
{
    UILabel* descLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
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
        
        logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 40, 80, 80)];
        //        logoImage.image = [UIImage imageNamed:@"follow_cover.png"];
        logoImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:logoImage];
        
        //CGRectGetHeight(logoImage.frame)
        statuslabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(logoImage.frame)+10, CGRectGetMaxY(titleLabel.frame)+10,frame.size.width-10-10-10-CGRectGetWidth(logoImage.frame),80) text:@"立即查看" font:[UIFont systemFontOfSize:14.0] textColor:NormalGray shadowColor:nil shadowOffset:CGSizeZero textAlignment:NSTextAlignmentLeft];
        statuslabel.numberOfLines = 0;
        [self addSubview:statuslabel];
    }
    return self;
}

-(void)fillWithTitle:(NSString*)title url:(NSString*)url content:(NSString *)content
{
    curTitle = title;
    curUrl = url;
    titleLabel.text = curTitle;
    statuslabel.text = content;
    [statuslabel resizeHeightWithAllowReduce:YES replaceFrameHeihgt:CGRectGetHeight(logoImage.frame)];
    
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
