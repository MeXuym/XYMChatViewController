//
//  FaceView.m
//  21cbh_iphone
//
//  Created by Franky on 14-6-10.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import "XYMFaceView.h"

#define FaceSize 32
#define HeightMargin 9
#define LeftMargin 15
#define ColumnCount 7

@implementation XYMIMEmotionEntity

///////////////////////////////////////////////////////////////////////////////////////////////////
// imageName:001.png
// code:[0]
// name:[微笑]
+ (XYMIMEmotionEntity *)entityWithDictionary:(NSDictionary*)dic atIndex:(int)index
{
    XYMIMEmotionEntity* entity = [[XYMIMEmotionEntity alloc] init];
    entity.name = dic[@"name"];
    entity.code = [NSString stringWithFormat:@"[%d]", index];//[dic objectForKey:@"code"];
    entity.imageName = [NSString stringWithFormat:@"Expression_%d.png", index+1];//[dic objectForKey:@"image"];
    
    return entity;
}

@end

@implementation XYMFaceView
{
    NSArray* emotionsArray;
    NSArray* class_emotion_array;
    NSInteger pageNum;
    NSInteger changeNum;
    
    UIScrollView* scrollView_;
    UIPageControl* pageControl_;
    
    UIButton* sendButton_;
    
    int widthMargin;
    int itemCountOfPage;
    
    BOOL isShowView;
}

@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self)
    {
        NSString* file1 = [[NSBundle mainBundle] pathForResource:@"emotion_icons" ofType:@"plist"];
        NSArray* array = [NSArray arrayWithContentsOfFile:file1];
        NSMutableArray* entities = [NSMutableArray arrayWithCapacity:array.count];
        for (int i = 0; i < array.count; i++) {
            NSDictionary* dic = array[i];
            XYMIMEmotionEntity* entity = [XYMIMEmotionEntity entityWithDictionary:dic atIndex:i];
            [entities addObject:entity];
        }
        emotionsArray = entities;
        
        class_emotion_array = @[@"/::)",@"/::~",@"/::B",@"/::|",@"/:8-)",@"/::<",@"/::$",@"/::X",@"/::Z",@"/::'(",@"/::-|",@"/::@",@"/::P",@"/::D",@"/::O",@"/::(",@"/::+",@"/:--b",@"/::Q",@"/::T",@"/:,@P",@"/:,@-D",@"/::d",@"/:,@o",@"/::g",@"/:|-)",@"/::!",@"/::L",@"/::>",@"/::,@",@"/:,@f",@"/::-S",@"/:?",@"/:,@x",@"/:,@@",@"/::8",@"/:,@!",@"/:!!!",@"/:xx",@"/:bye",@"/:wipe",@"/:dig",@"/:handclap",@"/:&-(",@"/:B-)",@"/:<@",@"/:@>",@"/::-O",@"/:>-|",@"/:P-(",@"/::'|",@"/:X-)",@"/::*",@"/:@x",@"/:8*",@"/:pd",@"/:<W>",@"/:beer",@"/:basketb",@"/:oo",@"/:coffee",@"/:eat",@"/:pig",@"/:rose",@"/:fade",@"/:showlove",@"/:heart",@"/:break",@"/:cake",@"/:li",@"/:bome",@"/:kn",@"/:footb",@"/:ladybug",@"/:shit",@"/:moon",@"/:sun",@"/:gift",@"/:hug",@"/:strong",@"/:weak",@"/:share",@"/:v",@"/:@)",@"/:jj",@"/:@@",@"/:bad",@"/:lvu",@"/:no",@"/:ok",@"/:love",@"/:<L>",@"/:jump",@"/:shake",@"/:<O>",@"/:circle",@"/:kotow",@"/:turn",@"/:skip",@"/:skip",@"/:oY"];
        
    }
    return self;
}

