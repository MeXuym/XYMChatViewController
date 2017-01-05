//
//  MoreMenuItem.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-17.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYMMoreMenuItem : NSObject

@property (nonatomic, strong) UIImage *normalIconImage;
@property (nonatomic, strong) UIImage *highlightIconImage;
@property (nonatomic, copy) NSString *title;

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title;

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                     highlightIconImage:(UIImage*)highlightIconImage
                                  title:(NSString *)title;

@end
