//
//  SkitHomeHeaderView.m
//  phonelive2
//
//  Created by vick on 2024/9/29.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitHomeHeaderView.h"
#import "SkitHeaderCardView.h"
#import "SkitHomeMoreVC.h"

@interface SkitHomeHeaderView ()

@property (nonatomic, strong) SkitHeaderCardView *collectView;
@property (nonatomic, strong) SkitHeaderCardView *historyView;

@end

@implementation SkitHomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.axis = UILayoutConstraintAxisVertical;
    self.spacing = 0;
    self.distribution = UIStackViewDistributionFillEqually;
    
    [self addArrangedSubview:self.collectView];
    [self addArrangedSubview:self.historyView];
}

- (void)refreshData {
    self.collectView.tableView.dataItems = self.collectArray.mutableCopy;
    [self.collectView.tableView reloadData];
    self.historyView.tableView.dataItems = self.historyArray.mutableCopy;
    [self.historyView.tableView reloadData];
    
    self.viewHeight = 0;
    self.collectView.hidden = YES;
    self.historyView.hidden = YES;
    if (self.collectArray.count > 0) {
        self.viewHeight += self.collectView.viewHeight;
        self.collectView.hidden = NO;
    }
    if (self.historyArray.count > 0) {
        self.viewHeight += self.historyView.viewHeight;
        self.historyView.hidden = NO;
    }
}

#pragma mark - lazy
- (SkitHeaderCardView *)collectView {
    if (!_collectView) {
        _collectView = [SkitHeaderCardView new];
        _collectView.titleLabel.text = YZMsg(@"Favorite");
        _collectView.clickMoreBlock = ^{
            SkitHomeMoreVC *vc = [SkitHomeMoreVC new];
            vc.titleText = YZMsg(@"Favorite");
            vc.type = @"3";
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        };
    }
    return _collectView;
}

- (SkitHeaderCardView *)historyView {
    if (!_historyView) {
        _historyView = [SkitHeaderCardView new];
        _historyView.titleLabel.text = YZMsg(@"skit_home_record");
        _historyView.clickMoreBlock = ^{
            SkitHomeMoreVC *vc = [SkitHomeMoreVC new];
            vc.titleText = YZMsg(@"skit_home_record");
            vc.type = @"0";
            [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
        };
    }
    return _historyView;
}

@end
