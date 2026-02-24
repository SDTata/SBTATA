//
//  HotSkitSegmentHeaderView.m
//  NewDrama
//
//  Created by s5346 on 2024/6/28.
//

#import "HotSkitSegmentHeaderView.h"

@interface HotSkitSegmentHeaderView ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<CateInfoModel*> *categoryInfoDataSources;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation HotSkitSegmentHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentIndex = -1;
        [self setupViews];
    }
    return self;
}

- (void)update:(NSArray<CateInfoModel*>*)models cateId:(NSString*)cateId {
    [self removeAllStackArrangeSubviews];
    self.categoryInfoDataSources = [NSMutableArray arrayWithArray:models];

    if (models.count <= 0) {
        return;
    }

    NSInteger selectIndex = -1;
    if (cateId.length > 0) {
        for (int i = 0; i<models.count; i++) {
            CateInfoModel *model = models[i];
            if ([model.cate_id isEqualToString:cateId]) {
                selectIndex = i;
                break;
            }
        }
    }

    HotSkitSegmentHeaderViewCell *tempCell = nil;
    for (int i = 0; i<models.count; i++) {
        CateInfoModel *model = models[i];
        HotSkitSegmentHeaderViewCell *cell = [[HotSkitSegmentHeaderViewCell alloc] initWithTitle:model.name];
        cell.tag = i;
        [cell addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [self.stackView addArrangedSubview:cell];

        if (self.currentIndex == - 1) {
            self.currentIndex = 0;
            tempCell = cell;
        } else if (selectIndex == i) {
            tempCell = cell;
        }
    }

    [self layoutIfNeeded];

    if (tempCell != nil) {
        [self tap:tempCell];
    }
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = RGB_COLOR(@"#EAE0F6", 1);

    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:containerView];
    containerView.layer.cornerRadius = 15;
    containerView.layer.masksToBounds = YES;
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.right.equalTo(self).inset(14);
        make.height.equalTo(@30);
    }];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;

    [containerView addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
    self.scrollView = scrollView;

    UIView *stackContainerView = [[UIView alloc] init];
    stackContainerView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:stackContainerView];
    [stackContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(scrollView);
        make.left.greaterThanOrEqualTo(scrollView);
        make.right.lessThanOrEqualTo(scrollView);
    }];

    [stackContainerView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(stackContainerView);
    }];
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
    }
    return _stackView;
}

#pragma mark - Method
- (void)removeAllStackArrangeSubviews {
    NSArray *arrangedSubviews = [self.stackView.arrangedSubviews copy];

    for (UIView *view in arrangedSubviews) {
        [self.stackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
}

#pragma mark - Action
- (void)tap:(HotSkitSegmentHeaderViewCell*)sender {
    for (HotSkitSegmentHeaderViewCell *cell in self.stackView.arrangedSubviews) {
        cell.selected = NO;
    }
    sender.selected = YES;

    if (sender.tag == self.currentIndex) {
        return;
    }
    self.currentIndex = sender.tag;
    [self isNeedScroll:sender.tag];

    if (self.categoryInfoDataSources.count > sender.tag) {
        NSString *cateId = [self.categoryInfoDataSources[sender.tag] cate_id];
        if (self.tapBlock) {
            self.tapBlock(cateId);
        }
    }
}

- (void)isNeedScroll:(NSInteger)currentIndex {
    if (self.stackView.arrangedSubviews.count <= currentIndex) {
        return;
    }
    HotSkitSegmentHeaderViewCell *cell = self.stackView.arrangedSubviews[currentIndex];
    CGFloat currentX = cell.x;
    CGFloat currentWidth = cell.width;

    CGFloat distance = currentX - self.scrollView.contentOffset.x;
    if (distance > self.scrollView.width/2) {
//偏右
        if (self.stackView.arrangedSubviews.count > currentIndex + 1) {
            HotSkitSegmentHeaderViewCell *nextCell = self.stackView.arrangedSubviews[currentIndex + 1];
            CGFloat nextCurrentX = nextCell.x;
            CGFloat nextCurrentWidth = nextCell.width;

            if ((distance + currentWidth + nextCurrentWidth) > self.scrollView.width) {
                CGFloat move = nextCurrentX + nextCurrentWidth - self.scrollView.width;
                [self.scrollView setContentOffset:CGPointMake(move, 0) animated:YES];
            }
        } else if (self.stackView.arrangedSubviews.count == currentIndex + 1) {
            CGFloat move = currentX + currentWidth - self.scrollView.width;
            [self.scrollView setContentOffset:CGPointMake(move, 0) animated:YES];
        }
    } else {
//偏左
        if (self.stackView.arrangedSubviews.count > currentIndex - 1) {
            if (currentIndex - 1 < 0) {
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                return;
            }
            HotSkitSegmentHeaderViewCell *preCell = self.stackView.arrangedSubviews[currentIndex - 1];
            CGFloat preCurrentX = preCell.x;
            CGFloat preCurrentWidth = preCell.width;

            if ((distance - preCurrentWidth) < 0) {
                CGFloat move = preCurrentX;
                [self.scrollView setContentOffset:CGPointMake(move, 0) animated:YES];
            }
        } else {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }



}

@end

@interface HotSkitSegmentHeaderViewCell ()

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation HotSkitSegmentHeaderViewCell

- (instancetype)initWithTitle:(NSString*)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.titleLabel.text = title;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.titleLabel];
    self.layer.cornerRadius = 13;
    self.layer.masksToBounds = YES;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self).inset(5);
        make.left.right.equalTo(self).inset(10);
        make.height.equalTo(@16);
    }];
}
- (void)select:(id)sender {

}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = RGB_COLOR(@"#9F57DF", 1);
    }
    return _titleLabel;
}

- (void)setSelected:(BOOL)selected {
    self.backgroundColor = selected ? RGB_COLOR(@"#9F57DF", 1) : [UIColor clearColor];
    self.titleLabel.textColor = selected ? [UIColor whiteColor] : RGB_COLOR(@"#9F57DF", 1);
}

@end
