//
//  otherUserMsgVC.m
//  phonelive2
//
//  Created by s5346 on 2024/8/13.
//  Copyright © 2024 toby. All rights reserved.
//

#import "otherUserMsgVC.h"
#import "hotModel.h"
#import "ShortVideoModel.h"
#import "LiveGifImage.h"

#import "EnterLivePlay.h"
#import "impressVC.h"
#import "fansViewController.h"
#import "attrViewController.h"
#import "webH5.h"
#import "guardRankVC.h"
#import "otherUserMsgCollectionViewController.h"
#import "ScrollUIPageViewController.h"
#import "AnimRefreshHeader.h"
#import <UMCommon/UMCommon.h>

#define HeaderImageHeight RatioBaseWidth390(265)
#define AttionBtnHeight 48;
#define siginLabelSpace 36 + 10;

@interface otherUserMsgVC ()<UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, otherUserMsgCollectionViewControllerDelegate, ScrollUIPageViewControllerDelegate>

@property(nonatomic, strong) UIView *naviView;
@property(nonatomic, strong) UIButton *returnBtn;
@property(nonatomic, strong) UIButton *shareBtn;
@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, assign) CGFloat HeaderHeight;
@property(nonatomic, strong) hotModel *infoModel;
@property(nonatomic, strong) NSMutableArray *liveArray;
@property(nonatomic, strong) NSMutableArray<ShortVideoModel*> *videoArray;
@property(nonatomic, strong) NSString *chatname;
@property(nonatomic, strong) NSString *icon;
@property(nonatomic, strong) UIButton *attionBtn;
@property(nonatomic, strong) UIButton *blackBtn;
@property(nonatomic, strong) SDAnimatedImageView *iconImgView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *IDLabel;
@property(nonatomic, strong) UIImageView *sexImgView;
@property(nonatomic, strong) UIImageView *hostImgView;
@property(nonatomic, strong) UIImageView *levelImgView;
@property(nonatomic, strong) SDAnimatedImageView *avatarIcon;
@property(nonatomic, strong) UILabel *likeCountLabel;
@property(nonatomic, strong) UILabel *followCountLabel;
@property(nonatomic, strong) UILabel *fansCountLabel;
@property(nonatomic, strong) UILabel *siginLabel;
@property(nonatomic, strong) UIView *impressView;
@property(nonatomic, strong) UIView *contributionView;
@property(nonatomic, strong) UIView *guardView;
@property(nonatomic, strong) UILabel *impressLabel;
@property(nonatomic, strong) UIButton *addImpBtn;
@property(nonatomic, strong) UIButton *videoBtn;
@property(nonatomic, strong) UIButton *likeBtn;
@property(nonatomic, strong) UIButton *liveBtn;
@property(nonatomic, strong) UIView *segmentSelectLineView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIStackView *segmentStackView;

@property (nonatomic, strong) UIView *segmentView;
@property (nonatomic, strong) ScrollUIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL scrollDelegateEnable;
@property (nonatomic, strong) UIView *otherView;
@property (nonatomic, strong) YYAnimatedImageView *liveGifImg;
@property (nonatomic, strong) UIButton *liveOnlineBtn;
@property (nonatomic, strong) MASConstraint *backgroundImageHeightConstraint;

@end

@implementation otherUserMsgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    if ([_userID isEqual:[Config getOwnID]]) {
        self.HeaderHeight = (275 + HeaderImageHeight) - AttionBtnHeight;
    }else{
        self.HeaderHeight = (275 + HeaderImageHeight);
    }

//    liveArray = [NSMutableArray array];
//    livePage = 0;
//
//    likeArray = [NSMutableArray array];
//    likePage = 0;
//
//    videoArray = [NSMutableArray array];
//    videoPage = 0;
//    segmentType = 0;

    [self setupViews];
    [self navigation];
    [self requestData];
    [self createPageViewController];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.pageViewController.view.frame = self.segmentView.bounds;
    self.segmentSelectLineView.y = self.segmentStackView.y + self.segmentStackView.height - self.segmentSelectLineView.height;
    self.segmentSelectLineView.width = self.videoBtn.width;
}

#pragma mark - private
- (void)setupViews {
    self.view.backgroundColor = RGB_COLOR(@"#EAE7EE", 1);

    UIView *backgroundImageView = [self createBackgroundImageView];
    [self.view addSubview:backgroundImageView];
    

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = UIColor.clearColor;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    WeakSelf
    AnimRefreshHeader *refreshHeader = [AnimRefreshHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }

        if (strongSelf.videoBtn.isSelected) {
            otherUserMsgCollectionViewController *viewController = strongSelf.viewControllers[0];
            [viewController refresh];
        }else if (strongSelf.likeBtn.isSelected) {
            otherUserMsgCollectionViewController *viewController = strongSelf.viewControllers[1];
            [viewController refresh];
        } else {
            otherUserMsgCollectionViewController *viewController = strongSelf.viewControllers[2];
            [viewController refresh];
        }
    }];

    if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.top > 20) {
        refreshHeader.ignoredScrollViewContentInsetTop = -(12);
    }
    [self.scrollView setMj_header:refreshHeader];

    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = UIColor.clearColor;
    [self.scrollView addSubview:self.containerView];

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    UIView *userInfoView = [self createUserInfo];
    [self.containerView addSubview:userInfoView];
    [userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(RatioBaseWidth390(22) + statusbarHeight + 64);
        make.left.right.equalTo(self.containerView);
    }];

    self.otherView = [self createOtherView];
   
    [self.otherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userInfoView.mas_bottom).offset(RatioBaseWidth390(10));
        make.left.right.equalTo(self.containerView);
    }];

    self.segmentView = [UIView new];
    self.segmentView.backgroundColor = RGB_COLOR(@"#EAE7EE", 1);
    [self.containerView addSubview:self.segmentView];
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.otherView.mas_bottom);
        make.left.right.bottom.equalTo(self.containerView);
        make.height.equalTo(@(_window_height - (64 + statusbarHeight + 45)));
    }];
    
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.containerView);
        self.backgroundImageHeightConstraint = make.height.mas_equalTo(HeaderImageHeight);
    }];
}

