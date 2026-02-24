//
//  MyCreateEarnReportVC.m
//  phonelive2
//
//  Created by vick on 2024/7/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateEarnReportVC.h"
#import "VKButton.h"
#import "MyCreateEarnReportCell.h"
#import "MyEarnReportModel.h"

@interface MyCreateEarnReportVC ()

@property (nonatomic, strong) VKButton *dateButton;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, strong) NSMutableArray <VKActionModel *> *actions;
@property (nonatomic, strong) VKActionModel *selectAction;

@end

@implementation MyCreateEarnReportVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [MyCreateEarnReportCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        [_tableView vk_headerRefreshSet];
        [_tableView vk_footerRefreshSet];
        [_tableView vk_showEmptyView];
        
        _weakify(self)
        _tableView.loadDataBlock = ^{
            _strongify(self)
            [self loadListData];
        };
    }
    return _tableView;
}

- (NSMutableArray<VKActionModel *> *)actions {
    if (!_actions) {
        NSMutableArray *results = [NSMutableArray array];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"create_date_today");
            model.value = @"today";
            model;
        })];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"create_date_yesterday");
            model.value = @"yesterday";
            model;
        })];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"create_date_week");
            model.value = @"week";
            model;
        })];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"create_date_month");
            model.value = @"month";
            model;
        })];
        _actions = results;
    }
    return _actions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self.tableView vk_headerBeginRefresh];
}

- (void)setupView {
    self.view.backgroundColor = vkColorRGB(231, 227, 235);
    self.view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.view.layer.cornerRadius = 20;
    
    VKButton *dateButton = [VKButton new];
    [dateButton vk_button:nil image:@"down_arrow" font:vkFont(16) color:UIColor.blackColor];
    [dateButton vk_buttonSelected:nil image:@"down_arrow" color:UIColor.blackColor];
    [dateButton vk_addTapAction:self selector:@selector(clickDateAction:)];
    dateButton.imagePosition = VKButtonImagePositionRight;
    [self.view addSubview:dateButton];
    self.dateButton = dateButton;
    [dateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *amountLabel = [UIView vk_label:nil font:vkFont(16) color:UIColor.blackColor];
    [self.view addSubview:amountLabel];
    self.amountLabel = amountLabel;
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.centerY.mas_equalTo(dateButton.mas_centerY);
    }];
    
    UIView *titleView = [UIView new];
    [titleView vk_border:nil cornerRadius:6];
    [self.view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(dateButton.mas_bottom).offset(10);
        make.height.mas_equalTo(22);
    }];
    {
        VKButton *titleButton1 = [VKButton new];
        [titleButton1 vk_button:YZMsg(@"create_report_from") image:@"create_report_from" font:vkFont(12) color:UIColor.whiteColor];
        titleButton1.backgroundColor = vkColorHex(0xAF99C9);
        titleButton1.userInteractionEnabled = NO;
        [titleView addSubview:titleButton1];
        
        VKButton *titleButton2 = [VKButton new];
        [titleButton2 vk_button:YZMsg(@"create_report_date") image:@"create_report_date" font:vkFont(12) color:UIColor.whiteColor];
        titleButton2.backgroundColor = vkColorHex(0xAF99C9);
        titleButton2.userInteractionEnabled = NO;
        [titleView addSubview:titleButton2];
        
        VKButton *titleButton3 = [VKButton new];
        [titleButton3 vk_button:YZMsg(@"create_report_amount") image:@"create_report_amount" font:vkFont(12) color:UIColor.whiteColor];
        titleButton3.backgroundColor = vkColorHex(0xAF99C9);
        titleButton3.userInteractionEnabled = NO;
        [titleView addSubview:titleButton3];
    }
    [titleView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:1.0 leadSpacing:0 tailSpacing:0];
    [titleView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(titleView.mas_bottom);
        make.bottom.mas_equalTo(0);
    }];
    
    self.selectAction = self.actions.firstObject;
    [self.dateButton setTitle:self.selectAction.title forState:UIControlStateNormal];
}

- (void)loadListData {
    WeakSelf
    [LotteryNetworkUtil getMyCreateReport:self.selectAction.value page:self.tableView.pageIndex block:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            [strongSelf.tableView vk_refreshFinish:nil];
            return;
        }
        MyEarnReportModel *model = [MyEarnReportModel modelFromJSON:networkData.data];
        strongSelf.amountLabel.text = [NSString stringWithFormat:@"%@ %@", YZMsg(@"create_total_amount"), [YBToolClass getRateCurrency:model.total_profit showUnit:YES]];
        [strongSelf.tableView vk_refreshFinish:model.profit_list];
    }];
}

- (void)clickDateAction:(UIButton *)button {
    NSArray *titles = [self.actions valueForKeyPath:@"title"];
    [YBPopupMenu showMenu:button style:VKPopupMenuDate width:90 titles:titles icons:nil block:^(NSInteger index) {
        self.selectAction = self.actions[index];
        [self.dateButton setTitle:self.selectAction.title forState:UIControlStateNormal];
        [self.tableView vk_headerBeginRefresh];
    }];
}

@end
