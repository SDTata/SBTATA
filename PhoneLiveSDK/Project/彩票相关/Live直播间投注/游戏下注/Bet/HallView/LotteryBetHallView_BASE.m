//
//  LotteryBetHallView_BASE.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetHallView_BASE.h"
#import "LotteryHallBaseCell.h"
#import "LotteryBetHallView_LHC.h"
#import "LotteryBetHallView_SSC.h"
#import "LotteryBetHallView_SC.h"
#import "LotteryBetHallView_YFKS.h"
#import "LotteryBetHallView_NN.h"
#import "LotteryBetHallView_BJL.h"
#import "LotteryBetHallView_ZJH.h"
#import "LotteryBetHallView_LH.h"
#import "LotteryBetHallView_ZP.h"
#import "BetConfirmViewController.h"

#import "LotteryBetSubView.h"
#import "LotteryChipSubView.h"
#import "LotteryNetworkUtil.h"
#import "LotteryVoiceUtil.h"

#define kHallSubViewTag 1000
#define kBetSubViewTag 10000
#define kChipSubViewTag 20000

@interface LotteryBetHallView_BASE ()

/// 续投数据
@property (nonatomic, strong) NSMutableDictionary *continueDict;

@end

@implementation LotteryBetHallView_BASE

+ (instancetype)createWithType:(NSInteger)type {
    switch (BetType(type)) {
        case LotteryBetTypeLHC:
            return [LotteryBetHallView_LHC new];
        case LotteryBetTypeSSC:
            return [LotteryBetHallView_SSC new];
        case LotteryBetTypeSC:
            return [LotteryBetHallView_SC new];
        case LotteryBetTypeYFKS:
            return [LotteryBetHallView_YFKS new];
        case LotteryBetTypeNN:
            return [LotteryBetHallView_NN new];
        case LotteryBetTypeBJL:
            return [LotteryBetHallView_BJL new];
        case LotteryBetTypeZJH:
            return [LotteryBetHallView_ZJH new];
        case LotteryBetTypeLH:
            return [LotteryBetHallView_LH new];
        case LotteryBetTypeZP:
            return [LotteryBetHallView_ZP new];
        default:
            return [LotteryBetHallView_BASE new];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (NSMutableDictionary *)continueDict {
    if (!_continueDict) {
        _continueDict = [NSMutableDictionary dictionary];
    }
    return _continueDict;
}

- (void)setupView {
    self.layer.masksToBounds = YES;
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UIStackView *betStackView = [UIStackView new];
    betStackView.axis = UILayoutConstraintAxisVertical;
    betStackView.spacing = 5;
    [scrollView addSubview:betStackView];
    self.betStackView = betStackView;
    [betStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.mas_equalTo(scrollView);
    }];
}

- (void)setBetModel:(LotteryBetModel *)betModel {
    _betModel = betModel;
    
    for (int i=0; i<self.views.count; i++) {
        LotteryHallBaseCell *view = self.views[i];
        NSString *superKey = view.superKey;
        NSString *key = view.key;
        LotteryWayModel *way = [betModel.ways filterBlock:^BOOL(LotteryWayModel *object) {
            return [object.name isEqualToString:superKey];
        }].firstObject;
        LotteryOptionModel *op = [way.options filterBlock:^BOOL(LotteryOptionModel *object) {
            return (object.name && [key containsString:object.name]) || [key isEqualToString:object.title];
        }].firstObject;
        LotteryOptionModel *sub = [op.data filterBlock:^BOOL(LotteryOptionModel *object) {
            return [key isEqualToString:object.title];
        }].firstObject;
        view.optionModel = !op.data ? op : sub;
        
        [view vk_addTapAction:self selector:@selector(clickBetAction:)];
        view.tag = kHallSubViewTag + i;
    }
    
    /// 显示已投注过的筹码
    WeakSelf
    vkGcdAfter(0.0, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        for (LotteryHallBaseCell *view in strongSelf.views) {
            if (view.optionModel.betlist.count > 0) {
                for (NSString *money in view.optionModel.betlist) {
                    LotteryChipSubView *chipSubView = [strongSelf addChipSubView:view money:money];
                    chipSubView.selected = YES;
                }
            }
            if (view.optionModel.betmine > 0) {
                LotteryBetSubView *betSubView = [strongSelf showBetSubView:view];
                [betSubView sureBetView];
                [betSubView updateMineNumb:view.optionModel.betmine];
            }
        }
    });
}

