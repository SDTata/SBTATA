//
//  LotteryNNModel.h
//  phonelive
//
//  Created by 400 on 2020/8/5.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PokerResultModel : NSObject

@property(nonatomic,strong)NSString  *niu;
@property(nonatomic,strong)NSArray   *pai;
@property(nonatomic,strong)NSString  *dian;

@end

@interface ResultVSModel : NSObject
@property(nonatomic,strong)PokerResultModel *blue;
@property(nonatomic,strong)PokerResultModel *red;

@property(nonatomic,strong)PokerResultModel *tiger;
@property(nonatomic,strong)PokerResultModel *dragon;

@end

@interface lastResultModel : NSObject

@property(nonatomic,strong)NSString *issue;
@property(nonatomic,strong)NSString *open_result;
@property(nonatomic,strong)NSString *open_result_zh;
@property(nonatomic,strong)NSString *open_result_another;
@property(nonatomic,strong)NSString *open_time;
@property(nonatomic,strong)ResultVSModel *vs;
@property(nonatomic,assign)NSInteger who_win;
@property(nonatomic,strong)NSArray   *win_pai;
@property(nonatomic,strong)NSArray   *results_data;
@property(nonatomic,strong)NSArray   *results_data_zh;
@property(nonatomic,strong)NSString  *pai_type_str;
@property(nonatomic,strong)NSDictionary  *te_ma_obj;
@property(nonatomic,strong)NSMutableArray *spare_2;

@end

@interface LotteryNNModel : NSObject

@property(nonatomic,strong)NSString *issue;

@property(nonatomic,strong)NSString *left_coin;
@property(nonatomic,strong)NSString *logo;
@property(nonatomic,strong)NSString *lotteryType;
@property(nonatomic,strong)NSString *name ;
@property(nonatomic,strong)NSString *sealingTim;
@property(nonatomic,assign)NSInteger serTime;
@property(nonatomic,strong)NSString *stopMsg;
@property(nonatomic,assign)NSInteger stopOrSell;
@property(nonatomic,assign)NSInteger time;

@property(nonatomic,strong)lastResultModel *lastResult;
@property(nonatomic,strong)NSArray *ways;

@end


NS_ASSUME_NONNULL_END