- (UIView*)createOtherView {
    UIView *otherView = [[UIView alloc] init];
    otherView.backgroundColor = RGB_COLOR(@"#EAE7EE", 1);
    otherView.layer.cornerRadius = RatioBaseWidth390(30);
    otherView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    otherView.layer.masksToBounds = YES;
    [self.containerView addSubview:otherView];
    // 獲讚
    UIView *likeView = [self createNumberTitle:YZMsg(@"public_like") label:self.likeCountLabel];
    // 關注
    UIView *followView = [self createNumberTitle:YZMsg(@"homepageController_attention") label:self.followCountLabel];
    // 粉絲
    UIView *fansView = [self createNumberTitle:YZMsg(@"public_fans") label:self.fansCountLabel];
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[likeView, followView, fansView]];
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.spacing = RatioBaseWidth390(30);
    [otherView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(otherView).offset(RatioBaseWidth390(15));
        make.left.equalTo(otherView).offset(RatioBaseWidth390(16));
        make.right.lessThanOrEqualTo(otherView).offset(-RatioBaseWidth390(16));
        make.height.equalTo(@22);
    }];

    self.siginLabel = [[UILabel alloc]init];
    self.siginLabel.textColor = [UIColor blackColor];
    self.siginLabel.font = [UIFont systemFontOfSize:14];
    self.siginLabel.numberOfLines = 2;
    [otherView addSubview:self.siginLabel];
    [self.siginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarIcon);
        make.top.equalTo(stackView.mas_bottom).offset(11);
        make.right.equalTo(otherView).offset(-15);
    }];

    //印象
    self.impressView = [[UIView alloc]init];
    self.impressView.backgroundColor = [UIColor clearColor];
    [otherView addSubview:self.impressView];
    [self.impressView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.siginLabel.isHidden) {
            make.top.equalTo(self.siginLabel.mas_bottom);
        } else {
            make.top.equalTo(self.siginLabel.mas_bottom).offset(10);
        }
        make.left.width.equalTo(otherView);
        make.height.equalTo(@52);
    }];
    self.impressLabel = [[UILabel alloc]init];
    self.impressLabel.textColor = [UIColor blackColor];
    self.impressLabel.font = [UIFont boldSystemFontOfSize:14];
    self.impressLabel.text = YZMsg(@"otherUserMsgVC_impressed");
    [otherView addSubview:self.impressLabel];
    [self.impressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.impressView).offset(15);
        make.top.equalTo(self.impressView);
        make.height.equalTo(@20);
    }];
    UIFont *impressFont = [UIFont systemFontOfSize:14];
    self.addImpBtn = [UIButton buttonWithType:0];
    self.addImpBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.addImpBtn.titleLabel.minimumScaleFactor = 0.5;
    [self.addImpBtn setTitle:YZMsg(@"upmessageInfo_add_the_impression") forState:0];
    [self.addImpBtn setTitleColor:RGB_COLOR(@"#757575", 1) forState:0];
    self.addImpBtn.titleLabel.font = impressFont;
    [self.addImpBtn addTarget:self action:@selector(addImpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.addImpBtn.layer.cornerRadius = 5;
    self.addImpBtn.layer.masksToBounds = YES;
    self.addImpBtn.layer.borderWidth = 1;
    self.addImpBtn.layer.borderColor = RGB_COLOR(@"#757575", 1).CGColor;//normalColors.CGColor;
    [otherView addSubview:self.addImpBtn];
    if ([_userID isEqual:[Config getOwnID]]) {
        self.addImpBtn.hidden = YES;
    }

    //排行
    self.contributionView = [self createRank:YZMsg(@"RankVC_contribution_list") imageString:@"PersonalCenterContributionIcon"];
    self.guardView = [self createRank:YZMsg(@"otherUserMsgVC_GuardTop") imageString:@"PersonalCenterGuardIcon"];
    UIStackView *rankStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.contributionView, self.guardView]];
    rankStackView.distribution = UIStackViewDistributionFillEqually;
    rankStackView.spacing = 8;
    [otherView addSubview:rankStackView];
    [rankStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.impressView.mas_bottom).offset(25);
        make.left.right.equalTo(otherView).inset(15);
        make.height.equalTo(@36);
    }];

    // line
    UIView *impressAndRankView = [[UIView alloc] init];
    impressAndRankView.backgroundColor = [UIColor clearColor];
    [otherView addSubview:impressAndRankView];
    [impressAndRankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.impressView.mas_bottom);
        make.bottom.equalTo(rankStackView.mas_top);
        make.left.right.equalTo(otherView).inset(15);
    }];

    UIView *impressAndRankLineView = [[UIView alloc] init];
    impressAndRankLineView.backgroundColor = [UIColor lightGrayColor];
    impressAndRankLineView.alpha = 0.5;
    [impressAndRankView addSubview:impressAndRankLineView];
    [impressAndRankLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(impressAndRankView);
        make.left.right.equalTo(impressAndRankView);
        make.height.equalTo(@1);
    }];

    if (![_userID isEqual:[Config getOwnID]]) {
        self.attionBtn = [[UIButton alloc] init];
        self.attionBtn.backgroundColor = RGB_COLOR(@"#B42ECC", 1);
        [self.attionBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterAddIcon"] forState:UIControlStateNormal];
        [self.attionBtn setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
        [self.attionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.attionBtn.layer.cornerRadius = 18;
        self.attionBtn.layer.masksToBounds = YES;
        [self.attionBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [otherView addSubview:self.attionBtn];
        [self.attionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rankStackView.mas_bottom).offset(12);
            make.left.right.equalTo(otherView).inset(16);
            make.height.equalTo(@36);
        }];
    }

    self.videoBtn = [UIButton buttonWithType:0];
    [self.videoBtn setTitle:[NSString stringWithFormat:@"%@",YZMsg(@"work")] forState:0];
    [self.videoBtn setTitleColor:RGB_COLOR(@"#757575", 1) forState:UIControlStateNormal];
    [self.videoBtn setTitleColor:RGB_COLOR(@"#1A1A1A", 1) forState:UIControlStateSelected];
    self.videoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.videoBtn addTarget:self action:@selector(live_videoSwitch:) forControlEvents:UIControlEventTouchUpInside];
    self.videoBtn.tag = 1213;

    self.likeBtn = [UIButton buttonWithType:0];
    [self.likeBtn setTitle:[NSString stringWithFormat:@"%@",YZMsg(@"like")] forState:0];
    [self.likeBtn setTitleColor:RGB_COLOR(@"#757575", 1) forState:UIControlStateNormal];
    [self.likeBtn setTitleColor:RGB_COLOR(@"#1A1A1A", 1) forState:UIControlStateSelected];
    self.likeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.likeBtn addTarget:self action:@selector(live_videoSwitch:) forControlEvents:UIControlEventTouchUpInside];
    self.likeBtn.tag = 1214;

    self.liveBtn = [UIButton buttonWithType:0];
    [self.liveBtn setTitle:[NSString stringWithFormat:@"%@ %@",YZMsg(@"homepageController_live"),@"0"] forState:0];
    [self.liveBtn setTitleColor:RGB_COLOR(@"#757575", 1) forState:UIControlStateNormal];
    [self.liveBtn setTitleColor:RGB_COLOR(@"#1A1A1A", 1) forState:UIControlStateSelected];
    self.liveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.liveBtn addTarget:self action:@selector(live_videoSwitch:) forControlEvents:UIControlEventTouchUpInside];
    self.liveBtn.tag = 1215;

    self.segmentStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.videoBtn, self.likeBtn, self.liveBtn]];
    self.segmentStackView.distribution = UIStackViewDistributionFillEqually;
    [otherView addSubview:self.segmentStackView];
    [self.segmentStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.attionBtn.superview == nil) {
            make.top.equalTo(rankStackView.mas_bottom).offset(12);
        } else {
            make.top.equalTo(self.attionBtn.mas_bottom);
        }
        make.left.right.equalTo(otherView).inset(15);
        make.bottom.equalTo(otherView).offset(-8);
        make.height.equalTo(@40);
    }];

    UIView *segmentStackViewLineView = [[UIView alloc] init];
    segmentStackViewLineView.backgroundColor = [UIColor lightGrayColor];
    segmentStackViewLineView.alpha = 0.5;
    [otherView addSubview:segmentStackViewLineView];
    [segmentStackViewLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.segmentStackView);
        make.height.equalTo(@1);
    }];

    self.segmentSelectLineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 0, 4)];
    self.segmentSelectLineView.backgroundColor = [UIColor blackColor];
    [otherView addSubview:self.segmentSelectLineView];

    self.scrollDelegateEnable = YES;
    [self live_videoSwitch:self.videoBtn];

    return otherView;
}

