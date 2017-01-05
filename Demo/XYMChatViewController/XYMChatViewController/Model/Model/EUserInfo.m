//
//  EUserInfo.m
//  healthcoming
//
//  Created by Franky on 15/8/6.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import "EUserInfo.h"
#import "ETagInfo.h"
#import "ChineseToPinyin.h"

@implementation EUserInfo
{
    NSString* information_;
    NSString* patientHis_;
}

@synthesize nUID,userName,groupId,userPhoto,userPhotobag,phoneNo,patientSex,birthday,age,patientIsMarry,labers,patientLaber;
@synthesize pinyin = _pinyin;
@synthesize archivesLaber2 = _archivesLaber2;
@synthesize motherArchives2 = _motherArchives2;
@synthesize childArchives2 = _childArchives2;
@synthesize hdArchives2 = _hdArchives2;
@synthesize otherTag = _otherTag;

-(id)initWithDic:(NSDictionary *)dic
{
    if (self = [self init]) {
        int userId = [dic intWithKey:@"userId"];
        nUID = [NSString stringWithFormat:@"%d",userId];
        userName = [dic objectWithKey:@"userName"];
        groupId = [dic intWithKey:@"groupId"];
        userPhoto = [dic objectWithKey:@"userPhoto"];
        userPhotobag = [dic objectWithKey:@"userPhotobag"];
        phoneNo = [dic objectWithKey:@"phoneNo"];
        patientSex = [dic intWithKey:@"patientSex"];
        birthday = [dic objectWithKey:@"birthday"];
        age = [dic intWithKey:@"age"];
        patientIsMarry = [dic intWithKey:@"patientIsMarry"];
        NSArray* array = [dic objectWithKey:@"laber"];
        NSMutableArray* tagArray = [NSMutableArray array];
        for (NSDictionary* tagDic in array)
        {
            ETagInfo* item = [[ETagInfo alloc] initWithDic:tagDic];
            [tagArray addObject:item];
        }
        labers = tagArray;
        
        //用来另外传给会话模型的
        self.labers2 = [dic objectWithKey:@"laber"];
        
        patientLaber = [dic objectWithKey:@"patientLaber"];
        self.address = [dic objectWithKey:@"address"];
        self.patientTxt = [dic objectWithKey:@"patientTxt"];
        self.rem = [dic objectWithKey:@"rem"];
        
        self.archivesLaber = [dic objectWithKey:@"archivesLaber"];
        self.motherArchives = [dic objectWithKey:@"motherArchives"];
        self.childArchives = [dic objectWithKey:@"childArchives"];
        self.hdArchives = [dic objectWithKey:@"hdArchives"];
    }
    return self;
}

-(NSArray *)otherTag
{
    if(!_otherTag)
    {
        NSMutableArray* array = [NSMutableArray array];
        if(self.motherArchives2.count > 0)
        {
            MotherArchive* archive = self.motherArchives2.firstObject;
            ETagInfo* item = [[ETagInfo alloc] init];
            item.laberName = [NSString stringWithFormat:@"孕%d周",archive.yunzhong/7];
            item.type = 1;
            [array addObject:item];
        }
        if(self.childArchives2.count > 0)
        {
            ETagInfo* item = [[ETagInfo alloc] init];
            item.laberName = [NSString stringWithFormat:@"%lu个宝宝",self.childArchives2.count];
            item.type = 2;
            [array addObject:item];
        }
        if(self.hdArchives2.count > 0)
        {
            HdArchive* archive = self.hdArchives2.firstObject;
            if(archive.medical.length > 0)
            {
                NSArray* array2 = [archive.medical componentsSeparatedByString:@","];
                if(array2.count > 0)
                {
                    for (NSString* str in array2)
                    {
                        ETagInfo* item = [[ETagInfo alloc] init];
                        item.laberName = str;
                        item.type = 3;
                        [array addObject:item];
                    }
                }
            } 
        }
        
        _otherTag = array;
    }
    return _otherTag;
}

-(NSString *)information
{
    if(!information_)
    {
        information_ = [NSString stringWithFormat:@"%@, %d岁",patientSex == 1?@"男":@"女",age];
    }
    return information_;
}

