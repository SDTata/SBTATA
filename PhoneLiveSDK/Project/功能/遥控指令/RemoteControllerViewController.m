//
//  RemoteControllerViewController.m
//  phonelive2
//
//  Created by s5346 on 2023/12/4.
//  Copyright © 2023 toby. All rights reserved.
//

#import "RemoteControllerViewController.h"

@interface RemoteControllerViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    UIView *containerView;
    UIButton *orderButton;
    UILabel *orderButtonLabel;
    UICollectionView *collectionView;
    MASConstraint *collectionHeightConstrain;
    MASConstraint *floatingViewHeightConstrain;
    UIImageView *titleImageView;
    UILabel *titleLabel;
    UIView *showDiamondView;
    UIImageView *topBackgroundImageView;
    UILabel *myDiamondLabel;

    CGFloat cellWidth;
    CGFloat cellHeight;
    CGFloat itemSpace;
    UIEdgeInsets collectionViewInset;
    LiveToyInfInfoType infoType;
    NSString *toyName;
    NSString *orderName;
}
@property(nonatomic,strong) hotModel *playModel;
@property(nonatomic,strong) RemoteOrderModel *selectModel;
@property(nonatomic,strong) NSMutableArray<RemoteOrderModel*> *models;

@end

@implementation RemoteControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reset];
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"moneyChange" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"moneyChange" object:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    UIView *touchView = [[touches anyObject] view];
    if (touchView != self.view) {
        return;
    }
    WeakSelf
    floatingViewHeightConstrain.equalTo(@500);
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        [strongSelf.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        STRONGSELF
        [strongSelf.delegate remoteControllerViewControllerForDismiss];
    }];
}

- (void)dealloc {
    NSLog(@">>>RemoteControllerViewController release");
}

- (void)addPlayModel:(hotModel *)playModel {
    self.playModel = playModel;
}

- (void)setupViewsForType:(LiveToyInfInfoType)type toyName:(NSString*)toy orderName:(NSString*)order {
    infoType = type;
    toyName = YZMsg(@"RC toy");//toy;
    orderName = YZMsg(@"Issue command");//order;

    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    collectionViewInset = UIEdgeInsetsMake(6, 14, 6, 14);
    itemSpace = 6;
    cellWidth = floor((CGRectGetWidth(self.view.frame) - itemSpace - collectionViewInset.left - collectionViewInset.right) / 2.0);
    cellHeight = 58;//96 * cellWidth / 320.0;

    collectionHeightConstrain.equalTo(@((collectionViewInset.top + cellHeight) * 5 + itemSpace));
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[RemoteControllerCell self] forCellWithReuseIdentifier:@"RemoteControllerCell"];
    [collectionView reloadData];

    orderButton.adjustsImageWhenHighlighted = NO;
    [orderButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view layoutIfNeeded];
    showDiamondView.layer.cornerRadius = CGRectGetHeight(showDiamondView.frame) / 2.0;

    [self changeUI];

    WeakSelf
    floatingViewHeightConstrain.equalTo(@0);
    [UIView animateWithDuration:0.2 animations:^{
        STRONGSELF
        [strongSelf.view layoutIfNeeded];
        strongSelf->showDiamondView.layer.cornerRadius = CGRectGetHeight(strongSelf->showDiamondView.frame) / 2.0;
    }];
}