- (UIView*)createUserInfo {
    UIView *containerView = [[UIView alloc] init];

    self.avatarIcon = [[SDAnimatedImageView alloc]init];
    self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarIcon.clipsToBounds = YES;
    self.avatarIcon.layer.cornerRadius = RatioBaseWidth390(112)/2.0;
    self.avatarIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarIcon.layer.borderWidth = RatioBaseWidth390(3);
    self.avatarIcon.layer.masksToBounds = YES;
    [containerView addSubview:self.avatarIcon];
    [self.avatarIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(RatioBaseWidth390(16));
        make.top.bottom.equalTo(containerView);
        make.size.mas_equalTo(RatioBaseWidth390(112));
    }];

    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
    self.nameLabel.minimumScaleFactor = 0.5;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    [containerView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarIcon).offset(RatioBaseWidth390(18));
        make.left.equalTo(self.avatarIcon.mas_right).offset(RatioBaseWidth390(17));
        make.right.lessThanOrEqualTo(containerView).offset(-20);
        make.height.mas_equalTo(28);
    }];

    // live tag
    NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
    self.liveGifImg = [[YYAnimatedImageView alloc]init];
    LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
    [imgAnima setAnimatedImageLoopCount:0];
    self.liveGifImg.image = imgAnima;
    self.liveGifImg.runloopMode = NSRunLoopCommonModes;
    self.liveGifImg.animationRepeatCount = 0;
    [self.liveGifImg startAnimating];
    self.liveGifImg.hidden = YES;
    [containerView addSubview:self.liveGifImg];

    [self.liveGifImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(3);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(18);
    }];

    // ID
    self.IDLabel = [[UILabel alloc]init];
    self.IDLabel.textColor = [UIColor whiteColor];
    self.IDLabel.font = [UIFont systemFontOfSize:12];
    [containerView addSubview:self.IDLabel];
    [self.IDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(17);
    }];

    // 性別
    self.sexImgView = [[UIImageView alloc]init];
    [containerView addSubview:self.sexImgView];
    [self.sexImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.IDLabel.mas_bottom).offset(4);
        make.height.width.mas_equalTo(20);
    }];

    self.hostImgView = [[UIImageView alloc]init];
    [containerView addSubview:self.hostImgView];
    [self.hostImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.sexImgView);
        make.left.equalTo(self.sexImgView.mas_right).offset(4);
        make.width.equalTo(self.hostImgView.mas_height).multipliedBy(2);
    }];

    self.levelImgView = [[UIImageView alloc]init];
    [containerView addSubview:self.levelImgView];
    [self.levelImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.sexImgView);
        make.left.equalTo(self.hostImgView.mas_right).offset(4);
        make.width.equalTo(self.hostImgView.mas_height).multipliedBy(2);
    }];

    self.liveOnlineBtn = [UIButton buttonWithType:0];
    [self.liveOnlineBtn setBackgroundColor:[UIColor clearColor]];
    self.liveOnlineBtn.tag = 181221;
    self.liveOnlineBtn.hidden = YES;
    [self.liveOnlineBtn addTarget:self action:@selector(goLivePlay) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:self.liveOnlineBtn];

    [self.liveOnlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView.mas_left);
        make.top.equalTo(self.avatarIcon.mas_top);
        make.bottom.equalTo(self.IDLabel.mas_bottom);
        make.right.equalTo(containerView.mas_right);
    }];

    return containerView;
}

