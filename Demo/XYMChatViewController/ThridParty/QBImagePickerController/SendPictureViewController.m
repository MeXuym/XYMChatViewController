//
//  SendPictureViewController.m
//  healthcoming
//
//  Created by jack xu on 16/8/2.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import "SendPictureViewController.h"
#import "MJPhotoBrowser.h"

@interface SendPictureViewController ()

@end

@implementation SendPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton setTitle:@"发送" forState:normal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize: 16];
    [sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    sendButton.frame = CGRectMake(0, 0, 60, 30);
    UIBarButtonItem *sendButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = sendButtonItem;
    
}

-(void)sendAction{
    //调用代理方法
    [_delegate sendPhoto:self.assetCollectionViewController info:self.info];
    NSLog(@"点了发送");
}

-(void)setPhoto:(UIImage *)photo{

    CGSize size = photo.size;
    
    if(size.height > size.width){
    
        UIImageView *photoView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - ScreenHeight*(size.width/size.height))*0.5, 0, ScreenHeight*(size.width/size.height), ScreenHeight)];
        photoView.image = photo;
        [self.view addSubview:photoView];
        
    }else if (size.width > size.height){
    
        UIImageView *photoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (ScreenHeight - ScreenWidth*(size.height/size.width))*0.5, ScreenWidth, ScreenWidth*(size.height/size.width))];
        photoView.image = photo;
        [self.view addSubview:photoView];
        
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma mark ----------QBImagePickerControllerDelegate 的代理方法-------------

//- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
//{
//    if([imagePickerController.class isSubclassOfClass:UIImagePickerController.class])
//    {
//        UIImage *chosedImage=[info objectForKey:UIImagePickerControllerEditedImage];
//        [self sendImage:chosedImage isScale:YES];
//    }
//    else if ([imagePickerController.class isSubclassOfClass:QBImagePickerController.class])
//    {
//        if(imagePickerController.allowsMultipleSelection) {
//            //NSArray *mediaInfoArray = (NSArray *)info;
//            //[self dismissViewControllerAnimated:YES completion:^{}];
//        } else {
//            UIImage *chosedImage=[info objectForKey:UIImagePickerControllerOriginalImage];
//            [self sendImage:chosedImage isScale:NO];
//        }
//    }
//    [self dismissViewControllerAnimated:YES completion:^{
//        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
