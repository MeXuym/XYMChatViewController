//
//  hhmkPublic.h
//  healthcoming
//
//  Created by Franky on 15/8/5.
//  Copyright (c) 2015年 Franky. All rights reserved.
//

#ifndef healthcoming_hhmkPublic_h
#define healthcoming_hhmkPublic_h

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define DSelfUpLoadImg @"selfUpLoadImg"
#define DSamllPic @"pictue_small"
#define DLargePic @"pictue_large"
#define DVoicePath @"VoicePath"
#define DVoiceUrl @"VoiceUrl"

#define appversion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define appNo [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define NormalGreen UIColorFromRGB(0x00a378)
#define LightGreen UIColorFromRGB(0x3cba98)
#define DarkGreen UIColorFromRGB(0x216654)
#define NormalGray UIColorFromRGB(0x999999)
#define LightGray UIColorFromRGB(0xCCCCCC)
#define BGGray UIColorFromRGB(0xebebeb)
#define SHAREBGGray UIColorFromRGB(0xefefef)
#define SHAREBottomGray UIColorFromRGB(0xF8F8F8)
#define Font15Size [UIFont systemFontOfSize:15.0]

#define IMClientDB @"IMClient.db"
#define IMMsgStatusNotifaction @"MsgStatusNotifaction"
#define IMNewMsgNotifaction @"NewMsgNotifaction"
#define IMConnectStateChangeNotiction @"ConnectStateChangeNotiction"
#define IMSessionChangeNotifaction @"SessionChangeNotifaction"

#define KNewPushMsgNotifaction @"NewPushMsgNotifaction"
#define KRegistCompletedNotifaction @"RegistCompletedNotifaction"
#define KUnReadCountNotifaction @"UnReadCountNotifaction"
#define KReadedCountNatifaction @"ReadedCountNotifaction"
#define KGroupChangedNotifaction @"GroupChangedNotifaction"
#define KGroupUserChangedNotifaction @"GroupUserChangedNotifaction"
#define KUserKickOffNotifaction @"UserKickOffNotifaction"
#define KSignChangedNotifaction @"SignChangedNotifaction"
#define KSessionNameNotifaction @"SessionNameNotifaction"
#define KMyGoodsChangedNotifaction @"MyGoodsChangedNotifaction"
#define KMyGoodsChangedNotifaction2 @"MyGoodsChangedNotifaction2"
#define KCashAuditMsgNotifaction @"CashAuditMsgNotifaction"
#define KOpenMyGoodsNotifaction @"OpenMyGoodsNotifaction"



#define appSessionOverContent @"本次咨询已结束"
#define appNoticeFile(userId) [NSString stringWithFormat:@"notice_%d.txt", userId]
#define xiaoyue_Id @"-233"
#define follow_Id @"-234"

#define OpenScoket 1

#define IMPORT 9083

// 正式环境 : 注释 DEBUG_ENABLE
// 测试环境 : 取消注释 DEBUG_ENABLE
#define DEBUG_ENABLE 1
//

/////** 测试环境 */
//#ifdef DEBUG_ENABLE
/** weixin */
//#define WebChat @"webchat.baymy.cn/"
///** hsp */
//#define IMSERVER @"hsp.baymy.cn"
///** server */
//#define POSTSERVER  @"server.baymy.cn"
///** Qiniu */
////#define QN_URL_FOR_KEY(key) [NSString stringWithFormat:@"http://7xl8mj.com1.z0.glb.clouddn.com/%@", key]
////七牛整改
//#define QN_URL_FOR_KEY(key) [NSString stringWithFormat:@"http://file.baymy.cn/%@", key]
///** youmeng */
//#define UMengAppKey @"55e03648e0f55accc9002202"
///** baidu */
//#define ApiKey @"sMs2uvhRPV0ImDo4kKzN4MCw"
//#define baseScan @"http://website.baymy.cn/chat/scan_fail.html?pcToken="
//#define baseScan1 @"http://web.baymy.cn/chat/scan_fail.html?pcToken="
//#define PushMode 0
//#define UseUCS 0
//#define healthEduWebURL @"http://webchat.baymy.cn/profcontent/views/public_class_list.html?platform=ios"
//#define healthOneEduWebURL @"http://webchat.baymy.cn/profcontent/views/public_class_list.html?platform=ios&notop=1"
//#define healthTipsWebURL @"http://webchat.baymy.cn/appwarp/views/category_recom_list.html?platform=ios&tokenId=%@&userId=%@"

