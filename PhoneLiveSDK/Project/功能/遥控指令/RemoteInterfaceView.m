//
//  RemoteInterfaceView.m
//  c700LIVE
//
//  Created by s5346 on 2023/12/7.
//  Copyright © 2023 toby. All rights reserved.
//

#import "RemoteInterfaceView.h"

#define HiddenConnectInfo @"hiddenConnectInfo"
@implementation OrderUserModel

@end

@interface RemoteInterfaceView()<CAAnimationDelegate>
{
    BOOL isShowCoolDownAnimation;

    UIView *containerView;
    UIStackView *stackView;

    // connect view
    UIView *connectView;
    UILabel *connectTitleLabel;
    UILabel *connectSubTitleLabel;

    // 縮小等待執行者畫面
    UIView *smallWaitView;
    UIStackView *smallNextWaitManStackView;
    NSMutableArray<UILabel*> *smallWaitManColdTimeArray;
    NSMutableArray<UIView*> *smallWaitManColdTimeViewArray;
    CAShapeLayer *avatarColddownViewLayer;

    // 標題畫面
    UIView *titleView;
    UILabel *titleLabel;
    UIButton *arrowButton;
    UILabel *archorBleConnectedInfo;
    UILabel *batteryInfoLabel;
    UIButton *hiddenConnectInfoButton;
    UIView *titlelineView;

    // 正在控制的畫面
    UIView *mainView;
    UIView *circleView;
    UILabel *coldtimeLabel;
    UILabel *modelNameLabel;
    UIView *drawColdtimeView;
    CAShapeLayer *circleLayer;
    CGFloat circleRadius;
    UIView *pinkCircleView;
    UILabel *currentControlNameLabel;
    UIImageView *currentControlAvatarView;
    UILabel *currentQueueCountLabel;

    // 目前等待控制
    UIView *controlWaitView;
    UIStackView *nextControlManStackView;

    // 目前等待指令
    UIView *orderWaitView;
    UIStackView *nextOrderManStackView;

    // 剩餘執行時間
    UIView *remainingView;
    UILabel *remainingLabel;
}
@property (nonatomic, strong) OrderUserModel *currentUser;
@property (nonatomic, strong) NSMutableArray<OrderUserModel*> *totalQueue;
@property (nonatomic, assign) int currentCountdown;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property(nonatomic, assign) BOOL isArchor;
@end

@implementation RemoteInterfaceView

- (instancetype)initWithArchir:(BOOL)isArchor {
    self = [super init];
        if (self) {
//            [[NSUserDefaults standardUserDefaults] registerDefaults:@{HiddenConnectInfo: @NO}];
            
            self.isArchor = isArchor;
            isShowCoolDownAnimation = false;
            self.totalQueue = [NSMutableArray array];
            [self setupViews];
            [self showConnectView];
        }
        return self;
}

- (void)forceShrink:(CGPoint)point {
    if (!arrowButton.isSelected) {
        [self shrink];
    }
    WeakSelf
    [UIView animateWithDuration:kPrompt_DismisTime animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf updateContainerView:point.x y:point.y];
    }];
}

- (void)receiveOrderModel:(OrderUserModel*)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateData:info];
    });
}

- (void)changeToyStatus:(BOOL)isConnected {
    if (archorBleConnectedInfo == nil) {
        return;
    }
    archorBleConnectedInfo.text = isConnected ? YZMsg(@"live_toy_open") : YZMsg(@"live_toy_close");
    archorBleConnectedInfo.textColor = isConnected ? [UIColor greenColor] : [UIColor redColor];
}

- (void)showConnectView {
    isShowCoolDownAnimation = false;
    mainView.hidden = true;
    controlWaitView.hidden = true;
    orderWaitView.hidden = true;
    remainingView.hidden = true;
    smallWaitView.hidden = true;
    connectView.hidden = false;
    arrowButton.hidden = true;
    titleLabel.userInteractionEnabled = false;
    titlelineView.hidden = false;

    if (!self.isArchor) {
        hiddenConnectInfoButton.hidden = false;
        [self updateContainerView:CGRectGetMinX(containerView.frame) y:CGRectGetMinY(containerView.frame)];

        // 判斷是否只顯示 title view
        if ([[NSUserDefaults standardUserDefaults] boolForKey:HiddenConnectInfo]) {
            titlelineView.hidden = true;
            connectView.hidden = true;
        }
    }
}

-(void)changeBatteryInfo:(int)battery {
    if (batteryInfoLabel == nil) {
        return;
    }
    batteryInfoLabel.text = [NSString stringWithFormat:@"%@:%i%%", YZMsg(@"ToyDetailVC_battery"),battery];
    if (battery <= 20) {
        batteryInfoLabel.textColor = [UIColor redColor];
    } else {
        batteryInfoLabel.textColor = [UIColor greenColor];
    }
}

#pragma mark - update data
- (void)updateData:(OrderUserModel*)model {
    if (self.totalQueue.count > 0) {
        int index = (int)self.totalQueue.count - 1;
        OrderUserModel *lastModel = self.totalQueue[index];
        if (model.type == lastModel.type &&
            [model.giftID isEqualToString:lastModel.giftID] &&
            [model.uid isEqualToString:lastModel.uid]) {
            lastModel.second = [NSString stringWithFormat:@"%d", [lastModel.second intValue] + [model.second intValue]];
            self.totalQueue[index] = lastModel;
        } else {
            [self.totalQueue addObject:model];
        }
    } else {
        [self.totalQueue addObject:model];
    }

    [self nextQueue];
}

