//
//  QNResourceManager.h
//  healthcoming
//
//  Created by Franky on 15/8/21.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

//static NSString* const Image_Folder = @"app/image/";
//static NSString* const Video_Folder = @"app/video/";
//static NSString* const Audio_Folder = @"app/audio/";
//static NSString* const Head_Folder = @"app/head/";

//8月七牛整改相关，加多一个平台类型
static NSString* const Image_Folder = @"app/ios/image/";
static NSString* const Video_Folder = @"app/ios/video/";
static NSString* const Audio_Folder = @"app/ios/audio/";
static NSString* const Head_Folder = @"app/ios/head/";

@interface QNResourceManager : NSObject

+ (instancetype)sharedManager;


-(void)uploadImage:(UIImage *)image
               key:(NSString*)key
        folderName:(NSString *)folderName
     completeBlock:(void (^)(BOOL, NSString *, CGFloat, CGFloat))completeBlock;

- (void)uploadImage:(UIImage *)image
                key:(NSString*)key
         folderName:(NSString *)folderName
      progressBlock:(void (^)(NSString *key, float progress))progressBlock
      completeBlock:(void (^)(BOOL success,  NSString *key, CGFloat width, CGFloat height))completeBlock;

//upload file with urlkey
- (void)uploadFileWithUrlkey:(NSString *)urlkey
                         key:(NSString*)key
                  folderName:(NSString *)folderName
               progressBlock:(void (^)(NSString *key, float progress))progressBlock
               completeBlock:(void (^)(BOOL success,  NSString *key))completeBlock;

// download file with url
- (void)downloadFileWithUrl:(NSString*)url
              progressBlock:(void (^)(CGFloat progress))progressBlock
              completeBlock:(void (^)(BOOL success, NSError *error))completeBlock;

// 上传多张图片,按队列依次上传
+ (void)uploadImages:(NSArray *)imageArray progress:(void (^)(CGFloat))progress success:(void (^)(NSArray *))success failure:(void (^)())failure;

+(NSString*)getNormalImageKey;

+(NSString *)generateTimeKeyWithPrefix:(NSString *)keyPrefix folderName:(NSString*)folderName isImage:(BOOL)isImage;

@end
