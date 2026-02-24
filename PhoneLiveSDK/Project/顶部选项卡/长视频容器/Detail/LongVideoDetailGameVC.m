//
//  LongVideoDetailGameVC.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoDetailGameVC.h"
#import "LongVideoDetailGamePagerVC.h"

@interface LongVideoDetailGameVC ()

@end

@implementation LongVideoDetailGameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    NSMutableArray *titles = [NSMutableArray array];
//    for (NSInteger i=0; i<self.gameList.count; i++) {
//        [titles addObject:@""];
//    }
    [titles addObject:@""];
    self.categoryView.titles = titles;
    self.categoryView.segmentStyle = SegmentStylePoint;
    [self.view addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-VK_BOTTOM_H-10);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(30*titles.count);
        make.height.mas_equalTo(8);
    }];
    
    self.categoryView.hidden = YES;
}

- (VKPagerChildVC *)renderViewControllerWithIndex:(NSInteger)index {
    LongVideoDetailGamePagerVC *vc = [LongVideoDetailGamePagerVC new];
//    vc.gameList = [HomeRecommendGame arrayFromJson:self.gameList[index]];
    vc.gameList = [HomeRecommendGame arrayFromJson:self.gameList];
    return vc;
}

@end