- (void)nextQueue {
    if (self.currentUser != nil) {
        [self updateWaitAndRemainingUI];
        // 合併下一個
        if (self.totalQueue.count > 0) {
            OrderUserModel *model = self.totalQueue[0];
            if (model.type == self.currentUser.type &&
                [model.giftID isEqualToString:self.currentUser.giftID] &&
                [model.uid isEqualToString:self.currentUser.uid]) {
                [self.totalQueue removeObject:model];
                self.currentCountdown += [model.second intValue];
                self.currentUser.second = [NSString stringWithFormat:@"%d", self.currentCountdown];
                [self removeSmallWaitMan];
                [self updateWaitAndRemainingUI];
                [self updateMainView:self.currentUser];
                [self smallViewAvatarColddown];
                if (self.currentUser.type == LiveToyInfoRemoteControllerForToy) {
                    if ([self.delegate respondsToSelector:@selector(remoteInterfaceViewDelegateForStartToy:)]) {
                        [self.delegate remoteInterfaceViewDelegateForStartToy:self.currentUser];
                    }
                }
            }
        }
        return;
    }

    if (self.totalQueue.count <= 0) {
        [self updateWaitAndRemainingUI];
        [self showConnectView];
        return;
    }

    OrderUserModel *model = self.totalQueue[0];
    [self.totalQueue removeObjectAtIndex:0];
    self.currentUser = model;

    if (self.currentUser.type == LiveToyInfoRemoteControllerForToy) {
        if ([self.delegate respondsToSelector:@selector(remoteInterfaceViewDelegateForStartToy:)]) {
            [self.delegate remoteInterfaceViewDelegateForStartToy:self.currentUser];
        }
    }

    [self updateWaitAndRemainingUI];
    [self updateMainView:self.currentUser];
    [self smallViewAvatarColddown];
}

#pragma mark - update UI
- (void)updateWaitAndRemainingUI {
    isShowCoolDownAnimation = true;
    if (arrowButton.isSelected) {
        [self showSmallView];
    } else {
        [self showDetailView];
    }
    [self updateWaitControlMan];
    [self updateWaitOrderMan];
    [self updateSmallWaitMan];
    [self updateRemainingTime];
    currentQueueCountLabel.text = [NSString stringWithFormat:@"%@: %ld位",
                                   YZMsg(@"RemoteInterfaceView_in_queue"),// 当前排队中
                                   self.totalQueue.count];

    if (!self.isArchor) {
        hiddenConnectInfoButton.hidden = true;
    }
    [self updateContainerView:CGRectGetMinX(containerView.frame) y:CGRectGetMinY(containerView.frame)];
}

- (void)updateMainView:(OrderUserModel*)model {
    // 操控人
    currentControlNameLabel.text = [NSString stringWithFormat:@"%@：%@", YZMsg(@"RemoteInterfaceView_remote_user"), model.name];
    modelNameLabel.text = model.orderName;
    coldtimeLabel.text = [NSString stringWithFormat:@"%@s", model.second];
    [currentControlAvatarView sd_setImageWithURL:[NSURL URLWithString:model.avatar]];

    [self startCountdownTimer];
    [self circleAnimation:[model.second intValue] layer:circleLayer];
}

- (void)updateWaitControlMan {
    for (UIView *tempView in nextControlManStackView.arrangedSubviews) {
        [nextControlManStackView removeArrangedSubview:tempView];
        [tempView removeAllSubviews];
    }

    NSMutableArray *toyControlArray = [NSMutableArray array];
    for (OrderUserModel *model in self.totalQueue) {
        if (model.type == LiveToyInfoRemoteControllerForToy) {
            [toyControlArray addObject:model];
        }
    }

    for (int i = 0; i < 2; i++) {
        if (i >= toyControlArray.count) {
            break;
        }
        OrderUserModel *model = toyControlArray[i];
        UIView *tempView = [self createQueueManView:model.name second:[model.second intValue] type:model.orderName];
        [nextControlManStackView addArrangedSubview:tempView];
    }

    if (!arrowButton.isSelected) {
        controlWaitView.hidden = toyControlArray.count > 0 ? false : true;
    }
}

- (void)updateWaitOrderMan {
    for (UIView *tempView in nextOrderManStackView.arrangedSubviews) {
        [nextOrderManStackView removeArrangedSubview:tempView];
        [tempView removeAllSubviews];
    }

    NSMutableArray *orderControlArray = [NSMutableArray array];
    for (OrderUserModel *model in self.totalQueue) {
        if (model.type == LiveToyInfoRemoteControllerForAnchorman) {
            [orderControlArray addObject:model];
        }
    }

    for (int i = 0; i < 2; i++) {
        if (i >= orderControlArray.count) {
            break;
        }
        OrderUserModel *model = orderControlArray[i];
        UIView *tempView = [self createQueueManView:model.name second:[model.second intValue] type:model.orderName];
        [nextOrderManStackView addArrangedSubview:tempView];
    }

    if (!arrowButton.isSelected) {
        orderWaitView.hidden = orderControlArray.count > 0 ? false : true;
    }
}

- (void)updateSmallWaitMan {
    NSMutableArray *containerMainArray = [NSMutableArray array];
    if (self.currentUser != nil) {
        [containerMainArray addObject:self.currentUser];
    }
    [containerMainArray addObjectsFromArray:self.totalQueue];

    for (int i = (int)smallNextWaitManStackView.arrangedSubviews.count; i < 2; i++) {
        if (i >= containerMainArray.count) {
            return;
        }
        OrderUserModel *model = containerMainArray[i];
        UIView *tempView = [self createSmallWaitManViewForName:model.name order:model.orderName avatar:model.avatar];
        [smallNextWaitManStackView addArrangedSubview:tempView];
    }
}

