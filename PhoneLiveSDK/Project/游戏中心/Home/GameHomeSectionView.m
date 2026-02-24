//
//  GameHomeSectionView.m
//  phonelive2
//
//  Created by vick on 2024/10/7.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameHomeSectionView.h"
#import "VKMarqueeView.h"
#import "myWithdrawVC2.h"
#import "exchangeVC.h"
#import "PayViewController.h"
#import "GameMoreListVC.h"
#import "webH5.h"
#import <UMCommon/UMCommon.h>

@interface GameHomeSectionView ()

@property (nonatomic, strong) VKMarqueeView *marqueeView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, strong) NSArray *marqueeDatas;

@end

@implementation GameHomeSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setTextBalance];
        [self refreshBtnClick];
       
    }
    return self;
}

- (void)setupView {
    UIView *marqueeBackView = [UIView new];
    [self addSubview:marqueeBackView];
    [marqueeBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    {
        UIImageView *iconView = [UIImageView new];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [iconView setImage:[ImageBundle imagewithBundleName:@"game_gg"]];
        [marqueeBackView addSubview:iconView];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.size.mas_equalTo(25);
        }];
        
        [marqueeBackView addSubview:self.marqueeView];
        [self.marqueeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(iconView.mas_right).offset(5);
            make.right.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
    }
    
    UIView *bottomView = [UIView new];
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(marqueeBackView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(60);
    }];
    {
        UILabel *nickNameLabel = [UIView vk_label:nil font:vkFont(12) color:vkColorHex(0x97a4b0)];
        [bottomView addSubview:nickNameLabel];
        self.nickNameLabel = nickNameLabel;
        [nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(bottomView.mas_centerY).offset(-3);
        }];
        
        UILabel *balanceLabel = [UIView vk_label:nil font:vkFontBold(18) color:UIColor.blackColor];
        [bottomView addSubview:balanceLabel];
        self.balanceLabel = balanceLabel;
        [balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(bottomView.mas_centerY).offset(3);
        }];
        
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        refreshBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [refreshBtn setImage:[ImageBundle imagewithBundleName:@"game_sx"] forState:UIControlStateNormal];
        [refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:refreshBtn];
        [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(balanceLabel.mas_right).offset(5);
            make.size.mas_equalTo(30);
            make.centerY.mas_equalTo(balanceLabel.mas_centerY);
        }];
        
        [bottomView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.width.mas_equalTo(60*4);
            make.top.bottom.mas_equalTo(0);
        }];
    }
}

- (void)reloadMarqueeData:(NSString *)gameTip {
    NSArray *system_msg = @[gameTip];
    NSMutableArray *arrayStr = [NSMutableArray array];
    for (NSString *subStr in system_msg) {
        NSString *stringMuta = @"";
        NSArray *subStrA = [subStr componentsSeparatedByString:@"\n"];
        for (NSString *subStr in subStrA) {
            stringMuta = [[stringMuta stringByAppendingString:subStr] stringByAppendingString:@"  "];
        }
        
        [arrayStr addObject:stringMuta];
    }
    if(system_msg.count > 0){
        self.marqueeView.titles  = arrayStr;
    }else{
        self.marqueeView.titles  = [NSMutableArray arrayWithArray:@[@" "]];
    }
   
   
}

#pragma mark - Action
- (void)refreshBtnClick {
    [MBProgressHUD showMessage:nil];
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"User.getWithdraw&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            LiveUser *user = [Config myProfile];
            user.coin = minstr([infoDic valueForKey:@"coin"]);
            [Config updateProfile:user];
            [strongSelf setTextBalance];
            NSString *gameTip = [infoDic objectForKey:@"gameTip"];
            [strongSelf reloadMarqueeData:gameTip];
            [strongSelf updateSystemMsg];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"金额刷新"};
    [MobClick event:@"game_page_menue_click" attributes:dict];
}

-(void)updateSystemMsg{
   
    NSString *getWithdrawUrl = [NSString stringWithFormat:@"Home.getMarqueeContent&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getWithdrawUrl withBaseDomian:YES andParameter:@{@"type":@"game_center"} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = [info firstObject];
            NSString *gameTip = [infoDic objectForKey:@"content"];
            [strongSelf reloadMarqueeData:gameTip];
        }else{
//            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
    }];
}

-(void)setTextBalance{
    LiveUser *user = [Config myProfile];
    self.nickNameLabel.text = user.user_nicename;
    self.balanceLabel.text = [NSString toAmount:user.coin].toDivide10.toRate.toUnit;
}

