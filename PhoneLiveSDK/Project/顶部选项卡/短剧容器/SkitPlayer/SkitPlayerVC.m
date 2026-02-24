//
//  SkitPlayerVC.m
//  phonelive2
//
//  Created by vick on 2024/9/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPlayerVC.h"
#import "VideoTableView.h"
#import "SkitPlayerManager.h"
#import "VideoProgressManager.h"
#import "HomeSearchVC.h"
#import <UMCommon/UMCommon.h>
#import "KingSalaryViewController.h"
#import "SkitAllEpisodesListViewController.h"

@interface SkitPlayerVC () <SkitPlayerManagerDelegate, SkitAllEpisodesListViewControllerDelegate>

//@property (nonatomic, strong) UIView *allDramaListContainer;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) VideoTableView *tableView;
//@property (nonatomic, strong) SkitPlayerManager *manager;
@property (nonatomic, strong) HomeRecommendSkit *selectSkit;
@property (nonatomic, strong) SkitVideoInfoModel *selectVideo;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) NSMutableSet<SkitPlayerVideoCell*> *cacheCells;
@property (nonatomic, assign) BOOL isFirstAppear;

@end

@implementation SkitPlayerVC

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
//    [self.manager reset];
    for (SkitPlayerVideoCell *cell in self.cacheCells) {
        [cell removePlayerManager];
    }
    self.cacheCells = [NSMutableSet set];
    VKLOG(@"SkitPlayerVC - dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTopBarItems" object:@{@"isHidden": [NSNumber numberWithBool:YES]}];
    //禁用屏幕左滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [VideoTicketFloatView showTicketButton];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.ttcTransitionDelegate.smalCurPlayCell.alpha = 1;

    [self cellPause:YES indexPath:self.selectIndexPath];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseAll];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self cellPause:NO indexPath:self.selectIndexPath];
}

- (void)viewDidLoad {
    self.cacheCells = [NSMutableSet set];
    self.isFirstAppear = YES;
    [super viewDidLoad];
    [self setupView];
//    [self manager];
    
    [self.skitArray setValue:nil forKeyPath:@"videoArray"];
    self.tableView.dataItems = self.skitArray.mutableCopy;


    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.skitIndex];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self skitPlayerManagerDelegateStartPlayIndexPath:indexPath];
    }];
}

- (void)setupView {
    self.view.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:self.allDramaListContainer];
//    [self.allDramaListContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view);
//        make.bottom.mas_equalTo(-VK_BOTTOM_H);
//        make.height.equalTo(@66);
//    }];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        if (self.hasTabbar) {
            CGFloat tabBarHeight = VK_SCREEN_H - self.tabBarController.tabBar.height;
            make.height.equalTo(@(tabBarHeight));
        } else {
            make.bottom.equalTo(0);
        }
    }];
    
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[ImageBundle imagewithBundleName:@"fh-2"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(15.75, 18.5, 15.75, 18.5)];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.view).offset(8);
        make.size.equalTo(@44);
    }];
    
    UIButton *searchButton = [[UIButton alloc] init];
    [searchButton setImage:[ImageBundle imagewithBundleName:@"home_search_button"] forState:UIControlStateNormal];
//    [searchButton setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.right.equalTo(self.view).offset(-8);
        make.size.equalTo(@40);
    }];
}

- (void)setSelectIndexPath:(NSIndexPath *)selectIndexPath {
    _selectIndexPath = selectIndexPath;
    if (self.currentIndexBlock) {
        self.currentIndexBlock(selectIndexPath.section);
    }

    if (self.getViewCurrentIndexBlock) {
        UIView *cell = self.getViewCurrentIndexBlock(selectIndexPath.section);
        if (cell) {
            self.ttcTransitionDelegate.smalCurPlayCell = cell;
        }
    }

//    HomeRecommendSkit *skit = self.tableView.dataItems[self.selectIndexPath.section];
//    self.selectSkit = skit;
//    if (selectIndexPath.row < skit.videoArray.count) {
//        self.selectVideo = skit.videoArray[selectIndexPath.row];
//    }
}

#pragma mark - Action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)search {
    HomeSearchVC *searchVC = [HomeSearchVC new];
    searchVC.type = 1;
    [[MXBADelegate sharedAppDelegate] pushViewController:searchVC animated:YES];
}

- (void)showAllDrama {
    SkitAllEpisodesListViewController *vc = [SkitAllEpisodesListViewController new];
    vc.delegate = self;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
    [vc updateData:self.selectSkit videoInfoModel:self.selectSkit.videoArray selectVideoId:self.selectVideo.video_id];
    [UIView animateWithDuration:0.2 animations:^{
        self.tabBarController.tabBar.alpha = 0;
    }];
}

