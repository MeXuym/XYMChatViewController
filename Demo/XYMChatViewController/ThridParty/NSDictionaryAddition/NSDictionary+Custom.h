//
//  NSDictionary+Custom.h
//  TianyaQing
//
//  Created by gzty1 on 12-3-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Custom)
- (BOOL)boolWithKey:(id)aKey;
- (int)intWithKey:(id)aKey;
- (double)doubleWithKey:(id)aKey;
- (id)objectWithKey:(id)aKey;
- (id)valueAtIndex:(int)index;
- (id)keyAtIndex:(int)index;
@end