- (void)clickRechargeAction {
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [[MXBADelegate sharedAppDelegate] pushViewController:payView animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"充值"};
    [MobClick event:@"game_page_menue_click" attributes:dict];
}

- (void)clickWithDrawAction {
    myWithdrawVC2 *withdraw = [[myWithdrawVC2 alloc]init];
    withdraw.titleStr = YZMsg(@"public_WithDraw");
    [[MXBADelegate sharedAppDelegate] pushViewController:withdraw animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"提现"};
    [MobClick event:@"game_page_menue_click" attributes:dict];
}

- (void)clickGameReportAction {
    if (_gameReportDic) {
        NSString *url = [_gameReportDic objectForKey:@"href"];
        webH5 *VC = [[webH5 alloc]init];
        VC.titles = YZMsg(minstr([_gameReportDic valueForKey:@"name"]));
        url = [YBToolClass decodeReplaceUrl:url];
        VC.urls = url;
        [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"event_detail": @"报表"};
        [MobClick event:@"game_page_menue_click" attributes:dict];
    }
}

- (void)clickBackAmountAction {
    [MBProgressHUD showMessage:YZMsg(@"exchangeVC_OneKeyBack")];
    WeakSelf
    [GameToolClass backAllCoin:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        if (code == 0 && info && ![info isEqual:[NSNull null]]) {
            NSDictionary *infoDic = info;
            if([infoDic isKindOfClass:[NSArray class]]){
                infoDic =  [info firstObject];
            }
            LiveUser *user = [Config myProfile];
            user.coin =  minstr([infoDic valueForKey:@"coin"]);
            [Config updateProfile:user];
            [strongSelf setTextBalance];
            [MBProgressHUD showSuccess:YZMsg(@"myRechargeCoinVC_OptionSuccess")];
        }else if(msg && ![msg isEqual:[NSNull null]]&& msg.length > 0){
            
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"一键归集"};
    [MobClick event:@"game_page_menue_click" attributes:dict];
}

#pragma mark - lazy
- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [VKActionGridCell class];
        _tableView.scrollEnabled = NO;
        _tableView.itemHeight = 60;
        
        _weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, VKActionModel *item) {
            _strongify(self)
            [self runSelector:item.action];
        };
        
        CGSize size = CGSizeMake(30, 30);
        NSMutableArray *results = [NSMutableArray array];
        [results addObject:({
            VKActionModel *m = [VKActionModel new];
            m.title = YZMsg(@"Bet_Charge_Title");
            m.icon = @"game_cz";
            m.action = @selector(clickRechargeAction);
            m.iconSize = size;
            m.titleFont = vkFont(12);
            m;
        })];
        [results addObject:({
            VKActionModel *m = [VKActionModel new];
            m.title = YZMsg(@"public_WithDraw");
            m.icon = @"game_tixian";
            m.action = @selector(clickWithDrawAction);
            m.iconSize = size;
            m.titleFont = vkFont(12);
            m;
        })];
        [results addObject:({
            VKActionModel *m = [VKActionModel new];
            m.title = YZMsg(@"GameCenter_List");
            m.icon = @"game_bb";
            m.action = @selector(clickGameReportAction);
            m.iconSize = size;
            m.titleFont = vkFont(12);
            m;
        })];
        [results addObject:({
            VKActionModel *m = [VKActionModel new];
            m.title = YZMsg(@"exchangeVC_OneKeyBack");
            m.icon = @"game_yjgj";
            m.action = @selector(clickBackAmountAction);
            m.iconSize = size;
            m.titleFont = vkFont(12);
            m;
        })];
        _tableView.dataItems = results;
    }
    return _tableView;
}

- (VKMarqueeView *)marqueeView {
    if (!_marqueeView) {
        _marqueeView = [VKMarqueeView new];
        _marqueeView.textColor = UIColor.blackColor;
        _marqueeView.font = vkFont(14);
        
        WeakSelf
        _marqueeView.clickBlock = ^(NSInteger index) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf.marqueeView.titles != nil && strongSelf.marqueeView.titles.count>0) {
                vkAlert(YZMsg(@"public_systemMsgTitle"), strongSelf.marqueeView.titles[index], @[YZMsg(@"publictool_sure")], nil);
            }else{
                NSArray *system_msg = [common getSystemMsg];
                NSString *text = [system_msg componentsJoinedByString:@"\n"];
                vkAlert(YZMsg(@"public_systemMsgTitle"), text, @[YZMsg(@"publictool_sure")], nil);
            }
           
           
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"event_detail": @"公告"};
            [MobClick event:@"game_page_menue_click" attributes:dict];
        };
    }
    return _marqueeView;
}

@end
