//
//  LongVideoDetailVideoVC.m
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoDetailVideoVC.h"
#import "LongVideoCell.h"
#import "LongVideoDetailMainVC.h"
#import <UMCommon/UMCommon.h>

@interface LongVideoDetailVideoVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;

@end

@implementation LongVideoDetailVideoVC

- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [LongVideoTwoCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        [_tableView vk_showEmptyView];
        
        _weakify(self)
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, ShortVideoModel *item) {
            _strongify(self)
            VideoBaseCell *cell = [self.tableView cellForItemAtIndexPath:indexPath];
            LongVideoDetailMainVC *vc = [LongVideoDetailMainVC new];
            vc.videoId = item.video_id;
            vc.originalModel = item;
            [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:cell.videoImgView];
            [MobClick event:@"longvideo_subvideo_detail_click" attributes:@{@"eventType": @(1)}];
        };
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self loadListData];
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)loadListData {
    self.tableView.dataItems = self.videoList.mutableCopy;
    [self.tableView reloadData];
}

@end
