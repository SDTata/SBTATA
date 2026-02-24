//
//  HomeSearchRecordCell.m
//  phonelive2
//
//  Created by user on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeSearchRecordCell.h"
#import "BTagCollectionViewCell.h"
#import "BTagsView.h"

@interface HomeSearchRecordCell() <TagViewDelegate>
@property (nonatomic, strong) NSArray * dataSource;
@property (nonatomic, strong) BTagsView *tagsView;
@end

@implementation HomeSearchRecordCell
/// 此方法用于更新cell中嵌入collectionView等scrollView变化高度的计算
/// CGSize size = [super systemLayoutSizeFittingSize 返回的是默认布局可确定的高度
/// 由于collectionView高度是变化的，因此需要手动获取。并添加到size中返回，如果有分多个变化的view，需要累加
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    CGSize size = [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    // 刷新子布局约束
    [self.tagsView.collectionView setNeedsLayout];
    [self.tagsView.collectionView layoutIfNeeded];
    // 获取scrollView高度
    CGFloat height = self.tagsView.collectionView.collectionViewLayout.collectionViewContentSize.height;
    return CGSizeMake(size.width, height + size.height);
}

- (void)updateView {
    self.contentView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 16;
    bgView.layer.masksToBounds = YES;
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).inset(10);
    }];
    UILabel *titleLabel = [UIView vk_label:nil font:vkFontBold(11) color:UIColor.whiteColor];
    [bgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    self.titleLabel.textColor = vkColorHex(0x1A1A1A);
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(14);
        make.left.mas_equalTo(14);
    }];
    
    UIImageView *titleRightIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    titleRightIcon.contentMode = UIViewContentModeScaleAspectFit;
    [bgView addSubview: titleRightIcon];
    self.titleRightIcon = titleRightIcon;
    [titleRightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(titleLabel.mas_trailing).offset(6);
        make.size.mas_equalTo(31);
        make.centerY.mas_equalTo(titleLabel);
    }];
    [titleRightIcon setHidden:YES];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [rightButton addTarget:self action:@selector(buttonAciton:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:rightButton];
    self.rightButton = rightButton;
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(bgView).inset(10);
        make.size.mas_equalTo(18);
        make.centerY.mas_equalTo(titleLabel);
    }];
    
    [bgView addSubview:self.tagsView];
    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.leading.trailing.bottom.mas_equalTo(bgView).inset(10);
    }];
    
    [self updateData];
}

- (void)buttonAciton:(UIButton *)sender {
    [common saveSearchRedcord:@[]];
    [self.baseTableView reloadData];
}

- (void)updateData {
    self.titleLabel.text = YZMsg(@"home_search_searchRecord");
    [self.rightButton setImage:[ImageBundle imagewithBundleName:@"home_search_cell_clear"] forState:UIControlStateNormal];
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    if (_datas) {
        self.tagsView.datas = datas;
    }
}

#pragma mark - Get

- (BTagsView *)tagsView {
    if (!_tagsView) {
        _tagsView = [BTagsView new];
        _tagsView.delelgate = self;
    }
    return _tagsView;
}

#pragma mark - TagViewDelegate
- (void)didSelecedTag:(NSString *)text {
    if (![text isEqualToString:@""]) {
        [self.delegate didSelecedTag:text];
    }
    [self reload];
}
@end
