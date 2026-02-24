//
//  LotteryBetModel.h
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LotteryOptionModel;

@interface LotteryResultModel : NSObject
@property (nonatomic, copy) NSString *issue;
@property (nonatomic, copy) NSString *open_result;
@property (nonatomic, copy) NSString *open_result_another;
@property (nonatomic, copy) NSString *open_time;
@property (nonatomic, strong) NSArray *spare_2;
@property (nonatomic, strong) NSDictionary *te_ma_obj;
@property (nonatomic, strong) NSDictionary *vs;
@property (nonatomic, assign) NSInteger who_win;
@property (nonatomic, copy) NSArray *win_pai;
@property (nonatomic, assign) NSInteger lotteryType;
@end

@interface LotteryOptionModel : NSObject
@property (nonatomic, copy) NSString *betall;
@property (nonatomic, copy) NSArray *betlist;
@property (nonatomic, assign) NSInteger betmine;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *st;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id data;
@end

@interface LotteryWayModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray <LotteryOptionModel *> *options;
@property (nonatomic, copy) NSString *st;
@end

@interface LotteryBetModel : NSObject
@property (nonatomic, copy) NSString *issue;
@property (nonatomic, strong) LotteryResultModel *lastResult;
@property (nonatomic, copy) NSString *left_coin;
@property (nonatomic, copy) NSString *lobbyServer;
@property (nonatomic, copy) NSString *lobby_flag;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, assign) NSInteger lotteryType;
@property (nonatomic, copy) NSString *music;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger sealingTim;
@property (nonatomic, assign) NSInteger serTime;
@property (nonatomic, copy) NSString *stopMsg;
@property (nonatomic, assign) NSInteger stopOrSell;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, strong) NSArray <LotteryWayModel *> *ways;

@property (nonatomic, strong) NSDate *timeDate;
@property (nonatomic, assign) NSInteger timeOffset;
@property (nonatomic, assign) NSInteger timeReplyCount;

@end
