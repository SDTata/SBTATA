//
//  SkitHeaderCardView.m
//  phonelive2
//
//  Created by vick on 2024/9/30.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitHeaderCardView.h"
#import "SkitVideoCell.h"
#import "VKButton.h"
#import "SkitPlayerVC.h"
#import <UMCommon/UMCommon.h>

@implementation SkitHeaderCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (CGFloat)viewHeight {
    return 40 + SkitVideoThreeCell.itemHeight;
}

- (void)setupView {
    UILabel *titleLabel = [UIView vk_label:nil font:vkFont(14) color:UIColor.blackColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    
    VKButton *moreButton = [VKButton buttonWithType:UIButtonTypeCustom];
    [moreButton vk_button:YZMsg(@"More_title") image:@"video_pay_arrow_pink" font:vkFont(14) color:vkColorHex(0xbb67ff)];
    moreButton.imagePosition = VKButtonImagePositionRight;
    moreButton.spacingBetweenImage = 5;
    [moreButton vk_addTapAction:self selector:@selector(clickMoreAction)];
    [self addSubview:moreButton];
    self.moreButton = moreButton;
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(SkitVideoThreeCell.itemHeight);
    }];
}

- (void)clickMoreAction {
    if (self.clickMoreBlock) {
        self.clickMoreBlock();
    }
}

#pragma mark - lazy
- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.viewStyle = VKCollectionViewStyleHorizontal;
        _tableView.registerCellClass = [SkitVideoThreeCell class];
        _tableView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        
        _weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, id item) {
            _strongify(self)
            SkitPlayerVC *viewController = [SkitPlayerVC new];
            viewController.skitArray = self.tableView.dataItems;
            viewController.skitIndex = indexPath.row;
            viewController.hasTabbar = YES;
            [[MXBADelegate sharedAppDelegate] pushViewController:viewController cell:[self.tableView cellForItemAtIndexPath:indexPath] hidesBottomBarWhenPushed:NO];
            
            if ([self.titleLabel.text isEqualToString:YZMsg(@"Favorite")]) {
                [MobClick event:@"home_skit_favorite_detail_click" attributes:@{ @"eventType": @(1)}];
            } else if ([self.titleLabel.text isEqualToString:YZMsg(@"skit_home_record")]) {
                [MobClick event:@"home_skit_history_detail_click" attributes:@{ @"eventType": @(1)}];
            }
            viewController.currentIndexBlock = ^(NSInteger currentIndex) {
                _strongify(self)
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:indexPath.section];
                if ([self.tableView numberOfItemsInSection:indexPath.section] > currentIndex) {
                    [self.tableView scrollToItemAtIndexPath:newIndexPath
                                           atScrollPosition:UICollectionViewScrollPositionNone
                                                   animated:YES];
                }
            };

            viewController.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSInteger index) {
                _strongifyReturn(self)
                return [self.tableView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:indexPath.section]].contentView;;
            };
        };
    }
    return _tableView;
}

@end
