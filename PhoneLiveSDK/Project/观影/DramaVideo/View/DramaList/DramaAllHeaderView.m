//
//  DramaAllHeaderView.m
//  phonelive2
//
//  Created by s5346 on 2024/5/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DramaAllHeaderView.h"

@interface DramaAllHeaderView ()

@property(nonatomic, strong) UILabel *allDramaTitleLabel;
@property(nonatomic, strong) UILabel *payInfoLabel;
@property(nonatomic, strong) UIView *payInfoView;
@property(nonatomic, strong) NSArray<DramaVideoInfoModel*> *videoInfoModels;

@end

@implementation DramaAllHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)updateData:(DramaInfoModel*)infoModel videoInfoModel:(NSArray<DramaVideoInfoModel*>*)videoInfoModels {
    self.videoInfoModels = videoInfoModels;
    int payCount = 0;
    for (DramaVideoInfoModel *model in videoInfoModels) {
        if (model.isNeedPay) {
            payCount += 1;
        }
    }

    NSString *allEpisodes = [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_all_episodes"), videoInfoModels.count];
    self.allDramaTitleLabel.text = [NSString stringWithFormat:@"%@•%@", infoModel.name, allEpisodes];
    self.payInfoLabel.text = @"";
    if (payCount > 0) {
        self.payInfoLabel.text = [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_pay_info"), payCount];
    }
    self.payInfoView.hidden = self.payInfoLabel.text.length <= 0;
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = RGB_COLOR(@"#333333", 1);
    self.layer.cornerRadius = 21;
    self.layer.masksToBounds = YES;

    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.image = [ImageBundle imagewithBundleName:@"djtb-2"];
    [self addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(23);
        make.centerY.equalTo(self);
        make.width.equalTo(@14);
        make.height.equalTo(@13.5);
    }];

    UIImageView *upArrowImageView = [[UIImageView alloc] init];
    upArrowImageView.image = [ImageBundle imagewithBundleName:@"xszk"];
    [self addSubview:upArrowImageView];
    [upArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@13);
        make.height.equalTo(@7);
        make.right.equalTo(self).offset(-23);
        make.centerY.equalTo(self);
    }];

    [self.payInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@14);
    }];

    [self.payInfoView addSubview:self.payInfoLabel];
    [self.payInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.payInfoView).inset(2);
        make.left.right.equalTo(self.payInfoView).inset(6);
    }];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.allDramaTitleLabel, self.payInfoView]];
    stackView.spacing = 2;
    stackView.alignment = UIStackViewAlignmentCenter;
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImageView.mas_right).offset(10);
        make.right.lessThanOrEqualTo(upArrowImageView.mas_left).offset(-10);
        make.centerY.equalTo(self);
    }];
}

#pragma mark - Lazy
- (UILabel *)allDramaTitleLabel {
    if (!_allDramaTitleLabel) {
        _allDramaTitleLabel = [[UILabel alloc] init];
        _allDramaTitleLabel.font = [UIFont systemFontOfSize:15];
        _allDramaTitleLabel.textColor = [UIColor whiteColor];
    }
    return _allDramaTitleLabel;
}

- (UIView *)payInfoView {
    if (!_payInfoView) {
        _payInfoView = [[UIView alloc] init];
        _payInfoView.backgroundColor = RGB_COLOR(@"#B73AF5", 1);
        _payInfoView.layer.cornerRadius = 7;
        _payInfoView.layer.masksToBounds = YES;
        _payInfoView.hidden = YES;
    }
    return _payInfoView;
}

- (UILabel *)payInfoLabel {
    if (!_payInfoLabel) {
        _payInfoLabel = [[UILabel alloc] init];
        _payInfoLabel.font = [UIFont systemFontOfSize:10];
        _payInfoLabel.textColor = [UIColor whiteColor];
    }
    return _payInfoLabel;
}

@end
