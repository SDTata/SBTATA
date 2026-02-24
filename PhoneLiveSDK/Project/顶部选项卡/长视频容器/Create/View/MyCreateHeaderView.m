//
//  MyCreateHeaderView.m
//  phonelive2
//
//  Created by vick on 2024/7/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import "MyCreateHeaderView.h"
#import "MyCreateEarnReportVC.h"
#import "MyCreatePostRuleVC.h"
#import "PostVideoViewController.h"
#import "myWithdrawVC2.h"
#import "myProfitVC.h"
@interface MyCreateHeaderView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) VKBaseCollectionView *tableView;

@end

@implementation MyCreateHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        [_topView vk_border:nil cornerRadius:16];
        
        UILabel *amountLabel = [UIView vk_label:nil font:vkFont(16) color:UIColor.whiteColor];
        [_topView addSubview:amountLabel];
        self.amountLabel = amountLabel;
        [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _topView;
}

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [VKActionGridCell class];
        _tableView.scrollEnabled = NO;
        
        _weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, VKActionModel *item) {
            _strongify(self)
            [self runSelector:item.action];
        };
        
        NSMutableArray *results = [NSMutableArray array];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"public_WithDraw");
            model.icon = @"create_menu_draw";
            model.iconSize = CGSizeMake(35, 35);
            model.action = @selector(clickWithdrawAction);
            model;
        })];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"create_menu_record");
            model.icon = @"create_menu_record";
            model.iconSize = CGSizeMake(35, 35);
            model.action = @selector(clickRecordAction);
            model;
        })];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"create_menu_rule");
            model.icon = @"create_menu_rule";
            model.iconSize = CGSizeMake(35, 35);
            model.action = @selector(clickRuleAction);
            model;
        })];
        [results addObject:({
            VKActionModel *model = [VKActionModel new];
            model.title = YZMsg(@"create_menu_upload");
            model.icon = @"create_menu_upload";
            model.iconSize = CGSizeMake(35, 35);
            model.action = @selector(clickUploadAction);
            model;
        })];
        _tableView.dataItems = results;
    }
    return _tableView;
}

- (void)setupView {
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(70);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.topView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topView.horizontalColors = @[vkColorHex(0x9F57DF), vkColorHex(0xD4A6FC)];
}

- (void)setInfoModel:(MyCreateInfoModel *)infoModel {
    _infoModel = infoModel;
    self.amountLabel.text = [NSString stringWithFormat:@"%@：%@", YZMsg(@"create_total_income"), [YBToolClass getRateCurrency:infoModel.income showUnit:YES]];
}

- (void)clickWithdrawAction {
    myProfitVC *VC = [[myProfitVC alloc]init];
    VC.titleStr = YZMsg(@"public_WithDraw");
    VC.isCreator = true;
    [[MXBADelegate sharedAppDelegate] pushViewController:VC animated:YES];
    
//    myWithdrawVC2 *withdraw = [[myWithdrawVC2 alloc]init];
//    withdraw.titleStr = YZMsg(@"public_WithDraw");
//    [[MXBADelegate sharedAppDelegate] pushViewController:withdraw animated:YES];
}

- (void)clickRecordAction {
    MyCreateEarnReportVC *vc = [MyCreateEarnReportVC new];
    vc.view.frame = CGRectMake(0, 0, VK_SCREEN_W, VKPX(500));
    [vc showFromBottom];
}

- (void)clickRuleAction {
    MyCreatePostRuleVC *vc = [MyCreatePostRuleVC new];
    vc.view.frame = CGRectMake(0, 0, VK_SCREEN_W, VK_SCREEN_H - VK_NAV_H);
    [vc showFromBottom];
}

- (void)clickUploadAction {
    PostVideoViewController *postVideo = [[PostVideoViewController alloc]initWithNibName:@"PostVideoViewController" bundle:[XBundle currentXibBundleWithResourceName:@"PostVideoViewController"]];
    postVideo.fromMyCreatVC = YES;
    [[MXBADelegate sharedAppDelegate] pushViewController:postVideo animated:YES];
}

@end