#pragma mark - SkitPlayerManagerDelegate
- (void)skitPlayerManagerDelegateStartPlayIndexPath:(NSIndexPath *)indexPath {
    HomeRecommendSkit *skit = self.tableView.dataItems[indexPath.section];
    if (skit.videoArray.firstObject.video_id) {
        [UIView performWithoutAnimation:^{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }];
        SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self pauseAll];
        [cell.manager startPlayVideo];

        self.selectSkit = skit;
        if (self.selectIndexPath.row < skit.videoArray.count) {
            self.selectVideo = skit.videoArray[self.selectIndexPath.row];
        }

        if (self.isFirstAppear) {
            self.isFirstAppear = NO;
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + 0.5) animated:YES];
        }
        return;
    }
    [MBProgressHUD showMessage:nil];
    WeakSelf
    [LotteryNetworkUtil getSkitVideoList:skit.skit_id block:^(NetworkData *networkData) {
        if (!networkData.status) {
            [MBProgressHUD showError:networkData.msg];
            return;
        }
        STRONGSELF
        if (!strongSelf) return;
        [MBProgressHUD hideHUD];
        skit.is_favorite = [networkData.data[@"is_favorite"] integerValue];
        skit.total_browse = [networkData.data[@"total_browse"] integerValue];
        skit.videoArray = [SkitVideoInfoModel arrayFromJson:networkData.data[@"list"]];
        [strongSelf startPlayVideoWithIndexPath:indexPath];
//        [strongSelf.tableView reloadData];
//        [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }];
}

- (void)startPlayVideoWithIndexPath:(NSIndexPath *)indexPath {
    HomeRecommendSkit *skit = self.tableView.dataItems[indexPath.section];
    self.tableView.extraData = skit;
    [UIView performWithoutAnimation:^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    }];

    if (![skit.skit_id isEqualToString:self.selectSkit.skit_id]) {
        WeakSelf
        vkGcdAfter(0.1, ^{
            STRONGSELF
            if (!strongSelf) return;
            NSDictionary *dict = [VideoProgressManager loadUserProgress:strongSelf.selectSkit.skit_id];
            NSInteger currentEpisode = [dict[@"currentEpisode"] integerValue];
            currentEpisode = MAX(0, currentEpisode-1);
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentEpisode inSection:indexPath.section];
            [UIView performWithoutAnimation:^{
                [strongSelf.tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }];
            strongSelf.selectSkit = skit;
            strongSelf.selectVideo = skit.videoArray[nextIndexPath.row];
            strongSelf.selectIndexPath = nextIndexPath;
            SkitPlayerVideoCell *cell = [strongSelf.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.manager setupVideoInfoWithCell:cell model:strongSelf.selectVideo infoModel:strongSelf.selectSkit];
            [strongSelf pauseAll];
            [cell.manager startPlayVideo];

            if (strongSelf.isFirstAppear) {
                strongSelf.isFirstAppear = NO;
                [strongSelf.tableView setContentOffset:CGPointMake(0, strongSelf.tableView.contentOffset.y + 0.5) animated:YES];
            }
            return;
        });
    }
    self.selectSkit = skit;
    self.selectVideo = skit.videoArray[indexPath.row];
    self.selectIndexPath = indexPath;
    SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.manager setupVideoInfoWithCell:[self.tableView cellForRowAtIndexPath:indexPath] model:self.selectVideo infoModel:self.selectSkit];
}

- (void)skitPlayerManagerDelegateForSkit {
    [self showAllDrama];
}

- (void)selectVideo:(NSString*)videoId {
    NSInteger index = [self.selectSkit.videoArray indexOfObjectPassingTest:^BOOL(SkitVideoInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.video_id == videoId;
    }];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.selectIndexPath.section];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    self.selectVideo = self.selectSkit.videoArray[indexPath.row];
    self.selectIndexPath = indexPath;
    SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.manager setupVideoInfoWithCell:[self.tableView cellForRowAtIndexPath:indexPath] model:self.selectVideo infoModel:self.selectSkit];
}

