//
//  HealthShareContentView.h
//  healthcoming
//
//  Created by Young on 16/6/14.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "XYMRequestContentView.h"

@interface XYMHealthShareContentView : XYMRequestContentView
@property (nonatomic,retain) NSString* curTitle;
@property (nonatomic,retain) NSString* curUrl;
@property (nonatomic,retain,readonly) UIImageView* logoImage;
@property (nonatomic,retain,readonly) UILabel* titleLabel;
@property (nonatomic,retain,readonly) UILabel* statuslabel;

-(void)fillWithTitle:(NSString*)title url:(NSString*)url content:(NSString *)content;
@end
