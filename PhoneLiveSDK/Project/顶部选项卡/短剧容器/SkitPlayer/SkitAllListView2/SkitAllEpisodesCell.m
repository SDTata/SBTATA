//
//  SkitAllEpisodesCell.m
//  phonelive2
//
//  Created by s5346 on 2025/3/16.
//  Copyright © 2025 toby. All rights reserved.
//

#import "SkitAllEpisodesCell.h"
#import "LiveGifImage.h"
@interface SkitAllEpisodesCell ()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) YYAnimatedImageView *liveGifImg;
@property (nonatomic, strong) UIView *vipPayView;
@property (nonatomic, strong) UIView *payView;
@property (nonatomic, strong) UILabel *payTitleLabel;

@end

@implementation SkitAllEpisodesCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)update:(SkitVideoInfoModel*)model index:(int)index isCurrent:(BOOL)isCurrent {
    if (model.isNeedPay) {
        self.vipPayView.hidden = !(model.isNeedPay == ShortVideoModelPayTypeVIP);
        if (self.vipPayView.isHidden) {
            self.payView.hidden = ![ShortVideoModel showPayTagIfNeed:model.coin_cost ticket_cost:model.ticket_cost];
            self.payTitleLabel.text = YZMsg(@"DramaAllListCell_pay");
        }
    } else {
        self.payView.hidden = ![ShortVideoModel showPayTagIfNeed:model.coin_cost ticket_cost:model.ticket_cost];
        self.payTitleLabel.text = YZMsg(@"movie_pay_Purchased");
    }

    self.titleLabel.text = [NSString stringWithFormat:@"%d", index];
    self.liveGifImg.hidden = !isCurrent;
    if (isCurrent) {
        self.containerView.backgroundColor = RGB_COLOR(@"#919191", 0.08);
        self.titleLabel.textColor = RGB_COLOR(@"#FF63AC", 1.0);
    } else {
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = RGB_COLOR(@"#919191", 1);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.vipPayView.horizontalColors = @[RGB_COLOR(@"#FFE4B8", 1.0), RGB_COLOR(@"#FF9A7C", 1.0)];
    self.payView.horizontalColors = @[RGB_COLOR(@"#FFC6F5", 1.0), RGB_COLOR(@"#FF6BAE", 1.0)];
}

#pragma mark - UI
- (void)setupViews {
    [self.contentView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - Lazy
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.layer.cornerRadius = 8;
        _containerView.layer.masksToBounds = YES;
        _containerView.backgroundColor = [UIColor whiteColor];

        _containerView.layer.borderColor = RGB_COLOR(@"#919191", 0.15).CGColor;
        _containerView.layer.borderWidth = 1;

        [_containerView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_containerView).inset(8);
            make.left.right.equalTo(_containerView).inset(14);
        }];

        [_containerView addSubview:self.liveGifImg];
        [self.liveGifImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(_containerView).inset(4);
            make.height.mas_equalTo(5);
            make.width.mas_equalTo(9);
        }];

        [_containerView addSubview:self.vipPayView];
        [self.vipPayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(_containerView);
            make.left.greaterThanOrEqualTo(_containerView).offset(10);
            make.height.equalTo(@15);
        }];

        [_containerView addSubview:self.payView];
        [self.payView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(_containerView);
            make.left.greaterThanOrEqualTo(_containerView).offset(10);
            make.height.equalTo(@15);
        }];
    }
    return _containerView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:600];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5;
        _titleLabel.textColor = RGB_COLOR(@"#919191", 1);
    }
    return _titleLabel;
}

- (YYAnimatedImageView *)liveGifImg {
    if (!_liveGifImg) {
        NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
        _liveGifImg = [[YYAnimatedImageView alloc]init];
        LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
        [imgAnima setAnimatedImageLoopCount:0];
        _liveGifImg.image = imgAnima;
        _liveGifImg.runloopMode = NSRunLoopCommonModes;
        _liveGifImg.animationRepeatCount = 0;
        [_liveGifImg startAnimating];
        _liveGifImg.hidden = YES;
    }
    return _liveGifImg;
}

- (UIView *)vipPayView {
    if (!_vipPayView) {
        _vipPayView = [UIView new];
        _vipPayView.layer.borderColor = RGB_COLOR(@"#FF9A7C", 1).CGColor;
        _vipPayView.layer.borderWidth = 0.6;
        _vipPayView.layer.cornerRadius = 8;
        _vipPayView.layer.maskedCorners = kCALayerMinXMaxYCorner;
        _vipPayView.layer.masksToBounds = YES;
        _vipPayView.hidden = YES;

        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:10 weight:600];
        titleLabel.textColor = RGB_COLOR(@"#632300", 1);
        titleLabel.text = YZMsg(@"VIP Pay");
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = 0.5;
        [_vipPayView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_vipPayView);
            make.left.right.equalTo(_vipPayView).inset(2);
        }];
    }
    return _vipPayView;
}

- (UIView *)payView {
    if (!_payView) {
        _payView = [UIView new];
        _payView.layer.borderColor = RGB_COLOR(@"#FF6BAE", 1).CGColor;
        _payView.layer.borderWidth = 0.6;
        _payView.layer.cornerRadius = 8;
        _payView.layer.maskedCorners = kCALayerMinXMaxYCorner;
        _payView.layer.masksToBounds = YES;
        _payView.hidden = YES;

        UILabel *titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:10 weight:600];
        titleLabel.textColor = RGB_COLOR(@"#632300", 1);
        titleLabel.text = YZMsg(@"DramaAllListCell_pay");
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = 0.5;
        [_payView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_payView);
            make.left.right.equalTo(_payView).inset(5);
        }];
        self.payTitleLabel = titleLabel;
    }
    return _payView;
}

@end
