//
//  AnchorRoomEditAlertView.m
//  phonelive2
//
//  Created by vick on 2025/7/29.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorRoomEditAlertView.h"
#import "AnchorInputAlertView.h"
#import "AnchorAmountAlertView.h"

@interface AnchorRoomEditAlertView ()

@property (nonatomic, strong) VKBaseTableView *tableView;

@end

@implementation AnchorRoomEditAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self refreshData];
    }
    return self;
}

- (VKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseTableView new];
        _tableView.registerCellClass = [VKActionListCell class];
        _tableView.contentInset = UIEdgeInsetsMake(14, 0, 14, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        @weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, VKActionModel *item) {
            @strongify(self)
            [self runSelector:item.action];
        };
    }
    return _tableView;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    [self corner:VKCornerMaskTop radius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
        make.height.mas_equalTo(220+VK_BOTTOM_H);
    }];
    
    UILabel *titleLabel = [UIView vk_label:@"房间类型" font:vkFontMedium(16) color:vkColorHex(0x111118)];
    titleLabel.backgroundColor = vkColorHexA(0x919191, 0.08);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.bottom.mas_equalTo(-VK_BOTTOM_H);
    }];
}

- (void)refreshData {
    NSArray *arrays = [common live_type];
    NSMutableArray *results = [NSMutableArray array];
    for (NSArray *arr in arrays) {
        NSString *typestring = arr[0];
        int types = [typestring intValue];
        switch (types) {
            case 0:/// 免费房间
                [results addObject:({
                    VKActionModel *model = [VKActionModel new];
                    model.title = YZMsg(@"Livebroadcast_room_type_nomal");
                    model.showArrow = YES;
                    model.action = @selector(clickNormalTypeAction);
                    model;
                })];
                break;
            case 1:/// 密码房间
                [results addObject:({
                    VKActionModel *model = [VKActionModel new];
                    model.title = YZMsg(@"Livebroadcast_room_type_pwd");
                    model.value = @"设置";
                    model.showArrow = YES;
                    model.action = @selector(clickPwdTypeAction);
                    model;
                })];
                break;
            case 2:/// 付费房间
                [results addObject:({
                    VKActionModel *model = [VKActionModel new];
                    model.title = YZMsg(@"Livebroadcast_room_type_tickets");
                    model.value = @"设置";
                    model.showArrow = YES;
                    model.action = @selector(clickPayTypeAction);
                    model;
                })];
                break;
            case 3:/// 计时房间
                [results addObject:({
                    VKActionModel *model = [VKActionModel new];
                    model.title = YZMsg(@"Livebroadcast_room_type_time");
                    model.value = @"设置";
                    model.showArrow = YES;
                    model.action = @selector(clickTimeTypeAction);
                    model;
                })];
                break;
            default:
                break;
        }
    }
    self.tableView.dataItems = results;
    [self.tableView reloadData];
}

- (void)clickNormalTypeAction {
    if (self.clickTypeBlock) {
        self.clickTypeBlock(@"0", nil);
    }
    [self hideAlert:nil];
}

- (void)clickPwdTypeAction {
    AnchorInputAlertView *view = [AnchorInputAlertView new];
    view.titleLabel.text = @"设置房间密码";
    view.textField.placeholder = @"请输入房间密码";
    [view showFromCenter];
    
    @weakify(self)
    view.clickConfirmBlock = ^(NSString *text) {
        @strongify(self)
        if (self.clickTypeBlock) {
            self.clickTypeBlock(@"1", text);
        }
        [self hideAlert:nil];
    };
}

- (void)clickPayTypeAction {
    AnchorInputAlertView *view = [AnchorInputAlertView new];
    view.titleLabel.text = @"设置收费金额";
    view.textField.placeholder = @"请输入收费金额";
    [view showFromCenter];
    
    @weakify(self)
    view.clickConfirmBlock = ^(NSString *text) {
        @strongify(self)
        if (self.clickTypeBlock) {
            self.clickTypeBlock(@"2", text);
        }
        [self hideAlert:nil];
    };
}

- (void)clickTimeTypeAction {
    AnchorAmountAlertView *view = [AnchorAmountAlertView new];
    [view showFromCenter];
    
    @weakify(self)
    view.clickConfirmBlock = ^(NSString *text) {
        @strongify(self)
        if (self.clickTypeBlock) {
            self.clickTypeBlock(@"3", text);
        }
        [self hideAlert:nil];
    };
}

@end
