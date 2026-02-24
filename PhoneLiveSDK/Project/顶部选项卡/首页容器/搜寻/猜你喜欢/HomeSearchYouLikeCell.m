//
//  HomeSearchYouLikeCell.m
//  c700LIVE
//
//  Created by user on 2024/7/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeSearchYouLikeCell.h"
#import "YouLikeView.h"
#import <UMCommon/UMCommon.h>

@interface HomeSearchYouLikeCell() <TagViewDelegate>
@property (nonatomic, strong) NSArray * dataSource;
@property (nonatomic, strong) YouLikeView *youLikeView;
@end

@implementation HomeSearchYouLikeCell

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    CGSize size = [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
    // 刷新子布局约束
    [self.youLikeView.collectionView setNeedsLayout];
    [self.youLikeView.collectionView layoutIfNeeded];
    // 获取scrollView高度
    CGFloat height = self.youLikeView.collectionView.collectionViewLayout.collectionViewContentSize.height;
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
    
    [bgView addSubview:self.youLikeView];
    [self.youLikeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.leading.trailing.mas_equalTo(bgView).inset(14);
        make.bottom.mas_equalTo(bgView).inset(14);
    }];
    
    [self updateData];
}

- (void)buttonAciton:(UIButton *)sender {
    self.didSelectCellBlock();
    [MobClick event:@"search_change_tag_click" attributes:@{@"eventType": @(1)}];
}

- (void)updateData {
    self.titleLabel.text = YZMsg(@"home_search_youLike");
    [self.rightButton setImage:[ImageBundle imagewithBundleName:@"home_search_cell_reflash"] forState:UIControlStateNormal];
}

#pragma mark - Set

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    if (_datas) {
        self.youLikeView.datas = datas;
    }
}

#pragma mark - Get

- (YouLikeView *)youLikeView {
    if (!_youLikeView) {
        _youLikeView = [YouLikeView new];
        _youLikeView.delelgate = self;
    }
    return _youLikeView;
}

#pragma mark - TagViewDelegate
- (void)didSelecedTag:(NSString *)text {
    [self.delegate didSelecedTag:text];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"guess_tag": text};
    [MobClick event:@"search_guess_click" attributes:dict];
}
@end
