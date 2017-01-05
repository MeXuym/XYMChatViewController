//
//  MessageContentButton.m
//  healthcoming
//
//  Created by Franky on 15/8/14.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "XYMMessageContentButton.h"

@implementation XYMMessageContentButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //图片
        self.backImageView = [[UIImageView alloc]init];
        self.backImageView.userInteractionEnabled = YES;
        self.backImageView.layer.cornerRadius = 5;
        self.backImageView.layer.masksToBounds  = YES;
        self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.backImageView];
    }
    return self;
}

-(void)setIsSelf:(BOOL)isSelf
{
    _isSelf = isSelf;
    if (isSelf) {
        self.backImageView.frame = CGRectMake(5, 5, 220, 220);
    }else{
        self.backImageView.frame = CGRectMake(15, 5, 220, 220);
    }
}

-(void)clean
{
    self.backImageView.hidden = YES;
    [self setBackgroundImage:nil forState:UIControlStateNormal];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    return (action == @selector(copy:));
//}
//
//-(void)copy:(id)sender
//{
//    
//}

@end
