//
//  IMQNFileLoadUtil.m
//  JLWeChat
//
//  Created by jimneylee on 14-10-25.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "QNResourceManager.h"
#import "AFNHttpRequest.h"
#import "QiniuSDK.h"
#import "QNAuthPolicy.h"
#import "FileUtil.h"

@implementation QNResourceManager

+ (instancetype)sharedManager
{
    static QNResourceManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc ] init];
    });
    
    return _sharedManager;
}

#pragma mark Upload Image

-(void)uploadImage:(UIImage *)image
               key:(NSString*)key
        folderName:(NSString *)folderName
     completeBlock:(void (^)(BOOL, NSString *, CGFloat, CGFloat))completeBlock
{
    [self uploadImage:image key:key folderName:folderName progressBlock:nil completeBlock:completeBlock];
}

- (void)uploadImage:(UIImage *)image
                key:(NSString*)key
         folderName:(NSString *)folderName
      progressBlock:(void (^)(NSString *key, float progress))progressBlock
      completeBlock:(void (^)(BOOL success,  NSString *key, CGFloat width, CGFloat height))completeBlock
{
    
    if(!key)
    {
        key = [QNResourceManager generateTimeKeyWithPrefix:@"upload" folderName:folderName isImage:YES];
    }
    void (^block)(NSString* token)=^(NSString* token)
    {
        // scale image with mode UIViewContentModeScaleAspectFit
        UIImage* newImage = image;
//        CGFloat kMaxLength = 1500.f;
//        if (image.size.width > kMaxLength || image.size.height > kMaxLength) {
//            CGRect rect = [image convertRect:CGRectMake(0.f, 0.f, kMaxLength, kMaxLength)
//                             withContentMode:UIViewContentModeScaleAspectFit];
//            newImage = [image transformWidth:rect.size.width height:rect.size.height rotate:YES];
//        }
        
//        NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0);
//        NSLog(@"压缩前：%lu",imageData.length/1024);
        
        NSData *imageData = UIImageJPEGRepresentation(newImage, 0.5);
        NSLog(@"压缩后：%lu",imageData.length/1024);
//        NSData *imageData = UIImagePNGRepresentation(newImage);
        QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"image/jpeg" progressHandler:progressBlock
                                                            params:nil checkCrc:YES cancellationSignal:nil];
        QNUploadManager *upManager = [QNUploadManager sharedInstanceWithConfiguration:nil];

        [upManager putData:imageData key:key
                     token:token complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                         if (info.statusCode == 200) {
                             completeBlock(YES, key, newImage.size.width, newImage.size.height);
                         }
                         else {
                             completeBlock(NO, nil, 0.f, 0.f);
                         }
                     } option:opt];
    };
    
    NSString *token = [QNAuthPolicy defaultToken];
    if(token)
    {
        block(token);
    }
    else
    {
        [AFNHttpRequest uptokenRequest:1 completed:^(NSDictionary *response, BOOL isSuccess, int errorCode, NSString* errorMsg) {
            NSString* tokenStr = [response objectWithKey:@"uptoken"];
            int validDate = [response intWithKey:@"validDate"];
            [QNAuthPolicy setDefaultToken:tokenStr validDate:validDate];
            block(tokenStr);
        }];
    }
}



#pragma mark - Upload & Download File (Audio & Video)

- (void)uploadFileWithUrlkey:(NSString *)urlkey
                         key:(NSString*)key
                  folderName:(NSString *)folderName
               progressBlock:(void (^)(NSString *key, float progress))progressBlock
               completeBlock:(void (^)(BOOL success,  NSString *key))completeBlock
{
    if(!key)
    {
        key = [QNResourceManager generateTimeKeyWithPrefix:@"upload" folderName:folderName isImage:NO];
    }
    void (^block)(NSString* token)=^(NSString* token)
    {
        QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:progressBlock//获取上传进度
                                                            params:nil checkCrc:YES cancellationSignal:nil];
        
        QNUploadManager *upManager = [QNUploadManager sharedInstanceWithConfiguration:nil];
        NSString* tmpFile = [FileUtil tempPathWithFileName:urlkey];
        NSData *data = [NSData dataWithContentsOfFile:tmpFile];
        [upManager putData:data key:key
                     token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                         if (info.statusCode == 200) {
                             completeBlock(YES, key);
                         }
                         else {
                             completeBlock(NO, nil);
                         }
                     } option:opt];
    };
    
    NSString *token = [QNAuthPolicy defaultToken];
    if(token)
    {
        block(token);
    }
    else
    {
        [AFNHttpRequest uptokenRequest:1 completed:^(NSDictionary *response, BOOL isSuccess, int errorCode, NSString* errorMsg) {
            NSString* tokenStr = [response objectWithKey:@"uptoken"];
            int validDate = [response intWithKey:@"validDate"];
            [QNAuthPolicy setDefaultToken:tokenStr validDate:validDate];
            block(tokenStr);
        }];
    }
}

- (void)downloadFileWithUrl:(NSString*)url
              progressBlock:(void (^)(CGFloat progress))progressBlock
              completeBlock:(void (^)(BOOL success, NSError *error))completeBlock
{
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSString* filePath = [FileUtil tempPathWithFileName:url.lastPathComponent];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        progressBlock((float)totalBytesRead / totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completeBlock(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completeBlock(NO, error);
    }];
    
    [operation start];
}


#pragma mark -  Generate Key

+(NSString *)getNormalImageKey
{
    return [QNResourceManager generateTimeKeyWithPrefix:@"upload" folderName:Image_Folder isImage:YES];
}

+(NSString *)generateTimeKeyWithPrefix:(NSString *)keyPrefix folderName:(NSString*)folderName isImage:(BOOL)isImage
{
    NSString *timeString = [QNResourceManager generateTimeKey];
    NSString* fileName = [NSString stringWithFormat:@"%@-%@", keyPrefix, timeString];
    //8月群发助手（文件名加上随机数不让文件重名）
    int x = arc4random() % 100;
    return [NSString stringWithFormat:@"%@%@xu%dxu.%@",folderName, fileName.md5, x,isImage?@"jpg":@"amr"];
}

//上传时间
+ (NSString *)generateTimeKey
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [f setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *timeString = [f stringFromDate:[NSDate date]];
    return timeString;
}

@end
