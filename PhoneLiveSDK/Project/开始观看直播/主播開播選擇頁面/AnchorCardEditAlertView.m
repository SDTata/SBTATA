//
//  AnchorCardEditAlertView.m
//  phonelive2
//
//  Created by vick on 2025/7/23.
//  Copyright © 2025 toby. All rights reserved.
//

#import "AnchorCardEditAlertView.h"

@implementation AnchorCardEditAlertCell

+ (CGFloat)itemHeight {
    return 50;
}

- (void)updateView {
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(14) color:vkColorHex(0x111118)];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.centerY.mas_equalTo(0);
    }];
    
    UIButton *tickButton = [UIView vk_buttonImage:@"live_tick_n" selected:@"live_tick_s"];
    tickButton.userInteractionEnabled = NO;
    [self.contentView addSubview:tickButton];
    self.tickButton = tickButton;
    [tickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.size.mas_equalTo(18);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)updateData {
    VKActionModel *model = self.itemModel;
    self.titleLabel.text = model.title;
    self.tickButton.selected = model.selected;
}

@end


@interface AnchorCardEditAlertView ()

@property (nonatomic, strong) VKBaseTableView *tableView;

@end

@implementation AnchorCardEditAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setupData];
    }
    return self;
}

- (VKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseTableView new];
        _tableView.registerCellClass = [AnchorCardEditAlertCell class];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 14, 0, 14);
        
        @weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, VKActionModel *item) {
            @strongify(self)
            [self.tableView selectIndexPath:indexPath key:@"selected"];
            if (self.selectPriceBlock) {
                self.selectPriceBlock(indexPath.row, item.title);
            }
            [self hideAlert:nil];
        };
    }
    return _tableView;
}

- (void)setupView {
    self.backgroundColor = UIColor.whiteColor;
    [self corner:VKCornerMaskTop radius:14];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(VK_SCREEN_W);
        make.height.mas_equalTo(350+VK_BOTTOM_H);
    }];
    
    UILabel *titleLabel = [UIView vk_label:@"推送名片价格" font:vkFontMedium(16) color:vkColorHex(0x111118)];
    titleLabel.backgroundColor = vkColorHexA(0x919191, 0.08);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.bottom.mas_equalTo(-VK_BOTTOM_H);
    }];
}

- (void)setupData {
    NSArray *priceA = [common getContactPrice];
    NSMutableArray *arrayPriceShow = [NSMutableArray array];
    for (NSString *subPrice in priceA) {
        VKActionModel *model = [VKActionModel new];
        if ([subPrice intValue] == 0) {
            model.title = YZMsg(@"Livebroadcast_Nopush_card");
        }else{
            NSString *price = minstr(subPrice);
            NSString *currencyCoin = [YBToolClass getRateCurrency:price showUnit:YES];
            model.title = currencyCoin;
        }
        [arrayPriceShow addObject:model];
    }
    self.tableView.dataItems = arrayPriceShow;
    [self.tableView reloadData];
}

@end
