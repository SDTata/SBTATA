//
//  DailyCheckInViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/8/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DailyCheckInViewController.h"
#import "DailyCheckInCell.h"
#import "GradientProgressView.h"
#import "UserBonusModel.h"
#import "BindPhoneNumberViewController.h"

@interface DailyCheckInViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *floatingView;
@property (nonatomic, strong) UILabel *checkInDayLabel;
@property (nonatomic, strong) UICollectionView *dayCollectionView;
@property (nonatomic, strong) NSArray<UserBonusItemModel*> *sevenDayItems;
@property (nonatomic, strong) UserBonusModel *dataSource;
@property (nonatomic, strong) UIView *continuosView;

@end

@implementation DailyCheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];

    self.floatingView.transform = CGAffineTransformMakeTranslation(0, self.floatingView.bounds.size.height);
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnFloatingView:)];
    self.floatingView.userInteractionEnabled = YES;
    [self.floatingView addGestureRecognizer:pan];

    [self pullInternet];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.floatingView.transform = CGAffineTransformIdentity;
    } completion:^(UIViewAnimatingPosition finalPosition) {
    }];
}

- (void)update {
    [self.dayCollectionView reloadData];
    [self updateDailyCheckInText];

    [self.continuosView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *continuosView = [self createContinuousCheckInView];
    [self.continuosView addSubview:continuosView];
    [continuosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.continuosView);
    }];
}

- (void)updateDailyCheckInText {
    NSString *continuousDay = self.dataSource.count_day.length > 0 ? self.dataSource.count_day : @"";
    NSString *fullText = [NSString stringWithFormat:@"%@ %@ %@",
                          YZMsg(@"ContinuousCheckin"),
                          continuousDay,
                          YZMsg(@"public_Day")];

    NSDictionary *defaultAttributes = @{NSForegroundColorAttributeName: RGB_COLOR(@"#000000", 0.7),
                                        NSFontAttributeName: [UIFont boldSystemFontOfSize:20]};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullText attributes:defaultAttributes];
    NSRange numberRange = [fullText rangeOfString:continuousDay];
    if (numberRange.location != NSNotFound) {
        NSDictionary *numberAttributes = @{NSForegroundColorAttributeName: RGB_COLOR(@"#bb67ff", 1),
                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:16]};
        [attributedString setAttributes:numberAttributes range:numberRange];
    }

    self.checkInDayLabel.attributedText = attributedString;
}

#pragma mark - API
-(void)pullInternet {
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.Bonus" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if (![info isKindOfClass:[NSArray class]]) {
                return;
            }
            NSArray<UserBonusModel *> *bonusInfoArray = [UserBonusModel mj_objectArrayWithKeyValuesArray:info];
            strongSelf.dataSource = [bonusInfoArray lastObject];
//            strongSelf.dataSource.count_day = @"8";
            strongSelf.sevenDayItems = strongSelf.dataSource.bonus_list;
            [strongSelf update];
        }

    } fail:^(NSError * _Nonnull error) {

    }];
}

#pragma mark - UI

