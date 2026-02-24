//
//  LuckyDrawViewController.m
//  phonelive2
//
//  Created by user on 2024/8/20.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LuckyDrawViewController.h"
#import "LuckyDrawTableViewCell.h"
#import "BonusRulesViewController.h"
#import "RotationModel.h"
#import "TYRotaryView.h"
#import "LuckydrawResultVC.h"
#import "RotationNothingVC.h"

@interface LuckyDrawViewController () <UITableViewDelegate>
{
    BOOL isLoading;
}
@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *floatingView;
@property (nonatomic, strong) UILabel *remainingCountLabel;
@property (nonatomic, strong) UILabel *remainingBonusNumberLabel;
@property (nonatomic, strong) UIImageView *titleBgImageView;
@property (nonatomic, strong) UIImageView *titleIconImageView;
@property (nonatomic, strong) VKBaseTableView *tableView;
@property (nonatomic, strong) TYRotaryView *rotaryView;
@property (nonatomic, strong) RotationModel *resultModel;
@property (nonatomic, strong) RotationSubModel *currentPrizeModel;  //当前奖品
@property (nonatomic,assign) BOOL isRunning;
@property (nonatomic,assign) BOOL isDismiss;
@end

@implementation LuckyDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self getViewInformation];
    self.floatingView.transform = CGAffineTransformMakeTranslation(0, self.floatingView.bounds.size.height);
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnFloatingView:)];
    self.floatingView.userInteractionEnabled = YES;
    [self.floatingView addGestureRecognizer:pan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.floatingView.transform = CGAffineTransformIdentity;
    } completion:^(UIViewAnimatingPosition finalPosition) {
    }];
    
    [self getViewInformation];

    if (![self isMovingToParentViewController]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LivePlayStart" object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!self.isDismiss) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LivePlayStop" object:nil];
    }
}

#pragma mark - UI

