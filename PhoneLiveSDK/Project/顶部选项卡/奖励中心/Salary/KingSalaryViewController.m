//
//  KingSalaryViewController.m
//  phonelive2
//
//  Created by s5346 on 2024/8/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "KingSalaryViewController.h"
#import "KingSalaryHeaderView.h"
#import "KingSalaryCell.h"
#import "KingSalaryModel.h"
#import "BonusRulesViewController.h"

@interface KingSalaryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *floatingView;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *levelNameLabel;
@property (nonatomic, strong) UILabel *levelTipLabel;
@property (nonatomic, strong) UIProgressView *levelProgressView;
@property (nonatomic, strong) UILabel *leftLavelLabel;
@property (nonatomic, strong) UILabel *rightLavelLabel;
@property (nonatomic, strong) UIScrollView *tableScrollView;
@property (nonatomic, strong) UIView *tableContainerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *salaryDataSource;
@property (nonatomic, strong) KingSalaryModel *model;
@property (nonatomic, strong) NSArray<SalaryLevelItem*> *levelItems;

@end

@implementation KingSalaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
    [self update];

    self.floatingView.transform = CGAffineTransformMakeTranslation(0, self.floatingView.bounds.size.height);
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnFloatingView:)];
    self.floatingView.userInteractionEnabled = YES;
    [self.floatingView addGestureRecognizer:pan];

    [self requestData];
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
    if (self.model == nil) {
        return;
    }

    self.levelLabel.text = [NSString stringWithFormat:@"V.%@", minstr(self.model.level)];// @"V.0";
    self.levelNameLabel.text = YZMsg(@"VIPVC_King");
    int minusUpgrade = self.model.leve_c_end.intValue - self.model.leve_c_cur.intValue;
    self.levelTipLabel.text = [NSString stringWithFormat:YZMsg(@"VIPVC_Charge%@_UpKingLeve%ld"), [YBToolClass getRateCurrency:@(minusUpgrade).stringValue showUnit:YES], self.model.level.intValue + 1];
    float curProg = ([self.model.leve_c_cur floatValue] - [self.model.leve_c_start floatValue])/([self.model.leve_c_end floatValue] -[self.model.leve_c_start floatValue]);
    self.levelProgressView.progress = curProg;
    self.leftLavelLabel.text = [NSString stringWithFormat:@"V%@", self.model.level];
    self.rightLavelLabel.text = [NSString stringWithFormat:@"V%d", self.model.level.intValue + 1];

    self.levelItems = self.model.list;
    [self.collectionView reloadData];
}

- (void)showRules {
    NSString *rule = self.model.rule;
    if (rule.length <= 0) {
        return;
    }
    BonusRulesViewController *vc = [BonusRulesViewController new];
    vc.htmlCode = rule;
    vc.page = 2;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - API
-(void)requestData{
    NSString *urlStr = @"Kingreward.getList";
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:urlStr withBaseDomian:YES andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
//            if(![info isKindOfClass:[NSArray class]]|| [(NSArray*)info count]<=0){
//                [MBProgressHUD showError:msg];
//                return;
//            }
//            NSArray<KingSalaryModel *> *array = [KingSalaryModel mj_objectArrayWithKeyValuesArray:info];
            strongSelf.model = [KingSalaryModel mj_objectWithKeyValues:info];

            [strongSelf update];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

#pragma mark - UI

- (void)setupViews {
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    [self.view addGestureRecognizer:closeTap];

    [self.view addSubview:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(105);
        make.left.right.bottom.equalTo(self.view);
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
    titleLabel.text = YZMsg(@"VIPVC_title");
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
        make.top.right.equalTo(containerView).inset(5);
        make.size.equalTo(@44);
    }];

    UIButton *ruleButton = [UIButton new];
    [ruleButton addTarget:self action:@selector(showRules) forControlEvents:UIControlEventTouchUpInside];
    ruleButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    [ruleButton setImage:[ImageBundle imagewithBundleName:@"kingrule"] forState:UIControlStateNormal];
    [containerView addSubview:ruleButton];
    [ruleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(closeButton.mas_left);
        make.centerY.equalTo(closeButton);
        make.size.equalTo(@44);
    }];

    UIImageView *titleBgImageView = [UIImageView new];
    titleBgImageView.image = [ImageBundle imagewithBundleName:@"KingSalary_title_bg"];
    [containerView addSubview:titleBgImageView];
    [titleBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(RatioBaseWidth375(10));
        make.centerX.equalTo(containerView);
        make.width.equalTo(@RatioBaseWidth375(345));
        make.height.equalTo(titleBgImageView.mas_width).multipliedBy(146/345.0);
    }];

    UIImageView *titleIconImageView = [UIImageView new];
    titleIconImageView.image = [ImageBundle imagewithBundleName:@"KingSalary_vip_icon"];
    [containerView addSubview:titleIconImageView];
    [titleIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBgImageView).offset(RatioBaseWidth375(5));
        make.right.equalTo(titleBgImageView).offset(RatioBaseWidth375(-10));
        make.size.equalTo(@RatioBaseWidth375(40));
    }];

    [titleBgImageView addSubview:self.levelLabel];
    [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBgImageView).offset(RatioBaseWidth375(21));
        make.left.equalTo(titleBgImageView).offset(RatioBaseWidth375(22));
    }];

    [titleBgImageView addSubview:self.levelNameLabel];
    [self.levelNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.levelLabel.mas_right).offset(2);
        make.bottom.equalTo(self.levelLabel.mas_bottom).offset(-4);
    }];

    [titleBgImageView addSubview:self.levelTipLabel];
    [self.levelTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.levelLabel.mas_bottom).offset(RatioBaseWidth375(10));
        make.left.equalTo(self.levelLabel);
        make.right.equalTo(titleBgImageView);
    }];

    [titleBgImageView addSubview:self.levelProgressView];
    [self.levelProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.levelTipLabel.mas_bottom).offset(RatioBaseWidth375(5));
        make.left.equalTo(self.levelLabel);
        make.width.equalTo(@RatioBaseWidth375(136));
        make.height.equalTo(@5);
    }];

    [titleBgImageView addSubview:self.leftLavelLabel];
    [self.leftLavelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.levelProgressView.mas_bottom).offset(2);
        make.left.equalTo(self.levelProgressView);
    }];

    [titleBgImageView addSubview:self.rightLavelLabel];
    [self.rightLavelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.levelProgressView.mas_bottom).offset(2);
        make.right.equalTo(self.levelProgressView);
    }];

    UILabel *currentLevelLabel = [UILabel new];
    currentLevelLabel.text = YZMsg(@"VIPVC_Current_Level");
    currentLevelLabel.font = [UIFont boldSystemFontOfSize:12];
    currentLevelLabel.textColor = [UIColor whiteColor];
    [titleBgImageView addSubview:currentLevelLabel];
    [currentLevelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftLavelLabel.mas_bottom).offset(RatioBaseWidth375(12));
        make.left.equalTo(self.levelLabel);
    }];

    [containerView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBgImageView.mas_bottom).offset(RatioBaseWidth375(25));
        make.left.right.equalTo(containerView).inset(RatioBaseWidth375(15));
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];

    self.collectionView.layer.cornerRadius = 8;
    self.collectionView.layer.borderColor = RGB_COLOR(@"#b4bdc5", 1).CGColor;
    self.collectionView.layer.borderWidth = 1;
    self.collectionView.layer.masksToBounds = YES;

    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
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

