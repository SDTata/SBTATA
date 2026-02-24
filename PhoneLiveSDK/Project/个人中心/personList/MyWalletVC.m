//
//  MyWalletVC.m
//  phonelive2
//
//  Created by user on 2024/8/14.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyWalletVC.h"
#import "MyWalletTableViewCell.h"
#import "LotteryNetworkUtil.h"
#import <UMCommon/UMCommon.h>

@interface MyWalletVC ()
@property (nonatomic, strong) VKBaseTableView *tableView;
@end

@implementation MyWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self getWalletList];
}

- (void)setupViews {
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id) self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    UIView *navtion = [[UIView alloc] initWithFrame: CGRectZero];
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn:) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    
    titleLabel.text = YZMsg(@"profile_center_myWallet");
    [navtion addSubview:titleLabel];
    
    [self.view addSubview:navtion];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[VKBaseTableView alloc]initWithFrame: CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 110.0f;
    _tableView.sectionHeaderHeight = 10.0f;
    _tableView.automaticDimension = YES;
    _tableView.registerCellClass = [MyWalletTableViewCell class];
    [self.view addSubview:_tableView];
    
    [navtion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(44);
        make.leading.trailing.mas_equalTo(self.view);
    }];
    
    [returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(navtion).offset(10);
        make.centerY.mas_equalTo(navtion);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(44);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(44);
        make.center.mas_equalTo(navtion);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view).inset(20);
        make.top.mas_equalTo(navtion.mas_bottom);
    }];
    
    [_tableView vk_headerRefreshSet];
    _weakify(self)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _strongify(self)
        [self getWalletList];
    }];
    _tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        _strongify(self)
        [self getWalletList];
    }];
    _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, NSDictionary *item) {
        NSLog(@"%@", item);
        _strongify(self)
        [self getWalletInfo:item[@"code"]];
        NSDictionary *dict = @{ @"eventType": @(0),
                                @"wallet_name": item[@"code"]};
        [MobClick event:@"withdraw_wallet_click" attributes:dict];
    };
    _tableView.clickCellActionBlock = ^(NSIndexPath *indexPath, id item, NSInteger actionIndex) {
        NSLog(@"%@", item);
        _strongify(self)
        [self getWalletList];
    };
}

- (void)getWalletList {
    _weakify(self)
    [self.tableView vk_headerBeginRefresh];
    [self getMyWalletList:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        _strongify(self)
        [self.tableView vk_refreshFinish: networkData.info];
    }];
}

- (void)getWalletInfo:(NSString *)code {
    _weakify(self)
    [self.tableView vk_headerBeginRefresh];
    [self getWalletInfo:code block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        _strongify(self)
        NSLog(@"%@",networkData.info);
        [[YBUserInfoManager sharedManager] pushVipPayWebviewinfo:networkData.info];
    }];
}

- (void)doReturn:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[MXBADelegate sharedAppDelegate] popViewController:YES];
    }
}

// 获取未读消息列表
- (void)getMyWalletList:(NetworkBlock)block {
    [LotteryNetworkUtil baseRequest:@"User.getMyWallet" params:nil block:block];
}

// 获取钱包详情
- (void)getWalletInfo:(NSString *)code block:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"code"] = code;
    [LotteryNetworkUtil baseRequest:@"User.getWalletInfo" params:dict block:block];
}
@end