- (UIView*)createBackgroundImageView {
    UIView *containerView = [[UIView alloc] init];
    self.iconImgView = [[SDAnimatedImageView alloc]init];
    self.iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImgView.clipsToBounds = YES;
    self.iconImgView.userInteractionEnabled = YES;
    [containerView addSubview:self.iconImgView];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];

    for (int i = 0; i<2; i++) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.alpha = 0.3;
        [containerView addSubview:blurEffectView];
        [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.iconImgView);
        }];
    }

    UIView *iconImgViewBackView = [[UIView alloc]init];
    iconImgViewBackView.backgroundColor = RGB_COLOR(@"#36013B", 0.6);
    [self.iconImgView addSubview:iconImgViewBackView];
    [iconImgViewBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.iconImgView);
    }];
    return containerView;
}

- (void)navigation{
    self.naviView = [[UIView alloc]init];
    self.naviView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.naviView];
    [self.naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(64 + statusbarHeight));
    }];

    self.returnBtn = [UIButton buttonWithType:0];
    [self.returnBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterBackIcon"] forState:0];
    [self.returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    self.returnBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.naviView addSubview:self.returnBtn];
    [self.returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.naviView).offset(5);
        make.size.equalTo(@40);
        make.bottom.equalTo(self.naviView);
    }];

    self.shareBtn = [UIButton buttonWithType:0];
    [self.shareBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterSearchIcon"] forState:0];
    [self.shareBtn addTarget:self action:@selector(tapSearch) forControlEvents:UIControlEventTouchUpInside];
    self.shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.naviView addSubview:self.shareBtn];
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.naviView).offset(-5);
        make.size.equalTo(@40);
        make.bottom.equalTo(self.naviView);
    }];
    self.shareBtn.hidden = YES;

    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = navtionTitleFont;
    self.titleLabel.textColor = [UIColor blackColor];
    [self.naviView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.returnBtn);
        make.left.equalTo(self.returnBtn.mas_right).offset(10);
        make.right.equalTo(self.shareBtn.mas_left).offset(-10);
    }];
}

-(UIView*)createNumberTitle:(NSString*)title label:(UILabel*)countLabel {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor clearColor];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@22);
    }];

    if (countLabel == self.likeCountLabel) {
        [container addSubview:self.likeCountLabel];
        [self.likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(container);
        }];
    } else if (countLabel == self.followCountLabel) {
        [container addSubview:self.followCountLabel];
        [self.followCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(container);
        }];
    } else if (countLabel == self.fansCountLabel) {
        [container addSubview:self.fansCountLabel];
        [self.fansCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(container);
        }];
    }

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = RGB_COLOR(@"#757575", 1);
    [container addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countLabel.mas_right).offset(2);
        make.bottom.right.equalTo(container);
    }];

    if ([title isEqualToString:YZMsg(@"public_like")]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLike)];
        [container addGestureRecognizer:tap];
    } else if ([title isEqualToString:YZMsg(@"homepageController_attention")]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFollow)];
        [container addGestureRecognizer:tap];
    } else if ([title isEqualToString:YZMsg(@"public_fans")]) {
        /*
         客服-Chen: 短视频用户资料这里的关注和粉丝，按照版本点了没反应，苹果的可以点，但是苹果的显示有粉丝和关注，点进去是空白。
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFans)];
        [container addGestureRecognizer:tap];
         */
    }

    return container;
}

