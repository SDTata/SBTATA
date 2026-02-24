//
//  SearchResultAnchorListCell.m
//  phonelive2
//
//  Created by user on 2024/8/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SearchResultAnchorListCell.h"
#import "HomeSearchResultModel.h"
#import "LiveGifImage.h"
@interface SearchResultAnchorListCell ()

@property(nonatomic, strong) SDAnimatedImageView *avatarImageView;
@property(nonatomic, strong) UILabel *userNameLabel;
@property(nonatomic, strong) UILabel *fansCountLabel;
@property(nonatomic, strong) UILabel *accountLabel;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UIView *gifImgAndLiveTag;
// 舊版UI
@property(nonatomic, strong) UILabel *signatureL;
@property(nonatomic, strong) SDAnimatedImageView *sexL;
@property(nonatomic, strong) SDAnimatedImageView *levelL;
@property(nonatomic, strong) SDAnimatedImageView *hostlevel;

@end
@implementation SearchResultAnchorListCell

- (void)updateData {
    HomeSearchResultAnchorList *model = (HomeSearchResultAnchorList *)self.itemModel;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
    self.userNameLabel.text = model.user_nicename;
    _signatureL.text = [NSString stringWithFormat:@"%@: %@",YZMsg(@"ppublic_account"),model.identifier]; //model.signature;
    //性别 1男
    if ([[model valueForKey:@"sex"] isEqual:@"1"]) {
        self.sexL.image = [ImageBundle imagewithBundleName:@"sex_man"];
    }
    else {
        self.sexL.image = [ImageBundle imagewithBundleName:@"sex_woman"];
    }
    //级别
    NSDictionary *userLevel = [common getUserLevelMessage:model.level];
    [self.levelL sd_setImageWithURL:[NSURL URLWithString:minstr([[common getAnchorLevelMessage:model.level_anchor] valueForKey:@"thumb"])]];
    [self.hostlevel sd_setImageWithURL:[NSURL URLWithString:minstr([userLevel valueForKey:@"thumb"])]];
    
//    //关注
//    [self.subscribeButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"public_fans_followed_Icon")] forState:UIControlStateSelected];
//    
//    
//    [self.subscribeButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"public_fans_follow_Icon")] forState:UIControlStateNormal];
    // 设置默认（未选中）状态的边框颜色、宽度和圆角半径
   
    self.subscribeButton.layer.borderWidth = 1.5;
    self.subscribeButton.layer.cornerRadius = 13;
    
    // 设置按钮标题
    [self.subscribeButton setTitle:YZMsg(@"RankCell_FollowButton") forState:UIControlStateNormal];
    [self.subscribeButton setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateSelected];

    // 设置按钮标题颜色
    [self.subscribeButton setTitleColor:vkColorHex(0xff5fed) forState:UIControlStateNormal];
    [self.subscribeButton setTitleColor:vkColorHex(0xc8c8c8) forState:UIControlStateSelected];

    
    if ([model.identifier isEqual:[Config getOwnID]]) {
        self.subscribeButton.hidden = YES;
    } else {
        self.subscribeButton.hidden = NO;
        if ([model.isattention isEqual:@"0"]) {
            self.subscribeButton.selected = NO;
            self.subscribeButton.layer.borderColor = vkColorHex(0xff5fed).CGColor; // #ff5fed
        }
        else {
            self.subscribeButton.selected = YES;
            self.subscribeButton.layer.borderColor = vkColorHex(0xc8c8c8).CGColor; // #ff5fed
        }
    }
    self.fansCountLabel.text = [NSString stringWithFormat:@"%@: %@",YZMsg(@"public_fans"),model.fans];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLiveBorderWithAnimation:model.isLive];
    });
    self.gifImgAndLiveTag.hidden = !model.isLive;
}

- (void)updateView {
    self.contentView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.fansCountLabel];