-(NSString *)patientHis
{
    if(!patientHis_)
    {
        if(patientLaber)
        {
            NSInteger count = patientLaber.count > 6?6:patientLaber.count;
            NSMutableString* mutableStr = [NSMutableString string];
            for (int i = 0; i < count; i++)
            {
                NSDictionary* dic = [patientLaber objectAtIndex:i];
                NSString* laberName = [dic objectWithKey:@"laberName"];
                [mutableStr appendString:laberName];
                if (i != patientLaber.count - 1)
                {
                    [mutableStr appendString:@"/"];
                }
            }
            patientHis_ = mutableStr;
        }
        else
        {
            patientHis_ = @"无";
        }
    }
    return patientHis_;
}

-(NSString *)showName
{
    if(self.rem && self.rem.length > 0)
    {
        return self.rem;
    }
    return userName;
}

-(NSString *)pinyin
{
    if(!_pinyin && self.showName != nil && self.showName.length > 0)
    {
        _pinyin = [[ChineseToPinyin pinyinFromChiniseString:self.showName] lowercaseString];
    }
    return _pinyin;
}

-(NSArray *)archivesLaber2
{
    if(!_archivesLaber2 && self.archivesLaber)
    {
        NSMutableArray* array = [NSMutableArray array];
        for (NSDictionary* dic in self.archivesLaber) {
            ETagInfo* item = [[ETagInfo alloc] initWithDic:dic];
            [array addObject:item];
        }
        _archivesLaber2 = array;
    }
    return _archivesLaber2;
}

-(NSArray *)motherArchives2
{
    if(!_motherArchives2 && self.motherArchives)
    {
        NSMutableArray* array = [NSMutableArray array];
        for (NSDictionary* item in self.motherArchives) {
            MotherArchive* m = [[MotherArchive alloc] init];
            m.motherDate = [item objectWithKey:@"motherDate"];
            m.lastMen = [item objectWithKey:@"lastMen"];
            m.insHospital = [item objectWithKey:@"insHospital"];
            m.isPerCard = [item boolWithKey:@"isPerCard"];
            [array addObject:m];
        }
        _motherArchives2 = array;
    }
    return _motherArchives2;
}

-(NSArray *)childArchives2
{
    if(!_childArchives2 && self.childArchives)
    {
        NSMutableArray* array = [NSMutableArray array];
        for (NSDictionary* item in self.childArchives) {
            ChildArchive* m = [[ChildArchive alloc] init];
            m.childName = [item objectWithKey:@"childName"];
            m.birthday = [item objectWithKey:@"birthday"];
            m.address = [item objectWithKey:@"address"];
            m.childSex = [item intWithKey:@"childSex"];
            [array addObject:m];
        }
        _childArchives2 = array;
    }
    return _childArchives2;
}

-(NSArray *)hdArchives2
{
    if(!_hdArchives2 && self.hdArchives)
    {
        NSMutableArray* array = [NSMutableArray array];
        for (NSDictionary* item in self.hdArchives) {
            HdArchive* m = [[HdArchive alloc] init];
            m.hdName = [item objectWithKey:@"hdName"];
            m.birthday = [item objectWithKey:@"birthday"];
            m.sureDate = [item objectWithKey:@"sureDate"];
            m.medical = [item objectWithKey:@"medical"];
            m.otherMedical = [item objectWithKey:@"otherMedical"];
            [array addObject:m];
        }
        _hdArchives2 = array;
    }
    return _hdArchives2;
}
-(NSArray *)motherDate2
{
    MotherArchive *motherArchive = self.motherArchives2.firstObject;
    NSLog(@"date = %@",motherArchive.motherDate);
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* inputDate = [inputFormatter dateFromString:motherArchive.motherDate];
    NSLog(@"date = %@", inputDate);
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit |NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:inputDate];
    
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    
    NSString *motherArchivesStr = [NSString stringWithFormat:@"%ld年%ld月",(long)year,(long)month];
    //去掉前面两位
    motherArchivesStr =  [NSString stringWithFormat:@"预%@",[motherArchivesStr substringFromIndex:2]];
    
    
    
    NSDate *now = [NSDate date];
    
    NSComparisonResult result = [now compare:inputDate];
    int ci = 0;
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=2; break;
            //date02=date01
        case NSOrderedSame: ci=1; break;
        default:
            break;
    }
    
    NSMutableArray* array = [NSMutableArray array];

    //有填这个数据的才加入到数组
    if(motherArchive.motherDate){
        if(ci > 0){
            ETagInfo* item = [[ETagInfo alloc]init];
            item.isUser = NO;
            item.isSys = NO;
            item.laberName = motherArchivesStr;
            item.type = 1;
            [array addObject:item];
        }
    }
    _motherDate2 = array;
    
    return _motherDate2;
}


