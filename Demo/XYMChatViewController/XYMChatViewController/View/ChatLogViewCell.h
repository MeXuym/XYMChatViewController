//
//  ChatLogViewCell.h
//  healthcoming
//
//  Created by Franky on 15/8/18.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYMMessageItemAdaptor.h"

@protocol ChatLogViewDelegate <NSObject>

-(void)imageClick:(NSDictionary*)imageInfo imageView:(UIImageView*)imageView;
-(void)voiceClick:(XYMMessageItemAdaptor *)item;

@end

@interface ChatLogViewCell : UITableViewCell

@property (nonatomic,assign) id<ChatLogViewDelegate> delegate;

+(CGFloat)heightForLogCell:(XYMMessageItemAdaptor*)adaptor;
-(void)fillWithData:(XYMMessageItemAdaptor*)data;

-(void)startVoicePlay;
-(void)stopVoicePlay;

@end
