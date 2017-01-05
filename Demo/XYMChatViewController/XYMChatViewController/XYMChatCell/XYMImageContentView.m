//
//  ImageContentView.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-15.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMImageContentView.h"
#import "UIImageView+WebCache.h"
#import "QNResourceManager.h"

@interface XYMImageContentView()
{
    NSString* fixKey;
    NSString* localUrl_;
    NSString* imageUrl_;
    UIImageView* imageView_;
    UIView* grayView_;
    UILabel* perLabel_;
    
    BOOL isUpload;
}
@end

@implementation XYMImageContentView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView_=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imageView_.contentMode=UIViewContentModeScaleAspectFill;
        imageView_.clipsToBounds=YES;
        imageView_.userInteractionEnabled = NO;
        imageView_.tag = 6666;
        [self addSubview:imageView_];
        
        grayView_=[[UIView alloc] initWithFrame:imageView_.frame];
        grayView_.backgroundColor=[UIColor grayColor];
        grayView_.alpha=0.5;
        grayView_.hidden=YES;
        grayView_.userInteractionEnabled = NO;
        [self addSubview:grayView_];
        
        perLabel_=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(imageView_.frame)-20,CGRectGetMidY(imageView_.frame)-10, 50, 20)];
        perLabel_.font=[UIFont systemFontOfSize:15];
        perLabel_.textColor=[UIColor blackColor];
        perLabel_.hidden=YES;
        [self addSubview:perLabel_];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame imageDic:(NSDictionary*)dic isUpLoad:(BOOL)flag
{
    self = [self initWithFrame:frame];
    if (self) {
        isUpload = flag;
        fixKey = [dic objectForKey:DSelfUpLoadImg];
        if(fixKey)
        {
            localUrl_ = QN_URL_FOR_KEY(fixKey);
        }
        if(isUpload && localUrl_)
        {
            imageView_.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:localUrl_];
        }
        if(!imageUrl_)
        {
            imageUrl_ = [dic objectForKey:DSamllPic];
        }
    }
    return self;
}

-(void)startRequestWithCompleted:(void (^)(XYMRequestContentView*, NSString*))block
{
    if(isUpload)
    {
        if(imageView_.image && localUrl_ && localUrl_.length>0)
        {
            grayView_.hidden = NO;
            perLabel_.hidden = NO;
//            __block float sum = 0;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage* image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:localUrl_];
                [[QNResourceManager sharedManager] uploadImage:image
                                                           key:fixKey
                                                    folderName:Image_Folder
                                                 progressBlock:^(NSString *key, float progress) {
                                                     NSLog(@"%f",progress);
//                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         perLabel_.text = [NSString stringWithFormat:@"%0.f%%",progress];
//                                                     });
                                                 } completeBlock:^(BOOL success, NSString *key, CGFloat width, CGFloat height) {
//                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         if(block)
                                                         {
                                                             block(self, key);
                                                         }
                                                         grayView_.hidden=YES;
                                                         perLabel_.hidden=YES;
//                                                     });
                                                 }];
            });
            
        }
    }
    else
    {
        if(localUrl_)
        {
            imageView_.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:localUrl_];
        }
        if(!imageView_.image && imageUrl_)
        {
            [imageView_ sd_setImageWithURL:[NSURL URLWithString:imageUrl_] placeholderImage:[UIImage imageNamed:@"img_load_100.png"]];
        }
    }
}

-(NSInteger)getCurrentImageTag
{
    return imageView_.tag;
}

-(void)dealloc
{
    [self cancelAndClean];
}

@end