//    [self.contentView addSubview:self.accountLabel];
    [self.contentView addSubview:self.signatureL];
    [self.contentView addSubview:self.sexL];
    [self.contentView addSubview:self.levelL];
    [self.contentView addSubview:self.hostlevel];
    [self.contentView addSubview:self.subscribeButton];
    [self.contentView addSubview:self.gifImgAndLiveTag];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(56);
        make.leading.mas_equalTo(self.contentView).offset(2);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(12);
        make.top.mas_equalTo(self.avatarImageView);
        make.height.mas_equalTo(18);
    }];
    
    [self.fansCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(12);
        make.top.mas_equalTo(self.userNameLabel.mas_bottom);
        make.height.mas_equalTo(18);
    }];
    
    [self.signatureL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(12);
        make.top.mas_equalTo(self.fansCountLabel.mas_bottom);
        make.height.mas_equalTo(18);
    }];
    
    [self.sexL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userNameLabel.mas_trailing).offset(5);
        make.centerY.mas_equalTo(self.userNameLabel);
        make.size.mas_equalTo(14);
    }];
    
    [self.levelL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.sexL.mas_trailing).offset(5);
        make.centerY.mas_equalTo(self.userNameLabel);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(28);
    }];
    
    [self.hostlevel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.levelL.mas_trailing).offset(5);
        make.centerY.mas_equalTo(self.userNameLabel);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(28);
        make.trailing.mas_lessThanOrEqualTo(self.subscribeButton.mas_leading).inset(4);
    }];
    
//    [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.avatarImageView.mas_trailing).offset(12);
//        make.top.mas_equalTo(self.userNameLabel.mas_bottom);
//        make.height.mas_equalTo(17);
//    }];
    
    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(52);
        make.trailing.mas_equalTo(self.contentView).inset(10);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.gifImgAndLiveTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.avatarImageView.mas_centerX);
        make.bottom.mas_equalTo(self.avatarImageView.mas_bottom);
        make.height.mas_equalTo(11);
        make.width.mas_equalTo(self.avatarImageView);
    }];
}

