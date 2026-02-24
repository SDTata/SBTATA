//
//  LobbyLotteryMenuBarView.m
//  phonelive2
//
//  Created by user on 2023/12/19.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LobbyLotteryMenuBarView.h"
#import "LotteryNetworkUtil.h"
#import "LotteryCodeResultCell.h"
#import "LiveBetListYFKSCell.h"
#import "UIViewController+Alert.h"
#import "LotteryVoiceUtil.h"
#import "popWebH5.h"
#import "LobbyHistoryAlertController.h"
#import "SwitchLotteryViewController.h"
#import "OpenHistoryViewController.h"

@interface LobbyLotteryMenuBarView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *lastResultLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) VKBaseTableView *resultTableView;
@property (nonatomic, strong) VKBaseCollectionView *recordTableView;

@property (nonatomic, assign) NSInteger lotteryType;

@end

@implementation LobbyLotteryMenuBarView

- (instancetype)initWithType:(NSInteger)lotteryType
{
    self = [super init];
    if (self) {
        self.lotteryType = lotteryType;
        [self setupView];
    }
    return self;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        UIStackView *stackView = [UIStackView new];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.spacing = 5;
        [_scrollView addSubview:stackView];
        self.stackView = stackView;
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.height.mas_equalTo(self.scrollView);
        }];
        
        for (VKActionModel *m in self.itemArray) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.minimumScaleFactor = 0.3;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 30/2;
            [btn addTarget:self action:@selector(clickMenuAction:) forControlEvents:UIControlEventTouchUpInside];
            
            btn.selected = m.selected;
            btn.extraData = m;
            [btn setImage:[ImageBundle imagewithBundleName:m.icon] forState:UIControlStateNormal];
            [btn setImage:[ImageBundle imagewithBundleName:m.iconSelected] forState:UIControlStateSelected];
            [btn setImage:[ImageBundle imagewithBundleName:m.iconSelected] forState:UIControlStateSelected|UIControlStateHighlighted];
            [btn setTitle:m.title forState:UIControlStateSelected];
            [btn setTitle:m.title forState:UIControlStateSelected|UIControlStateHighlighted];
            
            [btn setBackgroundImage:vkColorImage(vkColorHexA(0x000000, 0.5), CGSizeMake(30, 30)) forState:UIControlStateNormal];
            [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"yfks_anniu2"] forState:UIControlStateSelected];
            [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"yfks_anniu2"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [stackView addArrangedSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(30);
            }];
        }
    }
    return _scrollView;
}

- (NSMutableArray *)itemArray {
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
        
        VKActionModel *m1 = [VKActionModel new];
        m1.title = YZMsg(@"trend_title");
        m1.icon = @"yfks_icon_zst";
        m1.action = @selector(clickM1Action:);
        [_itemArray addObject:m1];
        
        VKActionModel *m2 = [VKActionModel new];
        m2.title = YZMsg(@"LobbyLotteryVC_BetRecord");
        m2.icon = @"yfks_icon_tzjl";
        m2.action = @selector(clickM2Action:);
        [_itemArray addObject:m2];
        
        VKActionModel *m3 = [VKActionModel new];
        m3.title = YZMsg(@"menu_lottery_result");
        m3.icon = @"yfks_icon_kjjl";
        m3.action = @selector(clickM3Action:);
        [_itemArray addObject:m3];
        
        VKActionModel *m4 = [VKActionModel new];
        m4.icon = @"yfks_icon_wfsm";
        m4.action = @selector(clickM4Action:);
        [_itemArray addObject:m4];
        
//        VKActionModel *m5 = [VKActionModel new];
//        m5.icon = LotteryVoiceUtil.shared.muteImage;
//        m5.action = @selector(clickM5Action:);
//        [_itemArray addObject:m5];
        
        VKActionModel *m6 = [VKActionModel new];
        m6.icon = @"yfks_icon_lstz";
        m6.action = @selector(clickM6Action:);
        [_itemArray addObject:m6];
        
        if (!(self.lotteryType == 7 || self.lotteryType == 32)) {
            VKActionModel *m7 = [VKActionModel new];
            m7.icon = @"yfks_icon_qhxb";
            m7.action = @selector(clickM7Action:);
            [_itemArray addObject:m7];
        }
//        VKActionModel *m8 = [VKActionModel new];
//        m8.icon = @"yfks_icon_lw";
//        m8.action = @selector(clickM8Action:);
//        [_itemArray addObject:m8];
        
        VKActionModel *m9 = [VKActionModel new];
        m9.icon = @"yfks_icon_game";
        m9.action = @selector(clickM9Action:);
        [_itemArray addObject:m9];
        
//        VKActionModel *m10 = [VKActionModel new];
//        m10.icon = @"live_redpack";
//        m10.action = @selector(clickM10Action:);
//        [_itemArray addObject:m10];
    }
    return _itemArray;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _nameLabel;
}
- (UILabel *)timeTitleLabel {
    if (!_timeTitleLabel) {
        _timeTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeTitleLabel.textColor = UIColor.whiteColor;
        _timeTitleLabel.font = [UIFont systemFontOfSize:13];
        _timeTitleLabel.text = @"本期截止:";
    }
    return _timeTitleLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = UIColor.redColor;
        _timeLabel.font = [UIFont systemFontOfSize:13];
    }
    return _timeLabel;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logoImageView;
}

