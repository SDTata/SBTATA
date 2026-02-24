//
//  VideoMenuAlertView.m
//  phonelive2
//
//  Created by vick on 2024/7/4.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoMenuAlertView.h"

@implementation VideoMenuAlertCell

+ (NSInteger)itemCount {
    return 4;
}

+ (CGFloat)itemSpacing {
    return 10;
}

+ (CGFloat)itemLineSpacing {
    return 10;
}

+ (CGFloat)itemHeight {
    return 40;
}

- (void)updateView {
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self.contentView vk_border:nil cornerRadius:10];
    
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)updateData {
    MovieCateModel *model = self.itemModel;
    self.titleLabel.text = model.name;
}

@end


@implementation VideoMenuAlertView

/// 设置位置
- (CGPoint)alertCenterOffset {
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat offsetY = VK_SCREEN_H/2 - height/2 - VK_NAV_H * 2;
    return CGPointMake(0, -offsetY);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [VideoMenuAlertCell class];
        _tableView.scrollEnabled = NO;
        
        _weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, id item) {
            _strongify(self)
            [self hideAlert:nil];
            !self.clickIndexBlock ?: self.clickIndexBlock(indexPath.row);
        };
    }
    return _tableView;
}

- (void)setupView {
    self.backgroundColor = UIColor.groupTableViewBackgroundColor;
    [self vk_border:nil cornerRadius:10];
    
    UILabel *titleLabel = [UIView vk_label:YZMsg(@"movie_nav") font:vkFont(14) color:UIColor.blackColor];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(-20);
        make.height.mas_greaterThanOrEqualTo(0);
        make.width.mas_equalTo(VKPX(300));
    }];
}

- (void)setDataArray:(NSArray<MovieCateModel *> *)dataArray {
    _dataArray = dataArray;
    
    self.tableView.dataItems = dataArray.mutableCopy;
    [self.tableView reloadData];
    
    CGFloat height = self.tableView.contentHeight;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

@end