-(void)initViews
{
    if (isShowView) {
        return;
    }
    
    changeNum = 0;
    widthMargin = ((self.frame.size.width - LeftMargin)/ColumnCount - FaceSize)/2;
    itemCountOfPage = 3*ColumnCount;
    pageNum = emotionsArray.count/itemCountOfPage+1;
    if(!scrollView_)
    {
        scrollView_=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-70)];
        scrollView_.contentSize=CGSizeMake(self.frame.size.width*pageNum, self.frame.size.height-70);
        scrollView_.pagingEnabled = YES;
        scrollView_.scrollEnabled = YES;
        scrollView_.showsVerticalScrollIndicator = NO;
        scrollView_.showsHorizontalScrollIndicator = NO;
        scrollView_.userInteractionEnabled = YES;
        scrollView_.minimumZoomScale = 1;
        scrollView_.maximumZoomScale = 1;
        scrollView_.decelerationRate = 0.01f;
        scrollView_.backgroundColor = [UIColor clearColor];
        scrollView_.delegate=self;
        [self addSubview:scrollView_];
    }
    
    for (int i=0; i<emotionsArray.count; i++)
    {
//        if(i+1>=itemCountOfPage&&(i+1)%itemCountOfPage==0)
//        {
//            pageNum++;
////            continue;
//        }
//        else
//        {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=[self cellFrameWithNum:i isDelete:NO];
            button.tag=i;
            [button addTarget:self action:@selector(itemSelectEvent:)forControlEvents:UIControlEventTouchUpInside];

            XYMIMEmotionEntity* entity = [emotionsArray objectAtIndex:i];
            NSString* imgName = entity.imageName;
            if([imgName hasSuffix:@".png"])
            {
                [button setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            }
            [scrollView_ addSubview:button];
//        }
    }
    
    for (int i=0; i<pageNum; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=[self cellFrameWithNum:(i+1)*itemCountOfPage-1 isDelete:YES];
        button.tag=999;
        [button addTarget:self action:@selector(deletePressEvent:)forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"DeleteEmoticonBtn.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"DeleteEmoticonBtnHL.png"] forState:UIControlStateHighlighted];
        [scrollView_ addSubview:button];
    }
    
    if(pageNum>1)
    {
        pageControl_=[[UIPageControl alloc] initWithFrame:CGRectMake((self.frame.size.width - 120)/2, self.frame.size.height-70, 120, 30)];
        pageControl_.numberOfPages=pageNum;
        [pageControl_ addTarget:self action:@selector(changePageEvent) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pageControl_];
    }
    
    sendButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton_ setFrame:CGRectMake(self.frame.size.width-60, self.frame.size.height-45, 55, 40)];
    [sendButton_ setBackgroundColor:[UIColor blueColor]];
    [sendButton_ setTitle:@"发送" forState:UIControlStateNormal];
    sendButton_.layer.cornerRadius=5;
    [sendButton_ addTarget:self action:@selector(sendPressEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton_];
    
    isShowView = YES;
}

- (NSString*)imageNameForEmotionCode:(NSString*)code
{
    for (XYMIMEmotionEntity* e in emotionsArray) {
        if ([e.code isEqualToString:code]) {
            return e.imageName;
        }
    }
    return nil;
}

- (NSString*)imageNameForEmotionRegex:(NSString*)regex
{
    int i = 0;
    for (NSString* str in class_emotion_array)
    {
        if([str isEqualToString:regex])
        {
            if(i < emotionsArray.count)
            {
                XYMIMEmotionEntity* e = emotionsArray[i];
                return e.imageName;
            }
            break;
        }
        i++;
    }
    return nil;
}

- (NSString*)faceNameForEmotionRegex:(NSString*)regex
{
    int i = 0;
    for (NSString* str in class_emotion_array)
    {
        if([str isEqualToString:regex])
        {
            if(i < emotionsArray.count)
            {
                XYMIMEmotionEntity* e = emotionsArray[i];
                return e.name;
            }
            break;
        }
        i++;
    }
    return nil;
}

- (NSString*)imageNameForEmotionName:(NSString*)name
{
    for (XYMIMEmotionEntity* e in emotionsArray) {
        if ([e.name isEqualToString:name]) {
            return e.imageName;
        }
    }
    return nil;
}

-(CGRect)cellFrameWithNum:(int)num isDelete:(BOOL)isDelete
{
    CGRect rect =CGRectMake(0, 0, FaceSize, FaceSize);
    
    if(num>=(itemCountOfPage-1)&&num%(itemCountOfPage-1)==0&&!isDelete)
    {
        changeNum ++;
    }
    if(!isDelete)
    {
        num += changeNum;
    }
    
    rect.origin.x=LeftMargin+widthMargin+num%ColumnCount*(FaceSize+widthMargin*2)+num/itemCountOfPage*self.frame.size.width;
    rect.origin.y=HeightMargin+num%itemCountOfPage/ColumnCount*(FaceSize+HeightMargin*2);
    
    return rect;
}

-(void)deletePressEvent:(UIView*)sender
{
    if(sender.tag!=999) return;
    if(delegate&&[delegate respondsToSelector:@selector(deleteClickEvent)])
    {
        [delegate deleteClickEvent];
    }
}

-(void)sendPressEvent:(id)sender
{
    if(delegate&&[delegate respondsToSelector:@selector(sendClickEvent)])
    {
        [delegate sendClickEvent];
    }
}

-(void)itemSelectEvent:(UIView*)sender
{
    NSInteger i = sender.tag;
    XYMIMEmotionEntity* entity = [emotionsArray objectAtIndex:i];
    if(delegate&&[delegate respondsToSelector:@selector(itemClickEvent:)])
    {
        [delegate itemClickEvent:entity.name];
    }
}

-(void)changePageEvent
{
    scrollView_.contentOffset = CGPointMake(self.frame.size.width*pageControl_.currentPage, 0.0f);
    [pageControl_ setNeedsDisplay];
}

-(void)dealloc
{
    emotionsArray=nil;
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    int index = scrollView.contentOffset.x/self.frame.size.width;
    int mod   = fmod(scrollView.contentOffset.x,self.frame.size.width);
    if( mod >= 160)
        index++;
    pageControl_.currentPage = index;
}

@end