- (void)setupViews {
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    [self.view addGestureRecognizer:closeTap];

    [self.view addSubview:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(105);
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@RatioBaseWidth375(361));
    }];

    UIView *containerView = [UIView new];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.floatingView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.floatingView);
    }];

    UIImageView *bgImageView = [UIImageView new];
    bgImageView.image = [ImageBundle imagewithBundleName:@"KingSalary_bg"];
    [containerView addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(containerView);
        make.height.equalTo(bgImageView.mas_width).multipliedBy(474/1125.0);
    }];

    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = YZMsg(@"Daily Sign-in");
    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(containerView);
        make.height.equalTo(@RatioBaseWidth375(48));
    }];

    UIButton *closeButton = [UIButton new];
    [closeButton addTarget:self action:@selector(closeAnimation) forControlEvents:UIControlEventTouchUpInside];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13);
    [closeButton setImage:[ImageBundle imagewithBundleName:@"demo_icon_close"] forState:UIControlStateNormal];
    [containerView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(containerView).inset(2);
        make.size.equalTo(@44);
    }];

    UIImageView *titleBgImageView = [UIImageView new];
    titleBgImageView.image = [ImageBundle imagewithBundleName:@"DailyCheckIn_title_bg"];
    [containerView addSubview:titleBgImageView];
    [titleBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(RatioBaseWidth375(7));
        make.centerX.equalTo(containerView);
        make.width.equalTo(@RatioBaseWidth375(345));
        make.height.equalTo(titleBgImageView.mas_width).multipliedBy(266/345.0);
    }];

    UIImageView *titleIconImageView = [UIImageView new];
    titleIconImageView.image = [ImageBundle imagewithBundleName:@"DailyCheckIn_vip_icon"];
    [titleBgImageView addSubview:titleIconImageView];
    [titleIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBgImageView).offset(RatioBaseWidth375(10));
        make.right.equalTo(titleBgImageView).offset(RatioBaseWidth375(-15));
        make.size.equalTo(@RatioBaseWidth375(65));
    }];

    [titleBgImageView addSubview:self.checkInDayLabel];
    [self.checkInDayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleBgImageView).offset(RatioBaseWidth375(15));
        make.centerY.equalTo(titleIconImageView);
        make.right.equalTo(titleIconImageView.mas_left).offset(-2);
    }];

    [self.floatingView addSubview:self.dayCollectionView];
    [self.dayCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@RatioBaseWidth375(316));
        make.height.equalTo(@RatioBaseWidth375(56));
        make.centerX.equalTo(self.floatingView);
        make.top.equalTo(titleIconImageView.mas_bottom);
    }];

    UILabel *secondTitleLabel = [UILabel new];
    secondTitleLabel.font = [UIFont systemFontOfSize:12];
    secondTitleLabel.textColor = RGB_COLOR(@"#000000", 0.8);
    secondTitleLabel.text = YZMsg(@"The more consecutive sign-ins, the greater the rewards");
    secondTitleLabel.adjustsFontSizeToFitWidth = YES;
    secondTitleLabel.minimumScaleFactor = 0.8;
    [titleBgImageView addSubview:secondTitleLabel];
    [secondTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dayCollectionView.mas_bottom).offset(RatioBaseWidth375(25));
        make.left.equalTo(titleBgImageView).offset(RatioBaseWidth375(15));
        make.height.equalTo(@RatioBaseWidth375(20));
    }];

    [self.floatingView addSubview:self.continuosView];
    [self.continuosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(secondTitleLabel.mas_bottom);
        make.left.right.equalTo(secondTitleLabel);
        make.height.equalTo(@RatioBaseWidth375(90));
    }];

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (UIView*)createContinuousCheckInView {
    if (self.dataSource == nil) {
        return [UIView new];
    }
    UIView *containerView = [UIView new];
    
    UIView *redDot = [self createGradientDot];
    [containerView addSubview:redDot];
    [redDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).offset(RatioBaseWidth375(27));
        make.left.equalTo(containerView);
        make.size.equalTo(@15);
    }];

    CGFloat continuousDay = self.dataSource.count_day.intValue;

    CGFloat firstSpace = RatioBaseWidth375(29 + 2);
    CGFloat otherSpace = RatioBaseWidth375(36 + 4);
    CGFloat giftSpace = RatioBaseWidth375(36);
    CGFloat totalDistance = firstSpace + otherSpace * 3 + giftSpace * 4;

    CGFloat distance = 0;
    if (continuousDay <= 7) {
        distance = continuousDay / 7 * firstSpace;
    } else {
        CGFloat otherDay = continuousDay - 7;
        CGFloat giftCount = (int)continuousDay / 7;
        distance = firstSpace + giftSpace * giftCount + (otherDay / 7 * otherSpace);
    }

    UIStackView *stackView = [UIStackView new];
    stackView.spacing = RatioBaseWidth375(36);
    [stackView addArrangedSubview:[self createContinuousGiftView:7 continuousDay:continuousDay isLast:NO]];
    [stackView addArrangedSubview:[self createContinuousGiftView:14 continuousDay:continuousDay isLast:NO]];
    [stackView addArrangedSubview:[self createContinuousGiftView:21 continuousDay:continuousDay isLast:NO]];
    [stackView addArrangedSubview:[self createContinuousGiftView:28 continuousDay:continuousDay isLast:YES]];
    [containerView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(redDot.mas_right).offset(RatioBaseWidth375(29));
        make.top.equalTo(containerView).offset(RatioBaseWidth375(15));
    }];

    GradientProgressView *progressView = [GradientProgressView new];
    [containerView insertSubview:progressView belowSubview:redDot];
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(redDot.mas_right);
        make.centerY.equalTo(redDot);
        make.height.equalTo(@5);
        make.right.equalTo(stackView.mas_right).offset(RatioBaseWidth375(-2));
    }];

    CGFloat progress = (100 / totalDistance * distance) / 100.0;
    [progressView progress:progress];

    return containerView;
}

- (UIView*)createGradientDot {
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(2.5, 2.5, 10, 10)];
    circleView.layer.cornerRadius = 5;
    circleView.layer.masksToBounds = YES;

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = circleView.bounds;
    gradientLayer.colors = @[(id)RGB_COLOR(@"#fa7d99", 1).CGColor, (id)RGB_COLOR(@"#ff4a83", 1).CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0.3, 0.2);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer.type = kCAGradientLayerRadial;
    [circleView.layer addSublayer:gradientLayer];

    UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    outerView.layer.cornerRadius = 7.5;
    outerView.layer.masksToBounds = YES;
    outerView.backgroundColor = RGB_COLOR(@"#fa7d99", 0.5);
    [outerView addSubview:circleView];

    return outerView;
}