#pragma mark - UI
- (void)setupViews {
    WeakSelf;
    containerView = [[UIView alloc] init];
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        floatingViewHeightConstrain = make.bottom.equalTo(weakSelf.view).offset(500);
    }];

    UIView *headerView = [[UIView alloc] init];
    [containerView addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(containerView);
        make.height.equalTo(headerView.mas_width).multipliedBy(45/360.0);
    }];

    topBackgroundImageView = [[UIImageView alloc] init];
    topBackgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [headerView addSubview:topBackgroundImageView];
    [topBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerView);
    }];


    showDiamondView = [[UIView alloc] init];
    showDiamondView.backgroundColor = RGB_COLOR(@"#171717", 0.5);
    [headerView addSubview:showDiamondView];
    [showDiamondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerView).offset(-16);
        make.height.equalTo(headerView).multipliedBy(22/45.0);
        make.centerY.equalTo(headerView);
    }];

    UITapGestureRecognizer *tapRecharge = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recharge)];
    [showDiamondView addGestureRecognizer:tapRecharge];

    UIImageView *plusImageView = [[UIImageView alloc] init];
    plusImageView.image = [ImageBundle imagewithBundleName:@"remote_add.png"];
    [showDiamondView addSubview:plusImageView];
    [plusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(headerView).multipliedBy(12/45.0);
        make.width.equalTo(plusImageView.mas_height);
        make.right.equalTo(showDiamondView).offset(-2);
        make.centerY.equalTo(showDiamondView);
    }];

    myDiamondLabel = [[UILabel alloc] init];
    myDiamondLabel.font = [UIFont systemFontOfSize:15];
    myDiamondLabel.textColor = [UIColor whiteColor];
    [showDiamondView addSubview:myDiamondLabel];
    [myDiamondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(plusImageView.mas_left).offset(-4);
        make.top.bottom.equalTo(showDiamondView);
        make.left.equalTo(showDiamondView).offset(4);
    }];

    titleImageView = [[UIImageView alloc] init];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    [headerView addSubview:titleImageView];
    [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(25);
        make.centerY.equalTo(headerView);
        make.width.equalTo(headerView).multipliedBy(25/360.0);
        make.height.equalTo(titleImageView.mas_width);
    }];

    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleImageView.mas_right).offset(7);
        make.centerY.equalTo(titleImageView);
    }];

    UIView *bodyView = [[UIView alloc] init];
    bodyView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:bodyView];
    [bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom);
        make.left.right.equalTo(containerView);
        make.bottom.equalTo(containerView);
    }];

    orderButton = [[UIButton alloc] init];
    orderButton.titleLabel.font = [UIFont systemFontOfSize:13];
    orderButton.backgroundColor = RGB_COLOR(@"#B4B4B4", 1);
    orderButton.layer.cornerRadius = 29/2.0;
    orderButton.layer.masksToBounds = true;
    [bodyView addSubview:orderButton];
    [orderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bodyView).offset(-14);
        make.height.equalTo(@29);
        make.bottom.equalTo(weakSelf.view.safeAreaLayoutGuide).offset(-14);
    }];

    orderButtonLabel = [[UILabel alloc] init];
    orderButtonLabel.textColor = [UIColor whiteColor];
    orderButtonLabel.backgroundColor = [UIColor clearColor];
    orderButtonLabel.textAlignment = NSTextAlignmentCenter;
    orderButtonLabel.font = [UIFont systemFontOfSize:13];
    [bodyView addSubview:orderButtonLabel];
    [orderButtonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(orderButton);
        make.left.right.equalTo(orderButton).inset(10);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:[RemoteControllerCell self] forCellWithReuseIdentifier:@"RemoteControllerCell"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [bodyView addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(bodyView);
        collectionHeightConstrain = make.height.equalTo(@280);
        make.bottom.equalTo(orderButton.mas_top).offset(-6);
    }];
}

#pragma mark - private

- (void)refreshData:(NSNotification *)notification {
    NSString *leftCoin = (notification.userInfo[@"money"]);

    LiveUser *user = [Config myProfile];
    user.coin = minstr(leftCoin);
    [Config updateProfile:user];

    [self updateCoin];
}

- (void)reset {
    self.models = [NSMutableArray arrayWithArray:@[]];
    myDiamondLabel.text = @"";
}

- (void)changeUI {
    [self reset];
    switch (infoType) {
        case LiveToyInfoRemoteControllerForAnchorman:
            orderButtonLabel.text = orderName;
            titleLabel.text = orderName;
            titleImageView.image = [ImageBundle imagewithBundleName:@"control_order"];
            topBackgroundImageView.image = [ImageBundle imagewithBundleName:@"control_order_bg_bottom"];
            break;
        case LiveToyInfoRemoteControllerForToy:
            orderButtonLabel.text = toyName;
            titleLabel.text = toyName;
            titleImageView.image = [ImageBundle imagewithBundleName:@"remotecontroll"];
            topBackgroundImageView.image = [ImageBundle imagewithBundleName:@"remotecontroll_bottom_02"];
            break;
    }

    [self getInfo];
}

