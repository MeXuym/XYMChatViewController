//
//  RequestContentView.m
//  21cbh_iphone
//
//  Created by Franky on 14-7-22.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMRequestContentView.h"

@implementation XYMRequestContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void)startRequestWithCompleted:(void (^)(XYMRequestContentView*, NSString*))block
{
    //子类继承
}

-(void)cancelAndClean
{
    self.tag=0;
    if(currentRequest){
        [currentRequest cancel];
        [currentRequest setCompletionBlock:nil];
        currentRequest=nil;
    }
    
}

-(void)dealloc
{
    [self cancelAndClean];
}

@end
