//
//  NSDate+Custom.m
// 
//
//  Created by Liccon Chang on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Custom.h"

@implementation NSDate (Custom)

+(NSString*)currentDateTimeString
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SS"];
    NSString* str = [formatter stringFromDate:date];
    
    return str;
}

+ (NSString*)intervalSinceNowWithTimestamp:(NSString *)timestamp
{
    NSDate* d= [NSDate dateWithTimestamp:timestamp];
    return [d intervalSinceNow];
}

+ (NSString*)intervalSinceNow:(NSString *)theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    if (d == nil) { //注意：服务器在博客列表中返回的时间字符串格式为:"replyTime":"2012-7-16 17:26"
        [date setDateFormat:@"yyyy-MM-dd HH:mm"];
        d = [date dateFromString:theDate];
    }
    NSString *timeString=[d intervalSinceNow];
    return timeString;
}

- (NSString*)intervalSinceNow
{
    return [self getDateString:@"yyyy-MM-dd HH:mm"];
}

- (NSString*)intervalSinceNow:(NSString*)format
{
    return [self getDateString:format];
}

- (NSString*)intervalSinceNowDate:(NSString*)dataFormat
{
    NSTimeInterval late=[self timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    if (cha<60)
    {
        timeString=[NSString stringWithFormat:@"刚刚"];
    }
    else if (cha>=60 && cha<3600) 
    {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    else if (cha>=3600&&cha<86400) 
    {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else
    {
        timeString=[self getDateString:dataFormat];
    }
    return timeString;    
}

- (NSString*)dateStringForShow
{
    NSDate* nowDate = [NSDate date];
    
    NSInteger nowYear = [nowDate getYear];
    NSInteger createYear = [self getYear];
    if (nowYear != createYear)//不是当年
    {
        return [self getDateString:@"yyyy年MM月dd日 HH:mm"];
    }
    else
    {
        if ([nowDate getMonth] == [self getMonth])//同月
        {
            if ([nowDate getDay] == [self getDay])//同日
            {
                return [self getDateString:@"HH:mm"];//@"今天";
            }
            else if([nowDate getDay] - [self getDay] == 1)
            {
                return [NSString stringWithFormat:@"昨天 %@",[self getDateString:@"HH:mm"]];//@"昨天";
            }
            else if([nowDate getDay] - [self getDay] == 2)
            {
                return [NSString stringWithFormat:@"前天 %@",[self getDateString:@"HH:mm"]];//@"前天";
            }
        }
        return [self getDateString:@"MM月dd日 HH:mm"];
    }
}

- (NSString*)dateStringForSessionShow
{
    NSDate* nowDate = [NSDate date];
    
    NSInteger nowYear = [nowDate getYear];
    NSInteger createYear = [self getYear];
    if (nowYear != createYear)//不是当年
    {
        return [self getDateString:@"yyyy/MM/dd"];
    }
    else
    {
        if ([nowDate getMonth] == [self getMonth])//同月
        {
            if ([nowDate getDay] == [self getDay])//同日
            {
                return [self getDateString:@"HH:mm"];//@"今天";
            }
            else if([nowDate getDay] - [self getDay] == 1)
            {
                //return [NSString stringWithFormat:@"昨天 %@",[self getDateString:@"HH:mm"]];//@"昨天";
                return [NSString stringWithFormat:@"昨天"];
            }
        }
        return [self getDateString:@"MM/dd"];
    }
}

- (NSString*)dateStringForSessionShowEx
{
    NSTimeInterval late=[self timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    if (cha<60)
    {
        timeString=[NSString stringWithFormat:@"刚刚"];
    }
    else if (cha>=60 && cha<3600)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    else
    {
        timeString = [self dateStringForSessionShow];
    }
    return timeString;
}

- (NSString*)dateStringForChatShow
{
    NSTimeInterval late=[self timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    if (cha<60)
    {
        timeString=[NSString stringWithFormat:@"刚刚"];
    }
    else if (cha>=60 && cha<3600)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    else
    {
        timeString = [self dateStringForShow];
    }
    return timeString;
}

+ (NSDate*)dateWithDateString:(NSString*)dateTimeString
{
    if (![dateTimeString isKindOfClass:[NSString class]] || [dateTimeString length]<10)
    {
        return nil;
    }
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    NSDate* retDate=nil;
    if ([dateTimeString length]>=19)
    {
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        retDate=[dateFormat dateFromString:[dateTimeString substringToIndex:19]];
    }
    else if ([dateTimeString length]>=16)
    {
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        retDate=[dateFormat dateFromString:[dateTimeString substringToIndex:16]];
    }
    else
    {
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        retDate=[dateFormat dateFromString:[dateTimeString substringToIndex:10]];
    }
    return retDate;
}

+ (NSDate*)dateWithTimestamp:(NSString*)timestamp 
{
    NSString* newtimestamp = [NSString stringWithFormat:@"%@%@",timestamp,@"0000000000"];
    NSString* new_sec = [newtimestamp substringToIndex:10];
	NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * timeNumber = [formatter numberFromString:new_sec];

	return [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
}

- (NSString*)getDateString
{
    return [self getDateString:@"yyyy-MM-dd"];
}

- (NSString*)getDateString:(NSString*)format
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:usLocale];	
	NSString* dateString = [dateFormatter stringFromDate:self];
    return dateString;
}

- (NSString*)getTimeString
{
    return [self getTimeString:@"HH:mm:ss"];
}

- (NSString*)getTimeString:(NSString*)format
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:format];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:usLocale];	
	NSString* timeString = [dateFormatter stringFromDate:self];
    return timeString;
}

-(NSDate*)getLastDayOfWeek
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit
                                         fromDate:self];
    // 得到星期几
    // 1(星期天) 2(星期二) 3(星期三) 4(星期四) 5(星期五) 6(星期六) 7(星期天)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    
    NSLog(@"weekDay:%ld   day:%ld",weekDay,day);
    
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff,lastDiff;
    if (weekDay == 1) {
        firstDiff = 1;
        lastDiff = 0;
    }else{
        firstDiff = [calendar firstWeekday] - weekDay;
        lastDiff = 9 - weekDay;
    }
    
    NSLog(@"firstDiff:%ld   lastDiff:%ld",firstDiff,lastDiff);
    
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"星期一开始 %@",[formater stringFromDate:firstDayOfWeek]);
    NSLog(@"当前 %@",[formater stringFromDate:self]);
    NSLog(@"星期天结束 %@",[formater stringFromDate:lastDayOfWeek]);
    
    return lastDayOfWeek;
}

//获取日
- (NSUInteger)getDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitDay) fromDate:self];
    return [dayComponents day];
}
//获取月
- (NSUInteger)getMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMonth) fromDate:self];
    return [dayComponents month];
}
//获取年
- (NSUInteger)getYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitYear) fromDate:self];
    return [dayComponents year];
}
//获取小时
- (int)getHour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags =NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    NSInteger hour = [components hour];
    return (int)hour;
}
//获取分钟
- (int)getMinute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags =NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    NSInteger minute = [components minute];
    return (int)minute;
}

@end
