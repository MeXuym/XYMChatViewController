//
//  QNAuthPolicy.m
//  healthcoming
//
//  Created by Franky on 15/8/21.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "QNAuthPolicy.h"
#import "GTM_Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

static NSString *defaultToken = nil;
static int validTime = 0;

@implementation QNAuthPolicy

+ (NSString *)defaultToken
{
//    if (!defaultToken) {
//        defaultToken = [[QNAuthPolicy tokenWithScope:QN_BUCKET_NAME] copy];
        if(validTime <= [NSDate date].timeIntervalSince1970)
        {
            defaultToken = nil;
        }
//    }
    return defaultToken;
}

+(void)setDefaultToken:(NSString *)token validDate:(int)validDate
{
    defaultToken = token;
    validTime = [NSDate date].timeIntervalSince1970;
    validTime += validDate - 300;
}

+ (NSString *)tokenWithScope:(NSString *)scope
{
    QNAuthPolicy *p = [[QNAuthPolicy alloc] init];
    p.scope = scope;
    return nil;//[p makeToken:QN_AK secretKey:QN_SK];
}

// Make a token string conform to the UpToken spec.

- (NSString *)makeToken:(NSString *)accessKey secretKey:(NSString *)secretKey
{
    const char *secretKeyStr = [secretKey UTF8String];
    
    NSString *policy = [self marshal];
    
    NSData *policyData = [policy dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *encodedPolicy = [GTM_Base64 stringByWebSafeEncodingData:policyData padded:TRUE];
    const char *encodedPolicyStr = [encodedPolicy cStringUsingEncoding:NSUTF8StringEncoding];
    
    char digestStr[CC_SHA1_DIGEST_LENGTH];
    bzero(digestStr, 0);
    
    CCHmac(kCCHmacAlgSHA1, secretKeyStr, strlen(secretKeyStr), encodedPolicyStr, strlen(encodedPolicyStr), digestStr);
    
    NSString *encodedDigest = [GTM_Base64 stringByWebSafeEncodingBytes:digestStr length:CC_SHA1_DIGEST_LENGTH padded:TRUE];
    
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@",  accessKey, encodedDigest, encodedPolicy];
    
    return token;
}

// Marshal as JSON format string.

- (NSString *)marshal
{
    time_t deadline;
    time(&deadline);
    
    deadline += (self.expires > 0) ? self.expires : 3600; // 1 hour by default.
    NSNumber *deadlineNumber = [NSNumber numberWithLongLong:deadline];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (self.scope) {
        [dic setObject:self.scope forKey:@"scope"];
    }
    if (self.callbackUrl) {
        [dic setObject:self.callbackUrl forKey:@"callbackUrl"];
    }
    if (self.callbackBodyType) {
        [dic setObject:self.callbackBodyType forKey:@"callbackBodyType"];
    }
    if (self.customer) {
        [dic setObject:self.customer forKey:@"customer"];
    }
    
    [dic setObject:deadlineNumber forKey:@"deadline"];
    
    if (self.escape) {
        NSNumber *escapeNumber = [NSNumber numberWithLongLong:self.escape];
        [dic setObject:escapeNumber forKey:@"escape"];
    }
    
    NSError *error = nil;
    NSString *jsonString = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions
                                                         error:&error];
    if (!error) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else {
        NSLog(@"json->object error : %@", error);
        return nil;
    }
    
    return jsonString;
}

@end
