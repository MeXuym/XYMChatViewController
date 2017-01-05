//
//  NSString(Emoji).h
//  healthcoming
//
//  Created by Franky on 15/9/3.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Custom)

-(BOOL)isContainsEmoji;
-(NSRange)GetEmojiRange;

@end
