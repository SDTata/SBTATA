//
//  MyCreateFooterView.m
//  phonelive2
//
//  Created by vick on 2024/7/22.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateFooterView.h"

@interface MyCreateFooterView ()

@property (nonatomic, strong) VKButton *tickButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *outButton;
@property (nonatomic, strong) UIButton *hideButton;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation MyCreateFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    
    VKButton *tickButton = [VKButton buttonWithType:UIButtonTypeCustom];
    [tickButton vk_button:YZMsg(@"Livebroadcast_order_select_all") image:@"create_tick_n" font:vkFont(14) color:vkColorHex(0x808080)];
    [tickButton vk_buttonSelected:nil image:@"create_tick_s" color:nil];
    [tickButton vk_addTapAction:self selector:@selector(clickTickAction)];
    [self addSubview:tickButton];
    self.tickButton = tickButton;
    [tickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.height.mas_equalTo(26);
        make.top.mas_equalTo(10);
    }];
    
    UIButton *deleteButton = [UIView vk_button:YZMsg(@"BetCell_remove") image:nil font:vkFont(14) color:UIColor.whiteColor];
    [deleteButton vk_border:nil cornerRadius:13];
    deleteButton.backgroundColor = vkColorHex(0xF251BB);
    [deleteButton vk_addTapAction:self selector:@selector(clickDeleteAction)];
    [self addSubview:deleteButton];
    self.deleteButton = deleteButton;
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.centerY.height.mas_equalTo(tickButton);
        make.width.mas_equalTo(56);
    }];
    
    UIButton *outButton = [UIView vk_button:YZMsg(@"create_manage_show") image:nil font:vkFont(14) color:UIColor.whiteColor];
    [outButton vk_border:nil cornerRadius:13];
    outButton.backgroundColor = vkColorHex(0x9F57DF);
    [outButton vk_addTapAction:self selector:@selector(clickOutAction)];
    [self addSubview:outButton];
    self.outButton = outButton;
    [outButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(deleteButton.mas_left).offset(-10);
        make.centerY.height.width.mas_equalTo(deleteButton);
    }];
    
    UIButton *hideButton = [UIView vk_button:YZMsg(@"create_manage_hide") image:nil font:vkFont(14) color:UIColor.whiteColor];
    [hideButton vk_border:nil cornerRadius:13];
    hideButton.backgroundColor = vkColorHex(0xF251BB);
    [hideButton vk_addTapAction:self selector:@selector(clickHideAction)];
    [self addSubview:hideButton];
    self.hideButton = hideButton;
    [hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(outButton.mas_left).offset(-10);
        make.centerY.height.width.mas_equalTo(outButton);
    }];
    
    UILabel *countLabel = [UIView vk_label:nil font:vkFont(14) color:vkColorHex(0x808080)];
    countLabel.adjustsFontSizeToFitWidth = YES;
    countLabel.minimumScaleFactor = 0.1;
    [self addSubview:countLabel];
    self.countLabel = countLabel;
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tickButton.mas_right).offset(5);
        make.centerY.mas_equalTo(tickButton.mas_centerY);
        make.right.mas_equalTo(hideButton.mas_left).offset(-10);
    }];
}

- (void)setType:(NSString *)type {
    _type = type;
    if (self.type.integerValue == 1) {
        self.outButton.hidden = NO;
        self.hideButton.hidden = NO;
    } else {
        self.outButton.hidden = YES;
        self.hideButton.hidden = YES;
    }
    self.tickButton.selected = NO;
}

- (void)setSelectVideos:(NSArray<ShortVideoModel *> *)selectVideos {
    _selectVideos = selectVideos;
    [self refreshVideoCount];
}

/// 更新选中数量
- (void)refreshVideoCount {
    NSString *count = [NSString stringWithFormat:@"%ld", self.selectVideos.count];
    NSString *text = [NSString stringWithFormat:YZMsg(@"create_select_count"), count];
    self.countLabel.attributedText = vkAttributedTexts(text, @[count], vkColorHex(0xF251BB), self.countLabel.font);
}

/// 全选
- (void)clickTickAction {
    BOOL value = self.tickButton.selected;
    self.tickButton.selected = !value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(myCreateFooterViewDeletgateSelectAll:)]) {
        [self.delegate myCreateFooterViewDeletgateSelectAll:!value];
    }
}

/// 删除视频
- (void)clickDeleteAction {
    if (!self.selectVideos.count) {
        [MBProgressHUD showError:YZMsg(@"create_should_choose")];
        return;
    }
    NSArray *ids = [self.selectVideos valueForKeyPath:@"video_id"];
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getMyCreateManage:ids action:@"delete" block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf refreshNotify];
    }];
}

/// 公开视频
- (void)clickOutAction {
    if (!self.selectVideos.count) {
        [MBProgressHUD showError:YZMsg(@"create_should_choose")];
        return;
    }
    NSArray *ids = [self.selectVideos valueForKeyPath:@"video_id"];
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getMyCreateManage:ids action:@"show" block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf refreshNotify];
    }];
}

/// 隐藏视频
- (void)clickHideAction {
    if (!self.selectVideos.count) {
        [MBProgressHUD showError:YZMsg(@"create_should_choose")];
        return;
    }
    NSArray *ids = [self.selectVideos valueForKeyPath:@"video_id"];
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getMyCreateManage:ids action:@"hide" block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        [MBProgressHUD hideHUD];
        [strongSelf refreshNotify];
    }];
}

- (void)refreshNotify {
    if (self.delegate && [self.delegate respondsToSelector:@selector(myCreateFooterViewDeletgateRefreshList)]) {
        [self.delegate myCreateFooterViewDeletgateRefreshList];
    }
    self.tickButton.selected = NO;
}

@end