- (void)removeSmallWaitMan {
    UIView *tempView = [smallNextWaitManStackView.arrangedSubviews firstObject];
    [smallNextWaitManStackView removeArrangedSubview:tempView];
    [tempView removeAllSubviews];

    if (smallWaitManColdTimeArray.count > 0) {
        [smallWaitManColdTimeArray removeObjectAtIndex:0];
    }

    if (smallWaitManColdTimeViewArray.count > 0) {
        [smallWaitManColdTimeViewArray removeObjectAtIndex:0];
    }
}

- (void)updateRemainingTime {
    int totalTime = 0;
    for (OrderUserModel *model in self.totalQueue) {
        totalTime += [model.second intValue];
    }
    // 剩余执行时长
    remainingLabel.text = [NSString stringWithFormat:@"%@: %ds", YZMsg(@"RemoteInterfaceView_remain_time"), totalTime];

    if (!arrowButton.isSelected) {
        [remainingView setHidden:orderWaitView.isHidden && controlWaitView.isHidden];
    }
}

- (void)smallViewAvatarColddown {
    [self updateSmallWaitManColdTime:self.currentCountdown];
    [smallWaitView layoutIfNeeded];
    UIView *avatarColddownView = [smallWaitManColdTimeViewArray firstObject];
    [avatarColddownView.layer addSublayer:[self addCircleLayer:RGB_COLOR(@"#EA4D8E", 1) frame:avatarColddownView.bounds lineWidth:3]];
    avatarColddownViewLayer = [self addCircleLayer:[UIColor whiteColor] frame:avatarColddownView.bounds lineWidth:3];
    [avatarColddownView.layer addSublayer:avatarColddownViewLayer];
    [self circleAnimation:[self.currentUser.second intValue] layer:avatarColddownViewLayer];
}

#pragma mark - private
- (void)showDetailView {
    mainView.hidden = false;
    connectView.hidden = true;
    smallWaitView.hidden = true;
    arrowButton.hidden = false;
    titleLabel.userInteractionEnabled = true;

    if (!arrowButton.isSelected) {
        controlWaitView.hidden = nextControlManStackView.arrangedSubviews.count > 0 ? false : true;
        orderWaitView.hidden = nextOrderManStackView.arrangedSubviews.count > 0 ? false : true;
        [remainingView setHidden:orderWaitView.isHidden && controlWaitView.isHidden];
    }
}

- (void)showSmallView {
    mainView.hidden = true;
    controlWaitView.hidden = true;
    orderWaitView.hidden = true;
    remainingView.hidden = true;
    connectView.hidden = true;
    smallWaitView.hidden = false;
    arrowButton.hidden = false;
    titleLabel.userInteractionEnabled = true;
}

- (void)onlyShowMainView {
    mainView.hidden = false;
    controlWaitView.hidden = true;
    orderWaitView.hidden = true;
    remainingView.hidden = true;
    connectView.hidden = true;
    smallWaitView.hidden = true;
    arrowButton.hidden = false;
    titleLabel.userInteractionEnabled = true;
}

- (void)shrink {
    if (arrowButton.isHidden) {
        return;
    }

    [self updateContainerView:CGRectGetMinX(containerView.frame) y:CGRectGetMinY(containerView.frame)];

    if (arrowButton.isSelected) {
        arrowButton.selected = false;
        [self showDetailView];
    } else {
        arrowButton.selected = true;
        [self showSmallView];
    }
}

- (void)updateSmallWaitManColdTime:(int)time {
    UILabel *tempLabel = [smallWaitManColdTimeArray firstObject];
    tempLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    tempLabel.text = [NSString stringWithFormat:@"%ds", time];
}

- (void)circleAnimation:(CGFloat)maxColdtimeCount layer:(CAShapeLayer*)layer {
    if (layer == nil) {
        return;
    }
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.delegate = self;
    drawAnimation.duration = maxColdtimeCount;
//    [drawAnimation setValue:circleLayer forKey:@"afterBorderLoading"];
    drawAnimation.fromValue = @(0.0);
    drawAnimation.toValue = @(1.0);
    drawAnimation.removedOnCompletion = false;
    drawAnimation.fillMode = kCAFillModeForwards;
    [layer addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
}

- (void)startCountdownTimer {
    if (self.countdownTimer != nil) {
        return;
    }
    self.currentCountdown = [self.currentUser.second intValue];
    WeakSelf;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
        STRONGSELF;
        if (strongSelf.currentCountdown <= 0) {
            [strongSelf startNextQueue];
            return;
        }
        strongSelf.currentCountdown -= 1;
        strongSelf->coldtimeLabel.text = [NSString stringWithFormat:@"%ds", self.currentCountdown];
        [strongSelf updateSmallWaitManColdTime:strongSelf.currentCountdown];
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
}

- (void)startNextQueue {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    [self removeSmallWaitMan];
    [self reset];
    [self nextQueue];
}

- (void)updateContainerView:(CGFloat)x y:(CGFloat)y {
    if (containerView == nil) {
        // containerView 已被销毁或不在窗口上，不执行设置约束的操作
        return;
    }

    WeakSelf
    [containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        make.left.equalTo(strongSelf).offset(x);
        make.top.equalTo(strongSelf).offset(y);
        if (strongSelf->isShowCoolDownAnimation == false && !strongSelf.isArchor) {
            make.width.equalTo(@AD(120));
        } else {
            make.width.equalTo(@AD(198));
        }
    }];
}

