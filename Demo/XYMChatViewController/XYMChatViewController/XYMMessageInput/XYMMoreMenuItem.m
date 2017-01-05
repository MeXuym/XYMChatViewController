//
//  MoreMenuItem.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMMoreMenuItem.h"

@implementation XYMMoreMenuItem

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title{
    if (self) {
        self.normalIconImage = normalIconImage;
        self.title = title;
    }
    return self;
}

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage highlightIconImage:(UIImage *)highlightIconImage title:(NSString *)title
{
    if (self) {
        self.normalIconImage = normalIconImage;
        self.highlightIconImage = highlightIconImage;
        self.title = title;
    }
    return self;
}

- (void)dealloc{
    self.normalIconImage = nil;
    self.title = nil;
}

@end
