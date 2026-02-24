//
//  hotModel.h
//  yunbaolive
//
//  Created by zqm on 16/4/25.
//  Copyright © 2016年 cat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <MJExtension/MJExtension.h>
#import "ShortVideoModel.h"


@interface hotModel : NSObject

@property(nonatomic,strong)NSString *stream;

@property(nonatomic,strong)NSString *Id;

@property(nonatomic,strong)NSString *zhuboPlace;//主播位置

@property(nonatomic,strong)NSString *onlineCount;//在线人数

@property(nonatomic,strong)NSString *signature;

@property(nonatomic,strong)NSString *sex;

@property(nonatomic,strong)NSString *level;

@property(nonatomic,assign)BOOL isLive;

@property(nonatomic,assign)BOOL encryption;

@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *video_type;

@property(nonatomic,strong)NSString *have_red_envelope;//红包状态

@property(nonatomic,strong)NSString *zhuboStatus;//直播状态

@property(nonatomic,strong)NSString *zhuboImage;//主播图片

@property(nonatomic,strong)NSString *zhuboIcon;//主播头像

@property(nonatomic,strong)NSString *zhuboID;//主播ID

@property(nonatomic,strong)NSString *game_action;//游戏

@property(nonatomic,strong)NSString *title;

@property(nonatomic,strong)NSString *zhuboName;//主播名字

@property(nonatomic,strong)NSString *avatar_thumb;

@property(nonatomic,strong)NSString *level_anchor;//主播等级

@property(nonatomic,strong)NSString *distance;//距离

@property(nonatomic,strong)NSString *lottery_name;//彩种名称

@property(nonatomic,strong)NSString *pull;

@property(nonatomic,assign)NSInteger lottery_type; //彩种类型

@property(nonatomic,strong)NSString *chat_flag; //端口号

@property(nonatomic,strong)NSString *centerUrl; //游戏中心serverurl


@property(nonatomic,strong)NSString *barrage_fee;
@property(nonatomic,strong)NSString *push;

@property(nonatomic,strong)NSString *chatserver;

@property(nonatomic,strong)NSString *isvideo;

@property(nonatomic,strong)NSString *supportVibrator; // 是否有跳蛋

@property(nonatomic,strong)NSDictionary *roomLotteryInfo;

@property(nonatomic,strong)NSString *votestotal;

@property(nonatomic,strong)NSString *guard_nums;

@property(nonatomic,strong)NSString *anyway;

@property(nonatomic,strong)NSString *goodnum;
@property(nonatomic,strong)NSString *nums;

@property(nonatomic,strong)NSDictionary *liang;

@property(nonatomic,strong)NSDictionary *vip;

@property(nonatomic,strong)NSArray *game_switch;

@property(nonatomic,strong)NSString *shut_time;

@property(nonatomic,strong)NSString *fans;

@property(nonatomic,strong)NSString *userlist_time;

@property(nonatomic,strong)NSString *live_region;

@property(nonatomic,strong)NSString *live_region_icon;

@property(nonatomic,assign)CGRect nameR;

@property(nonatomic,assign)CGRect placeR;

@property(nonatomic,assign)CGRect imageR;

@property(nonatomic,assign)CGRect IconR;

@property(nonatomic,assign)CGRect CountR;

@property(nonatomic,assign)CGRect statusR;

@property (nonatomic, strong) VideoSizeModel *cover_meta;

@property (nonatomic, strong) NSDate *startTime;  // 开始时间

@property (nonatomic, assign) NSTimeInterval stayDuration; // 停留时间总计
@end
