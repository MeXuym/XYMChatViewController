//
//  NewsContentView.h
//  healthcoming
//
//  Created by Franky on 15/10/15.
//  Copyright © 2015年 Franky. All rights reserved.
//

#import "XYMRequestContentView.h"

@interface XYMNewsContentView : XYMRequestContentView

@property (nonatomic,retain) NSString* curTitle;
@property (nonatomic,retain) NSString* curUrl;
@property (nonatomic,retain,readonly) UIImageView* logoImage;
@property (nonatomic,retain,readonly) UILabel* titleLabel;
@property (nonatomic,retain,readonly) UILabel* statuslabel;

-(void)fillWithTitle:(NSString*)title url:(NSString*)url;

@end