- (void)setupViews {
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
    [self.view addGestureRecognizer:closeTap];
    
    [self.view addSubview:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(75);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = vkColorRGB(242, 243, 247);
    [self.floatingView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.floatingView);
    }];
    
    UIImageView *rotation_bg = [UIImageView new];
    rotation_bg.image = [ImageBundle imagewithBundleName:@"rotation_bg"];
    [containerView addSubview:rotation_bg];
    UIImageView *luckydraw_header_bg = [UIImageView new];
    luckydraw_header_bg.image = [ImageBundle imagewithBundleName:@"Luckydraw_header_bg"];
    [containerView addSubview:luckydraw_header_bg];
    
    [luckydraw_header_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(containerView);
        make.height.equalTo(luckydraw_header_bg.mas_width).multipliedBy(240.0/1125.0);
    }];
    
    [rotation_bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(luckydraw_header_bg.mas_bottom).offset(-24);
        make.left.right.equalTo(containerView);
        make.height.equalTo(rotation_bg.mas_width).multipliedBy(1350.0/1125.0);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = YZMsg(@"luckyDraw_title");
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
    
    UIView *tableHeaderView = [UIView new];
    [tableHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_window_width-30);
        make.height.mas_equalTo(452);
    }];
    
    _tableView = [[VKBaseTableView alloc]initWithFrame: CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = @RatioBaseWidth375(52).floatValue;
    _tableView.sectionHeaderHeight = 0.1f;
    _tableView.automaticDimension = YES;
    _tableView.registerCellClass = [LuckyDrawTableViewCell class];
    _tableView.layer.cornerRadius = 12;
    _tableView.layer.masksToBounds = YES;
    _tableView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _tableView.layer.shadowColor = vkColorRGB(130, 147, 145).CGColor;
    _tableView.layer.shadowOpacity = 0.5;
    _tableView.layer.shadowOffset = CGSizeMake(0.0, 2);
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    _tableView.tableHeaderView = tableHeaderView;
    _tableView.delegate = self;
    [containerView addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(containerView).inset(15);
        make.top.mas_equalTo(luckydraw_header_bg.mas_bottom).offset(-20);
        make.bottom.mas_equalTo(containerView);
    }];
    
    [_tableView vk_headerRefreshSet];
    _weakify(self)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _strongify(self)
        [self getViewInformation];
    }];
    _tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        _strongify(self)
        [self getList];
    }];
    _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, NSDictionary *item) {
        NSLog(@"%@", item);
        _strongify(self)
        //[self getWalletInfo:item[@"code"]];
    };
    _tableView.clickCellActionBlock = ^(NSIndexPath *indexPath, id item, NSInteger actionIndex) {
        _strongify(self)
        if ([item isKindOfClass:[NSDictionary class]] && ![item[@"btn_jump"] isEqualToString:@""]) {
            NSString *scheme = item[@"btn_jump"];
            NSDictionary *data = @{ @"scheme": scheme};
           
            [[YBUserInfoManager sharedManager] pushVC: data viewController: self];
        }
    };
    
    UIImageView *titleBgImageView = [UIImageView new];
    titleBgImageView.image = [ImageBundle imagewithBundleName:@"rotation_title_bg"];
    [containerView addSubview:titleBgImageView];
    self.titleBgImageView = titleBgImageView;
    [titleBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.centerX.equalTo(containerView);
        make.width.equalTo(@RatioBaseWidth375(200));
        make.height.equalTo(titleBgImageView.mas_width).multipliedBy(54/200.0);
    }];
    
    UILabel *remainingBonustitleLabel = [UILabel new];
    remainingBonustitleLabel.textAlignment = NSTextAlignmentCenter;
    remainingBonustitleLabel.font = [UIFont italicSystemFontOfSize: 12];
    remainingBonustitleLabel.textColor = vkColorRGB(255, 244, 121);
    remainingBonustitleLabel.text = YZMsg(@"luckyDraw_remaining_bonus_in_the_prize_pool");
    CGAffineTransform  matrix = CGAffineTransformMake(1, 0, tanf(-15 * (CGFloat)M_PI/ 180), 1, 0, 0);
    remainingBonustitleLabel.transform = matrix;
    [titleBgImageView addSubview:remainingBonustitleLabel];
    [remainingBonustitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBgImageView).offset(6);
        make.left.right.equalTo(titleBgImageView).inset(20);
        make.height.equalTo(@RatioBaseWidth375(12));
    }];
    
    UILabel *remainingBonusNumberLabel = [UIView vk_label:nil font:vkFontName(16, @"SFProRounded-Semibold") color:vkColorRGB(255, 255, 255)];
    remainingBonusNumberLabel.textAlignment = NSTextAlignmentCenter;
    remainingBonusNumberLabel.text = @"";
    [titleBgImageView addSubview:remainingBonusNumberLabel];
    [remainingBonusNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remainingBonustitleLabel.mas_bottom).offset(2);
        make.left.right.equalTo(titleBgImageView).inset(20);
        make.height.equalTo(@RatioBaseWidth375(19));
    }];
    self.remainingBonusNumberLabel = remainingBonusNumberLabel;
    
    UIImageView *titleIconImageView = [UIImageView new];
    titleIconImageView.image = [ImageBundle imagewithBundleName:@"rotation_title_triangle"];
    [containerView addSubview:titleIconImageView];
    self.titleIconImageView = titleIconImageView;
    [titleIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBgImageView.mas_bottom).offset(-18);
        make.centerX.equalTo(titleBgImageView);
        make.width.equalTo(@RatioBaseWidth375(28));
        make.height.equalTo(@RatioBaseWidth375(22));
    }];
    
    UIImageView *rotation_borderImageView = [UIImageView new];
    rotation_borderImageView.image = [ImageBundle imagewithBundleName:@"rotation_border"];
    [tableHeaderView addSubview:rotation_borderImageView];
    [rotation_borderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tableHeaderView).offset(37);
        make.centerX.equalTo(titleIconImageView);
        make.size.equalTo(@RatioBaseWidth375(264));
    }];
    
    self.rotaryView = [TYRotaryView new];
    __weak typeof(self) weakself = self;
    self.rotaryView.rotaryStartTurnBlock = ^{
        NSLog(@"开始旋转");
        [weakself starToLottery];
    };
    
    self.rotaryView.rotaryEndTurnBlock = ^{
        NSLog(@"旋转结束");
        weakself.isRunning = false;
        // 抽奖结束 次数减一
        [weakself handleEndRollAction];
    };
    [tableHeaderView addSubview:self.rotaryView];
    [self.rotaryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(rotation_borderImageView);
        make.size.equalTo(@RatioBaseWidth375(192));
    }];
    
    UILabel *remainingLabel = [UILabel new];
    remainingLabel.textAlignment = NSTextAlignmentRight;
    remainingLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0];
    remainingLabel.textColor = vkColorRGB(161, 125, 250);
    remainingLabel.text = YZMsg(@"luckyDraw_number_of_draws_remaining");
    [tableHeaderView addSubview:remainingLabel];
    [remainingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rotation_borderImageView.mas_bottom).offset(4);
        make.right.equalTo(rotation_borderImageView.mas_centerX).offset(10);
        make.height.equalTo(@RatioBaseWidth375(48));
    }];
    
    UIView *remainingView = [UIView new];
    remainingView.layer.cornerRadius = 13;
    remainingView.layer.masksToBounds = YES;
    [tableHeaderView addSubview:remainingView];
    [remainingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(remainingLabel);
        make.left.equalTo(remainingLabel.mas_right).offset(12);
        make.width.equalTo(@RatioBaseWidth375(50));
        make.height.equalTo(@RatioBaseWidth375(26));
    }];
    [remainingView setHorizontalColors:@[vkColorRGB(141, 129, 255), vkColorRGB(169, 74, 255)]];
    
    UILabel *remainingCountLabel = [UILabel new];
    remainingCountLabel.textAlignment = NSTextAlignmentCenter;
    remainingCountLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0];
    remainingCountLabel.textColor = [UIColor whiteColor];
    remainingCountLabel.text = @"0";
    [remainingView addSubview:remainingCountLabel];
    [remainingCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(remainingView);
        make.width.mas_equalTo(remainingView);
    }];
    self.remainingCountLabel = remainingCountLabel;
    GradientButton *winningRecordButton = [[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 72, 24)];
    [winningRecordButton setTitle:YZMsg(@"luckyDraw_winning_record") forState:UIControlStateNormal];
    [winningRecordButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:12.0]];
    winningRecordButton.tag = 1;
    [winningRecordButton addTarget:self action:@selector(showBonusRules:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:winningRecordButton];
    [winningRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(remainingLabel.mas_bottom).offset(6);
        make.right.mas_equalTo(tableHeaderView.mas_centerX).inset(15);
        make.width.equalTo(@RatioBaseWidth375(72));
        make.height.equalTo(@RatioBaseWidth375(24));
    }];
    
    GradientButton *bonusRulesButton = [[GradientButton alloc] initWithFrame:CGRectMake(0, 0, 72, 24)];
    [bonusRulesButton setTitle:YZMsg(@"luckyDraw_bonus_rules") forState:UIControlStateNormal];
    [bonusRulesButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:12.0]];
    bonusRulesButton.tag = 2;
    [bonusRulesButton addTarget:self action:@selector(showBonusRules:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:bonusRulesButton];
    [bonusRulesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(remainingLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(tableHeaderView.mas_centerX).offset(15);
        make.width.equalTo(@RatioBaseWidth375(72));
        make.height.equalTo(@RatioBaseWidth375(24));
    }];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 0;
    tipsLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12.0];
    tipsLabel.textColor = vkColorRGB(161, 125, 250);
    tipsLabel.text = YZMsg(@"luckyDraw_tips");
    [tipsLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [tableHeaderView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bonusRulesButton.mas_bottom).offset(20);
        make.left.right.mas_equalTo(tableHeaderView);
    }];
    
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 圆角半径
    CGFloat cornerRadius = 12.0;

    // 创建一个路径用于设置圆角
    UIBezierPath *roundedPath;
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];

    // 判断是否是第一个和最后一个 cell
    if (indexPath.row == 0 && indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)) {
        // 只有一行时，四角圆角
        roundedPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds
                                            byRoundingCorners:UIRectCornerAllCorners
                                                  cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    } else if (indexPath.row == 0) {
        // 第一行，设置上圆角
        roundedPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds
                                            byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                  cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    } else if (indexPath.row == ([tableView numberOfRowsInSection:indexPath.section] - 1)) {
        // 最后一行，设置下圆角
        roundedPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds
                                            byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                  cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    } else {
        // 其他行没有圆角
        roundedPath = [UIBezierPath bezierPathWithRect:cell.bounds];
    }

    // 设置 maskLayer 的 path
    maskLayer.path = roundedPath.CGPath;
    cell.layer.mask = maskLayer;

    // 添加边框或阴影（可选）
    cell.layer.masksToBounds = NO;
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 1);
    cell.layer.shadowRadius = 2;
    cell.layer.shadowOpacity = 0.2;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat alpha = 1 - (offsetY / 100.0);
    alpha = MAX(MIN(alpha, 1), 0);
    self.titleBgImageView.alpha = alpha;
    self.titleIconImageView.alpha = alpha;
}