- (void)clickBetAction:(UITapGestureRecognizer *)tap {
    LotteryHallBaseCell *view = (LotteryHallBaseCell *)tap.view;
    [self addChipSubView:view money:[NSString stringWithFormat:@"%.2f", self.chipModel.chipNumber]];
}

/// 显示下注弹窗
- (LotteryBetSubView *)showBetSubView:(LotteryHallBaseCell *)view {
    [self eachBetSubViewsBlock:^(LotteryBetSubView *view) {
        view.isHiddenTopView = YES;
    }];
    LotteryBetSubView *betSubView = [self viewWithTag:kBetSubViewTag + view.tag];
    if (!betSubView) {
        _weakify(self)
        betSubView = [LotteryBetSubView instanceLotteryBetSubViewwWithFrame:CGRectZero contentEdge:3 withBlock:^(BOOL sure) {
            _strongify(self)
            if (sure) {
                [self doBet];
            } else {
                [self clearBetViewInfo:NO];
            }
        }];
        betSubView.layer.zPosition = 2;
        betSubView.tag = kBetSubViewTag + view.tag;
        [self addSubview:betSubView];
        [betSubView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(view.mas_centerX);
            make.centerY.mas_equalTo(view.mas_centerY);
            make.height.mas_equalTo(VKPX(40));
            make.width.mas_equalTo(VKPX(60));
        }];
    }
    [betSubView addBetNum:[NSString stringWithFormat:@"%.2f", self.chipModel.chipNumber] ways:view.key];
    return betSubView;
}

/// 添加筹码
- (LotteryChipSubView *)addChipSubView:(LotteryHallBaseCell *)view money:(NSString *)money {
    [self showBetSubView:view];
    LotteryChipSubView *chipSubView = [LotteryChipSubView new];
    chipSubView.isEdit = self.chipModel.isEdit;
    chipSubView.money = money;
    chipSubView.layer.zPosition = 1;
    chipSubView.tag = kChipSubViewTag + view.tag;
    [self addSubview:chipSubView];
    [chipSubView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_bottom);
    }];
    [self layoutIfNeeded];
    
    /// 筹码移动动画
    _weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        _strongify(self)
        NSInteger x = vkRandomNumber(0, CGRectGetWidth(view.frame)-CGRectGetWidth(chipSubView.frame));
        NSInteger y = vkRandomNumber(0, CGRectGetHeight(view.frame)-CGRectGetHeight(chipSubView.frame));
        [chipSubView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view.mas_left).offset(x);
            make.top.mas_equalTo(view.mas_top).offset(y);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [LotteryVoiceUtil.shared startPlayHint:@"jiafamaaudio"];
    }];
    
    return chipSubView;
}

/// 遍历弹窗
- (void)eachBetSubViewsBlock:(void(^)(LotteryBetSubView *view))block {
    for (LotteryBetSubView *view in self.subviews) {
        if (view.tag > kBetSubViewTag && view.tag < kChipSubViewTag) {
            !block ?: block(view);
        }
    }
}

/// 遍历筹码
- (void)eachChipSubViewsBlock:(void(^)(LotteryChipSubView *view))block {
    for (LotteryChipSubView *view in self.subviews) {
        if (view.tag > kChipSubViewTag) {
            !block ?: block(view);
        }
    }
}

/// 清空
- (void)clearBetViewInfo:(BOOL)isAllClear {
    for (LotteryHallBaseCell *view in self.views) {
        [view hideWinAnimation];
    }
    [self eachBetSubViewsBlock:^(LotteryBetSubView *view) {
        [view clearBetView];
    }];
    [self eachChipSubViewsBlock:^(LotteryChipSubView *view) {
        if (isAllClear || !view.selected) {
            [view removeFromSuperview];
        }
    }];
}