- (void)tapTpSelectToy {
    if ([self.delegate respondsToSelector:@selector(remoteInterfaceViewDelegateForSelectToy)]) {
        [self.delegate remoteInterfaceViewDelegateForSelectToy];
    }
}

- (void)showGiftPanel {
    if ([self.delegate respondsToSelector:@selector(remoteInterfaceViewDelegateForShowPanel)]) {
        [self.delegate remoteInterfaceViewDelegateForShowPanel];
    }
}

- (void)hiddenConnectInfo {
    hiddenConnectInfoButton.selected = !hiddenConnectInfoButton.isSelected;
    [[NSUserDefaults standardUserDefaults] setBool:hiddenConnectInfoButton.isSelected forKey:HiddenConnectInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showConnectView];
}

#pragma mark - UI

- (void)setupViews {
    containerView = [[UIView alloc] init];
    containerView.layer.cornerRadius = 8;
    containerView.layer.masksToBounds = true;
    containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self addSubview:containerView];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [containerView addGestureRecognizer:pan];

    [self updateContainerView:AD(16.6) y:AD(153)];

    stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    [containerView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];

    titleView = [self createTtitleView];
    [stackView addArrangedSubview:titleView];

    mainView = [self createMainView];
    [stackView addArrangedSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(stackView).inset(3);
    }];

    controlWaitView = [self createRemoteView];
    [stackView addArrangedSubview:controlWaitView];

    orderWaitView = [self createOrderView];
    [stackView addArrangedSubview:orderWaitView];

    remainingView = [self createRemainingView];
    [stackView addArrangedSubview:remainingView];

    smallWaitView = [self createSmallWaitView];
    [stackView addArrangedSubview:smallWaitView];

    connectView = [self createConnectView];
    [stackView addArrangedSubview:connectView];

    [self layoutIfNeeded];
    [self addColdtimeCircle];
}

- (UIView*)createQueueManView:(NSString*)name second:(int)second type:(NSString*)type {
    UIView *tempView = [[UIView alloc] init];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@AD(20));
    }];

    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.text = type;
    typeLabel.textColor = [UIColor whiteColor];
    typeLabel.font = [UIFont boldSystemFontOfSize:12];
    typeLabel.minimumScaleFactor = 0.5;
    typeLabel.adjustsFontSizeToFitWidth = true;
    [tempView addSubview:typeLabel];
    [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(tempView);
        make.width.equalTo(tempView).multipliedBy(1/3.0);
    }];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = name;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:12];
    nameLabel.minimumScaleFactor = 0.5;
    nameLabel.adjustsFontSizeToFitWidth = true;
    [tempView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(tempView);
    }];

    UILabel *secondLabel = [[UILabel alloc] init];
    secondLabel.text = [NSString stringWithFormat:@"%ds", second];
    secondLabel.textColor = RGB_COLOR(@"#EA4D8E", 1);
    secondLabel.font = [UIFont boldSystemFontOfSize:12];
    [tempView addSubview:secondLabel];
    [secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(tempView);
        make.left.equalTo(nameLabel.mas_right).offset(4);
        make.right.lessThanOrEqualTo(typeLabel.mas_left).offset(-2);
    }];

    [nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [secondLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    return tempView;
}

// connect view
- (UIView*)createConnectView {
    UIView *tempView = [[UIView alloc] init];

    UIView *connectView = [[UIView alloc] init];
    [tempView addSubview:connectView];
    [connectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@AD(72));
        make.top.equalTo(tempView).offset(AD(11));
        make.bottom.equalTo(tempView).offset(-AD(11));
        make.centerX.equalTo(tempView);
    }];

    UIImageView *connectBackgroundImageView = [[UIImageView alloc] init];
    connectBackgroundImageView.userInteractionEnabled = true;
    connectBackgroundImageView.image = [ImageBundle imagewithBundleName:@"remote_bootom"];
    [connectView addSubview:connectBackgroundImageView];
    [connectBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(connectView);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGiftPanel)];
    [connectBackgroundImageView addGestureRecognizer:tap];

    UIImageView *remoteIcon = [[UIImageView alloc] init];
    remoteIcon.image = [ImageBundle imagewithBundleName:@"remotecontroll"];
    [connectView addSubview:remoteIcon];
    [remoteIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@AD(22));
        make.top.equalTo(connectView).offset(AD(10));
        make.centerX.equalTo(connectView);
    }];

    connectTitleLabel = [[UILabel alloc] init];
    connectTitleLabel.text = YZMsg(@"RemoteInterfaceView_toy_connect");// 跳蛋已連接
    connectTitleLabel.textAlignment = NSTextAlignmentCenter;
    connectTitleLabel.textColor = [UIColor whiteColor];
    connectTitleLabel.font = [UIFont boldSystemFontOfSize:12];
    connectTitleLabel.adjustsFontSizeToFitWidth = true;
    connectTitleLabel.minimumScaleFactor = 0.5;
    [connectView addSubview:connectTitleLabel];
    [connectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remoteIcon.mas_bottom).offset(AD(4));
        make.left.right.equalTo(connectView).inset(4);
    }];

    connectSubTitleLabel = [[UILabel alloc] init];
    connectSubTitleLabel.text = YZMsg(@"RemoteInterfaceView_wait_you_control");// 等你來操控
    connectSubTitleLabel.textAlignment = NSTextAlignmentCenter;
    connectSubTitleLabel.textColor = [UIColor whiteColor];
    connectSubTitleLabel.font = [UIFont boldSystemFontOfSize:10];
    connectSubTitleLabel.adjustsFontSizeToFitWidth = true;
    connectSubTitleLabel.minimumScaleFactor = 0.5;
    [connectView addSubview:connectSubTitleLabel];
    [connectSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(connectTitleLabel.mas_bottom).offset(AD(2));
        make.left.right.equalTo(connectView).inset(AD(12));
    }];

    return tempView;
}