-(void)getViewInformation {
   
    if (isLoading) {
        return;
    }
    isLoading = true;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow  animated:YES];
    
    WeakSelf
    [LotteryNetworkUtil baseRequest:@"Live.getLuckydraw" params:dict block:^(NetworkData *networkData) {
        [hud hideAnimated:YES];
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->isLoading = false;
        [hud hideAnimated:YES];
        if (networkData.code == 0 && networkData.info) {
            if(![networkData.info isKindOfClass:[NSArray class]] || [(NSArray*)networkData.info count] <= 0) {
                [MBProgressHUD showError:networkData.msg];
                return;
            }
            strongSelf.resultModel = [RotationModel mj_objectWithKeyValues:networkData.info[0]];
            if (strongSelf.resultModel.reward.count == 10) {
                [strongSelf.rotaryView loadLottery:strongSelf.resultModel.reward];
            }
            if (strongSelf.resultModel.process_tip && strongSelf.resultModel.process_tip.length > 0) {
                //NSAttributedString * attStr = [[NSAttributedString alloc] initWithData:[strongSelf.resultModel.process_tip dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                NSLog(@"%@",strongSelf.resultModel.process_tip);
                //strongSelf.textViewBottom.attributedText = attStr;
            }
            [strongSelf getList];
            strongSelf.remainingBonusNumberLabel.text = [strongSelf poolNumber];
            strongSelf.remainingCountLabel.text = [NSString stringWithFormat: @"%d",strongSelf.resultModel.left_times];
        } else {
            [MBProgressHUD showError:networkData.msg];
        }
    }];
}
// 開始抽獎
- (void)doLuckydraw:(NetworkBlock)block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [LotteryNetworkUtil baseRequest:@"Live.doLuckydraw" params:dict block:block];
}

