//
//  JSONAddition.h
//  healthcoming
//
//  Created by Franky on 15/8/15.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(CWPSerializing)

- (NSString *)JSONString;
- (NSData *)JSONData;

@end

@interface NSDictionary(CWPSerializing)

- (NSString *)JSONString;

@end

@interface NSString(CWPDeserializing)

- (id)objectFromJSONString;

@end