// 縮小等待執行者畫面
- (UIView*)createSmallWaitView {
    UIView *tempView = [[UIView alloc] init];
    smallWaitManColdTimeArray = [NSMutableArray array];
    smallWaitManColdTimeViewArray = [NSMutableArray array];

    smallNextWaitManStackView = [[UIStackView alloc] init];
    smallNextWaitManStackView.spacing = AD(10);
    smallNextWaitManStackView.axis = UILayoutConstraintAxisVertical;
    [tempView addSubview:smallNextWaitManStackView];
    [smallNextWaitManStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tempView).offset(AD(18));
        make.left.equalTo(tempView).offset(AD(30));
        make.right.equalTo(tempView).offset(-AD(30));
        make.bottom.equalTo(tempView).offset(-AD(18));
    }];

    return tempView;
}

- (UIView*)createSmallWaitManViewForName:(NSString*)name order:(NSString*)order avatar:(NSString*)avatar {
    UIView *tempView = [[UIView alloc] init];

    UIView *cellView = [[UIView alloc] init];
    [tempView addSubview:cellView];
    cellView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    cellView.layer.cornerRadius = 10;
    cellView.layer.masksToBounds = true;
    [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tempView);
    }];

    UIImageView *avatarView = [[UIImageView alloc] init];
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatar]];
    avatarView.backgroundColor = [UIColor whiteColor];
    [tempView addSubview:avatarView];
    avatarView.layer.cornerRadius = AD(36)/2;
    avatarView.layer.masksToBounds = true;
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@AD(36));
        make.left.equalTo(cellView).offset(-AD(4));
        make.centerY.equalTo(cellView);
        make.bottom.equalTo(cellView);
    }];

    UIView *avatarColddownView = [[UIView alloc] init];
    avatarColddownView.layer.cornerRadius = (AD(36) + 3)/2;
    avatarColddownView.layer.masksToBounds = true;
    avatarColddownView.backgroundColor = RGB_COLOR(@"#EA4D8E", 1);
    [tempView insertSubview:avatarColddownView belowSubview:avatarView];
    [avatarColddownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(avatarView);
        make.size.equalTo(@(AD(36) + 3));
    }];
    [smallWaitManColdTimeViewArray addObject:avatarColddownView];

    UILabel *timeLabel = [[UILabel alloc] init];
    [avatarView addSubview:timeLabel];
    [smallWaitManColdTimeArray addObject:timeLabel];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont boldSystemFontOfSize:12];
    timeLabel.adjustsFontSizeToFitWidth = true;
    timeLabel.minimumScaleFactor = 0.5;
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(avatarView);
    }];

    UILabel *orderLabel = [[UILabel alloc] init];
    orderLabel.text = [NSString stringWithFormat:@"%@: %@", YZMsg(@"RemoteInterfaceView_order_name"), order];// 指令
    [cellView addSubview:orderLabel];
    orderLabel.textColor = [UIColor whiteColor];
    orderLabel.font = [UIFont boldSystemFontOfSize:10];
    orderLabel.adjustsFontSizeToFitWidth = true;
    orderLabel.minimumScaleFactor = 0.5;
    [orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatarView.mas_right).offset(5);
        make.right.equalTo(cellView).offset(-4);
        make.centerY.equalTo(avatarView).offset(-AD(8));
    }];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = [NSString stringWithFormat:@"%@: %@", YZMsg(@"RemoteInterfaceView_remote_user"), name];// 操控人
    [cellView addSubview:nameLabel];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:10];
    nameLabel.adjustsFontSizeToFitWidth = true;
    nameLabel.minimumScaleFactor = 0.5;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatarView.mas_right).offset(5);
        make.right.equalTo(cellView).offset(-4);
        make.centerY.equalTo(avatarView).offset(AD(8));
    }];

    [orderLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    return tempView;
}