- (void)updateData:(NSDictionary*)dic {
    otherUserMsgCollectionViewController *liveController = self.viewControllers[2];
    liveController.level_anchor = minstr(self.infoModel.level_anchor);

    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"avatar"])] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
    self.nameLabel.text = minstr([dic valueForKey:@"user_nicename"]);

    NSString *laingname = minstr([[dic valueForKey:@"liang"] valueForKey:@"name"]);
    if ([laingname isEqual:@"0"]) {
        self.IDLabel.text = [NSString stringWithFormat:@"ID:%@",minstr([dic valueForKey:@"id"])];
    } else{
        self.IDLabel.text = [NSString stringWithFormat:@"%@:%@",YZMsg(@"public_liang"),laingname];
    }

    [self.avatarIcon sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"avatar"])] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];

    if ([minstr([dic valueForKey:@"sex"]) isEqual:@"1"]) {
        self.sexImgView.image = [ImageBundle imagewithBundleName:@"PersonalCenterManIcon"];
    }else{
        self.sexImgView.image = [ImageBundle imagewithBundleName:@"PersonalCenterWomanIcon"];
    }

    NSDictionary *levelDic1 = [common getAnchorLevelMessage:minstr([dic valueForKey:@"level_anchor"])];
    [self.hostImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic1 valueForKey:@"thumb"])]];

    NSDictionary *levelDic = [common getUserLevelMessage:minstr([dic valueForKey:@"level"])];
    [self.levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];

    self.likeCountLabel.text = [YBToolClass formatLikeNumber:minstr([dic valueForKey:@"short_video_total_like_count"])];
    self.followCountLabel.text = [YBToolClass formatLikeNumber:minstr([dic valueForKey:@"follows"])];
    self.fansCountLabel.text = [YBToolClass formatLikeNumber:minstr([dic valueForKey:@"fans"])];

    NSString *signatureText = minstr([dic valueForKey:@"signature"]);
    self.siginLabel.text = signatureText;
    self.siginLabel.hidden = signatureText.length <= 0;

    [self.impressView removeAllSubviews];
    UIFont *impressFont = [UIFont systemFontOfSize:14];
    NSArray *labelArray = [dic valueForKey:@"label"];
    CGFloat speace = 8;
    if (labelArray.count>0) {
        CGFloat jianju = 0;
        for (int i = 0; i < labelArray.count; i ++) {
            UILabel *label = [[UILabel alloc]init];
            label.font = impressFont;
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.cornerRadius = 5;
            label.layer.masksToBounds = YES;
            label.text = minstr([labelArray[i] valueForKey:@"name"]);
            UIColor *color = RGB_COLOR(minstr([labelArray[i] valueForKey:@"colour"]), 1);
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = color;
            [self.impressView addSubview:label];
            CGFloat yinxiangWidth = [[YBToolClass sharedInstance] widthOfString:label.text andFont:impressFont andHeight:26];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.impressView).offset(15+jianju);
                make.width.mas_equalTo(yinxiangWidth + speace);
                make.height.mas_equalTo(26);
                make.top.equalTo(self.impressLabel.mas_bottom).offset(6);
            }];
            jianju = yinxiangWidth+ speace + 10 + jianju;
            if (i == labelArray.count - 1) {
                [self.addImpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(label.mas_right).offset(15);
                    make.height.mas_equalTo(26);
                    make.width.mas_equalTo(60+speace);
                    make.top.equalTo(label);
                }];
            }
        }
    }else{
        [self.addImpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.impressView).offset(15);
            make.height.mas_equalTo(26);
            make.width.mas_equalTo(80);
            make.top.equalTo(self.impressLabel.mas_bottom).offset(6);
        }];
    }

//    [self updateContribution:[dic valueForKey:@"contribute"] view:self.contributionView];
//    [self updateContribution:[dic valueForKey:@"guardlist"] view:self.guardView];

    [self.liveBtn setTitle:[NSString stringWithFormat:@"%@ %@",YZMsg(@"homepageController_live"),minstr([dic valueForKey:@"livenums"])] forState:0];

    self.liveGifImg.hidden = !self.infoModel.isLive;
    self.liveOnlineBtn.hidden = !self.infoModel.isLive;
}

- (void)updateContribution:(NSArray*)listArray view:(UIView*)container {
    if (![listArray isKindOfClass:[NSArray class]]) {
        listArray = @[];
    }
    int maxPerple = listArray.count > 3 ? 3:(int)listArray.count;
    for (int i = 0; i < maxPerple; i ++ ) {
        UIImageView *icon = [[UIImageView alloc]init];
        [icon sd_setImageWithURL:[NSURL URLWithString:minstr([listArray[i] valueForKey:@"avatar"])]];
        icon.layer.cornerRadius = 15;
        icon.layer.masksToBounds = YES;
        icon.layer.borderWidth = 1;
        [container addSubview:icon];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.centerY.equalTo(container);
        }];
        if (i == 0) {
            [icon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(container).offset(-40*(maxPerple -1) - 15);
            }];
            icon.layer.borderColor= RGB_COLOR(@"#ffdd00", 1).CGColor;
        }
        if (i == 1) {
            [icon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(container).offset(-40*(maxPerple -2) - 15);
            }];
            icon.layer.borderColor= RGB_COLOR(@"#cbd4da", 1).CGColor;

        }
        if (i == 2) {
            [icon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(container).offset(-40*(maxPerple -3) - 15);
            }];
            icon.layer.borderColor= RGB_COLOR(@"#ac6a00", 1).CGColor;
        }
    }
}

- (void)changeAttentionButtonStyle:(BOOL)isAttention {
    if (isAttention) {
        [self.attionBtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
        self.attionBtn.backgroundColor = [UIColor whiteColor];
        [self.attionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.attionBtn setImage:nil forState:UIControlStateNormal];
        return;
    }
    [self.attionBtn setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
    self.attionBtn.backgroundColor = RGB_COLOR(@"#B42ECC", 1);
    [self.attionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.attionBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterAddIcon"] forState:UIControlStateNormal];
}

- (void)addImpBtnClick{
    impressVC *vc = [[impressVC alloc]init];
    vc.isAdd = YES;
    vc.touid = _userID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView*)createRank:(NSString*)title imageString:(NSString*)imageString {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.cornerRadius = 10;
    container.layer.masksToBounds = YES;

    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.image = [ImageBundle imagewithBundleName:imageString];
    [container addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@16);
        make.centerY.equalTo(container);
        make.left.equalTo(container).offset(11);
    }];

    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.image = [ImageBundle imagewithBundleName:@"arrows_43"];
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [container addSubview:arrowImageView];
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@5);
        make.height.equalTo(@11);
        make.right.equalTo(container).offset(-17);
        make.centerY.equalTo(container);
    }];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = RGB_COLOR(@"#000000", 1);
    titleLabel.text = title;
    [container addSubview:titleLabel];
    [container addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImageView.mas_right).offset(4);
        make.centerY.equalTo(container);
        make.right.equalTo(arrowImageView.mas_left).offset(-5);
    }];

    if ([title isEqualToString:YZMsg(@"RankVC_contribution_list")]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContribution)];
        [container addGestureRecognizer:tap];
    } else if ([title isEqualToString:YZMsg(@"otherUserMsgVC_GuardTop")]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGuard)];
        [container addGestureRecognizer:tap];
    }

    return container;
}

