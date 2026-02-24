//
//  BetListModel.h
//  phonelive2
//
//  Created by test on 2021/9/20.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface BetListTotalModel : NSObject
@property(nonatomic,strong)NSString *money;
@property(nonatomic,strong)NSString *profit;
@end

@interface BetStatusInfoModel : NSObject
@property(nonatomic,strong)NSString *sid;
@property(nonatomic,strong)NSString *sname;
@end

@interface BetListPageModel : NSObject
@property(nonatomic,strong)NSString *current;
@property(nonatomic,strong)NSString *max;
@end

@interface BetLotterysInfoModel : NSObject
@property(nonatomic,strong)NSString *lid;
@property(nonatomic,strong)NSString *lname;
@end

@interface BetListDetailModel : NSObject
@property(nonatomic,strong) NSArray *money;
@property(nonatomic,strong) NSArray *way;
@end

@interface BetListDataModel : NSObject
@property(nonatomic,strong)NSString *after_coin;
@property(nonatomic,strong)NSString *before_coin;
@property(nonatomic,strong)NSString *issue;
@property(nonatomic,strong)NSString *live_dividend;
@property(nonatomic,strong)NSString *liveuid;
@property(nonatomic,strong)NSString *lotteryName;
@property(nonatomic,strong)NSString *lotteryType;
@property(nonatomic,strong)NSString *money;
@property(nonatomic,strong)NSString *orderid;
@property(nonatomic,strong)NSString *profit;
@property(nonatomic,strong)NSString *state;
@property(nonatomic,strong)NSString *tm;
@property(nonatomic,strong)NSString *total_money;
@property(nonatomic,strong)NSString *total_profit;
@property(nonatomic,strong)NSString *total_zushu;
@property(nonatomic,strong)NSString *uid;
@property(nonatomic,strong)NSString *way;
@property(nonatomic,strong)BetListDetailModel *detail;
@end

@interface BetListModel : NSObject
@property(nonatomic,strong)NSString *end_time;
@property(nonatomic,strong)NSArray <BetListDataModel *> *list;
@property(nonatomic,strong)NSArray <BetLotterysInfoModel *> *lotterysInfo;
@property(nonatomic,strong)BetListPageModel *page;
@property(nonatomic,strong)NSString *start_time;
@property(nonatomic,strong)NSArray <BetStatusInfoModel *> *statusInfo;
@property(nonatomic,strong)BetListTotalModel *total;
@end

NS_ASSUME_NONNULL_END
