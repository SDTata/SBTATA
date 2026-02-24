//
//  LobbyHistoryTypeView.h
//  phonelive2
//
//  Created by test on 2021/7/3.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BetListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LobbyHistoryTypeView : UIView
@property(nonatomic,strong)void(^completeHandler)(UIButton *);
@property(nonatomic,strong)void(^cancelHandler)(void);
+ (instancetype)instanceStateAlertWithSate:(NSInteger)state andInfoData:(NSArray<BetLotterysInfoModel *>*)lotteryInfo;
- (void)alertShowAnimationWithSuperView:(UIView *)superView;
-(void)dismissView;
@end

NS_ASSUME_NONNULL_END