- (void)skitPlayerManagerDelegateForEnd:(BOOL)isNext {
    NSInteger index = isNext ? self.selectIndexPath.row + 1 : self.selectIndexPath.row;
    [self changeVideoIndex:index];
//    HomeRecommendSkit *skit = self.tableView.dataItems[self.selectIndexPath.section];
//    NSInteger nextIndex = self.selectIndexPath.item + 1;
//    NSInteger nextSectionIndex = self.selectIndexPath.section + 1;
//    if ((skit.videoArray.count > nextIndex) && isNext) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nextIndex inSection:self.selectIndexPath.section];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
//        self.selectVideo = self.selectSkit.videoArray[indexPath.row];
//        self.selectIndexPath = indexPath;
//        SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        [cell.manager setupVideoInfoWithCell:[self.tableView cellForRowAtIndexPath:indexPath] model:self.selectVideo infoModel:self.selectSkit];
//    } else if (self.tableView.dataItems.count > nextSectionIndex && isNext) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:nextSectionIndex];
//        [self skitPlayerManagerDelegateStartPlayIndexPath:indexPath];
//    } else {
//        SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
//        [cell.manager.player.currentPlayerManager play];
//        if ([cell.manager.player.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
//            [cell.manager.player.controlView videoPlayer:cell.manager.player loadStateChanged:ZFPlayerLoadStatePlayable];
//        }
//    }
}

- (void)skitPlayerManagerDelegateForChat {
    [MBProgressHUD showError:YZMsg(@"Please stay tuned")];
}

- (void)skitPlayerManagerDelegateForTapVoice:(BOOL)isMuted {
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"mute":isMuted ? @(1): @(0)};
    [MobClick event:@"skit_mute_click" attributes:dict];
}

#pragma mark - SkitAllEpisodesListViewControllerDelegate
- (void)SkitAllEpisodesListViewControllerDelegateForSelect:(NSString*)videoId {
//    [self selectVideo:videoId];
    NSInteger index = [self.selectSkit.videoArray indexOfObjectPassingTest:^BOOL(SkitVideoInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.video_id == videoId;
    }];
    self.isFirstAppear = YES;
    [self changeVideoIndex:index];
}

- (void)SkitAllEpisodesListViewControllerDelegateForClose {
    [UIView animateWithDuration:0.2 animations:^{
        self.tabBarController.tabBar.alpha = 1;
    }];
}

#pragma mark - Lazy
- (VideoTableView *)tableView {
    if (!_tableView) {
        _tableView = [VideoTableView new];
        _tableView.viewStyle = VKTableViewStyleGrouped;
        _tableView.registerCellClass = [SkitPlayerVideoCell class];
        _tableView.pagingEnabled = YES;
        _tableView.scrollsToTop = NO;
        _tableView.zf_stopWhileNotVisible = YES;
        _tableView.decelerationRate = UIScrollViewDecelerationRateFast;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (self.hasTabbar) {
            CGFloat tabBarHeight = self.tabBarController.tabBar.height;
            _tableView.itemHeight = VK_SCREEN_H - tabBarHeight;
            _tableView.estimatedRowHeight = 0;
        }

        _tableView.rowsParseBlock = ^NSArray *(HomeRecommendSkit *section) {
            return section.videoArray;
        };

        WeakSelf
        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, id item) {
            STRONGSELF
            if (!strongSelf) { return; }
            SkitPlayerVideoCell *cell = [strongSelf->_tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                [cell.controlView handleSingleTapped];
            }
        };

        _tableView.configureCellBlock = ^(UITableViewCell *cell, id item, NSIndexPath *indexPath) {
            STRONGSELF
            if (!strongSelf) { return; }
            HomeRecommendSkit *skit = strongSelf.tableView.dataItems[indexPath.section];
            SkitVideoInfoModel *model = skit.videoArray[indexPath.row];
            SkitPlayerVideoCell *skitCell = (SkitPlayerVideoCell*)cell;
            [strongSelf.cacheCells addObject:skitCell];
            [skitCell update:model infoModel:skit];
            [skitCell.manager setupVideoInfoWithCell:skitCell model:model infoModel:skit];
            skitCell.manager.delegate = weakSelf;
        };

        _tableView.scrollViewDidEndDeceleratingBlock = ^(UIScrollView *scrollView) {
            STRONGSELF
            if (!strongSelf) { return; }
            [strongSelf handleScrollViewDidEndDecelerating:scrollView];
        };

        _tableView.scrollViewDidEndDraggingBlock = ^(UIScrollView *scrollView, BOOL willDecelerate) {
            STRONGSELF
            if (!strongSelf) { return; }
            [strongSelf handleScrollViewDidEndDragging:scrollView willDecelerate:willDecelerate];
        };
    }
    return _tableView;
}

//- (SkitPlayerManager *)manager {
//    if (!_manager) {
//        _manager = [[SkitPlayerManager alloc] initWithScrollView:self.tableView containerViewTag:11111111];
//        _manager.delegate = self;
//    }
//    return _manager;
//}