- (UIView*)createContinuousGiftView:(int)day continuousDay:(int)continuousDay isLast:(BOOL)isLast {
    BOOL isCheck = continuousDay >= day;
    UIView *containerView = [UIView new];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@RatioBaseWidth375(40));
        make.height.equalTo(@RatioBaseWidth375(55));
    }];

    UIImageView *giftImageView = [UIImageView new];
    [containerView addSubview:giftImageView];
    [giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@2);
        make.centerX.equalTo(containerView);
        make.size.equalTo(@RatioBaseWidth375(36));
    }];

    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:10];
    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(containerView);
        make.centerX.equalTo(containerView);
    }];

    UILabel *bonusLabel = [UILabel new];
    bonusLabel.font = [UIFont systemFontOfSize:10];
    bonusLabel.textColor = RGB_COLOR(@"#97a4b0", 1);
    // TODO: bill wait api
//    bonusLabel.text = @"+1.1";
    [containerView addSubview:bonusLabel];
    [bonusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(2);
        make.centerX.equalTo(containerView);
    }];

    if (isCheck) {
        NSString *image = isLast ? @"DailyCheckIn_vip_continuous_gift2_on" : @"DailyCheckIn_vip_continuous_gift1_on";
        giftImageView.image = [ImageBundle imagewithBundleName:image];
        titleLabel.textColor = RGB_COLOR(@"#d6a9ff", 1);
        titleLabel.text = YZMsg(@"Achieved");
    } else {
        NSString *image = isLast ? @"DailyCheckIn_vip_continuous_gift2" : @"DailyCheckIn_vip_continuous_gift1";
        giftImageView.image = [ImageBundle imagewithBundleName:image];
        titleLabel.textColor = RGB_COLOR(@"#97a4b0", 1);
        titleLabel.text = [NSString stringWithFormat:@"%@%d%@",
                           YZMsg(@"Consecutive Sign-ins"),
                           day,
                           YZMsg(@"public_Day")];
    }

    return containerView;
}

#pragma mark - Floating
- (void)panOnFloatingView:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 curve:UIViewAnimationCurveEaseOut animations:^{
                CGFloat translationY = self.floatingView.bounds.size.height;
                self.floatingView.transform = CGAffineTransformMakeTranslation(0, translationY);
                self.view.backgroundColor = [UIColor clearColor];
            }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self.floatingView];
            CGFloat fractionComplete = translation.y / self.floatingView.bounds.size.height;
            self.animator.fractionComplete = fractionComplete;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.animator.fractionComplete <= 0.22) {
                self.animator.reversed = YES;
            } else {
                __weak typeof(self) weakSelf = self;
                [self.animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                }];
            }
            [self.animator continueAnimationWithTimingParameters:nil durationFactor:0];
            break;
        }
        default:
            break;
    }
}

- (void)closeAnimation {
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2
                                                          delay:0
                                                        options:UIViewAnimationOptionCurveEaseOut
                                                     animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        CGFloat transformY = self.floatingView.bounds.size.height;
        self.floatingView.transform = CGAffineTransformMakeTranslation(0, transformY);
    } completion:^(UIViewAnimatingPosition finalPosition) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)closeView:(UIGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.view];
    UIView *touchView = [self.view hitTest:touchPoint withEvent:nil];

    if (touchView != self.view) {
        return;
    }

    [self closeAnimation];
}

#pragma mark - Lazy
- (UIView *)floatingView {
    if (!_floatingView) {
        _floatingView = [UIView new];
        _floatingView.backgroundColor = [UIColor whiteColor];
        _floatingView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _floatingView.layer.cornerRadius = 25;
        _floatingView.layer.masksToBounds = YES;
    }
    return _floatingView;
}

- (UILabel *)checkInDayLabel {
    if (!_checkInDayLabel) {
        _checkInDayLabel = [UILabel new];
        _checkInDayLabel.font = [UIFont boldSystemFontOfSize:20];
        _checkInDayLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    }
    return _checkInDayLabel;
}

- (UICollectionView *)dayCollectionView {
    if (!_dayCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionHeadersPinToVisibleBounds = YES;
        _dayCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _dayCollectionView.backgroundColor = [UIColor clearColor];
        _dayCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _dayCollectionView.dataSource = self;
        _dayCollectionView.delegate = self;
        [_dayCollectionView registerClass:[DailyCheckInCell class] forCellWithReuseIdentifier:@"DailyCheckInCell"];
    }
    return _dayCollectionView;
}

- (UIView *)continuosView {
    if (!_continuosView) {
        _continuosView = [UIView new];
        _continuosView.backgroundColor = [UIColor clearColor];
    }
    return _continuosView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sevenDayItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DailyCheckInCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DailyCheckInCell" forIndexPath:indexPath];
    if (self.sevenDayItems.count > indexPath.item) {
        UserBonusItemModel *model = self.sevenDayItems[indexPath.item];
        [cell update:model countDay:self.dataSource.count_day.intValue];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }

    if (self.sevenDayItems.count <= indexPath.item) {
        return;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(RatioBaseWidth375(40), RatioBaseWidth375(56));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return RatioBaseWidth375(6);
}

@end
