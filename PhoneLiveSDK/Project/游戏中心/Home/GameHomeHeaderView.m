//
//  GameHomeHeaderView.m
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameHomeHeaderView.h"
#import "SDCycleScrollView.h"
#import <UMCommon/UMCommon.h>

@interface GameHomeHeaderView () <SDCycleScrollViewDelegate>

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@end

@implementation GameHomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (SDCycleScrollView *)cycleScrollView {
    if (!_cycleScrollView) {
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[ImageBundle imagewithBundleName:@"cardImgLdsponsor"]];
        cycleScrollView.layer.cornerRadius = 7;
        cycleScrollView.layer.masksToBounds = YES;
        cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        cycleScrollView.pageControlDotSize = CGSizeMake(6, 6);
        cycleScrollView.pageDotColor = RGB_COLOR(@"#ffffff", 0.4);
        cycleScrollView.currentPageDotColor = RGB_COLOR(@"#ffffff", 0.8);
        cycleScrollView.autoScrollTimeInterval = 5;
        cycleScrollView.backgroundColor = RGB(244, 245, 246);
        _cycleScrollView = cycleScrollView;
    }
    return _cycleScrollView;
}

- (void)setupView {
    [self addSubview:self.cycleScrollView];
    [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
    }];
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    NSArray *array = [dataArray valueForKeyPath:@"image"];
    self.cycleScrollView.imageURLStringsGroup = array;
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSDictionary *infoDic = [self.dataArray objectAtIndex:index];
    if([infoDic objectForKey:@"url"]) {
        NSString *urlStr = [infoDic objectForKey:@"url"];
        NSString *urlShowType = [infoDic objectForKey:@"show_type"];
        NSDictionary *data = @{@"scheme": urlStr, @"showType": urlShowType};
        [[YBUserInfoManager sharedManager] pushVC: data viewController:nil];
    }
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail": @"banenr广告"};
    [MobClick event:@"game_page_menue_click" attributes:dict];
}

@end
