//
//  ShortVideosFollowHeader.m
//  phonelive2
//
//  Created by s5346 on 2024/9/27.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideosFollowHeader.h"
#import "otherUserMsgVC.h"
#import <UMCommon/UMCommon.h>

@interface ShortVideosFollowHeader ()
@property(nonatomic, strong) SDAnimatedImageView *avatarView;
@property(nonatomic, strong) UILabel *nickNameLabel;
@property(nonatomic, strong) UILabel *signatureLabel;
@property(nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) UIStackView *followStackView;
@property(nonatomic, strong) UIButton *followButton;
@property(nonatomic, strong) UIButton *followedButton;
@property(nonatomic, assign) ShortVideosFollowUserModel *model;
@property (assign,nonatomic) BOOL isFollowing;
@end

@implementation ShortVideosFollowHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(ShortVideosFollowUserModel*)model {
    self.model = model;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    self.nickNameLabel.text = model.nickname;
    self.signatureLabel.text = model.uid;



    self.infoLabel.text = [NSString stringWithFormat:@"%@ %@  %@ %@  %@ %@",
                           YZMsg(@"public_like"), [YBToolClass formatLikeNumber: model.like_count],
                           YZMsg(@"public_fans"), [YBToolClass formatLikeNumber: model.fans_count],
                           YZMsg(@"homepageController_attention"), [YBToolClass formatLikeNumber: model.follow_count]];
    BOOL isFollow = model.is_followed.boolValue;
    self.followButton.hidden = isFollow;
    self.followedButton.hidden = !isFollow;

    NSString *followTitle = model.is_recommend.intValue == 1 ? YZMsg(@"follow_recommend") : YZMsg(@"homepageController_attention");
    [self.followButton setTitle:followTitle forState:UIControlStateNormal];
}

- (NSString*)changeUnit:(NSString*)count {
    int countInt = count.intValue;
    if (countInt >= 10000) {
        return [NSString stringWithFormat:@"%.1f %@",
                countInt/10000.00,
                YZMsg(@"short_video_favorite_unit")];;
    }
    return count;
}

#pragma mark - UI
- (void)setupViews {
    [self addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
        make.size.equalTo(@50);
    }];

    [self addSubview:self.followStackView];
    [self.followStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.height.equalTo(@24);
    }];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.nickNameLabel, self.signatureLabel, self.infoLabel]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self.avatarView.mas_right).offset(10);
        make.right.lessThanOrEqualTo(self.followStackView.mas_left).offset(-5);
    }];
}

#pragma mark - Action
- (void)redirectToProfile {
    if (self.isFollowing) return; // 打关注API过程不让用户点进去个人页
    otherUserMsgVC *person = [[otherUserMsgVC alloc]init];
    person.userID = self.model.uid;
    [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"recommend":[self.model.is_recommend isEqualToString:@"1"] ? @(1) : @(0)};
    [MobClick event:@"shortvideo_follow_useravatar_click" attributes:dict];
}

- (void)followAction {
    BOOL isFollow = YES;
    self.model.is_followed = isFollow ? @"1" : @"0";
    self.followButton.hidden = isFollow;
    self.followedButton.hidden = !isFollow;
    [self requestFollow:isFollow];
    [MobClick event:@"shortvideo_follow_user_click" attributes:@{@"eventType": @(1)}];
}

- (void)unfollowAction {
    BOOL isFollow = NO;
    self.model.is_followed = isFollow ? @"1" : @"0";
    self.followButton.hidden = isFollow;
    self.followedButton.hidden = !isFollow;
    [self requestFollow:isFollow];
}

#pragma mark - API
- (void)requestFollow:(BOOL)isFollow {
    if (self.model == nil) {
        return;
    }
    NSDictionary *dic = @{
        @"touid": self.model.uid,
        @"is_follow": isFollow ? @(1) : @(0)
    };
    self.isFollowing = YES;
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isFollowing = NO;
        if (code == 0) {
            if (![info isKindOfClass:[NSArray class]]) {
                return;
            }

            NSDictionary *dic = [info firstObject];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                return;
            }

            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            newDic[@"uid"] = strongSelf.model.uid;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLiveplayAttion" object:newDic];
        } else {
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isFollowing = NO;
    }];
}

#pragma mark - Lazy
- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[SDAnimatedImageView alloc]init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.layer.cornerRadius = 25.0;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redirectToProfile)];
        [_avatarView addGestureRecognizer:tap];
    }
    return _avatarView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [UILabel new];
        _nickNameLabel.font = [UIFont boldSystemFontOfSize:14];
        _nickNameLabel.textColor = RGB_COLOR(@"#000000", 0.7);
    }
    return _nickNameLabel;
}

- (UILabel *)signatureLabel {
    if (!_signatureLabel) {
        _signatureLabel = [UILabel new];
        _signatureLabel.font = [UIFont boldSystemFontOfSize:10];
        _signatureLabel.textColor = RGB_COLOR(@"#97a4b0", 1);
    }
    return _signatureLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [UILabel new];
        _infoLabel.font = [UIFont boldSystemFontOfSize:10];
        _infoLabel.textColor = RGB_COLOR(@"#97a4b0", 1);
    }
    return _infoLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton new];
        [_followButton addTarget:self action:@selector(followAction) forControlEvents:UIControlEventTouchUpInside];
        _followButton.backgroundColor = RGB_COLOR(@"#d6a9ff", 1);
        _followButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        _followButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _followButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_followButton setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
        [_followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _followButton.layer.cornerRadius = 24 / 2.0;
        _followButton.layer.masksToBounds = YES;
        [_followButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(24));
        }];
    }
    return _followButton;
}

- (UIButton *)followedButton {
    if (!_followedButton) {
        _followedButton = [UIButton new];
        [_followedButton addTarget:self action:@selector(unfollowAction) forControlEvents:UIControlEventTouchUpInside];
        _followedButton.backgroundColor = [UIColor whiteColor];
        _followedButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        _followedButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _followedButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_followedButton setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
        [_followedButton setTitleColor:RGB_COLOR(@"#d6a9ff", 1) forState:UIControlStateNormal];
        _followedButton.layer.cornerRadius = 24 / 2.0;
        _followedButton.layer.borderWidth = 1.0;
        _followedButton.layer.borderColor = RGB_COLOR(@"#d6a9ff", 1).CGColor;
        _followedButton.layer.masksToBounds = YES;
        [_followedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@24);
        }];
    }
    return _followedButton;
}

- (UIStackView *)followStackView {
    if (!_followStackView) {
        self.followButton.hidden = YES;
        self.followedButton.hidden = YES;
        _followStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.followButton, self.followedButton]];
    }
    return _followStackView;
}

@end