// 上方面板
- (UIView*)createTtitleView {
    UIView *tempView = [[UIView alloc] init];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@AD(35));
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrink)];
    [tempView addGestureRecognizer:tap];

    arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowButton.userInteractionEnabled = false;
    [arrowButton setBackgroundImage:[ImageBundle imagewithBundleName:@"arrow_close"] forState:UIControlStateNormal];
    [arrowButton setBackgroundImage:[ImageBundle imagewithBundleName:@"arrow_open"] forState:UIControlStateSelected];
    [tempView addSubview:arrowButton];
    [arrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@11.5);
        make.height.equalTo(@6);
        make.right.equalTo(tempView.mas_right).offset(-15);
        make.centerY.equalTo(tempView);
    }];

    titleLabel = [[UILabel alloc] init];
    titleLabel.userInteractionEnabled = true;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.text = YZMsg(@"RemoteInterfaceView_control_and_order");// 遙控&指令
    titleLabel.textColor = RGB_COLOR(@"#EB4E8D", 1);
    titleLabel.minimumScaleFactor = 0.2;
    titleLabel.adjustsFontSizeToFitWidth = true;
    titleLabel.numberOfLines = 2;
    [tempView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(tempView);
        make.left.right.equalTo(tempView).inset(28);
    }];

    titlelineView = [[UIView alloc] init];
    titlelineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [tempView addSubview:titlelineView];
    [titlelineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(tempView);
        make.height.equalTo(@1);
    }];

    if (self.isArchor) {
        archorBleConnectedInfo = [[UILabel alloc] init];
        archorBleConnectedInfo.userInteractionEnabled = true;
        archorBleConnectedInfo.textColor = [UIColor redColor];
        archorBleConnectedInfo.font = [UIFont systemFontOfSize:10];
        [tempView addSubview:archorBleConnectedInfo];
        [archorBleConnectedInfo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(tempView);
            make.left.equalTo(tempView).offset(4);
        }];

        UITapGestureRecognizer *tapToToy = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTpSelectToy)];
        [archorBleConnectedInfo addGestureRecognizer:tapToToy];

        batteryInfoLabel = [[UILabel alloc] init];
        batteryInfoLabel.textColor = [UIColor greenColor];
        batteryInfoLabel.font = [UIFont systemFontOfSize:8];
        [tempView addSubview:batteryInfoLabel];
        [batteryInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.equalTo(tempView);
            make.right.equalTo(tempView).offset(-3);
        }];
    } else {
        hiddenConnectInfoButton = [[UIButton alloc] init];
        hiddenConnectInfoButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:HiddenConnectInfo];
        [hiddenConnectInfoButton setImage:[ImageBundle imagewithBundleName:@"arrow_return"] forState:UIControlStateNormal];
        hiddenConnectInfoButton.imageEdgeInsets = UIEdgeInsetsMake(14, 12, 14, 16);
        [hiddenConnectInfoButton addTarget:self action:@selector(hiddenConnectInfo) forControlEvents:UIControlEventTouchUpInside];
        [tempView addSubview:hiddenConnectInfoButton];
        [hiddenConnectInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tempView);
            make.centerY.equalTo(tempView);
            make.size.equalTo(@40);
        }];
    }

    return tempView;
}

// 主要倒數面板
- (UIView*)createMainView {
    circleRadius = AD(72);
    UIView *tempView = [[UIView alloc] init];

    circleView = [self createColdtimeView];
    circleView.layer.cornerRadius = circleRadius/2.0;
    circleView.layer.masksToBounds = true;
    [tempView addSubview:circleView];
    [circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tempView).offset(AD(12));
        make.size.equalTo(@(circleRadius));
        make.centerX.equalTo(tempView);
    }];

    coldtimeLabel = [[UILabel alloc] init];
    coldtimeLabel.textColor = [UIColor whiteColor];
    coldtimeLabel.font = [UIFont boldSystemFontOfSize:18];
    coldtimeLabel.textAlignment = NSTextAlignmentCenter;
    coldtimeLabel.adjustsFontSizeToFitWidth = true;
    coldtimeLabel.minimumScaleFactor = 0.5;
    [tempView addSubview:coldtimeLabel];
    [coldtimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(circleView).offset(AD(15.6));
        make.width.equalTo(@AD(54));
        make.height.equalTo(@AD(26));
        make.centerX.equalTo(tempView);
    }];

    modelNameLabel = [[UILabel alloc] init];
    modelNameLabel.textColor = [UIColor whiteColor];
    modelNameLabel.font = [UIFont boldSystemFontOfSize:8];
    modelNameLabel.textAlignment = NSTextAlignmentCenter;
    modelNameLabel.adjustsFontSizeToFitWidth = true;
    modelNameLabel.minimumScaleFactor = 0.5;
    [tempView addSubview:modelNameLabel];
    [modelNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(coldtimeLabel.mas_bottom);
        make.width.centerX.equalTo(coldtimeLabel);
    }];

    UIStackView *currentControlStackView = [[UIStackView alloc] init];
    currentControlStackView.spacing = AD(-4);
    currentControlStackView.alignment = UIStackViewAlignmentCenter;
    [tempView addSubview:currentControlStackView];
    [currentControlStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(circleView.mas_bottom).offset(AD(-2));
        make.centerX.equalTo(circleView);
        make.height.equalTo(@AD(34));
        make.width.lessThanOrEqualTo(tempView);
    }];

    currentControlAvatarView = [[UIImageView alloc] init];
    currentControlAvatarView.backgroundColor = [UIColor whiteColor];
    CGFloat currentControlAvatarViewHeight = AD(34);
    currentControlAvatarView.layer.cornerRadius = currentControlAvatarViewHeight / 2.0;
    currentControlAvatarView.layer.borderWidth = 1;
    currentControlAvatarView.layer.borderColor = RGB_COLOR(@"#EA4D8E", 1).CGColor;
    currentControlAvatarView.layer.masksToBounds = true;
    [currentControlStackView addArrangedSubview:currentControlAvatarView];
    [currentControlAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(currentControlAvatarViewHeight));
    }];

    UIView *currentControlView = [[UIView alloc] init];
    CGFloat currentControlViewHeight = AD(21);
    currentControlView.layer.cornerRadius = currentControlViewHeight / 2.0;
    currentControlView.layer.masksToBounds = true;
    currentControlView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [currentControlStackView addArrangedSubview:currentControlView];
    [currentControlStackView sendSubviewToBack:currentControlView];
    [currentControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(currentControlViewHeight));
    }];

    currentControlNameLabel = [[UILabel alloc] init];
    currentControlNameLabel.textColor = [UIColor whiteColor];
    currentControlNameLabel.font = [UIFont boldSystemFontOfSize:12];
    currentControlNameLabel.minimumScaleFactor = 0.7;
    currentControlNameLabel.adjustsFontSizeToFitWidth = true;
    [currentControlView addSubview:currentControlNameLabel];
    [currentControlNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(currentControlView);
        make.left.equalTo(currentControlView).offset(AD(9));
        make.right.equalTo(currentControlView).offset(-AD(10));
    }];

    currentQueueCountLabel = [[UILabel alloc] init];
    currentQueueCountLabel.textColor = RGB_COLOR(@"#EA4D8E", 1);
    currentQueueCountLabel.font = [UIFont boldSystemFontOfSize:12];
    currentQueueCountLabel.textAlignment = NSTextAlignmentCenter;
    currentQueueCountLabel.adjustsFontSizeToFitWidth = true;
    currentQueueCountLabel.minimumScaleFactor = 0.5;
    [tempView addSubview:currentQueueCountLabel];
    [currentQueueCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(currentControlStackView.mas_bottom).offset(10);
        make.left.right.equalTo(tempView);
        make.height.equalTo(@AD(20));
        make.bottom.equalTo(tempView.mas_bottom).offset(-6);
    }];

    return tempView;
}

