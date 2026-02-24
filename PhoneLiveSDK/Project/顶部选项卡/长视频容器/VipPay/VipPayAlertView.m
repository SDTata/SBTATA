//
//  VipPayAlertView.m
//  phonelive2
//
//  Created by vick on 2025/2/10.
//  Copyright © 2025 toby. All rights reserved.
//

#import "VipPayAlertView.h"
#import "VipPayAlertCell.h"
#import "VipPayModel.h"

@interface VipPayAlertView ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, strong) UIView *topBackView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) UIButton *openButton;

@property (nonatomic, strong) VipPayModel *vipModel;
@property (nonatomic, strong) VipPayListModel *selectItem;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation VipPayAlertView

- (BOOL)alertPresentationVC {
    return NO;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self loadListData];
    }
    return self;
}

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.viewStyle = VKCollectionViewStyleHorizontal;
        _tableView.registerCellClass = [VipPayAlertCell class];
        
        WeakSelf
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, VipPayListModel *item) {
            STRONGSELF
            if (!strongSelf) return;
            [strongSelf.tableView selectIndexPath:indexPath key:@"selected"];
            strongSelf.selectItem = item;
            [strongSelf refreshAmountData];
        };
    }
    return _tableView;
}

- (void)setupView {
    self.backgroundColor = vkColorHex(0xF0F0F0);
    [self vk_border:nil cornerRadius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
        make.height.mas_equalTo(VKPX(350));
    }];
    
    UIView *topBackView = [UIView new];
    [self addSubview:topBackView];
    self.topBackView = topBackView;
    [topBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"vip_pay_title") font:vkFontBold(18) color:vkColorHex(0x111118)];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(24);
    }];
    
    UILabel *nameLabel = [UIView vk_label:nil font:vkFont(12) color:vkColorHex(0x919191)];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_left);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(8);
    }];
    
    UIButton *closeButton = [UIView vk_buttonImage:@"pay_alert_close" selected:nil];
    [closeButton vk_addTapAction:self selector:@selector(clickCloseAction)];
    [self addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(14);
        make.size.mas_equalTo(30);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(nameLabel.mas_bottom).offset(14);
        make.height.mas_equalTo(VipPayAlertCell.itemHeight);
    }];
    
    UILabel *balanceLabel = [UIView vk_label:nil font:vkFont(12) color:vkColorHex(0x919191)];
    [self addSubview:balanceLabel];
    self.balanceLabel = balanceLabel;
    [balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableView.mas_left);
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(14);
    }];
    
    UIButton *openButton = [UIView vk_button:YZMsg(@"VIP_Activate_now") image:nil font:vkFontBold(16) color:vkColorHex(0x382814)];
    [openButton vk_border:nil cornerRadius:23];
    [self addSubview:openButton];
    self.openButton = openButton;
    [openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(22);
        make.right.mas_equalTo(-22);
        make.bottom.mas_equalTo(-50);
        make.height.mas_equalTo(46);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topBackView.verticalColors = @[vkColorHex(0xFFE9CC), vkColorHex(0xF0F0F0)];
    self.openButton.horizontalColors = @[vkColorHex(0xFFD883), vkColorHex(0xFFC663)];
}

- (void)loadListData {
    WeakSelf
    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [LotteryNetworkUtil getVipListBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        [strongSelf.hud hideAnimated:YES];
        strongSelf.hud = nil;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        VipPayModel *model = [VipPayModel modelFromJSON:networkData.data];
        strongSelf.vipModel = model;
        strongSelf.tableView.dataItems = model.vip_list.mutableCopy;
        [strongSelf.tableView reloadData];
        [strongSelf.tableView setDefalutIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        NSMutableAttributedString *nameText = [NSMutableAttributedString new];
        [nameText vk_appendString:[NSString stringWithFormat:@"%@:", YZMsg(@"vip_open_account")] color:vkColorHex(0x919191)];
        [nameText vk_appendString:model.user.user_nicename color:vkColorHex(0x111118)];
        [nameText vk_appendString:[NSString stringWithFormat:@"(%@)", model.user.id_] color:vkColorHex(0x111118)];
        strongSelf.nameLabel.attributedText = nameText;
    }];
}

- (void)refreshAmountData {
    if (self.vipModel.user.coin.floatValue >= self.selectItem.coin.floatValue) {
        [self.openButton setTitle:YZMsg(@"VIP_Activate_now") forState:UIControlStateNormal];
        [self.openButton vk_addTapAction:self selector:@selector(clickOpenAction)];
        
        NSMutableAttributedString *balanceText = [NSMutableAttributedString new];
        [balanceText vk_appendString:[NSString stringWithFormat:@"%@:", YZMsg(@"exchangeVC_balance")] color:vkColorHex(0x919191)];
        [balanceText vk_appendString:[NSString toAmount:self.vipModel.user.coin].toRate.toUnit color:vkColorHex(0x111118)];
        self.balanceLabel.attributedText = balanceText;
        
    } else {
        [self.openButton setTitle:YZMsg(@"vip_open_title") forState:UIControlStateNormal];
        [self.openButton vk_addTapAction:self selector:@selector(clickToRecharge)];
        
        NSMutableAttributedString *balanceText = [NSMutableAttributedString new];
        [balanceText vk_appendString:YZMsg(@"vip_pay_ballance") color:vkColorHex(0x919191)];
        [balanceText vk_appendString:[NSString stringWithFormat:@"(%@:%@)", YZMsg(@"LobbyBetConfirm_balance"), [NSString toAmount:self.vipModel.user.coin].toRate.toUnit] color:vkColorHex(0x111118)];
        [balanceText vk_appendString:@"|" color:vkColorHex(0x919191)];
        [balanceText vk_appendString:[NSString stringWithFormat:@"%@:%@", YZMsg(@"vip_pay_need_amount"), [[NSString toAmount:self.selectItem.coin] toSub:self.vipModel.user.coin].toRate.toUnit] color:vkColorHex(0x111118)];
        self.balanceLabel.attributedText = balanceText;
    }
}

- (void)clickCloseAction {
    [self hideAlert:nil];
}

- (void)clickToRecharge {
    [self hideAlert:nil];
    [YBUserInfoManager.sharedManager pushToRecharge];
}

- (void)clickOpenAction {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getVipPay:self.selectItem.id_ block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD showSuccess:YZMsg(@"PayVC_PaySuccess")];
        vkGcdAfter(1.0, ^{
            [strongSelf hideAlert:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:KGetBaseInfoNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:KVipPayNotificationMsg object:nil];
        });
    }];
}

@end