- (void)getList {
    
    
    [self.tableView vk_headerBeginRefresh];
    NSMutableArray *datas = [NSMutableArray arrayWithArray:self.resultModel.process_list];
    if (self.resultModel.process_tip) {
        [datas addObject:@{@"reset_time": self.resultModel.reset_time}];
    }
    [self.tableView vk_refreshFinish: [datas copy]];
}

- (void)starToLottery {
//    測試用
//    self.isRunning = true;
//    uint32_t randomNumber = arc4random_uniform(11);
//    NSLog(@"Random number between 0 and 10: %u", randomNumber);
//    self.currentPrizeModel = [self.resultModel.reward objectAtIndex:randomNumber];
//    NSLog(@"currentPrizeModel %@, %@", self.currentPrizeModel.item_type, self.currentPrizeModel.item_name);
//    [self.rotaryView animationWithSelectonIndex:randomNumber];
//    return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow  animated:YES];
    WeakSelf
    [self doLuckydraw:^(NetworkData *networkData) {
        [hud hideAnimated:YES];
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (networkData.code == 0 && networkData.info) {
            if (![networkData.info isKindOfClass:[NSArray class]] || [(NSArray*)networkData.info count] <= 0) {
                [MBProgressHUD showError:networkData.msg];
                return;
            }
            NSDictionary *resulDic = networkData.info[0];
            strongSelf.resultModel.left_times = [resulDic[@"left_times"] intValue];
            strongSelf.resultModel.pool = resulDic[@"luckydraw_money_pool"];
            NSDictionary *rewardDic = resulDic[@"reward"];
            NSString *rewardId = rewardDic[@"id"];
            if (rewardId) {
                int indexSel = 0;
                for (int i = 0; i<strongSelf.resultModel.reward.count; i++) {
                    RotationSubModel *subModel = strongSelf.resultModel.reward[i];
                    if ([subModel.ID isEqualToString:rewardId]) {
                        indexSel = i;
                        break;
                    }
                }
                strongSelf.currentPrizeModel = [strongSelf.resultModel.reward objectAtIndex:indexSel];
                //让转盘转起来
                strongSelf.isRunning = true;
                [strongSelf.rotaryView animationWithSelectonIndex:indexSel];
            }
        } else {
            strongSelf.isRunning = false;
            [MBProgressHUD showError:networkData.msg];
        }
    }];
}

