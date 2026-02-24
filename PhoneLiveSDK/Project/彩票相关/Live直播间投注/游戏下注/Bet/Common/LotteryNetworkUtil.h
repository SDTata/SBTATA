//
//  LotteryNetworkUtil.h
//  phonelive2
//
//  Created by vick on 2023/12/5.
//  Copyright © 2023 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkData : NSObject
@property (nonatomic, assign) BOOL status;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) id extra;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id info;
@end

typedef void (^NetworkBlock) (NetworkData *networkData);

@interface LotteryNetworkUtil : NSObject
+ (void)baseRequest:(NSString *)url params:(NSMutableDictionary *)params block:(NetworkBlock)block;
#pragma mark - 彩票
/// 开奖历史
+ (void)getOpenHistory:(NSInteger)type page:(NSInteger)page block:(NetworkBlock)block;

/// 投注记录
+ (void)getBetRecords:(NSInteger)type page:(NSInteger)page status:(NSInteger)status startTime:(NSString *)startTime endTime:(NSString *)endTime block:(NetworkBlock)block;

/// 直播彩种信息
+ (void)getBetViewInfo:(NSInteger)type liveId:(NSInteger)liveId block:(NetworkBlock)block;

/// 大厅彩种信息
+ (void)getHomeBetViewInfo:(NSInteger)type block:(NetworkBlock)block;

/// 彩票列表
+ (void)getLotteryList:(NSString *)type block:(NetworkBlock)block;

/// 平台游戏列表
+ (void)getPlatGames:(NSString *)plat subPlat:(NSString *)subPlat page:(NSInteger)page block:(NetworkBlock)block;

/// 游戏分组列表
+ (void)getGroupGames:(NSString *)group_id page:(NSInteger)page block:(NetworkBlock)block;

/// 平台列表
+ (void)getPlatsBlock:(NetworkBlock)block;

/// 排行榜
+ (void)getLiveBetRank:(NSInteger)type liveId:(NSInteger)liveId block:(NetworkBlock)block;

/// 投注
+ (void)getBetting:(NSInteger)type liveId:(NSInteger)liveId issue:(NSString *)issue way:(NSArray *)way money:(NSArray *)money block:(NetworkBlock)block;

/// 新增指令
+ (void)getLiveCmdAdd:(NSString *)name price:(NSString *)price duration:(NSString *)duration block:(NetworkBlock)block;

/// 修改指令
+ (void)getLiveCmdEdit:(NSString *)cmdId type:(NSString *)type name:(NSString *)name price:(NSString *)price duration:(NSString *)duration block:(NetworkBlock)block;

/// 删除指令
+ (void)getLiveCmdDelete:(NSString *)cmdId block:(NetworkBlock)block;

/// 获取指令
+ (void)getLiveCmdList:(NSString *)type block:(NetworkBlock)block;

#pragma mark - 电影
/// 首页长视频列表
+ (void)getMovieHomeListBlock:(NetworkBlock)block;

/// 根据分类查询长视频
+ (void)getMovieList:(NSString *)cateId sub:(NSString *)subId page:(NSInteger)page block:(NetworkBlock)block;

/// 根据短剧查询视频
+ (void)getSkitVideoList:(NSString *)skitId block:(NetworkBlock)block;

/// 长视频播放
+ (void)getMoviePlay:(NSString *)movieId isRefresh:(BOOL)isRefresh block:(NetworkBlock)block;

/// 我的观影劵
+ (void)getVideoTicketsBlock:(NetworkBlock)block;

/// 长视频观影劵付费
+ (void)getMovieUseTicket:(NSString *)movieId block:(NetworkBlock)block;

/// 长视频余额付费
+ (void)getMovieBuyMovie:(NSString *)movieId block:(NetworkBlock)block;

/// 短劇观影劵付费
+ (void)getSkitUseTicket:(NSString *)videoId block:(NetworkBlock)block;

/// 短劇余额付费
+ (void)getSkitUseCoin:(NSString *)videoId block:(NetworkBlock)block;

/// 短视频观影劵付费
+ (void)getShortVideoUseTicket:(NSString *)videoId block:(NetworkBlock)block;

/// 短视频余额付费
+ (void)getShortVideoUseCoin:(NSString *)videoId block:(NetworkBlock)block;

/// 我的创作，type: 0审核中 1已发布 2 未通过
+ (void)getMyCreateVideos:(NSString *)type page:(NSInteger)page block:(NetworkBlock)block;

/// 创作管理，delete 删除 hide隐藏 show显示
+ (void)getMyCreateManage:(NSArray *)ids action:(NSString *)action block:(NetworkBlock)block;

/// 创作收益报表，时间范围：today, yesterday, week, month
+ (void)getMyCreateReport:(NSString *)type page:(NSInteger)page block:(NetworkBlock)block;

/// 短剧列表，type类型 0:观看历史 1:最新短剧 2:热门短剧 3:收藏列表
+ (void)getSkitHomeList:(NSString *)type cate:(NSString *)cate page:(NSInteger)page block:(NetworkBlock)block;

#pragma mark - 奖励中心
/// 首页列表
+ (void)getRewardCenterInfoBlock:(NetworkBlock)block;

/// 闯关关卡
+ (void)getTaskListByGroup:(NSString *)groupId block:(NetworkBlock)block;

/// 实时返水
+ (void)getRebateRulesBlock:(NetworkBlock)block;

/// 领取任务奖励
+ (void)getTaskRewardById:(NSString *)taskId groupId:(NSString *)groupId block:(NetworkBlock)block;

/// 领取王者俸禄奖励
+ (void)getKingReward:(NSString *)type block:(NetworkBlock)block;

/// 领取签到奖励
+ (void)getSignRewardBlock:(NetworkBlock)block;

/// 领取抽奖奖励
+ (void)getDrawLuckyRewardBlock:(NetworkBlock)block;

/// 领取返水奖励
+ (void)getBackWaterRewardBlock:(NetworkBlock)block;

#pragma mark - 短視頻
+ (void)getShortVideoFavoriteBlock:(BOOL)isLike videoId:(NSString*)videoId block:(NetworkBlock)block;
+ (void)getShortVideoPlayEndvideoId:(NSString*)videoId playTime:(NSInteger)playTime;

#pragma mark - 通用
+ (void)getBaseInfoBlock:(NetworkBlock)block;

#pragma mark - 短劇
+ (void)getSkitToggleFavoriteSkit:(NSString*)skitId isAddL:(BOOL)isAdd block:(NetworkBlock)block;

/// VIP列表
+ (void)getVipListBlock:(NetworkBlock)block;

/// 购买VIP
+ (void)getVipPay:(NSString *)vipId block:(NetworkBlock)block;

@end
