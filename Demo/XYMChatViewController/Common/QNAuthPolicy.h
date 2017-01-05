//
//  QNAuthPolicy.h
//  healthcoming
//
//  Created by Franky on 15/8/21.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QNAuthPolicy : NSObject

@property (nonatomic, copy) NSString *scope;
@property (nonatomic, copy) NSString *callbackUrl;
@property (nonatomic, copy) NSString *callbackBodyType;
@property (nonatomic, copy) NSString *customer;
@property (nonatomic, assign) long long expires;
@property (nonatomic, assign) long long escape;

+ (NSString *)defaultToken;
+ (void)setDefaultToken:(NSString*)token validDate:(int)validDate;

+ (NSString *)tokenWithScope:(NSString *)scope;
- (NSString *)makeToken:(NSString *)accessKey secretKey:(NSString *)secretKey;

@end