- (void)updateInfo:(NSDictionary*)info {
    NSString *coin = minstr(info[@"coin"]);
    coin = [coin stringByReplacingOccurrencesOfString:@"," withString:@""];
    double coinDo = [coin doubleValue];
    LiveUser *liveUser = [Config myProfile];
    liveUser.coin = [NSString stringWithFormat:@"%.2f",coinDo];

    [Config updateProfile:liveUser];
    [self updateCoin];

    NSArray *tempInfos = info[@"toylist"];
    NSArray *cmdInfos = info[@"cmd_list"];
    if ([tempInfos isKindOfClass:[NSArray class]]) {
        NSMutableArray *infos = [NSMutableArray arrayWithArray:tempInfos];
        [infos addObjectsFromArray:cmdInfos];

        NSMutableArray *models = [NSMutableArray array];
        for (int i = 0 ; i < infos.count ; i++) {
            RemoteOrderModel *model = [RemoteOrderModel modelWithDic:infos[i]];
            if (infoType == LiveToyInfoRemoteControllerForAnchorman) {
                [models addObject:model];
            } else if (infoType == LiveToyInfoRemoteControllerForToy && [model.type isEqualToString:@"3"]) {
                [models addObject:model];
            }
        }
        self.models = models;
    }
    [collectionView reloadData];
}

- (void)getInfo {
    WeakSelf
    [self.delegate remoteControllerViewControllerForGetInfo:infoType completed:^(NSDictionary * _Nonnull info) {
        [weakSelf updateInfo:info];
    }];
}

- (void)sendAction:(UIButton*)sender {
    if (!sender.isSelected) {
        return;
    }
    [self sendOrderAction];
}

- (void)updateCoin {
    LiveUser *user = [Config myProfile];
    NSString *currencyCoin = [YBToolClass getRateCurrency:user.coin showUnit:YES];
    myDiamondLabel.text = currencyCoin;
}

- (void)sendOrderAction {
    NSString *lianfa = @"y";
    if ([_selectModel.type isEqual:@"1"]) {
        lianfa = @"n";
    }

    /*******发送礼物开始 **********/
    NSDictionary *giftDic = @{
        @"liveuid":self.playModel.zhuboID,
        @"stream":self.playModel.stream,
        @"giftid":self.selectModel.ID,
        @"giftcount":@"1",
        @"is_cmd" : _selectModel.cmdType.integerValue == 1 ? @YES : @NO
    };

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.sendGift" withBaseDomian:YES andParameter:giftDic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [MBProgressHUD showError:YZMsg(@"liwuview_sendSuccess")];
            [strongSelf.delegate remoteControllerViewControllerForSendGiftInfo:info andLianFa:lianfa];
            NSArray *info2 = [info firstObject];
            NSString *coin = [info2 valueForKey:@"coin"];
            double coinDo = [coin doubleValue];
            LiveUser *liveUser = [Config myProfile];
            liveUser.coin  =  [NSString stringWithFormat:@"%.2f",coinDo];
            [Config updateProfile:liveUser];
            [strongSelf updateCoin];
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
    }];
}

- (void)recharge {
    [self.delegate remoteControllerViewControllerForRecharge];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    orderButton.backgroundColor = RGB_COLOR(@"#E06BCB", 1);
    orderButton.selected = true;
    if (indexPath.item > self.models.count) {
        return;
    }
    self.selectModel = self.models[indexPath.item];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RemoteControllerCell *cell = (RemoteControllerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"RemoteControllerCell" forIndexPath:indexPath];
    RemoteOrderModel *model = self.models[indexPath.item];
    switch (infoType) {
        case LiveToyInfoRemoteControllerForAnchorman:
            [cell updateOrder:indexPath.item info:model];
            break;
        case LiveToyInfoRemoteControllerForToy:
            [cell updateRemoteToy:indexPath.item info:model];
            break;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return collectionViewInset;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return itemSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return itemSpace;
}
@end