- (LotteryCodeView_Base *)codeView {
    if (!_codeView) {
        NSInteger type = [@[@32, @7, @8] containsObject: @(self.lotteryType)] ? 8 : self.lotteryType;
        _codeView = [LotteryCodeView_Base createWithType:type];
        [_codeView vk_addTapAction:self selector:@selector(clickOpenHistoryAction)];
    }
    return _codeView;
}

- (ChartView *)chartView {
    if (!_chartView) {
        _chartView = [ChartView instanceChatViewWithType:self.lotteryType];
        [_chartView updateMenueStr1:YZMsg(@"Chart_Area_big_small") Str2:YZMsg(@"Chart_Area_single_double")];
    }
    return _chartView;
}

- (VKBaseCollectionView *)recordTableView {
    if (!_recordTableView) {
        _recordTableView = [VKBaseCollectionView new];
        _recordTableView.registerCellClass = [LiveBetListYFKSCell class];
        
        [_recordTableView vk_headerRefreshSet];
        [_recordTableView vk_footerRefreshSet];
        [_recordTableView vk_showEmptyView];
        
        _weakify(self)
        _recordTableView.loadDataBlock = ^{
            _strongify(self)
            [LotteryNetworkUtil getBetRecords:self.lotteryType page:self.recordTableView.pageIndex status:-1 startTime:nil endTime:nil block:^(NetworkData *networkData) {
                _strongify(self)
                NSArray *array = [BetListDataModel arrayFromJson:networkData.data[@"list"]];
                [self.recordTableView vk_refreshFinish:array];
            }];
        };
    }
    return _recordTableView;
}

- (VKBaseTableView *)resultTableView {
    if (!_resultTableView) {
        _resultTableView = [VKBaseTableView new];
        _resultTableView.registerCellClass = [LotteryCodeResultCell class];
        _resultTableView.automaticDimension = NO;
        _resultTableView.itemHeight = 45;
        [_resultTableView vk_headerRefreshSet];
        [_resultTableView vk_footerRefreshSet];
        [_resultTableView vk_showEmptyView];
        
        _resultTableView.pageStart = 0;
        
        _weakify(self)
        _resultTableView.loadDataBlock = ^{
            _strongify(self)
            [LotteryNetworkUtil getOpenHistory:self.lotteryType page:self.resultTableView.pageIndex block:^(NetworkData *networkData) {
                _strongify(self)
                NSArray *array = [LotteryResultModel arrayFromJson:networkData.data[@"list"]];
                [array setValue:@(self.lotteryType != 8 ? 8 : self.lotteryType) forKeyPath:@"lotteryType"];
                [self.resultTableView vk_refreshFinish:array];
            }];
        };
    }
    return _resultTableView;
}

