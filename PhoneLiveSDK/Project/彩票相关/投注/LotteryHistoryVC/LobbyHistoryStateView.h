//
//  LobbyHistoryStateView.h
//  phonelive2
//
//  Created by test on 2021/7/2.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BetListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LobbyHistoryStateView : UIView
@property(nonatomic,strong)void(^completeHandler)(UIButton *);
@property(nonatomic,strong)void(^cancelHandler)(void);
/**
 state 0 全部 1 已中奖 2 未中奖 3 待开奖 4 和局
 */
+ (instancetype)instanceStateAlertWithSate:(NSInteger)state andInfoData:(NSArray<BetStatusInfoModel *>*)lotteryInfo;
- (void)alertShowAnimationWithSuperView:(UIView *)superView;
-(void)dismissView;
@end

NS_ASSUME_NONNULL_END