@end

@implementation MotherArchive

@synthesize yunzhong = _yunzhong;
@synthesize chanhou = _chanhou;

-(int)yunzhong
{
    if(_yunzhong == 0)
    {
        /**
         *  @author Bennett.Peng, 16-05-18 22:05:16
         *
         *  @brief 错误 #2648 妇保计算逻辑曾清 及 标签逻辑需求变更。
         *
         *  @since <#1.3.2#>
         */
        NSCalendar *calender = [NSCalendar currentCalendar];
        //最后月经
        NSDate *lastMen = [NSDate dateWithDateString:self.lastMen];
        NSDate *now = [NSDate date];
            
        //末次月经到现在已经多少天了（怀孕几天）
        NSDateComponents *components = [calender components:NSCalendarUnitDay fromDate:lastMen toDate:now options:NSCalendarWrapComponents];
        _yunzhong = (int)components.day;
        
        
//        NSTimeInterval last = [[NSDate dateWithDateString:self.lastMen] timeIntervalSince1970];
//        NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
//        _yunzhong = (int)(current - last)/(60*60*24);
    }
    return _yunzhong;
}

-(int)chanhou
{
    if(_chanhou == 0)
    {
        
        NSCalendar *calender = [NSCalendar currentCalendar];
        NSDate *motherDate = [NSDate dateWithDateString:self.motherDate];
        NSDate *now = [NSDate date];
        
        //预产期到现在已经多少天了（产后几天）
        NSDateComponents *components = [calender components:NSCalendarUnitDay fromDate:motherDate toDate:now options:NSCalendarWrapComponents];
        _chanhou = (int)components.day;
        
//        NSUInteger last = [[NSDate dateWithDateString:self.motherDate] timeIntervalSince1970];
//        NSUInteger current = [[NSDate date] timeIntervalSince1970];
//        _chanhou = (int)(current - last)/(60*60*24);
    }
    return _chanhou;
}

@end

@implementation ChildArchive

@synthesize tianshu = _tianshu;
@synthesize nianling = _nianling;


//天数
-(int)tianshu
{
    if(_tianshu == 0)
    {
        
        NSCalendar *calender = [NSCalendar currentCalendar];
        NSDate *birth = [NSDate dateWithDateString:self.birthday];
        NSDate *now = [NSDate date];
        
        NSDateComponents *components = [calender components:NSCalendarUnitDay fromDate:birth toDate:now options:NSCalendarWrapComponents];
        _tianshu = (int)components.day;
        
//        NSUInteger last = [[NSDate dateWithDateString:self.birthday] timeIntervalSince1970];
//        NSUInteger current = [[NSDate date] timeIntervalSince1970];
//        _tianshu = (int)(current - last)/(60*60*24);
    }
    return _tianshu;
}

//年龄
-(int)nianling
{
    if(_nianling == 0)
    {
        
        NSCalendar *calender = [NSCalendar currentCalendar];
        NSDate *birth = [NSDate dateWithDateString:self.birthday];
        NSDate *now = [NSDate date];
        
        NSDateComponents *components = [calender components:NSCalendarUnitYear fromDate:birth toDate:now options:NSCalendarWrapComponents];
        _nianling = (int)components.year;
        
//        NSUInteger last = [[NSDate dateWithDateString:self.birthday] getYear];
//        NSUInteger current = [[NSDate date] getYear];
//        _nianling = (int)(current - last);
    }
    return _nianling;
}

@end

@implementation HdArchive

@end

@implementation FollowUser

@synthesize showTime=_showTime;

-(id)initWithDic:(NSDictionary *)dic
{
    if (self = [self init])
    {
        self.userId = [dic intWithKey:@"userId"];
        self.createTime = [dic objectWithKey:@"createTime"];
    }
    return self;
}

-(NSString *)showTime
{
    if(!_showTime)
    {
        _showTime = [[NSDate dateWithDateString:self.createTime] getDateString:@"MM-dd"];
    }
    return _showTime;
}

@end
