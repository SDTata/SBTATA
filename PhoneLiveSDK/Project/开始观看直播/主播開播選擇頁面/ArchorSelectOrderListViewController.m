//
//  ArchorSelectOrderListViewController.m
//  c700LIVE
//
//  Created by s5346 on 2023/12/27.
//  Copyright © 2023 toby. All rights reserved.
//

#import "ArchorSelectOrderListViewController.h"
#import "ArchorCmdEditVC.h"

@interface ArchorSelectOrderListViewController () <UICollectionViewDelegate, UICollectionViewDataSource> {
    // 全選指令 icon
    UIButton *selectAllOrderButton;
    // 指令陣列
    NSMutableArray<RemoteOrderModel*> *orderListModels;
    NSMutableArray<RemoteOrderModel*> *selectOrderModels;
    UICollectionView *orderListCollectionView;
}
@end

@implementation ArchorSelectOrderListViewController
- (void)dealloc {
    NSLog(@">>>ArchorSelectOrderListViewController release");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getLiveToyInfo:LiveToyInfoRemoteControllerForAnchorman];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor blackColor];
    WeakSelf;
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [ImageBundle imagewithBundleName:@"sy_bj"];
    [self.view addSubview:backgroundImageView];
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];

    UIButton *backIcon = [[UIButton alloc] init];
    [backIcon setImage:[ImageBundle imagewithBundleName:@"arrow_return"] forState:UIControlStateNormal];
    [backIcon addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backIcon setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.view addSubview:backIcon];
    [backIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop).offset(-12);
        make.left.equalTo(weakSelf.view).offset(8);
        make.size.equalTo(@44);
    }];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[ImageBundle imagewithBundleName:@"live_cmd_edit"] forState:UIControlStateNormal];
    [addButton vk_addTapAction:self selector:@selector(clickAddAction)];
    [addButton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.view addSubview:addButton];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop).offset(-12);
        make.right.equalTo(weakSelf.view).offset(-8);
        make.size.equalTo(@44);
    }];

    UIView *titleView = [[UIView alloc] init];
    titleView.layer.cornerRadius = 10;
    titleView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    titleView.layer.masksToBounds = true;
    titleView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backIcon.mas_bottom).offset(3);
        make.left.right.equalTo(weakSelf.view).inset(10);
        make.height.equalTo(@50);
    }];

    UIImageView *orderIconImageView = [[UIImageView alloc] init];
    [titleView addSubview:orderIconImageView];
    orderIconImageView.image = [ImageBundle imagewithBundleName:@"control_order"];
    [orderIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleView).offset(10);
        make.size.equalTo(@30);
        make.centerY.equalTo(titleView);
    }];

    // 指令列表
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = YZMsg(@"live_order_list");
    [titleView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(orderIconImageView.mas_right).offset(10);
        make.centerY.equalTo(orderIconImageView);
    }];


    // 全選 view
    UIView *selectAllOrderView = [[UIView alloc] init];
    [titleView addSubview:selectAllOrderView];
    [selectAllOrderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(titleView);
        make.left.greaterThanOrEqualTo(titleLabel.mas_right);
    }];
    UITapGestureRecognizer *allOrderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allOrderTapAction)];
    allOrderTap.numberOfTouchesRequired = 1;
    allOrderTap.numberOfTapsRequired = 1;
    [selectAllOrderView addGestureRecognizer:allOrderTap];

    selectAllOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllOrderButton addTarget:self action:@selector(allOrderTapAction) forControlEvents:UIControlEventTouchUpInside];
   
    [selectAllOrderButton setImage:[ImageBundle imagewithBundleName:@"orderListCell_off"] forState:UIControlStateNormal];
    [selectAllOrderButton setImage:[ImageBundle imagewithBundleName:@"orderListCell_on"] forState:UIControlStateSelected];
    [selectAllOrderView addSubview:selectAllOrderButton];
    [selectAllOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(titleView).offset(-15);
        make.centerY.equalTo(titleView);
        make.size.equalTo(@20);
    }];

    // 全選
    UILabel *selectAllOrderLabel = [[UILabel alloc] init];
    selectAllOrderLabel.textColor = [UIColor whiteColor];
    selectAllOrderLabel.font = [UIFont boldSystemFontOfSize:18];
    selectAllOrderLabel.text = YZMsg(@"Livebroadcast_order_select_all");
    [selectAllOrderView addSubview:selectAllOrderLabel];
    [selectAllOrderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(selectAllOrderView);
        make.right.equalTo(selectAllOrderButton.mas_left).offset(-4);
    }];
    selectAllOrderLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *allOrderTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allOrderTapAction)];
    allOrderTap1.numberOfTouchesRequired = 1;
    allOrderTap1.numberOfTapsRequired = 1;
    [selectAllOrderLabel addGestureRecognizer:allOrderTap1];

    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [selectAllOrderLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    orderListCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    orderListCollectionView.allowsMultipleSelection = true;
    [orderListCollectionView registerClass:[RemoteControllerCell self] forCellWithReuseIdentifier:@"RemoteControllerCell"];
    orderListCollectionView.delegate = self;
    orderListCollectionView.dataSource = self;
    orderListCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:orderListCollectionView];

    // 確認
    UIButton *startLiveBtn = [UIButton buttonWithType:0];
    startLiveBtn.layer.cornerRadius = 25.0;
    startLiveBtn.layer.masksToBounds = YES;
    [startLiveBtn setBackgroundColor:RGB_COLOR(@"#B93BF8", 1)];
    [startLiveBtn addTarget:self action:@selector(sureSelectedOrder) forControlEvents:UIControlEventTouchUpInside];
    [startLiveBtn setTitle:YZMsg(@"Livebroadcast_order_confirm") forState:0];
    startLiveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:startLiveBtn];
    [startLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view).inset(10);
        make.height.equalTo(@50);
        make.top.equalTo(orderListCollectionView.mas_bottom).offset(AD(20));
        make.bottom.equalTo(weakSelf.view).offset(-AD(100));
    }];
    
    [orderListCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView.mas_bottom).offset(8);
        make.left.right.equalTo(titleView).inset(0);
        make.bottom.equalTo(startLiveBtn.mas_top).offset(-20);
    }];
}