// 奖池剩余奖金
- (NSString *)poolNumber {
    return [YBToolClass getRateCurrency:minstr(self.resultModel.pool) showUnit:YES showComma:YES];
}

-(void)handleEndRollAction {
    //抽奖次数减1
    self.remainingBonusNumberLabel.text = [self poolNumber];
    self.remainingCountLabel.text = [NSString stringWithFormat: @"%d",self.resultModel.left_times];
    LuckydrawResultVC *resultVC = [LuckydrawResultVC new];
    resultVC.model = self.currentPrizeModel;
    resultVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:resultVC animated:NO completion:nil];
    /* 旧版UI
    if ([self.currentPrizeModel.item_type isEqualToString:@"nothing"]) {
        RotationNothingVC *resultNothiVC = [[RotationNothingVC alloc]initWithNibName:@"RotationNothingVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        resultNothiVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:resultNothiVC animated:NO completion:nil];
    } else {
        LuckydrawResultVC *resultVC = [LuckydrawResultVC new];
        resultVC.model = self.currentPrizeModel;
        resultVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:resultVC animated:NO completion:nil];
    }
     */
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
                weakSelf.isDismiss = YES;
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
        if (self.isRunning) {
            return;
        }
        self.isDismiss = YES;
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

- (void)showBonusRules:(GradientButton *)sender {
    
    BonusRulesViewController *vc = [BonusRulesViewController new];
   
    if (sender.tag == 1) {
        vc.page = 3;
        vc.htmlCode = @"";
    }else{
        vc.htmlCode = self.resultModel.rule;
        vc.page = 1;
    }
   
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    [self presentViewController:navController animated:YES completion:nil];
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
@end


@implementation GradientButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGradient];
        [self setupShadows];
    }
    return self;
}

- (void)setupGradient {
    // 設置漸變圖層
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:214/255.0 green:169/255.0 blue:255/255.0 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithRed:187/255.0 green:103/255.0 blue:255/255.0 alpha:1.0].CGColor
    ];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.cornerRadius = 12.0;  // 圓角半徑
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)setupShadows {
    // 設置第一個外部陰影
    self.layer.shadowColor = [UIColor colorWithRed:187/255.0 green:103/255.0 blue:255/255.0 alpha:0.2].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 4); // x, y
    self.layer.shadowRadius = 5.0; // 模糊度
    self.layer.shadowOpacity = 1.0; // 透明度
    
    // 設置第二個外部陰影
    CALayer *additionalShadowLayer = [CALayer layer];
    additionalShadowLayer.frame = self.bounds;
    additionalShadowLayer.shadowColor = [UIColor colorWithRed:187/255.0 green:103/255.0 blue:255/255.0 alpha:1.0].CGColor;
    additionalShadowLayer.shadowOffset = CGSizeMake(0, 2); // x, y
    additionalShadowLayer.shadowRadius = 0; // 模糊度
    additionalShadowLayer.shadowOpacity = 1.0; // 透明度
    additionalShadowLayer.cornerRadius = 12.0;
    [self.layer insertSublayer:additionalShadowLayer above:self.layer];
    
    // 設置內陰影
    CALayer *innerShadowLayer = [CALayer layer];
    innerShadowLayer.frame = self.bounds;
    innerShadowLayer.shadowColor = [UIColor colorWithRed:214/255.0 green:169/255.0 blue:255/255.0 alpha:0.5].CGColor;
    innerShadowLayer.shadowOffset = CGSizeMake(0, -2); // x, y
    innerShadowLayer.shadowRadius = 2.0; // 模糊度
    innerShadowLayer.shadowOpacity = 1.0; // 透明度
    innerShadowLayer.cornerRadius = 12.0;
    //innerShadowLayer.masksToBounds = YES;
    [self.layer addSublayer:innerShadowLayer];
}
@end
