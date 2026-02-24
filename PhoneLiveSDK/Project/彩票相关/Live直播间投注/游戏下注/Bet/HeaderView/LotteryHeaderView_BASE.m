//
//  LotteryHeaderView_BASE.m
//  phonelive2
//
//  Created by vick on 2023/12/6.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryHeaderView_BASE.h"
#import "LotteryHeaderView_LHC.h"
#import "LotteryHeaderView_SSC.h"
#import "LotteryHeaderView_SC.h"
#import "LotteryHeaderView_YFKS.h"
#import "LotteryHeaderView_NN.h"
#import "LotteryHeaderView_BJL.h"
#import "LotteryHeaderView_ZJH.h"
#import "LotteryHeaderView_LH.h"
#import "LotteryHeaderView_ZP.h"

#import "OpenHistoryViewController.h"

@implementation LotteryHeaderView_BASE

+ (instancetype)createWithType:(NSInteger)type {
    switch (BetType(type)) {
        case LotteryBetTypeLHC:
            return [[LotteryHeaderView_LHC alloc] initWithType:type];
        case LotteryBetTypeSSC:
            return [[LotteryHeaderView_SSC alloc] initWithType:type];
        case LotteryBetTypeSC:
            return [[LotteryHeaderView_SC alloc] initWithType:type];
        case LotteryBetTypeYFKS:
            return [[LotteryHeaderView_YFKS alloc] initWithType:type];
        case LotteryBetTypeNN:
            return [[LotteryHeaderView_NN alloc] initWithType:type];
        case LotteryBetTypeBJL:
            return [[LotteryHeaderView_BJL alloc] initWithType:type];
        case LotteryBetTypeZJH:
            return [[LotteryHeaderView_ZJH alloc] initWithType:type];
        case LotteryBetTypeLH:
            return [[LotteryHeaderView_LH alloc] initWithType:type];
        case LotteryBetTypeZP:
            return [[LotteryHeaderView_ZP alloc] initWithType:type];
        default:
            return [[LotteryHeaderView_BASE alloc] initWithType:type];
    }
}

- (instancetype)initWithType:(NSInteger)type {
    self = [super init];
    if (self) {
        self.lotteryType = type;
        [self setupView];
    }
    return self;
}

- (UIButton *)gameNameButton {
    if (!_gameNameButton) {
        _gameNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _gameNameButton.titleLabel.font = vkFontBold(14);
        [_gameNameButton setTitleColor:vkColorRGB(224, 189, 157) forState:UIControlStateNormal];
        _gameNameButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        _gameNameButton.layer.cornerRadius = 5;
        _gameNameButton.layer.masksToBounds = YES;
        _gameNameButton.layer.borderWidth = 1.0;
        _gameNameButton.layer.borderColor = vkColorRGB(224, 189, 157).CGColor;
        _gameNameButton.userInteractionEnabled = NO;
        _gameNameButton.backgroundColor = vkColorHexA(0x000000, 0.3);
    }
    return _gameNameButton;
}

- (LotteryCodeView_Base *)codeView {
    if (!_codeView) {
        _codeView = [LotteryCodeView_Base createWithType:self.lotteryType];
        _codeView.backgroundColor = vkColorHexA(0x000000, 0.3);
        _codeView.layer.cornerRadius = 5;
        _codeView.layer.masksToBounds = YES;
        _codeView.textListView.hidden = YES;
        [_codeView vk_addTapAction:self selector:@selector(clickOpenHistoryAction)];
    }
    return _codeView;
}

- (LotteryCodePopView_Base *)popCodeView {
    if (!_popCodeView) {
        _popCodeView = [LotteryCodePopView_Base new];
    }
    return _popCodeView;
}

- (void)setupView {
    
    /// 游戏名称
    [self addSubview:self.gameNameButton];
    [self.gameNameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(5);
    }];
    
    /// 开奖号码
    [self addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(5);
    }];
    
    self.showAnimateTime = 0;
}

- (void)setBetModel:(LotteryBetModel *)betModel {
    _betModel = betModel;
    
    [self.gameNameButton setTitle:betModel.name forState:UIControlStateNormal];
    self.codeView.resultModel = betModel.lastResult;
}

#pragma mark - 开始投注
- (void)doStart {
    [self.popCodeView removeFromSuperview];
    self.popCodeView = nil;
}

#pragma mark - 结束投注
- (void)doStop {
    
}

- (void)doPreAnimate {
    
}

#pragma mark - 开奖
- (void)doWin:(NSDictionary *)win {
    self.chartValue = win[@"result"];
    
    /// 悬浮开奖弹窗
    self.popCodeView.hidden = YES;
    [self addSubview:self.popCodeView];
    [self.popCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_bottom).offset(30);
    }];
    
    NSArray *winWays = win[@"winWays"];
    NSMutableArray *results = [NSMutableArray array];
    for (LotteryWayModel *way in self.betModel.ways) {
        if ([self.showKeys containsObject:way.name]) {
            for (LotteryOptionModel *op in way.options) {
                if ([winWays containsObject:op.title] && [self.showKeys containsObject:op.title]) {
                    [results addObject:op.st];
                }
            }
        }
    }
    self.popCodeView.result = [results componentsJoinedByString:@" "];
    
    _weakify(self)
    vkGcdAfter(self.showAnimateTime, ^{
        _strongify(self)
        self.popCodeView.hidden = NO;
        self.popCodeView.lotteryType = self.lotteryType;
        self.popCodeView.resultDict = win;
        self.codeView.resultDict = win;
    });
}

/// 开奖历史
- (void)clickOpenHistoryAction {
    OpenHistoryViewController *chipVC = [[OpenHistoryViewController alloc] initWithNibName:@"OpenHistoryViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    [chipVC setLotteryType:self.lotteryType];
    [vkTopVC().view addSubview:chipVC.view];
    [vkTopVC() addChildViewController:chipVC];
}

@end
