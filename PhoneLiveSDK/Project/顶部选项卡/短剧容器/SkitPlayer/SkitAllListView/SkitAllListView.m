//
//  SkitAllListView.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitAllListView.h"
#import "SkitAllListCell.h"

@interface SkitAllListView () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UIView *floatingView;
@property(nonatomic, strong) UIView *headerContainer;
@property(nonatomic, strong) UILabel *allDramaTitleLabel;
@property(nonatomic, strong) UILabel *payInfoLabel;
@property(nonatomic, strong) UIView *payInfoView;
@property(nonatomic, strong) UILabel *episodeLabel;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray<SkitVideoInfoModel*> *videoInfoModels;
@property(nonatomic, strong) NSString *selectVideoId;
@property(nonatomic, strong) HomeRecommendSkit *infoModel;

@end

@implementation SkitAllListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
        [self showAnimation];
        self.selectVideoId = @"";
    }
    return self;
}

- (void)updateData:(HomeRecommendSkit*)infoModel videoInfoModel:(NSArray<SkitVideoInfoModel*>*)videoInfoModels selectVideoId:(NSString*)videoId {
    self.selectVideoId = videoId;
    self.videoInfoModels = videoInfoModels;
    self.infoModel = infoModel;
    int payCount = 0;
    for (SkitVideoInfoModel *model in videoInfoModels) {
        if (model.isNeedPay) {
            payCount += 1;
        }
    }

    self.allDramaTitleLabel.text = infoModel.name;
    self.payInfoLabel.text = @"";
    if (payCount > 0) {
        self.payInfoLabel.text = [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_pay_info"), payCount];
    }
    self.payInfoView.hidden = self.payInfoLabel.text.length <= 0;
    self.episodeLabel.text = [NSString stringWithFormat:YZMsg(@"DramaAllHeaderView_all_episodes"), videoInfoModels.count];

    [self.tableView reloadData];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if (touch.view != self) {
        return;
    }
    [self closeAnimation];
}

#pragma mark - UI
- (void)setupViews {
    [self addSubview:self.floatingView];
    [self.floatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@RatioBaseHeight720(510));
    }];

    [self.floatingView addSubview:self.headerContainer];
    [self.headerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.floatingView);
        make.height.equalTo(@60);
    }];

    [self.floatingView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerContainer.mas_bottom);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
    }];

    [self layoutIfNeeded];

    self.floatingView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.floatingView.bounds));
}

- (void)showAnimation {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.floatingView.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished) {
    }];
}

- (void)closeAnimation {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.floatingView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.floatingView.bounds));
    }
                     completion:^(BOOL finished) {
        [self close];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoInfoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SkitAllListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.videoInfoModels.count > indexPath.row) {
        SkitVideoInfoModel *model = self.videoInfoModels[indexPath.row];
        [cell updateData:model cover:self.infoModel.cover];

        if ([model.video_id isEqualToString:self.selectVideoId]) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.videoInfoModels.count <= indexPath.row) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(skitAllListViewDelegateForSelect:)]) {
        SkitVideoInfoModel *model = self.videoInfoModels[indexPath.row];
        [self.delegate skitAllListViewDelegateForSelect:model.video_id];
    }
    [self close];
}

#pragma mark - Action
- (void)close {
    if ([self.delegate respondsToSelector:@selector(skitAllListViewDelegateForClose)]) {
        [self.delegate skitAllListViewDelegateForClose];
    }
    [self removeFromSuperview];
}

#pragma mark - Lazy
- (UIView *)floatingView {
    if (!_floatingView) {
        _floatingView = [[UIView alloc] init];
        _floatingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _floatingView.layer.cornerRadius = 15;
        _floatingView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _floatingView.layer.masksToBounds = YES;
    }
    return _floatingView;
}

- (UIView *)headerContainer {
    if (!_headerContainer) {
        _headerContainer = [[UIView alloc] init];

        UIImageView *iconImageView = [[UIImageView alloc] init];
        iconImageView.image = [ImageBundle imagewithBundleName:@"djtb-2"];
        [_headerContainer addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headerContainer).offset(14);
            make.top.equalTo(_headerContainer).offset(15);
            make.width.equalTo(@18);
            make.height.equalTo(@17);
        }];

        UIButton *closeButton = [[UIButton alloc] init];
        [closeButton setImage:[ImageBundle imagewithBundleName:@"gb"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAnimation) forControlEvents:UIControlEventTouchUpInside];
        [_headerContainer addSubview:closeButton];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@24);
            make.right.equalTo(_headerContainer).offset(-19);
            make.top.equalTo(_headerContainer).offset(15);
        }];

        [self.payInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@16);
        }];

        [self.payInfoView addSubview:self.payInfoLabel];
        [self.payInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.payInfoView).inset(2);
            make.left.right.equalTo(self.payInfoView).inset(6);
        }];

        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.allDramaTitleLabel, self.payInfoView]];
        stackView.spacing = 2;
        stackView.alignment = UIStackViewAlignmentCenter;
        [_headerContainer addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconImageView.mas_right).offset(10);
            make.right.lessThanOrEqualTo(closeButton.mas_left).offset(-10);
            make.centerY.equalTo(iconImageView);
            make.height.equalTo(@22);
        }];

        [_headerContainer addSubview:self.episodeLabel];
        [self.episodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(stackView.mas_bottom);
            make.left.equalTo(stackView);
            make.right.equalTo(closeButton.mas_left).offset(-10);
            make.height.equalTo(@20);
        }];

        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = RGB_COLOR(@"#B7B7B7", 1);
        [_headerContainer addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_headerContainer).inset(14);
            make.bottom.equalTo(_headerContainer);
            make.height.equalTo(@1);
        }];
    }
    return _headerContainer;
}

- (UILabel *)allDramaTitleLabel {
    if (!_allDramaTitleLabel) {
        _allDramaTitleLabel = [[UILabel alloc] init];
        _allDramaTitleLabel.font = [UIFont systemFontOfSize:18];
        _allDramaTitleLabel.textColor = [UIColor whiteColor];
    }
    return _allDramaTitleLabel;
}

- (UIView *)payInfoView {
    if (!_payInfoView) {
        _payInfoView = [[UIView alloc] init];
        _payInfoView.backgroundColor = RGB_COLOR(@"#B73AF5", 1);
        _payInfoView.layer.cornerRadius = 8;
        _payInfoView.layer.masksToBounds = YES;
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

- (UILabel *)episodeLabel {
    if (!_episodeLabel) {
        _episodeLabel = [[UILabel alloc] init];
        _episodeLabel.font = [UIFont systemFontOfSize:13];
        _episodeLabel.textColor = RGB_COLOR(@"#B7B7B7", 1);
    }
    return _episodeLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_tableView registerClass:[SkitAllListCell class] forCellReuseIdentifier:@"cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