//- (void)creatBottomView{
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, personCollection.bottom, _window_width, 40+ShowDiff)];
//    view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:view];
//    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _window_width, 1) andColor:RGB_COLOR(@"#f4f5f6", 1) andView:view];
//
//    //NSArray *bottomTitleArr = @[YZMsg(@"关注"),YZMsg(@"私信"),YZMsg(@"拉黑")];
//    NSArray *bottomTitleArr = @[YZMsg(@"homepageController_attention"),YZMsg(@"otherUserMsgVC_block")];
//    for (int i = 0; i< bottomTitleArr.count; i++) {
//        UIButton *btn = [UIButton buttonWithType:0];
//        btn.frame = CGRectMake(_window_width/2*i, 0, _window_width/2, 40);
//        [btn setTitle:bottomTitleArr[i] forState:0];
//        [btn setTitleColor:RGB_COLOR(@"#333333", 1) forState:0];
//        btn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [btn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:btn];
//        if (i == 0) {
//            self.attionBtn = btn;
//        }
//        if (i == 1) {
//            //jmsgBtn = btn;
//        }
//        if (i == 2) {
//            self.blackBtn = btn;
//        }
//        if (i != bottomTitleArr.count - 1) {
//            [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(btn.right-0.5, 12, 1, 16) andColor:RGB_COLOR(@"#f4f5f6", 1) andView:view];
//        }
//    }
//}

#pragma mark - Action
- (void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapSearch{
//    if (self.infoModel) {
//        if (!shareView) {
//            shareView = [[fenXiangView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
//            [shareView GetModel:infoModel];
//            [self.view addSubview:shareView];
//        }else{
//            [shareView show];
//        }
//    }
}

-(void)goLivePlay {
    if (self.infoModel) {
        [[EnterLivePlay sharedInstance]showLivePlayFromLiveID:[_userID integerValue] fromInfoPage:YES];
    }
}

- (void)live_videoSwitch:(UIButton *)sender{
    self.videoBtn.selected = NO;
    self.likeBtn.selected = NO;
    self.liveBtn.selected = NO;
    sender.selected = YES;

    NSString *type;
    if (sender.tag == 1213) {
        type = @"作品";
        [self goToPageAtIndex:0];
    } else if (sender.tag == 1214) {
        type = @"喜欢";
        [self goToPageAtIndex:1];
    } else {
        type = @"直播";
        [self goToPageAtIndex:2];
    }
    
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type": type};
    [MobClick event:@"user_profile_click" attributes:dict];
}

- (void)changeSegmentStyle {

}

- (void)tapLike {

}

- (void)tapFans {
    fansViewController *fans = [[fansViewController alloc]init];
    fans.fensiUid = _userID;
    [self.navigationController pushViewController:fans animated:YES];
}

- (void)tapFollow {
    attrViewController *att = [[attrViewController alloc]init];
    att.guanzhuUID = _userID;
    [self.navigationController pushViewController:att animated:YES];
}

//贡献榜
- (void)tapContribution {
    webH5 *rank = [[webH5 alloc]init];
    NSString *url = [NSString stringWithFormat:@"%@/index.php?g=Appapi&m=contribute&a=index&uid=%@&touid=%@&token=%@",[DomainManager sharedInstance].domainGetString,self.userID,[Config getOwnID],[Config getOwnToken]];
    url = [url stringByAppendingFormat:@"&l=%@",[YBNetworking currentLanguageServer]];
    rank.urls = url;
    
    [self.navigationController pushViewController:rank animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type": @"贡献榜"};
    [MobClick event:@"user_profile_click" attributes:dict];
}
//守护榜
- (void)tapGuard {
    guardRankVC *rank = [[guardRankVC alloc]init];
    rank.liveUID = self.userID;
    [self.navigationController pushViewController:rank animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type": @"守护榜"};
    [MobClick event:@"user_profile_click" attributes:dict];
}

#pragma mark - API
- (void)requestData{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getUserHome" withBaseDomian:YES andParameter:@{@"touid":_userID} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSDictionary *subDic = [info firstObject];
            strongSelf.infoModel = [hotModel mj_objectWithKeyValues:subDic];
            [strongSelf updateData:subDic];
            [strongSelf.liveArray addObjectsFromArray:[subDic valueForKey:@"liverecord"]];
            [strongSelf.videoArray addObjectsFromArray:[subDic valueForKey:@"videolist"]];

//            [strongSelf->personCollection reloadData];
            strongSelf.chatname = [subDic valueForKey:@"user_nicename"];
            strongSelf.icon = [subDic valueForKey:@"avatar"];

            if ([[subDic valueForKey:@"isattention"] isEqual:@"0"]) {
                [strongSelf changeAttentionButtonStyle:NO];
            } else {
                [strongSelf changeAttentionButtonStyle:YES];
            }

//            if ([[subDic valueForKey:@"isblack"] isEqual:@"1"]) {
//                [strongSelf->blackBtn setTitle:YZMsg(@"otherUserMsgVC_blocked") forState:UIControlStateNormal];
//            }
//            else{
//                [strongSelf->blackBtn setTitle:YZMsg(@"otherUserMsgVC_block") forState:UIControlStateNormal];
//            }

        }
    } fail:^(NSError * _Nonnull error) {

    }];
}