// 遙控等待介面
- (UIView*)createRemoteView {
    UIView *tempView = [[UIView alloc] init];

    UIImageView *remoteIcon = [[UIImageView alloc] init];
    remoteIcon.image = [ImageBundle imagewithBundleName:@"remotecontroll"];
    [tempView addSubview:remoteIcon];
    [remoteIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@AD(22));
        make.top.equalTo(tempView);
        make.left.equalTo(tempView).offset(AD(22));
    }];

    UILabel *remoteTitleLabel = [[UILabel alloc] init];
    remoteTitleLabel.text = YZMsg(@"RemoteInterfaceView_toy_title");
    remoteTitleLabel.textColor = [UIColor whiteColor];
    remoteTitleLabel.font = [UIFont boldSystemFontOfSize:12];
    remoteTitleLabel.adjustsFontSizeToFitWidth = true;
    remoteTitleLabel.minimumScaleFactor = 0.5;
    [tempView addSubview:remoteTitleLabel];
    [remoteTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(remoteIcon);
        make.left.equalTo(remoteIcon.mas_right).offset(15);
        make.right.equalTo(tempView).offset(-4);
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [tempView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remoteIcon.mas_bottom).offset(4);
        make.left.equalTo(tempView).offset(AD(22));
        make.right.equalTo(tempView).offset(-AD(22));
        make.height.equalTo(@1);
    }];

    nextControlManStackView = [[UIStackView alloc] init];
    nextControlManStackView.spacing = 4;
    nextControlManStackView.axis = UILayoutConstraintAxisVertical;
    [tempView addSubview:nextControlManStackView];
    [nextControlManStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(8);
        make.left.right.equalTo(lineView);
        make.bottom.equalTo(tempView.mas_bottom).offset(-10);
    }];

    return tempView;
}

// 指令等待介面
- (UIView*)createOrderView {
    UIView *tempView = [[UIView alloc] init];

    UIImageView *remoteIcon = [[UIImageView alloc] init];
    remoteIcon.image = [ImageBundle imagewithBundleName:@"control_order"];
    [tempView addSubview:remoteIcon];
    [remoteIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@AD(22));
        make.top.equalTo(tempView);
        make.left.equalTo(tempView).offset(AD(22));
    }];

    UILabel *orderTitleLabel = [[UILabel alloc] init];
    orderTitleLabel.text = YZMsg(@"RemoteInterfaceView_order_title");
    orderTitleLabel.textColor = [UIColor whiteColor];
    orderTitleLabel.font = [UIFont boldSystemFontOfSize:12];
    orderTitleLabel.adjustsFontSizeToFitWidth = true;
    orderTitleLabel.minimumScaleFactor = 0.5;
    [tempView addSubview:orderTitleLabel];
    [orderTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(remoteIcon);
        make.left.equalTo(remoteIcon.mas_right).offset(15);
        make.right.equalTo(tempView).offset(-4);
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [tempView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remoteIcon.mas_bottom).offset(4);
        make.left.equalTo(tempView).offset(AD(22));
        make.right.equalTo(tempView).offset(-AD(22));
        make.height.equalTo(@1);
    }];

    nextOrderManStackView = [[UIStackView alloc] init];
    nextOrderManStackView.spacing = 4;
    nextOrderManStackView.axis = UILayoutConstraintAxisVertical;
    [tempView addSubview:nextOrderManStackView];
    [nextOrderManStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(8);
        make.left.right.equalTo(lineView);
        make.bottom.equalTo(tempView.mas_bottom).offset(-10);
    }];

    return tempView;
}

// 剩餘時間
- (UIView*)createRemainingView {
    UIView *tempView = [[UIView alloc] init];

    remainingLabel = [[UILabel alloc] init];
    remainingLabel.text = [NSString stringWithFormat:@"%@: %@s", YZMsg(@"RemoteInterfaceView_remain_time"), @"0"];// 剩餘執行時長
    remainingLabel.textAlignment = NSTextAlignmentCenter;
    remainingLabel.font = [UIFont boldSystemFontOfSize:12];
    remainingLabel.textColor = RGB_COLOR(@"#EA4D8E", 1);
    remainingLabel.minimumScaleFactor = 0.7;
    remainingLabel.adjustsFontSizeToFitWidth = true;
    [tempView addSubview:remainingLabel];
    [remainingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tempView).offset(AD(0));
        make.left.right.equalTo(tempView).inset(4);
        make.bottom.equalTo(tempView.mas_bottom).offset(-AD(14));
    }];

    return tempView;
}