- (void)setupView {
    
    /// 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[ImageBundle imagewithBundleName:@"live_closed"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(clickCloseAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.height.mas_equalTo(30);
        make.top.mas_equalTo(0);
    }];
    
    /// 工具条
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(closeButton.mas_left).offset(-10);
        make.centerY.mas_equalTo(closeButton.mas_centerY);
        make.height.mas_equalTo(30);
    }];
    
    /// 游戏LOGO
    [self addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(10);
        make.top.mas_equalTo(self.scrollView.mas_bottom).offset(20);
        make.height.width.mas_equalTo(48);
    }];
    
    /// 游戏名称
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.logoImageView.mas_trailing).offset(10);
        make.top.mas_equalTo(self.logoImageView.mas_top);
        make.height.mas_equalTo(48);
    }];
    
    /// 最后一期开奖号码
    [self addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).offset(-10);
        //make.top.mas_equalTo(self.scrollView.mas_bottom).offset(20);
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    }];
    
    /// 最后一期日期
    _lastResultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _lastResultLabel.textColor = UIColor.whiteColor;
    _lastResultLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview: _lastResultLabel];
    [_lastResultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.codeView.mas_trailing).offset(-4);
        make.top.mas_equalTo(self.codeView.mas_bottom).offset(4);
    }];
    
    /// 截止标题
    [self addSubview:self.timeTitleLabel];
    [self.timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.logoImageView.mas_leading);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(2);
    }];
    
    /// 截止时间
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.timeTitleLabel.mas_trailing).offset(6);
        make.centerY.mas_equalTo(self.timeTitleLabel.mas_centerY);
        make.height.mas_equalTo(16);
    }];
    
    /// 走势图
    [self addSubview:self.chartView];
    [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(100);
    }];
    
    /// 投注记录
    [self addSubview:self.recordTableView];
    [self.recordTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(self.chartView);
    }];
    
    /// 开奖记录
    [self addSubview:self.resultTableView];
    [self.resultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(90);
        make.centerY.mas_equalTo(self.recordTableView.mas_centerY);
    }];
    
    /// 默认高度
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(240);
    }];
    
    /// 默认选中第一个
    [UIView performWithoutAnimation:^{
        [self clickMenuAction:self.stackView.arrangedSubviews.firstObject];
    }];
}

/// 点击菜单
- (void)clickMenuAction:(UIButton *)sender {
    VKActionModel *m = sender.extraData;
    [self runSelector:m.action object:sender];
}

/// 还原所有按钮宽度
- (void)resetView {
    for (UIButton *btn in self.stackView.arrangedSubviews) {
        btn.selected = NO;
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(30);
        }];
    }
}

/// 选中指定按钮
- (void)openView:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        [sender mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(90);
        }];
        sender.selected = !sender.selected;
        [sender layoutIfNeeded];
    }];
}

/// 隐藏所有视图
- (void)hideAllView {
    self.chartView.hidden = YES;
    self.recordTableView.hidden = YES;
    self.resultTableView.hidden = YES;
}

/// 走势图
- (void)clickM1Action:(UIButton *)sender {
    [self hideAllView];
    self.chartView.hidden = NO;
    [self resetView];
    [self openView:sender];
}

/// 投注记录
- (void)clickM2Action:(UIButton *)sender {
    [self hideAllView];
    self.recordTableView.hidden = NO;
    [self.recordTableView vk_headerBeginRefresh];
    [self resetView];
    [self openView:sender];
}

/// 开奖记录
- (void)clickM3Action:(UIButton *)sender {
    [self hideAllView];
    self.resultTableView.hidden = NO;
    [self.resultTableView vk_headerBeginRefresh];
    [self resetView];
    [self openView:sender];
}