- (void)bottomBtnClick:(UIButton *)sender{
    //关注
    if (sender == self.attionBtn) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [hud hideAnimated:YES afterDelay:10];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:@{@"touid":_userID,@"is_follow":([self.attionBtn.titleLabel.text isEqualToString:YZMsg(@"upmessageInfo_followed")]?@"0":@"1")} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [hud hideAnimated:YES];
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                [strongSelf requestData];
                if (![info isKindOfClass:[NSArray class]]) {
                    return;
                }

                NSDictionary *dic = [info firstObject];
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    return;
                }

                NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                newDic[@"uid"] = strongSelf.userID;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLiveplayAttion" object:newDic];

                NSString *isattent = minstr(dic[@"isattent"]);

                if ([isattent isEqual:@"1"]) {
                    [strongSelf changeAttentionButtonStyle:YES];
                    [strongSelf.blackBtn setTitle:YZMsg(@"otherUserMsgVC_block") forState:UIControlStateNormal];
                    NSLog(@"关注成功");
                    if (strongSelf.block) {
                        strongSelf.block();
                    }
                }
                else
                {
                    [strongSelf changeAttentionButtonStyle:NO];
                    NSLog(@"取消关注成功");
                }
            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^(NSError * _Nonnull error) {
            [hud hideAnimated:YES];
        }];

    }
    //私信
    /*
    if (sender == jmsgBtn) {
        NSString *name = [NSString stringWithFormat:@"%@%@",JmessageName,self.userID];
        //创建会话
        WeakSelf
        [JMSGConversation createSingleConversationWithUsername:name completionHandler:^(id resultObject, NSError *error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (error == nil) {
                JCHATConversationViewController *sendMessageCtl =[[JCHATConversationViewController alloc] initWithNibName:@"JCHATConversationViewController" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
                sendMessageCtl.hidesBottomBarWhenPushed = YES;
                sendMessageCtl.conversation = resultObject;
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:minstr(strongSelf.icon) forKey:@"avatar"];
                [dic setObject:minstr(strongSelf.userID) forKey:@"id"];
                [dic setObject:minstr(strongSelf.chatname) forKey:@"user_nicename"];
                [dic setObject:minstr(strongSelf.chatname) forKey:@"name"];
                if ([strongSelf->attionBtn.titleLabel.text isEqual:YZMsg(@"关注")]) {
                    [dic setObject:@"0" forKey:@"utot"];
                }else{
                    [dic setObject:@"1" forKey:@"utot"];
                }
                [dic setObject:resultObject forKey:@"conversation"];
                MessageListModel *model = [[MessageListModel alloc]initWithDic:dic];
                sendMessageCtl.userModel = model;
                [strongSelf.navigationController pushViewController:sendMessageCtl animated:YES];
            }else{
                [MBProgressHUD showError:YZMsg(@"对方未注册私信")];
            }
        }];

    }
     */
    //拉黑
    if (sender == self.blackBtn) {
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setBlack" withBaseDomian:YES andParameter:@{@"touid":_userID} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (code == 0) {
                if ([strongSelf.blackBtn.titleLabel.text isEqual:YZMsg(@"otherUserMsgVC_block")]) {
                    [strongSelf.blackBtn setTitle:YZMsg(@"otherUserMsgVC_blocked") forState:UIControlStateNormal];
                    [strongSelf changeAttentionButtonStyle:NO];
                    [MBProgressHUD showError:YZMsg(@"otherUserMsgVC_blocked")];
                }
                else{
                    [strongSelf.blackBtn setTitle:YZMsg(@"otherUserMsgVC_block") forState:UIControlStateNormal];
                    [MBProgressHUD showError:YZMsg(@"otherUserMsgVC_unblocked")];
                }

            }
        } fail:^(NSError * _Nonnull error) {

        }];
    }
}

#pragma mark - Lazy
- (UILabel *)likeCountLabel {
    if (!_likeCountLabel) {
        _likeCountLabel = [[UILabel alloc] init];
        _likeCountLabel.font = [UIFont boldSystemFontOfSize:16];
        _likeCountLabel.textColor = RGB_COLOR(@"#000000", 1);
    }
    return _likeCountLabel;
}

- (UILabel *)followCountLabel {
    if (!_followCountLabel) {
        _followCountLabel = [[UILabel alloc] init];
        _followCountLabel.font = [UIFont boldSystemFontOfSize:16];
        _followCountLabel.textColor = RGB_COLOR(@"#000000", 1);
    }
    return _followCountLabel;
}

