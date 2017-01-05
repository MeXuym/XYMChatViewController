//
//  FaceView.h
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYMIMEmotionEntity : NSObject

+ (XYMIMEmotionEntity *)entityWithDictionary:(NSDictionary*)dic atIndex:(int)index;

@property (nonatomic, copy) NSString* code;//for post, ex:[0]
@property (nonatomic, copy) NSString* name;//for parse, ex:[微笑]
@property (nonatomic, copy) NSString* imageName;//ex, Expression_1.pngs

@end

@class XYMFaceView;
@protocol XYMFaceViewDelegate<NSObject>

-(void)itemClickEvent:(NSString*)content;
-(void)deleteClickEvent;
-(void)sendClickEvent;
@end

@interface XYMFaceView : UIView<UIScrollViewDelegate>

@property (nonatomic,assign) id<XYMFaceViewDelegate> delegate;

-(void)initViews;
-(NSString*)imageNameForEmotionCode:(NSString*)code;
-(NSString*)imageNameForEmotionRegex:(NSString*)regex;
-(NSString*)faceNameForEmotionRegex:(NSString*)regex;
-(NSString*)imageNameForEmotionName:(NSString*)name;

@end


