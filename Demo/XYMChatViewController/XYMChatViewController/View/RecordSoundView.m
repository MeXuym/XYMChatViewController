//
//  RecordSoundView.m
//  healthcoming
//
//  Created by Franky on 15/8/19.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "RecordSoundView.h"

@interface RecordSoundView ()
{
    UIImageView* volumeImage;
    UIImageView* animationImage;
}

@property (nonatomic, strong, readonly) UIWindow *overlayWindow;

@end

@implementation RecordSoundView

@synthesize overlayWindow;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        volumeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"volume.png"]];
        volumeImage.frame = CGRectMake(0, 0, 160, 160);
        volumeImage.center = CGPointMake(ScreenWidth/2,ScreenHeight/2);
        [self addSubview:volumeImage];
        
        animationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wolume_animation1.png"]];
        animationImage.frame = CGRectMake(100, 30, 30, 82);
        [volumeImage addSubview:animationImage];
    }
    return self;
}

-(void)updateVolume:(int)volume
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* str = [NSString stringWithFormat:@"wolume_animation%d.png",volume];
        animationImage.image = [UIImage imageNamed:str];
    });
}

-(void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
    });
}

-(void)dimiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        overlayWindow = nil;
    });
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = NO;
        [overlayWindow makeKeyAndVisible];
    }
    return overlayWindow;
}

@end