- (UILabel *)fansCountLabel {
    if (!_fansCountLabel) {
        _fansCountLabel = [[UILabel alloc] init];
        _fansCountLabel.font = [UIFont boldSystemFontOfSize:16];
        _fansCountLabel.textColor = RGB_COLOR(@"#000000", 1);
    }
    return _fansCountLabel;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > 64+statusbarHeight) {
        self.naviView.backgroundColor = RGB_COLOR(@"#ffffff", 1);
        [self.returnBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterBackIcon_black"] forState:0];
        [self.shareBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterSearchIcon_black"] forState:0];
        self.titleLabel.text = minstr(self.chatname);
    }else{
        self.naviView.backgroundColor = RGB_COLOR(@"#ffffff", scrollView.contentOffset.y/(64.00000+statusbarHeight));
        [self.returnBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterBackIcon"] forState:0];
        [self.shareBtn setImage:[ImageBundle imagewithBundleName:@"PersonalCenterSearchIcon"] forState:0];
        self.titleLabel.text = @"";
    }

    BOOL canScroll = NO;
    if (scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height) {
        canScroll = YES;
    }
    if (canScroll) {
        self.scrollView.scrollEnabled = NO;
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            strongSelf.scrollView.scrollEnabled = YES;
        });
    }
    for (otherUserMsgCollectionViewController *controller in self.viewControllers) {
        [controller scroll:canScroll];
    }

    if (scrollView.contentOffset.y <= 0) {
        CGFloat height = HeaderImageHeight + fabs(scrollView.contentOffset.y);
        [self.backgroundImageHeightConstraint setOffset:height];
        [self.view layoutIfNeeded];
    }
}

#pragma mark - UIPageViewController
- (void)createPageViewController {
    otherUserMsgCollectionViewController *videoController = [[otherUserMsgCollectionViewController alloc] initWithType:otherUserMsgCollectionViewControllerVideo userID:self.userID];
    videoController.delegate = self;
    otherUserMsgCollectionViewController *likeController = [[otherUserMsgCollectionViewController alloc] initWithType:otherUserMsgCollectionViewControllerTypeLike userID:self.userID];
    likeController.delegate = self;
    otherUserMsgCollectionViewController *liveController = [[otherUserMsgCollectionViewController alloc] initWithType:otherUserMsgCollectionViewControllerTypeLive userID:self.userID];
    liveController.delegate = self;
    liveController.chatname = self.chatname;
    liveController.icon = self.icon;
    self.viewControllers = @[videoController, likeController, liveController];

    self.pageViewController = [[ScrollUIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.insetsLayoutMarginsFromSafeArea = NO;
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageViewController.scrollDelegate = self;

    // 设置初始页面
    [self.pageViewController setViewControllers:@[videoController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // 将 UIPageViewController 添加为子视图控制器
    [self addChildViewController:self.pageViewController];
    [self.segmentView addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    // 设置 UIPageViewController 的视图约束
    self.pageViewController.view.frame = self.segmentView.bounds;
}

- (void)goToPageAtIndex:(NSUInteger)index {
    if (index < self.viewControllers.count) {
        UIViewController *targetViewController = self.viewControllers[index];
        NSUInteger currentIndex = [self.viewControllers indexOfObject:self.pageViewController.viewControllers.firstObject];
        UIPageViewControllerNavigationDirection direction = (index > currentIndex) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;

        self.currentPage = index;
        WeakSelf
        [UIView animateWithDuration:0.3 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            UIButton *sender = nil;
            if (strongSelf.currentPage == 1) {
                sender = strongSelf.likeBtn;
            } else if (strongSelf.currentPage == 2) {
                sender = strongSelf.liveBtn;
            } else {
                sender = strongSelf.videoBtn;
            }
            self.segmentSelectLineView.x = sender.x + self.segmentStackView.x;
        }];
        self.scrollDelegateEnable = NO;

        [self.pageViewController setViewControllers:@[targetViewController]
                                          direction:direction
                                           animated:YES
                                         completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.scrollDelegateEnable = YES;
        }];
    }
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    return self.viewControllers[index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound || index == self.viewControllers.count - 1) {
        return nil;
    }
    return self.viewControllers[index + 1];
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        NSUInteger currentIndex = [self.viewControllers indexOfObject:[pageViewController.viewControllers firstObject]];
        self.currentPage = currentIndex;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [self.viewControllers indexOfObject:[pageViewController.viewControllers firstObject]];
}

#pragma mark - otherUserMsgCollectionViewControllerDelegate
- (void)otherUserMsgCollectionViewControllerForEndRefresh {
    [self.scrollView.mj_header endRefreshing];
}

- (void)otherUserMsgCollectionViewControllerForScrollToTop {
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y-5) animated:YES];
    for (otherUserMsgCollectionViewController *controller in self.viewControllers) {
        [controller scroll:NO];
    }
}

- (CGFloat)otherUserMsgCollectionViewControllerForGetEmptyHeight {
    return _window_height - CGRectGetMaxY(self.otherView.frame);;
}

#pragma mark - ScrollUIPageViewControllerDelegate
- (void)scrollUIPageViewControllerDelegateForScroll:(CGFloat)moveX scrollViewWidth:(CGFloat)scrollViewWidth scrollContentSizeWidth:(CGFloat)scrollContentSizeWidth {
    if (!self.scrollDelegateEnable) {
        return;
    }
    CGFloat newX = moveX + (self.currentPage * scrollViewWidth);
    CGFloat changeX = self.segmentStackView.width / scrollContentSizeWidth * newX + self.segmentStackView.x;
    if (changeX <= self.segmentStackView.x || (changeX + self.segmentSelectLineView.width) >= (self.segmentStackView.x + self.segmentStackView.width)) {
        return;
    }

    self.segmentSelectLineView.x = changeX;
    UIButton *sender = nil;

    if (CGRectGetMaxX(self.segmentSelectLineView.frame) > self.liveBtn.centerX) {
        sender = self.liveBtn;
    } else if (CGRectGetMaxX(self.segmentSelectLineView.frame) > self.likeBtn.centerX) {
        sender = self.likeBtn;
    } else {
        sender = self.videoBtn;
    }
    self.videoBtn.selected = NO;
    self.likeBtn.selected = NO;
    self.liveBtn.selected = NO;
    sender.selected = YES;
}

@end