- (SDAnimatedImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[SDAnimatedImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = 28;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textColor = [UIColor blackColor];
        _userNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _userNameLabel;
}

- (UILabel *)fansCountLabel {
    if (!_fansCountLabel) {
        _fansCountLabel = [[UILabel alloc] init];
        _fansCountLabel.textColor = vkColorRGB(77, 77, 77);
        _fansCountLabel.font = [UIFont systemFontOfSize:12];
    }
    return _fansCountLabel;
}

- (UILabel *)accountLabel {
    if (!_accountLabel) {
        _accountLabel = [[UILabel alloc] init];
        _accountLabel.textColor = vkColorRGB(77, 77, 77);
        _accountLabel.font = [UIFont systemFontOfSize:12];
    }
    return _accountLabel;
}

- (UIButton *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [UIButton new];
//        _subscribeButton.titleLabel.textColor = [UIColor whiteColor];
        _subscribeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _subscribeButton.layer.masksToBounds = YES;
        _subscribeButton.titleLabel.minimumScaleFactor = 0.2;
        _subscribeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//        _subscribeButton.layer.cornerRadius = 9;
//        _subscribeButton.layer.borderWidth = 1;
//        _subscribeButton.layer.borderColor = UIColor.yellowColor.CGColor;
        //[_subscribeButton setTitle:YZMsg(@"homepageController_attention") forState: UIControlStateNormal];
        [_subscribeButton addTarget:self action:@selector(gaunzhuBTN:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subscribeButton;
}

- (SDAnimatedImageView *)sexL {
    if (!_sexL) {
        _sexL = [[SDAnimatedImageView alloc] init];
        _sexL.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _sexL;
}

- (SDAnimatedImageView *)levelL {
    if (!_levelL) {
        _levelL = [[SDAnimatedImageView alloc] init];
        _levelL.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _levelL;
}

- (SDAnimatedImageView *)hostlevel {
    if (!_hostlevel) {
        _hostlevel = [[SDAnimatedImageView alloc] init];
        _hostlevel.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _hostlevel;
}
- (UILabel *)signatureL {
    if (!_signatureL) {
        _signatureL = [[UILabel alloc] init];
        _signatureL.textColor = vkColorRGB(77, 77, 77);
        _signatureL.font = [UIFont systemFontOfSize:12];
    }
    return _signatureL;
}

- (void)gaunzhuBTN:(UIButton *)button {
    HomeSearchResultAnchorList *model = (HomeSearchResultAnchorList *)self.itemModel;
    if ([[Config getOwnID] isEqual:model.identifier]) {
        [MBProgressHUD showError:YZMsg(@"RankVC_FollowMeError")];
            return;
    }
    [self.delegate doGuanzhu:model.identifier button:button];
}

- (UIView *)gifImgAndLiveTag {
    if (!_gifImgAndLiveTag) {
        UIView *control = [[UIView alloc] init];

        NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation_white" ofType:@"gif"];
        YYAnimatedImageView *gifImg = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
        [imgAnima setAnimatedImageLoopCount:0];
        gifImg.image = imgAnima;
        gifImg.runloopMode = NSRunLoopCommonModes;
        gifImg.animationRepeatCount = 0;
        [gifImg startAnimating];
        
        UIView *tagView = [[UIView alloc] init];
        tagView.layer.masksToBounds = YES;
        tagView.backgroundColor = RGB_COLOR(@"#F251BB", 1);

        UILabel *label = [[UILabel alloc] init];
        label.text = YZMsg(@"Live Streaming");
        label.font = [UIFont systemFontOfSize:8];
        label.textColor = [UIColor whiteColor];
        [control addSubview:tagView];
        [tagView addSubview:gifImg];
        [tagView addSubview:label];
        [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(control);
            make.height.mas_equalTo(11);
        }];
        
        [gifImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tagView.mas_left).offset(2);
            make.centerY.equalTo(tagView);
            make.height.mas_equalTo(8);
            make.width.mas_equalTo(8);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(tagView).inset(2);
            make.right.equalTo(tagView).inset(2);
            make.left.equalTo(gifImg.mas_right).offset(3);
        }];
        _gifImgAndLiveTag = control;
        _gifImgAndLiveTag.hidden = YES;
    }
    return _gifImgAndLiveTag;
}

- (void)addLiveBorderWithAnimation:(BOOL)isLive {
    [self.avatarImageView.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        if ([layer.name isEqualToString:@"LiveBorderLayer"]) {
            [layer removeFromSuperlayer];
        }
    }];

    if (isLive) {
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.name = @"LiveBorderLayer";
        borderLayer.strokeColor = RGB_COLOR(@"#F251BB", 1).CGColor;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.lineWidth = 2.0;

        CGFloat extraPadding = 4.0;  // 調整這個值來改變間距
        CGFloat borderWidth = borderLayer.lineWidth;
        CGFloat newSize = self.avatarImageView.bounds.size.width + extraPadding * 2;

        // 設定邊框 Frame 並讓它居中
        borderLayer.frame = CGRectMake(0, 0, newSize, newSize);
        borderLayer.position = CGPointMake(CGRectGetMidX(self.avatarImageView.bounds),
                                           CGRectGetMidY(self.avatarImageView.bounds));
        
        // 設定圓角，確保邊框仍然是圓形
        borderLayer.cornerRadius = newSize / 2;
        
        // 修正 UIBezierPath，讓邊框完整包圍 avatar
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderWidth / 2 + extraPadding,
                                                                               borderWidth / 2 + extraPadding,
                                                                               newSize - borderWidth - extraPadding * 2,
                                                                               newSize - borderWidth - extraPadding * 2)];
        borderLayer.path = path.CGPath;

        // 添加呼吸動畫（閃爍效果）
        CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
        pulse.fromValue = @(1.0);
        pulse.toValue = @(0.3);
        pulse.duration = 0.8;
        pulse.autoreverses = YES;
        pulse.repeatCount = HUGE_VALF;
        [borderLayer addAnimation:pulse forKey:@"pulseAnimation"];

        [self.avatarImageView.layer addSublayer:borderLayer];
    }
}
@end
