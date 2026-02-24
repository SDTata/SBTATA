//
//  LotteryNetworkUtil.m
//  phonelive2
//
//  Created by vick on 2023/12/5.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryNetworkUtil.h"

@implementation NetworkData

@end

@implementation LotteryNetworkUtil

+ (void)baseRequest:(NSString *)url params:(NSMutableDictionary *)params block:(NetworkBlock)block {
    params[@"uid"] = [Config getOwnID];
    params[@"token"] = [Config getOwnToken];
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:YES andParameter:params data:nil success:^(int code, NSArray *info, NSString *msg) {
        NetworkData *networkData = [NetworkData new];
        networkData.status = (code == 0);
        networkData.msg = msg;
        networkData.code = code;
        networkData.data = [info isKindOfClass:[NSArray class]] ? [info firstObject] : info;
        networkData.info = info;
        !block ?: block(networkData);
    } fail:^(NSError *error) {
        NetworkData *networkData = [NetworkData new];
        networkData.status = NO;
        networkData.msg = [error isKindOfClass:NSString.class] ? (NSString *)error : error.localizedDescription;
        networkData.code = [error isKindOfClass:NSString.class] ? 400 : error.code;
        !block ?: block(networkData);
    }];
}

+ (void)getOpenHistory:(NSInteger)type page:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"lottery_type"] = @(type);
    dict[@"page"] = @(page);
    [self baseRequest:@"Lottery.getOpenHistory" params:dict block:block];
}

+ (void)getBetRecords:(NSInteger)type page:(NSInteger)page status:(NSInteger)status startTime:(NSString *)startTime endTime:(NSString *)endTime block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"lottery_type"] = @(type);
    dict[@"page"] = @(page);
    dict[@"status"] = @(status);
    dict[@"start_time"] = startTime;
    dict[@"end_time"] = endTime;
    [self baseRequest:@"Lottery.betList3" params:dict block:block];
}

+ (void)getBetViewInfo:(NSInteger)type liveId:(NSInteger)liveId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"lottery_type"] = @(type);
    dict[@"live_id"] = @(liveId);
    [self baseRequest:@"Lottery.getBetViewInfo" params:dict block:block];
}

+ (void)getHomeBetViewInfo:(NSInteger)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"lottery_type"] = @(type);
    dict[@"support_nn"] = @(type == 10);
    [self baseRequest:@"Lottery.getHomeBetViewInfo" params:dict block:block];
}

+ (void)getLotteryList:(NSString *)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = type;
    [self baseRequest:@"Lottery.getLotteryList" params:dict block:block];
}

+ (void)getPlatGames:(NSString *)plat subPlat:(NSString *)subPlat page:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"plat"] = plat;
    dict[@"sub_plat"] = subPlat;
    dict[@"p"] = @(page);
    [self baseRequest:@"User.getPlatGames" params:dict block:block];
}

+ (void)getGroupGames:(NSString *)group_id page:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"group_id"] = group_id;
    dict[@"p"] = @(page);
    [self baseRequest:@"User.getGroupGames" params:dict block:block];
}

+ (void)getPlatsBlock:(NetworkBlock)block {
    [self baseRequest:@"User.getPlats" params:nil block:block];
}

+ (void)getLiveBetRank:(NSInteger)type liveId:(NSInteger)liveId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"lottery_type"] = @(type);
    dict[@"live_id"] = @(liveId);
    [self baseRequest:@"Lottery.getLiveBetRank" params:dict block:block];
}

+ (void)getBetting:(NSInteger)type liveId:(NSInteger)liveId issue:(NSString *)issue way:(NSArray *)way money:(NSArray *)money block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"lottery_type"] = @(type);
    dict[@"liveuid"] = @(liveId);
    dict[@"issue"] = issue;
    dict[@"way"] = vkToJson(way);
    dict[@"money"] = vkToJson(money);
    dict[@"serTime"] = vkTimestamp();
    dict[@"betid"] = vkTimestamp();
    [self baseRequest:@"Lottery.Betting" params:dict block:block];
}

+ (void)getLiveCmdAdd:(NSString *)name price:(NSString *)price duration:(NSString *)duration block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"name"] = name;
    dict[@"price"] = price;
    dict[@"duration"] = duration;
    [self baseRequest:@"Live.addLiveUserCmd" params:dict block:block];
}

+ (void)getLiveCmdEdit:(NSString *)cmdId type:(NSString *)type name:(NSString *)name price:(NSString *)price duration:(NSString *)duration block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"cmd_id"] = cmdId;
    dict[@"cmd_type"] = type;
    dict[@"name"] = name;
    dict[@"price"] = price;
    dict[@"duration"] = duration;
    [self baseRequest:@"Live.editLiveUserCmd" params:dict block:block];
}

+ (void)getLiveCmdDelete:(NSString *)cmdId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"cmd_id"] = cmdId;
    [self baseRequest:@"Live.deleteLiveUserCmd" params:dict block:block];
}

+ (void)getLiveCmdList:(NSString *)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = type;
//    dict[@"live_uid"] = [Config getOwnID];
    [self baseRequest:@"Live.getLiveToyInfo" params:dict block:block];
}

+ (void)getMovieHomeListBlock:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self baseRequest:@"Movie.getMovieHome" params:dict block:block];
}

+ (void)getMovieList:(NSString *)cateId sub:(NSString *)subId page:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"cate_id"] = cateId;
    dict[@"sub_cate_id"] = subId;
    dict[@"p"] = @(page);
    [self baseRequest:@"Movie.getMoviesByCate" params:dict block:block];
}

