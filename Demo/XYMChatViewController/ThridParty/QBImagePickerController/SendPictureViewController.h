//
//  SendPictureViewController.h
//  healthcoming
//
//  Created by jack xu on 16/8/2.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBAssetCollectionViewController.h"

//发送照片
@protocol SendPictureViewControllerDelegate <NSObject>
- (void)sendPhoto:(QBAssetCollectionViewController *)assetCollectionViewController info:(id)info;
@end


@interface SendPictureViewController : UIViewController

@property (strong,nonatomic)UIImage *photo;
@property (strong,nonatomic)QBAssetCollectionViewController *assetCollectionViewController;
@property (strong,nonatomic)id info;

@property (nonatomic, assign) id<SendPictureViewControllerDelegate> delegate;

@end
