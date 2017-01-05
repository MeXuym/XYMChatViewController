//
//  BaseViewController.h
//  EShoreJST
//
//  Created by Administrators on 15-5-4.
//  Copyright (c) 2015年 Administrators. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
@protected              //什么都不写，默认是这个属性
    BOOL isModalBack;
}

- (void)baseViewStyle;
- (void)setNavigationTitle:(NSString*)title;
- (void)setNavigationTitle:(NSString*)title textColor:(UIColor*)textColor fontSize:(Size)fontSize;
- (void)setNavigationBackButton;
- (void)setNavigationBackButtonWithImage:(UIImage*)image highlightImage:(UIImage *)highlightImage;
- (void)setNavigationBackButton:(CGRect)frame Image:(UIImage *)image highlightImage:(UIImage *)highlightImage;
- (void)onNavigationBackPressed;
- (void)setNavigationRightButton:(NSString*)title target:(id)target action:(SEL)action;
- (void)setNavigationLeftButton:(NSString*)title target:(id)target action:(SEL)action;

@end
