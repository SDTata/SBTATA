//
//  VideoPayCoverView.m
//  phonelive2
//
//  Created by vick on 2024/7/11.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoPayCoverView.h"
#import "VideoVipAlertView.h"
#import "VideoPayAlertView.h"
#import "VipPayAlertView.h"

@implementation VideoPayCoverView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame videotype:(NSInteger)videotype
{
    self = [super initWithFrame:frame];
    if (self) {
        self.videoType = videotype;
        [self setupView];
    }
    return self;
}


- (void)setupView {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self addSubview:self.blurEffectView];
    [self.blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UIView *contentView = [UIView new];
    [self addSubview:contentView];
    if (self.videoType == 3) {
        contentView.hidden = YES;
    }
    self.contentView = contentView;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(0);
    }];
    
    UIImageView *iconImgView = [UIImageView new];
    [contentView addSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(45);
    }];
    
    UIButton *lockButton = [UIView vk_button:nil image:nil font:vkFont(12) color:UIColor.whiteColor];
    lockButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    [lockButton vk_addTapAction:self selector:@selector(clickLockAction)];
    [contentView addSubview:lockButton];
    self.lockButton = lockButton;
    [lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(iconImgView.mas_bottom).offset(20);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refresh {
    if (self.is_vip) {
        self.iconImgView.image = [ImageBundle imagewithBundleName:@"video_pay_vip"];
        [self.lockButton setTitle:YZMsg(@"movie_pay_vip") forState:UIControlStateNormal];
        [self.lockButton vk_border:vkColorHex(0xF9DEA2) cornerRadius:15];
        [self.lockButton setTitleColor:vkColorHex(0xF9DEA2) forState:UIControlStateNormal];
    } else {
        self.iconImgView.image = [ImageBundle imagewithBundleName:@"video_pay_lock_n"];
        [self.lockButton setTitle:YZMsg(@"movie_pay_money") forState:UIControlStateNormal];
        [self.lockButton vk_border:vkColorHex(0xFFFFFF) cornerRadius:15];
        [self.lockButton setTitleColor:vkColorHex(0xFFFFFF) forState:UIControlStateNormal];
    }
}

- (void)clickLockAction {
    WeakSelf
    [MBProgressHUD showMessage:nil];
    [LotteryNetworkUtil getVideoTicketsBlock:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [Config setVideoTickets:networkData.data[@"ticket"]];
        LiveUser *user = [Config myProfile];
        user.coin = minstr(networkData.data[@"coin"]);
        [Config updateProfile:user];
        
        STRONGSELF
        if (!strongSelf) return;
        [strongSelf showPayAlert];
    }];
}

- (void)showPayAlert {
    if (self.is_vip && self.coin_cost <= 0) {
//        VideoVipAlertView *vc = [VideoVipAlertView new];
//        vc.videoType = self.videoType;
//        [vc showFromCenter];
        
        VipPayAlertView *view = [VipPayAlertView new];
        [view showFromBottom];
        return;
    }
    VideoPayAlertView *vc = [VideoPayAlertView new];
    vc.is_vip = self.is_vip;
    vc.ticket_cost = self.ticket_cost;
    vc.coin_cost = self.coin_cost;
    vc.clickPayBlock = self.clickPayBlock;
    vc.videoType = self.videoType;
    [vc showFromCenter];
}

@end