- (UILabel *)levelLabel {
    if (!_levelLabel) {
        _levelLabel = [UILabel new];
        _levelLabel.font = [UIFont boldSystemFontOfSize:36];
        _levelLabel.textColor = [UIColor whiteColor];
        _levelLabel.adjustsFontSizeToFitWidth = YES;
        _levelLabel.minimumScaleFactor = 0.5;
    }
    return _levelLabel;
}

- (UILabel *)levelNameLabel {
    if (!_levelNameLabel) {
        _levelNameLabel = [UILabel new];
        _levelNameLabel.font = [UIFont boldSystemFontOfSize:16];
        _levelNameLabel.textColor = [UIColor whiteColor];
    }
    return _levelNameLabel;
}

- (UILabel *)levelTipLabel {
    if (!_levelTipLabel) {
        _levelTipLabel = [UILabel new];
        _levelTipLabel.font = [UIFont boldSystemFontOfSize:10];
        _levelTipLabel.adjustsFontSizeToFitWidth = YES;
        _levelTipLabel.minimumScaleFactor = 0.5;
        _levelTipLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    }
    return _levelTipLabel;
}

- (UIProgressView *)levelProgressView {
    if (!_levelProgressView) {
        _levelProgressView = [UIProgressView new];
        _levelProgressView.progressTintColor = RGB_COLOR(@"#bb67ff", 1);
        _levelProgressView.trackTintColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _levelProgressView;
}

- (UILabel *)leftLavelLabel {
    if (!_leftLavelLabel) {
        _leftLavelLabel = [UILabel new];
        _leftLavelLabel.font = [UIFont boldSystemFontOfSize:10];
        _leftLavelLabel.textColor = RGB_COLOR(@"#e3e6f1", 1);
    }
    return _leftLavelLabel;
}

- (UILabel *)rightLavelLabel {
    if (!_rightLavelLabel) {
        _rightLavelLabel = [UILabel new];
        _rightLavelLabel.font = [UIFont boldSystemFontOfSize:10];
        _rightLavelLabel.textColor = RGB_COLOR(@"#e3e6f1", 1);
    }
    return _rightLavelLabel;
}

- (UIScrollView *)tableScrollView {
    if (!_tableScrollView) {
        _tableScrollView = [UIScrollView new];
        _tableScrollView.showsVerticalScrollIndicator = NO;
    }
    return _tableScrollView;
}

- (UIView *)tableContainerView {
    if (!_tableContainerView) {
        _tableContainerView = [UIView new];
    }
    return _tableContainerView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionHeadersPinToVisibleBounds = YES;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.bounces = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[KingSalaryCell class] forCellWithReuseIdentifier:@"KingSalaryCell"];
        [_collectionView registerClass:[KingSalaryHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"KingSalaryHeaderView"];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.levelItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KingSalaryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KingSalaryCell" forIndexPath:indexPath];
    if (self.levelItems.count > indexPath.item) {
        SalaryLevelItem *model = self.levelItems[indexPath.item];
        [cell update:model];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    KingSalaryHeaderView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"KingSalaryHeaderView" forIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.width, RatioBaseWidth375(35));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), RatioBaseWidth375(42));
}

@end
