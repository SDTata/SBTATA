//
//  YBUserInfoContentTableViewCell.m
//  phonelive2
//
//  Created by user on 2024/7/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import "YBUserInfoContentTableViewCell.h"
#import "YBUserInfoContentView.h"


@interface YBUserInfoContentTableViewCell() <YBUserInfoContentViewDelegate>
@property (nonatomic, strong) NSArray * dataSource;
@property (nonatomic, strong) YBUserInfoContentView *infoContentView;
@end

@implementation YBUserInfoContentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self updateView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    [self updateView];
}

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    CGSize size = [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    // 刷新子布局约束
    [self.infoContentView.collectionView setNeedsLayout];
    [self.infoContentView.collectionView layoutIfNeeded];
    // 获取scrollView高度
    CGFloat height = self.infoContentView.collectionView.collectionViewLayout.collectionViewContentSize.height;
    return CGSizeMake(size.width, height);
}

- (void)updateView {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.infoContentView];
    [self.infoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.leading.trailing.mas_equalTo(self.contentView);
    }];
}

- (void)buttonAciton:(UIButton *)sender {
    self.didSelectCellBlock();
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    if (_datas) {
        self.infoContentView.datas = datas;
    }
}

#pragma mark - Get

- (YBUserInfoContentView *)infoContentView {
    if (!_infoContentView) {
        _infoContentView = [YBUserInfoContentView new];
        _infoContentView.delegate = self;
    }
    return _infoContentView;
}

#pragma mark - YBUserInfoContentViewDelegate
- (void)didSelected:(NSDictionary *)data {
    [self.delegate didSelected:data];
}
@end