/// 投注
- (void)doBet {
    
    LiveUser *user = [Config myProfile];
    CGFloat balance = [user.coin floatValue] / 10;
    if (self.chipModel.chipNumber > balance) {
        [MBProgressHUD showError:YZMsg(@"LobbyLotteryVC_NoBalanceDetailDes")];
        return;
    }
    
    NSMutableArray *orders = [NSMutableArray array];
    [self eachBetSubViewsBlock:^(LotteryBetSubView *view) {
        view.isHiddenTopView = YES;
        [orders addObjectsFromArray:view.betInfos];
    }];
    
    NSMutableDictionary *order = [NSMutableDictionary dictionary];
    for (int i=0; i<orders.count; i++) {
        NSString *title = orders[i][@"way"];
        NSInteger _money = [orders[i][@"rmbMoney"] integerValue] * 1;
        NSInteger lastmoney = 0;
        if ([order objectForKey:title] ) {
            lastmoney = [[order objectForKey:title] integerValue];
        }
        lastmoney = lastmoney+_money;
        [order setObject:[NSString stringWithFormat:@"%ld",(long)lastmoney] forKey:title];
    }
    NSInteger liveuid = [GlobalDate getLiveUID];
  
    
    _weakify(self)
    [LotteryNetworkUtil getBetting:self.betModel.lotteryType liveId:liveuid issue:self.betModel.issue way:order.allKeys money:order.allValues block:^(NetworkData *networkData) {
        _strongify(self)
        if (!networkData.status) {
            [self clearBetViewInfo:NO];
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        
        [self eachChipSubViewsBlock:^(LotteryChipSubView *view) {
            view.selected = YES;
        }];
        
        [self eachBetSubViewsBlock:^(LotteryBetSubView *view) {
            if(view.isHiddenTopView){
                [view sureBetView];
            }
        }];
        
        /// 保存续投数据
        for (NSString *key in order.allKeys) {
            NSString *value = order[key];
            NSMutableArray *values = [NSMutableArray array];
            [values addObjectsFromArray:self.continueDict[key]];
            [values addObject:value];
            self.continueDict[key] = values;
        }
        
        VKBLOCK(self.clickBetBlock);
        
        /// 余额更新通知
        NSString *left_coin = minstr(networkData.data[@"left_coin"]);
        [NSNotificationCenter.defaultCenter postNotificationName:@"moneyChange" object:nil userInfo:@{@"money": left_coin}];
    }];
}

/// 续投
- (void)doContinue {
    if (self.continueDict.count <= 0) {
        return;
    }
    for (NSString *key in self.continueDict.allKeys) {
        NSArray *values = self.continueDict[key];
        LotteryHallBaseCell *view = [self.views vk_filter:@"key = %@ ", key].firstObject;
        for (NSString *value in values) {
            [self addChipSubView:view money:value];
        }
    }
}

/// 投注记录续投
- (void)doContinue:(BetListDataModel *)model {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [model.detail.way enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LotteryHallBaseCell *view = [self.views vk_filter:@"key = %@ ", obj].firstObject;
        if (view) {
            view.extraData = model.detail.money[idx];
            results[obj] = view;
        }
    }];
    
    /// 使用旧版投注
    if (results.count < model.detail.way.count) {
        [self clickHistoryBetActionOld:model];
        return;
    }
    
    for (NSString *key in results.allKeys) {
        LotteryHallBaseCell *view = results[key];
        [self addChipSubView:view money:view.extraData];
    }
}

/// 旧版投注弹窗
- (void)clickHistoryBetActionOld:(BetListDataModel *)item {
    BetConfirmViewController *betConfirmVC = [[BetConfirmViewController alloc] initWithNibName:@"BetConfirmViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    UIView *shadowView = [YBToolClass mengban:self.superview clickCallback:^{
        [betConfirmVC.view removeFromSuperview];
        [betConfirmVC removeFromParentViewController];
    }];
    
    NSString *selectedName = @"";
    NSString *selectedNameSt = @"";
    
    NSMutableArray *orders = [NSMutableArray array];
    NSArray *moneys = item.detail.money;
    [item.detail.way enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *order = [NSMutableDictionary dictionary];
        order[@"way"] = obj;
        order[@"money"] = moneys[idx];
        [orders addObject:order];
    }];
    
    NSDictionary *orderInfo = @{
        @"name": self.betModel.name,
        @"optionName": selectedName,
        @"optionNameSt": selectedNameSt,
        @"lotteryType": [NSString stringWithFormat:@"%ld", self.betModel.lotteryType],
        @"issue": self.betModel.issue,
        @"betLeftTime": [NSString stringWithFormat:@"%ld", self.betModel.time],
        @"sealingTime": [NSString stringWithFormat:@"%ld", self.betModel.sealingTim],
        @"orders": orders,
    };
    
    [betConfirmVC setOrderInfo:orderInfo];
    
    __weak BetConfirmViewController *weakVC = betConfirmVC;
    betConfirmVC.betBlock = ^(NSInteger idx, NSUInteger num){
        [shadowView removeFromSuperview];
        [weakVC.view removeFromSuperview];
        [weakVC removeFromParentViewController];
        
        /// 余额更新通知
        NSString *left_coin = [Config myProfile].coin;
        [NSNotificationCenter.defaultCenter postNotificationName:@"moneyChange" object:nil userInfo:@{@"money": left_coin}];
    };
    [self.superview addSubview:betConfirmVC.view];
    betConfirmVC.view.bottom = self.superview.bottom;
    [vkTopVC() addChildViewController:betConfirmVC];
}

