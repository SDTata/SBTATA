//
//  LongVideoDetailGamePagerVC.m
//  phonelive2
//
//  Created by vick on 2024/7/8.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LongVideoDetailGamePagerVC.h"
#import "VideoGameCell.h"
#import "LotteryBetHallVC.h"
#import <UMCommon/UMCommon.h>

@interface LongVideoDetailGamePagerVC ()

@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, assign) NSTimeInterval startTime; // 页面初始化时间
@property (nonatomic, assign) NSTimeInterval duration; // 页面停留总时长
@end

@implementation LongVideoDetailGamePagerVC

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    VKLOG(@"LongVideoDetailGamePagerVC - dealloc");
    NSString *formattedDuration = [self formatDurationToHMS:self.duration];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"duration": formattedDuration};
    [MobClick event:@"longvideo_playgame_duration_click" attributes:dict];
}

- (NSString *)formatDurationToHMS:(NSTimeInterval)duration {
    NSInteger hours = duration / 3600;                      // 小时
    NSInteger minutes = ((NSInteger)duration % 3600) / 60;  // 分钟
    NSInteger seconds = (NSInteger)duration % 60;           // 秒

    // 格式化为 "小时:分钟:秒"
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}
- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        _tableView = [VKBaseCollectionView new];
        _tableView.registerCellClass = [VideoGameCell class];
        _tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        _tableView.automaticDimension = YES;
        WeakSelf
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, HomeRecommendGame *item) {
            STRONGSELF
            NSDictionary *dict = @{ @"eventType": @(0),
                                    @"game_name": item.name};
            [MobClick event:@"longvideo_game_detail_click" attributes:dict];
            if ([item.plat isEqualToString:@"lottery"]) {
                LotteryBetHallVC *vc = [LotteryBetHallVC new];
                vc.lotteryType = item.kindID.integerValue;
                vc.isFromVideo = YES;
                [vc showGameFromBottom];
                // 初始化时记录时间戳
                strongSelf.startTime = [[NSDate date] timeIntervalSince1970];
                return;
            }
            if (item.plat && item.plat.length > 0) {
                // 初始化时记录时间戳
                strongSelf.startTime = [[NSDate date] timeIntervalSince1970];
                UINavigationController *nav = [MXBADelegate sharedAppDelegate].navigationViewController;
                [GameToolClass enterVideoH5Game:item.plat menueName:@"" kindID:item.kindID iconUrlName:item.icon parentViewController: nav autoExchange:[common getAutoExchange] success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                    
                } fail:^{
                    
                }];
            }else{
                [MBProgressHUD showError:YZMsg(@"GameListVC_UnknowGamePlat")];
            }
        };
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self loadListData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeGame) name:@"KLongVideoCloseGame" object:nil];
}

- (void)closeGame {
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    self.duration = endTime - self.startTime;
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
    self.tableView.dataItems = self.gameList.mutableCopy;
    [self.tableView reloadData];
}

@end