/////** 正式环境 */
//#else
/** weixin */
#define WebChat @"webchat.ihealthcoming.com/"
/** hsp */
#define IMSERVER  @"hsp.ihealthcoming.com"
/** server */
#define POSTSERVER  @"server.ihealthcoming.com"
/** Qiniu */
//#define QN_URL_FOR_KEY(key) [NSString stringWithFormat:@"http://7xlot7.com2.z0.glb.qiniucdn.com/%@", key]
//七牛整改
#define QN_URL_FOR_KEY(key) [NSString stringWithFormat:@"http://file.ihealthcoming.com/%@", key]
/** youmeng */
#define UMengAppKey @"55f17380e0f55a10a800303b"
/** baidu */
#define ApiKey @"IdOVGrFmRXDCAzxF3NOMAisT"
#define baseScan @"http://web.ihealthcoming.com/chat/scan_fail.html?pcToken="
//生产环境有没有第二个地址
#define baseScan1 @"http://web.baymy.cn/chat/scan_fail.html?pcToken="
#define PushMode 1

//#define UseUCS 1

//UseUCS 为1的话 无法在模拟器上调试
#define UseUCS 0

#define healthEduWebURL @"http://webchat.ihealthcoming.com/profcontent/views/public_class_list.html?platform=ios"
#define healthOneEduWebURL @"http://webchat.ihealthcoming.com/profcontent/views/public_class_list.html?platform=ios&notop=1"
#define healthTipsWebURL @"http://webchat.ihealthcoming.com/appwarp/views/category_recom_list.html?platform=ios&tokenId=%@&userId=%@"


//#endif

//#define WebChat @"webchat.baymy.cn/"
//#define WebChat @"webchat.ihealthcoming.com/"

//生产环境
//#define IMSERVER  @"hsp.ihealthcoming.com"
//公网测试环境
//#define IMSERVER @"hsp.baymy.cn"


//生产
//#define POSTSERVER  @"server.ihealthcoming.com"
//测试
//#define POSTSERVER  @"server.baymy.cn"

//Qiniu
//测试
//#define QN_URL_FOR_KEY(key) [NSString stringWithFormat:@"http://7xl8mj.com1.z0.glb.clouddn.com/%@", key]
//生产
//#define QN_URL_FOR_KEY(key) [NSString stringWithFormat:@"http://7xlot7.com2.z0.glb.qiniucdn.com/%@", key]

//友盟
//测试
//#define UMengAppKey @"55e03648e0f55accc9002202"
//生产
//#define UMengAppKey @"55f17380e0f55a10a800303b"

//百度推送
//测试key
//#define ApiKey @"sMs2uvhRPV0ImDo4kKzN4MCw"
//生产key
//#define ApiKey @"IdOVGrFmRXDCAzxF3NOMAisT"
//#define PushMode 0
//
//#define UseUCS 0
//云之迅
#define AccountSid @"497665903352220d51a761c89a4053d0"
#define AuthToken @"497ffcc2966c663276075718fbce8aa4"

#define UCSAccount @"72345029396503"
#define UCSPassWord @"4165c239"

static const int TagColor[] = {0x95d0e6};

#define color1 0xff7f92
#define color2 0x78d1ed
#define color3 0x9bcb61

typedef NS_ENUM(NSInteger, AppShareType) {
    DoctorCard = 2,
    NoticeDetail = 6,
};

#endif