//- (UIView *)allDramaListContainer {
//    if (!_allDramaListContainer) {
//        _allDramaListContainer = [[UIView alloc] init];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAllDrama)];
//        [_allDramaListContainer addGestureRecognizer:tap];
//    }
//    return _allDramaListContainer;
//}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.backgroundColor = [UIColor blackColor];
        _emptyView.hidden = YES;
        _emptyView.userInteractionEnabled = NO;

        UILabel *noDataLabel = [[UILabel alloc] init];
        noDataLabel.font = [UIFont systemFontOfSize:14];
        noDataLabel.textColor = UIColor.whiteColor;
        noDataLabel.text = YZMsg(@"DramaVideoViewController_video_not_available");
        [_emptyView addSubview:noDataLabel];
        [noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
        }];
    }
    return _emptyView;
}

#pragma mark - handle action
- (void)handleScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)willDecelerate {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        scrollView.panGestureRecognizer.enabled = NO;

        NSInteger index = self.selectIndexPath.item;
        if(translatedPoint.y < -50) {
            index ++;   //向下滑动索引递增
        }
        if(translatedPoint.y > 50) {
            index --;   //向上滑动索引递减
        }

//        if (skit.videoArray.count <= index) {
//            return;
//        }

        if (self.selectIndexPath.item == index) {
            scrollView.panGestureRecognizer.enabled = YES;
            return;
        }


        [self changeVideoIndex:index];
    });
}

- (void)changeVideoIndex:(NSInteger)index {
    HomeRecommendSkit *skit = self.tableView.dataItems[self.selectIndexPath.section];
    NSIndexPath *newIndexPath;
    if (index < 0) {
        // 切換上一部
        NSInteger newSection = self.selectIndexPath.section - 1;
        if (newSection < 0) {
            return;
        }
        newIndexPath = [NSIndexPath indexPathForItem:0 inSection:newSection];
    } else if (index >= skit.videoArray.count) {
        // 切換下一部
        NSInteger newSection = self.selectIndexPath.section + 1;
        if (newSection >= self.tableView.dataItems.count) {
            return;
        }
        newIndexPath = [NSIndexPath indexPathForItem:0 inSection:newSection];
    } else {
        // 切換上下一集
        newIndexPath = [NSIndexPath indexPathForItem:index inSection:self.selectIndexPath.section];
    }
    self.selectIndexPath = newIndexPath;

    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
        //UITableView滑动到指定cell
        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } completion:^(BOOL finished) {
        [self skitPlayerManagerDelegateStartPlayIndexPath:newIndexPath];
        //UITableView可以响应其他滑动手势
        self.tableView.panGestureRecognizer.enabled = YES;
    }];
}

- (void)handleScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        scrollView.panGestureRecognizer.enabled = NO;
//        CGFloat offsetY = self.tableView.contentOffset.y;
//        CGFloat viewH = CGRectGetHeight(self.tableView.frame);
//
//        // 計算總的 section 數
//        NSInteger totalSections = self.tableView.dataItems.count;
//
//        // 計算當前 section
//        NSInteger currentSection = (NSInteger)(offsetY / viewH) % totalSections;
//
//        // 計算當前 row
//        NSInteger currentRow = (NSInteger)(offsetY / viewH) / totalSections;
//
//        // 檢查是否超出範圍
//        HomeRecommendSkit *skit = self.tableView.dataItems[currentSection];
//        if (skit.videoArray.count <= currentRow) {
//            scrollView.panGestureRecognizer.enabled = YES;
//            return;
//        }
//
//        if (self.selectIndexPath.item == currentRow && self.selectIndexPath.section == currentSection) {
//            scrollView.panGestureRecognizer.enabled = YES;
//            return;
//        }
//
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentRow inSection:currentSection];
//
//        self.selectIndexPath = newIndexPath;
//        WeakSelf
//        [UIView animateWithDuration:0.15
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseOut animations:^{
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            //UITableView滑动到指定cell
//            [strongSelf.tableView scrollToRowAtIndexPath:self.selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//            [strongSelf pauseAll];
//        } completion:^(BOOL finished) {
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            [self skitPlayerManagerDelegateStartPlayIndexPath:self.selectIndexPath];
//            scrollView.panGestureRecognizer.enabled = YES;
//        }];
//    });
}

- (void)pauseAll {
    for (SkitPlayerVideoCell *cell in self.cacheCells) {
        [[cell manager] pauseVideo];
    }
}

- (void)cellPause:(BOOL)isPause indexPath:(NSIndexPath*)indexPath {
    SkitPlayerVideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[SkitPlayerVideoCell class]]) {
        if (isPause) {
            [[cell manager] pauseVideo];
        } else {
            [[cell manager] startPlayVideo];
        }
    }
}

@end