- (void)getLiveToyInfo:(LiveToyInfInfoType)type {
    NSString *typeString = @"";
    switch (type) {
        case LiveToyInfoRemoteControllerForAnchorman:
            typeString = @"4";
            break;
        case LiveToyInfoRemoteControllerForToy:
            typeString = @"3";
            break;
        default:
            return;
    }
    WeakSelf
    [LotteryNetworkUtil getLiveCmdList:typeString block:^(NetworkData *networkData) {
        STRONGSELF
        if (strongSelf == nil) return;
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        strongSelf->orderListModels = [NSMutableArray array];
        NSArray *tempInfos = networkData.data[@"toylist"];
        NSArray *cmdInfos = networkData.data[@"cmd_list"];
        if ([tempInfos isKindOfClass:[NSArray class]]) {
            NSMutableArray *infos = [NSMutableArray arrayWithArray:tempInfos];
            [infos addObjectsFromArray:cmdInfos];
            
            NSMutableArray<RemoteOrderModel*> *models = [NSMutableArray array];
            for (int i = 0 ; i < infos.count ; i++) {
                RemoteOrderModel *model = [RemoteOrderModel modelWithDic:infos[i]];
                [models addObject:model];
            }
            strongSelf->orderListModels = models;
        }
        
        strongSelf->selectOrderModels = [NSMutableArray array];
        for (int i = 0; i<strongSelf.oldSelectorderModels.count; i++) {
            RemoteOrderModel *oldModel = strongSelf.oldSelectorderModels[i];
            for (int j = 0; j<strongSelf->orderListModels.count; j++) {
                RemoteOrderModel *newModel = strongSelf->orderListModels[j];
                if ([newModel.ID isEqualToString:oldModel.ID]) {
                    [strongSelf->selectOrderModels addObject:newModel];
                    continue;
                }
            }
        }
        
        [strongSelf orderListSelectAllIfNeed];
        [strongSelf->orderListCollectionView reloadData];
    }];
}

- (void)allOrderTapAction {
    if (selectAllOrderButton.isSelected) {
        selectAllOrderButton.selected = false;
//        for (int i = 0; i<orderListModels.count; i++) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//            [orderListCollectionView deselectItemAtIndexPath:indexPath animated:false];
//        }
        selectOrderModels = [NSMutableArray array];
//        return;
    } else {
        selectOrderModels = [NSMutableArray arrayWithArray:orderListModels];
        selectAllOrderButton.selected = true;
    }

//    for (int i = 0; i<orderListModels.count; i++) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        [orderListCollectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
//    }
    [orderListCollectionView reloadData];
}

- (void)orderListSelectAllIfNeed {
    if (selectOrderModels.count == orderListModels.count) {
        selectAllOrderButton.selected = true;
    } else {
        selectAllOrderButton.selected = false;
    }
}

- (void)sureSelectedOrder {
    [self.delegate archorSelectOrderListViewControllerForSelectedOrder:selectOrderModels];
    [self back];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)clickAddAction {
    ArchorCmdEditVC *vc = [ArchorCmdEditVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma make - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return orderListModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RemoteControllerCell *cell = (RemoteControllerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"RemoteControllerCell" forIndexPath:indexPath];
    if (indexPath.item > orderListModels.count) {
        return cell;
    }
    RemoteOrderModel *model = orderListModels[indexPath.item];
    [cell updateOrderForOnlySelect:indexPath.item info:model];

    if ([selectOrderModels containsObject:model]) {
        [orderListCollectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item > orderListModels.count) {
        return;
    }
    RemoteOrderModel *model = orderListModels[indexPath.item];
    if (![selectOrderModels containsObject:model]) {
        [selectOrderModels addObject:model];
    }
    [self orderListSelectAllIfNeed];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item > orderListModels.count) {
        return;
    }
    RemoteOrderModel *model = orderListModels[indexPath.item];
    if ([selectOrderModels containsObject:model]) {
        [selectOrderModels removeObject:model];
    }
    [self orderListSelectAllIfNeed];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;//UIEdgeInsetsMake(6, 14, 6, 14);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets collectionViewInset = UIEdgeInsetsZero;//UIEdgeInsetsMake(6, 14, 6, 14);
    CGFloat itemSpace = 6;
    CGFloat cellWidth = floor((CGRectGetWidth(collectionView.frame) - itemSpace - collectionViewInset.left - collectionViewInset.right) / 2.0);
    CGFloat cellHeight = 58;//96 * cellWidth / 320.0;
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}
@end
