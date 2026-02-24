//
//  AnchorCmdListAlertView.m
//  phonelive2
//
//  Created by vick on 2025/7/25.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorCmdListAlertView.h"
#import "AnchorCmdListAlertCell.h"
#import "VKButton.h"
#import "ArchorCmdEditAlertView.h"

@interface AnchorCmdListAlertView ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, strong) VKButton *editButton;
@property (nonatomic, strong) VKButton *sureButton;
@property (nonatomic, strong) VKButton *allButton;
@property (nonatomic, strong) UISwitch *openButton;

@end

@implementation AnchorCmdListAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self.tableView vk_headerBeginRefresh];
    }
    return self;
}

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [AnchorCmdListAlertCell class];
        _tableView.contentInset = UIEdgeInsetsMake(14, 0, 14, 0);
        
        [_tableView vk_headerRefreshSet];
        [_tableView vk_showEmptyView];
        
        @weakify(self)
        _tableView.loadDataBlock = ^{
            @strongify(self)
            [self loadListData];
        };
        
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, RemoteOrderModel *item) {
            @strongify(self)
            /// 新增指令
            if (item.isAdd) {
                [self clickAlertAction:nil];
                return;
            }
            /// 编辑指令
            if (self.tableView.isEditType) {
                [self clickAlertAction:item];
                return;
            }
            /// 选择指令
            item.selected = !item.selected;
            [self.tableView reloadData];
        };
    }
    return _tableView;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    [self corner:VKCornerMaskTop radius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
        make.height.mas_equalTo(450+VK_BOTTOM_H);
    }];
    
    UIView *topView = [UIView new];
    topView.backgroundColor = vkColorHexA(0x919191, 0.08);
    [self addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    {
        UILabel *titleLabel = [UIView vk_label:@"指令列表" font:vkFontMedium(16) color:vkColorHex(0x111118)];
        [topView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.mas_equalTo(0);
        }];
        
        UISwitch *openButton = [UISwitch new];
        openButton.onTintColor = vkColorHex(0xFF63AC);
        [topView addSubview:openButton];
        self.openButton = openButton;
        [openButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-14);
            make.centerY.mas_equalTo(0);
        }];
    }
    
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = vkColorHexA(0x919191, 0.08);
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(VK_BOTTOM_H+46);
    }];
    {
        VKButton *editButton = [VKButton buttonWithType:UIButtonTypeCustom];
        [editButton vk_button:@"编辑" image:@"live_cmd_edit_red" font:vkFont(14) color:vkColorHex(0xFF63AC)];
        editButton.imageSize = CGSizeMake(18, 18);
        editButton.imagePosition = VKButtonImagePositionLeft;
        editButton.spacingBetweenImage = 6;
        [editButton vk_addTapAction:self selector:@selector(clickEditAction)];
        [bottomView addSubview:editButton];
        self.editButton = editButton;
        [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(46);
        }];
        
        VKButton *sureButton = [VKButton buttonWithType:UIButtonTypeCustom];
        [sureButton vk_button:@"确定" image:nil font:vkFont(14) color:vkColorHex(0xFF63AC)];
        [sureButton vk_addTapAction:self selector:@selector(clickSureAction)];
        sureButton.hidden = YES;
        [bottomView addSubview:sureButton];
        self.sureButton = sureButton;
        [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.height.mas_equalTo(editButton);
        }];
        
        VKButton *allButton = [VKButton buttonWithType:UIButtonTypeCustom];
        [allButton vk_button:@"全选" image:@"live_tick_n" font:vkFont(14) color:vkColorHex(0xFF63AC)];
        [allButton vk_buttonSelected:nil image:@"live_tick_s" color:nil];
        allButton.imageSize = CGSizeMake(18, 18);
        allButton.imagePosition = VKButtonImagePositionLeft;
        allButton.spacingBetweenImage = 6;
        [allButton vk_addTapAction:self selector:@selector(clickAllAction)];
        [bottomView addSubview:allButton];
        self.allButton = allButton;
        [allButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-14);
            make.centerY.height.mas_equalTo(editButton);
        }];
    }
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(topView.mas_bottom);
        make.bottom.mas_equalTo(bottomView.mas_top);
    }];
}

- (void)setOrderSwitchStatus:(BOOL)orderSwitchStatus {
    _orderSwitchStatus = orderSwitchStatus;
    self.openButton.on = orderSwitchStatus;
}

- (void)clickAlertAction:(RemoteOrderModel *)item {
    ArchorCmdEditAlertView *view = [ArchorCmdEditAlertView new];
    view.model = item;
    [view showFromBottom];
    
    @weakify(self)
    view.refreshBlock = ^{
        @strongify(self)
        [self.tableView vk_headerBeginRefresh];
    };
}

- (void)clickSureAction {
    self.editButton.hidden = NO;
    self.allButton.hidden = NO;
    self.sureButton.hidden = YES;
    
    self.tableView.isEditType = NO;
    [self.tableView reloadData];
}

- (void)clickEditAction {
    self.editButton.hidden = YES;
    self.allButton.hidden = YES;
    self.sureButton.hidden = NO;
    
    self.tableView.isEditType = YES;
    [self.tableView reloadData];
}

- (void)clickAllAction {
    self.allButton.selected = !self.allButton.selected;
    [self.tableView.dataItems setValue:@(self.allButton.selected) forKeyPath:@"selected"];
    [self.tableView reloadData];
}

- (void)loadListData {
    [LotteryNetworkUtil getLiveCmdList:@"4" block:^(NetworkData *networkData) {
        NSArray *tempInfos = networkData.data[@"toylist"];
        NSArray *cmdInfos = networkData.data[@"cmd_list"];
        NSMutableArray *infos = [NSMutableArray arrayWithArray:tempInfos];
        [infos addObjectsFromArray:cmdInfos];
        NSMutableArray<RemoteOrderModel*> *models = [NSMutableArray array];
        NSArray *selectedIds = [self.selectedModels valueForKeyPath:@"ID"];
        for (int i = 0 ; i < infos.count ; i++) {
            RemoteOrderModel *model = [RemoteOrderModel modelWithDic:infos[i]];
            model.selected = [selectedIds containsObject:model.ID];
            [models addObject:model];
        }
        RemoteOrderModel *add = [RemoteOrderModel new];
        add.isAdd = YES;
        add.giftname = @"添加指令";
        add.imagePath = @"live_cmd_add_red";
        [models addObject:add];
        [self.tableView vk_refreshFinish:models];
    }];
}

- (void)dealloc {
    if (self.clickSaveBlock) {
        BOOL status = self.openButton.isOn;
        NSArray *selecteds = [self.tableView.dataItems filterBlock:^BOOL(RemoteOrderModel *object) {
            return object.selected && !object.isAdd;
        }];
        status = selecteds.count > 0 ? status : NO;
        self.clickSaveBlock(selecteds, status);
    }
}

@end
