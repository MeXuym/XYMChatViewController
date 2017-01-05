//
//  MessageContentButton.h
//  healthcoming
//
//  Created by Franky on 15/8/14.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYMMessageContentButton : UIButton

@property (nonatomic, retain) UIImageView *backImageView;
@property (nonatomic, assign) BOOL isSelf;

-(void)updateSize:(CGSize)size;
-(void)clean;

@end