#pragma mark - 开始投注
- (void)doStart {
    self.userInteractionEnabled = YES;
    [self clearBetViewInfo:YES];
}

#pragma mark - 结束投注
- (void)doStop {
    self.userInteractionEnabled = NO;
    [self clearBetViewInfo:NO];
}

#pragma mark - 开奖
- (void)doWin:(NSDictionary *)wins {
    
    [LotteryVoiceUtil.shared startPlayHint:@"opengameresultaudio"];
    
    /// 移除确认弹窗
    [self eachBetSubViewsBlock:^(LotteryBetSubView *view) {
        [view removeFromSuperview];
    }];
    
    /// 赢方和输方
    NSMutableArray *winViews = [NSMutableArray array];
    NSMutableArray *loseViews = [NSMutableArray array];
    NSArray *winWays = wins[@"winWays"];
    for (LotteryHallBaseCell *view in self.views) {
        if ([winWays containsObject:view.key]) {
            [view hideWinAnimation];
            [view showWinAnimation];
            [winViews addObject:view];
        } else {
            [loseViews addObject:view];
        }
    }
    
    /// 所有筹码
    NSMutableArray *chipSubViews = [NSMutableArray array];
    [self eachChipSubViewsBlock:^(LotteryChipSubView *view) {
        [chipSubViews addObject:view];
    }];
    
    if (!chipSubViews.count) {
        return;
    }
    
    /// 收掉输方筹码
    _weakify(self)
    vkGcdAfter(1.0, ^{
        _strongify(self)
        [self chipsMoveToLoser:chipSubViews];
    });
    
    /// 输方筹码飞到赢方
    vkGcdAfter(2.0, ^{
        _strongify(self)
        [self chipsMoveToWinner:chipSubViews winViews:winViews];
    });
    
    /// 所有筹码飞到玩家
    vkGcdAfter(3.0, ^{
        _strongify(self)
        [self chipsMoveToPlayer:chipSubViews];
    });
}

/// 收掉输方筹码
- (void)chipsMoveToLoser:(NSArray *)chipSubViews {
    _weakify(self)
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _strongify(self)
        [chipSubViews mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.mas_top);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [LotteryVoiceUtil.shared startPlayHint:@"shoufamaaudio"];
    }];
}

/// 输方筹码飞到赢方
- (void)chipsMoveToWinner:(NSArray *)chipSubViews winViews:(NSArray *)winViews {
    _weakify(self)
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _strongify(self)
        NSArray *array = [chipSubViews sliceTo:winViews.count];
        for (NSInteger i=0; i<array.count; i++) {
            NSArray *chipViews = [array safeObjectWithIndex:i];
            UIView *winView = [winViews safeObjectWithIndex:i];
            for (UIView *chipSubView in chipViews) {
                NSInteger x = vkRandomNumber(0, CGRectGetWidth(winView.frame)-CGRectGetWidth(chipSubView.frame));
                NSInteger y = vkRandomNumber(0, CGRectGetHeight(winView.frame)-CGRectGetHeight(chipSubView.frame));
                [chipSubView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(winView.mas_left).offset(x);
                    make.top.mas_equalTo(winView.mas_top).offset(y);
                }];
            }
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [LotteryVoiceUtil.shared startPlayHint:@"shoufamaaudio"];
    }];
}

/// 所有筹码飞到玩家
- (void)chipsMoveToPlayer:(NSArray *)chipSubViews {
    _weakify(self)
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _strongify(self)
        [chipSubViews mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
            make.top.mas_equalTo(self.mas_bottom);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [LotteryVoiceUtil.shared startPlayHint:@"shoufamaaudio"];
    }];
}

@end
