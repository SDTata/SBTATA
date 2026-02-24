//
//  VideoSectionCell.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoSectionCell.h"
#import "MovieHomeModel.h"

@implementation VideoSectionCell

+ (CGFloat)itemHeight {
    return 40;
}

- (UIView *)moreView {
    if (!_moreView) {
        _moreView = [[UIView alloc] init];
        _moreView.backgroundColor = RGB_COLOR(@"#F6F0FE", 1);
        _moreView.layer.cornerRadius = 11;
        _moreView.layer.masksToBounds = YES;
        [_moreView vk_addTapAction:self selector:@selector(clickMoreAction)];
        [_moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@22);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        arrowImageView.image = [ImageBundle imagewithBundleName:@"HotHeaderRightArrowIcon"];
        [_moreView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_moreView).offset(-9);
            make.centerY.equalTo(_moreView);
            make.size.equalTo(@12);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        titleLabel.text = YZMsg(@"More_title");
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = RGB_COLOR(@"#4D4D4D", 1);
        [_moreView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_moreView).offset(15);
            make.top.bottom.equalTo(_moreView);
            make.right.equalTo(arrowImageView.mas_left);
        }];
    }
    return _moreView;
}

- (void)updateView {
    UIView *tagView = [UIView new];
    tagView.backgroundColor = vkColorHex(0x9F57DF);
    [self addSubview:tagView];
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(3);
    }];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.blackColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(0);
    }];
    
    [self addSubview:self.moreView];
    [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(22);
    }];
}

- (void)updateData {
    MovieHomeModel *model = self.itemModel;
    self.titleLabel.text = model.sub_cate.name;
}

- (void)clickMoreAction {
    if (self.clickSectionActionBlock) {
        self.clickSectionActionBlock(self.indexPath, self.itemModel, 0);
    }
}

@end
