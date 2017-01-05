//
//  NSDictionary+Custom.m
//  TianyaQing
//
//  Created by gzty1 on 12-3-6.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Custom.h"


@implementation NSDictionary (Custom)

- (BOOL)boolWithKey:(id)aKey
{
    id object=[self objectForKey:aKey];
    if([object isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    return [object boolValue];
}


- (int)intWithKey:(id)aKey
{
    id object=[self objectForKey:aKey];
    if([object isKindOfClass:[NSNull class]])
    {
        return -1;
    }
    return [object intValue];
}

- (double)doubleWithKey:(id)aKey
{
    id object=[self objectForKey:aKey];
    if([object isKindOfClass:[NSNull class]])
    {
        return -1;
    }
    return [object doubleValue];
}

- (id)objectWithKey:(id)aKey
{
	id object=[self objectForKey:aKey];
	if ([object isKindOfClass:[NSNull class]]) 
	{
		return nil;
	}
	return object;
}

- (id)keyAtIndex:(int)index
{
	NSArray* keyArray=[self allKeys];
	id key=[keyArray objectAtIndex:index];
	
	return key;
}

- (id)valueAtIndex:(int)index
{
	NSArray* keyArray=[self allKeys];
	id key=[keyArray objectAtIndex:index];
	id value=[self objectForKey:key];
	
	return value;
}

@end
