//
//  JSONAddition.m
//  healthcoming
//
//  Created by Franky on 15/8/15.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "JSONAddition.h"

@implementation NSArray(CWPSerializing)

-(NSString *)JSONString
{
    NSData *commandData = [NSJSONSerialization dataWithJSONObject:self
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];
    NSString* string = [[NSString alloc] initWithData:commandData encoding:NSUTF8StringEncoding];
    return string;
//    NSMutableString *mutStr = [NSMutableString stringWithString:string];
//    NSRange range = {0,string.length};
//    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
//    NSRange range2 = {0,mutStr.length};
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range2];
//    return mutStr;
}

-(NSData *)JSONData
{
    NSData *commandData = [NSJSONSerialization dataWithJSONObject:self
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];
    return commandData;
}

@end

@implementation NSDictionary(CWPSerializing)

-(NSString *)JSONString
{
    NSData *commandData = [NSJSONSerialization dataWithJSONObject:self
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];
    NSString* string = [[NSString alloc] initWithData:commandData encoding:NSUTF8StringEncoding];
    
    NSMutableString *mutStr = [NSMutableString stringWithString:string];
    NSRange range = {0,string.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end

@implementation NSString (CWPDeserializing)

-(id)objectFromJSONString
{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    return object;
}

@end