+ (void)getSkitVideoList:(NSString *)skitId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"skit_pid"] = skitId;
    [self baseRequest:@"Skit.getSkitListById" params:dict block:block];
}

+ (void)getMoviePlay:(NSString *)movieId isRefresh:(BOOL)isRefresh block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"movie_id"] = movieId;
    dict[@"refresh_url"] = @(isRefresh);
    dict[@"auto_deduct"] = @(YES);
    [self baseRequest:@"Movie.playMovie" params:dict block:block];
}

+ (void)getVideoTicketsBlock:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self baseRequest:@"User.getTicketInfo" params:dict block:block];
}

+ (void)getMovieUseTicket:(NSString *)movieId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"movie_id"] = movieId;
    dict[@"ticket_type"] = @"1";
    [self baseRequest:@"Movie.useTicket" params:dict block:block];
}

+ (void)getMovieBuyMovie:(NSString *)movieId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"movie_id"] = movieId;
    [self baseRequest:@"Movie.buyMovie" params:dict block:block];
}

+ (void)getSkitUseTicket:(NSString *)videoId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"skit_id"] = videoId;
    dict[@"ticket_type"] = @"1";
    [self baseRequest:@"Skit.useTicket" params:dict block:block];
}

+ (void)getSkitUseCoin:(NSString *)videoId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"skit_id"] = videoId;
    [self baseRequest:@"Skit.buyVideo" params:dict block:block];
}

+ (void)getShortVideoUseTicket:(NSString *)videoId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"video_id"] = videoId;
    dict[@"ticket_type"] = @"1";
    [self baseRequest:@"ShortVideo.useTicket" params:dict block:block];
}

+ (void)getShortVideoUseCoin:(NSString *)videoId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"video_id"] = videoId;
    [self baseRequest:@"ShortVideo.buyVideo" params:dict block:block];
}

+ (void)getMyCreateVideos:(NSString *)type page:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = type;
    dict[@"p"] = @(page);
    [self baseRequest:@"ShortVideo.getMyVideos" params:dict block:block];
}

+ (void)getMyCreateManage:(NSArray *)ids action:(NSString *)action block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"video_ids"] = [ids componentsJoinedByString:@","];
    dict[@"action"] = action;
    [self baseRequest:@"ShortVideo.manageVideo" params:dict block:block];
}

+ (void)getMyCreateReport:(NSString *)type page:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"time_period"] = type;
    dict[@"p"] = @(page);
    [self baseRequest:@"ShortVideo.getProfitInfo" params:dict block:block];
}

+ (void)getSkitHomeList:(NSString *)type cate:(NSString *)cate page:(NSInteger)page block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"type"] = type;
    dict[@"cate"] = cate;
    dict[@"page"] = @(page);
    [self baseRequest:@"Skit.getSkitListByType" params:dict block:block];
}

+ (void)getRewardCenterInfoBlock:(NetworkBlock)block {
    [self baseRequest:@"User.getRewardCenterInfo" params:nil block:block];
}

+ (void)getTaskListByGroup:(NSString *)groupId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"group_id"] = groupId;
    [self baseRequest:@"User.getTaskListByGroup" params:dict block:block];
}

+ (void)getRebateRulesBlock:(NetworkBlock)block {
    [self baseRequest:@"User.getRebateRules" params:nil block:block];
}

+ (void)getTaskRewardById:(NSString *)taskId groupId:(NSString *)groupId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"group_id"] = groupId;
    dict[@"taskID"] = taskId;
    [self baseRequest:@"User.getTaskReward" params:dict block:block];
}

+ (void)getKingReward:(NSString *)type block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"reward_type"] = type;
    [self baseRequest:@"Kingreward.getreward" params:dict block:block];
}

+ (void)getSignRewardBlock:(NetworkBlock)block {
    [self baseRequest:@"User.getBonus" params:nil block:block];
}

+ (void)getDrawLuckyRewardBlock:(NetworkBlock)block {
    [self baseRequest:@"Live.doLuckydraw" params:nil block:block];
}

+ (void)getBackWaterRewardBlock:(NetworkBlock)block {
    [self baseRequest:@"User.getRebateReward" params:nil block:block];
}

#pragma mark - 短視頻
+ (void)getShortVideoFavoriteBlock:(BOOL)isLike videoId:(NSString*)videoId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"video_id"] = videoId;
    dict[@"is_like"] = @(isLike?1:0);
    [self baseRequest:@"ShortVideo.likeVideo" params:dict block:block];
}

+ (void)getShortVideoPlayEndvideoId:(NSString*)videoId playTime:(NSInteger)playTime {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"video_id"] = videoId;
    dict[@"play_time"] = @(playTime);
    [self baseRequest:@"ShortVideo.playEnd" params:dict block:nil];
}

#pragma mark - 通用
+ (void)getBaseInfoBlock:(NetworkBlock)block {
    [self baseRequest:@"User.getBaseInfo" params:nil block:block];
}

#pragma mark - 短劇
+ (void)getSkitToggleFavoriteSkit:(NSString*)skitId isAddL:(BOOL)isAdd block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"skit_pid"] = skitId;
    dict[@"action"] = isAdd ? @0 : @1;
    [self baseRequest:@"Skit.toggleFavoriteSkit" params:dict block:block];
}

+ (void)getVipListBlock:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self baseRequest:@"Mall.index" params:dict block:block];
}

+ (void)getVipPay:(NSString *)vipId block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"vipid"] = vipId;
    [self baseRequest:@"Mall.buyvip" params:dict block:block];
}

@end