// 倒數圓圈畫面
- (UIView*)createColdtimeView {
    UIView *tempView = [[UIView alloc] init];
    tempView.layer.cornerRadius = circleRadius/2.0;
    tempView.layer.masksToBounds = true;
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(circleRadius));
    }];

    pinkCircleView = [[UIView alloc] init];
    [tempView addSubview:pinkCircleView];
    [pinkCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tempView);
    }];

    drawColdtimeView = [[UIView alloc] init];
    drawColdtimeView.backgroundColor = [UIColor clearColor];
    [tempView addSubview:drawColdtimeView];
    [drawColdtimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tempView);
    }];

    UIImageView *blackCircle = [[UIImageView alloc] init];
    blackCircle.image = [ImageBundle imagewithBundleName:@"coldtime_black_circle"];
    [tempView addSubview:blackCircle];
    [blackCircle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tempView);
    }];

    return tempView;
}

- (CAShapeLayer*)addCircleLayer:(UIColor*)circleColor frame:(CGRect)receiveframe lineWidth:(CGFloat)receiveLineWidth {
    CGFloat lineWidth = receiveLineWidth;
    CGFloat circleRadius = receiveframe.size.width;
    CGFloat radius = circleRadius / 2.0 - lineWidth / 2.0;
    double aDegree = M_PI / 180;
    double startDegree = 270;
    double endDegree = startDegree + 1;

    UIBezierPath *circularPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(receiveframe), CGRectGetMidY(receiveframe))
                                                                radius:radius
                                                            startAngle:aDegree * startDegree
                                                              endAngle:aDegree * endDegree
                                                             clockwise:NO];
    CAShapeLayer *drawLayer = [CAShapeLayer layer];
    drawLayer.path = circularPath.CGPath;
    drawLayer.strokeColor = circleColor.CGColor;
    drawLayer.lineWidth = lineWidth;
    drawLayer.fillColor = [UIColor clearColor].CGColor;
    return drawLayer;
}

- (void)addColdtimeCircle {
    [pinkCircleView.layer addSublayer:[self addCircleLayer:RGB_COLOR(@"#EA4D8E", 1) frame:drawColdtimeView.frame lineWidth:AD(8)]];
    circleLayer = [self addCircleLayer:[UIColor whiteColor] frame:drawColdtimeView.frame lineWidth:AD(8)];
    [drawColdtimeView.layer addSublayer:circleLayer];
}

- (void)reset {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    self.currentUser = nil;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        return;
    }
}

#pragma mark - 懸浮視窗移動
-(void)changePostion:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];

    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    CGRect originalFrame = containerView.frame;
    if (originalFrame.origin.x >= 0 && originalFrame.origin.x+originalFrame.size.width <= width) {
        originalFrame.origin.x += point.x;
    }
    if (originalFrame.origin.y >= 0 && originalFrame.origin.y+originalFrame.size.height <= height) {
        originalFrame.origin.y += point.y;
    }
    containerView.frame = originalFrame;
    [self updateContainerView:originalFrame.origin.x y:originalFrame.origin.y];
    [pan setTranslation:CGPointZero inView:self];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self beginPoint];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self changePoint];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self endPoint];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            [self endPoint];
        }
            break;

        default:
            break;
    }

}

- (void)beginPoint {

    titleLabel.userInteractionEnabled = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
- (void)changePoint {

    BOOL isOver = NO;

    CGRect frame = containerView.frame;

    if (frame.origin.x < 0) {
        frame.origin.x = 0;
        isOver = YES;
    } else if (frame.origin.x+frame.size.width > _window_width) {
        frame.origin.x = _window_width - frame.size.width;
        isOver = YES;
    }

    if (frame.origin.y < 20 + statusbarHeight) {
        frame.origin.y = 20 + statusbarHeight;
        isOver = YES;
    } else if (frame.origin.y+frame.size.height > _window_height) {
        frame.origin.y = _window_height - frame.size.height;
        isOver = YES;
    }
    if (isOver) {
        WeakSelf
        [UIView animateWithDuration:kPrompt_DismisTime animations:^{
            STRONGSELF
            if (strongSelf==nil) {
                return;
            }
            strongSelf->containerView.frame = frame;
            [strongSelf updateContainerView:frame.origin.x y:frame.origin.y];
        }];
    }
    titleLabel.userInteractionEnabled = YES;

}
static CGFloat _allowance = 30;
- (void)endPoint {
    CGFloat posX = containerView.frame.origin.x;
    CGFloat posY = containerView.frame.origin.y;
    CGRect frame = containerView.frame;
    if (posX <= _window_width / 2 - containerView.width/2) {

        if (posY >= _window_height - containerView.height - _allowance - (20 + statusbarHeight)) {
            frame.origin.y = _window_height - containerView.height ;
        }else{
            if (posY <= 20 + statusbarHeight + _allowance) {
                frame.origin.y = 20 + statusbarHeight;
            }else{
                frame.origin.x = 0;
            }
        }
    }else
    {
        if (posY >= _window_height - containerView.height - _allowance - (20 + statusbarHeight)) {
            frame.origin.y = _window_height - containerView.height;
        }else{
            if (posY <= 20 + statusbarHeight + _allowance) {
                frame.origin.y = 20 + statusbarHeight;
            }else{
                frame.origin.x = _window_width - containerView.width;
            }
        }
    }
    WeakSelf
    [UIView animateWithDuration:kPrompt_DismisTime animations:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->containerView.frame = frame;
        [strongSelf updateContainerView:frame.origin.x y:frame.origin.y];
    }];
    titleLabel.userInteractionEnabled = YES;
}
@end