/// 玩法说明
- (void)clickM4Action:(UIButton *)sender {
    popWebH5 *vc = [[popWebH5 alloc]init];
    vc.isBetExplain = YES;
    vc.isPresent = YES;
    vc.titles = YZMsg(@"LobbyLotteryVC_betExplain");
    NSString *url = [[DomainManager sharedInstance].domainGetString stringByAppendingFormat:@"index.php?g=Appapi&m=LotteryArticle&a=index&lotteryType=%@&uid=%@&token=%@",minnum(self.lotteryType), [Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    vc.urls = url;
    [vc showFromBottom];
}

/// 静音开关
- (void)clickM5Action:(UIButton *)sender {
    NSInteger muteValue = LotteryVoiceUtil.shared.muteValue;
    muteValue = (muteValue == 2) ? 0 : muteValue + 1;
    LotteryVoiceUtil.shared.muteValue = muteValue;
    [sender setImage:[ImageBundle imagewithBundleName:LotteryVoiceUtil.shared.muteImage] forState:UIControlStateNormal];
}

/// 投注历史
- (void)clickM6Action:(UIButton *)sender {
    LobbyHistoryAlertController *history = [[LobbyHistoryAlertController alloc]initWithNibName:@"LobbyHistoryAlertController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    history.view.frame = CGRectMake(0, _window_height, _window_width, _window_height);
    [vkTopVC().view addSubview:history.view];
    [vkTopVC() addChildViewController:history];
    history.view.frame = CGRectMake(0, 0, _window_width, _window_height);
    [history.view didMoveToSuperview];
    [history didMoveToParentViewController:vkTopVC()];
}

/// 切换游戏
- (void)clickM7Action:(UIButton *)sender {
    if (self.clickActionBlock) {
        self.clickActionBlock(1);
    }
}

/// 礼物
- (void)clickM8Action:(UIButton *)sender {
    
}

/// 游戏列表
- (void)clickM9Action:(UIButton *)sender {
    SwitchLotteryViewController *lottery = [[SwitchLotteryViewController alloc]initWithNibName:@"SwitchLotteryViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    lottery.isFromGameCenter = YES;
    lottery.lotteryDelegate = self.lotteryDelegate;
    lottery.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [vkTopVC() addChildViewController:lottery];
    [vkTopVC().view addSubview:lottery.view];
}

/// 红包
- (void)clickM10Action:(UIButton *)sender {
    
}

- (void)clickCloseAction {
    if (self.clickActionBlock) {
        self.clickActionBlock(0);
    }
}

- (void)clickOpenHistoryAction {
    OpenHistoryViewController *chipVC = [[OpenHistoryViewController alloc] initWithNibName:@"OpenHistoryViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    WeakSelf
    chipVC.closeCallback = ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    };
    [chipVC setLotteryType:self.lotteryType];
    [vkTopVC().view addSubview:chipVC.view];
    [vkTopVC() addChildViewController:chipVC];
}

- (void)setBetModel:(LotteryBetModel *)betModel {
    self.codeView.resultModel = betModel.lastResult;
    self.codeView.textListView.hidden = YES;
    if (![@[@32, @7, @8] containsObject: @(self.lotteryType)]) {
        self.codeView.textListView.hidden = NO;
    }
    self.nameLabel.text = betModel.name;
    _lastResultLabel.text = [NSString stringWithFormat:YZMsg(@"history_betTitle%@"),betModel.lastResult.issue];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:minstr(betModel.logo)]
                      options:1
                     progress:nil
                    completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        WeakSelf
        if (image && weakSelf !=nil) {
            [weakSelf.logoImageView setImage:image];
        }
    }];
}
- (void)setIconAndName:(NSString *)iconUrl withName: (NSString *)lotteryName {
    self.nameLabel.text = lotteryName;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:minstr(iconUrl)]
                      options: 1
                     progress: nil
                    completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        WeakSelf
        if (image && weakSelf != nil) {
            [weakSelf.logoImageView setImage:image];
        }
    }];
}
@end
