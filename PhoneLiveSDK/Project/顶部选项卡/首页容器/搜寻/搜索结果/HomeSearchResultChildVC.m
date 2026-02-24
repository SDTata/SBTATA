//
//  HomeSearchResultChildVC.m
//  phonelive2
//
//  Created by user on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "HomeSearchResultChildVC.h"
#import "HomeSearchResultNetworkUtil.h"
#import "LongVideoCell.h"
#import "LongVideoDetailMainVC.h"
#import "RSWaterfallsflowLayout.h"
#import "ShortVideoListViewController.h"
#import "SkitPlayerVC.h"
#import "SearchResultSkitContentViewCell.h"
#import "SearchResultShortVideosContentViewCell.h"
#import "SearchResultAnchorListCell.h"
#import "otherUserMsgVC.h"
#import "hotModel.h"
#import "SearchResultLiveStreamCell.h"
#import "LivePlayTableVC.h"


@interface HomeSearchResultChildVC () <RSWaterfallsflowLayoutDelegate, guanzhu> {
    UIView *noDataView;
}
@property (nonatomic, strong) VKBaseCollectionView *tableView;
@property (nonatomic, weak) ShortVideoListViewController *shortVideoViewController;
@end

@implementation HomeSearchResultChildVC
- (VKBaseCollectionView *)tableView {
    if (!_tableView) {
        RSWaterfallsflowLayout *layout = [[RSWaterfallsflowLayout alloc] init];
        layout.delegate = self;
        _tableView = [VKBaseCollectionView new];
        _tableView.customCollectionViewLayout = layout;
        _tableView.viewStyle = VKCollectionViewStyleSingle;
        _tableView.registerCellClass = [LongVideoSearchResultCell class];
        _tableView.registerCellClass = [SearchResultSkitContentViewCell class];
        _tableView.registerCellClass = [SearchResultShortVideosContentViewCell class];
        _tableView.registerCellClass = [SearchResultLiveStreamCell class];
        _tableView.registerCellClass = [SearchResultAnchorListCell class];
        _tableView.automaticDimension = YES;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
        
        [_tableView vk_headerRefreshSet];
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
        footer.triggerAutomaticallyRefreshPercent = 1;
        _tableView.mj_footer = footer;
        WeakSelf
        _tableView.loadDataBlock = ^{
            STRONGSELF
            if (strongSelf.onceDelay) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf loadListData];
                });
            } else {
                [strongSelf loadListData];
            }
        };
        
        _tableView.registerCellClassBlock = ^Class(NSIndexPath *indexPath, id item) {
            if ([item isKindOfClass:[HomeRecommendSkit class]]) { // 短剧
                
                return [SearchResultSkitContentViewCell class];
                
            } else if ([item isKindOfClass:[ShortVideoModel class]] && !((ShortVideoModel*)item).isSearchResultMovies) { // 短视频
                
                return [SearchResultShortVideosContentViewCell class];
                
            } else if ([item isKindOfClass:[ShortVideoModel class]] && ((ShortVideoModel*)item).isSearchResultMovies) { // 长视频
                
                return [LongVideoSearchResultCell class];
                
            } else if ([item isKindOfClass:[hotModel class]]) { // 直播
                return [SearchResultLiveStreamCell class];
                
            } else if ([item isKindOfClass:[HomeSearchResultAnchorList class]]) { // 主播
                return [SearchResultAnchorListCell class];
                
            } else {
                return [LongVideoSearchResultCell class];
            }
        };

        _tableView.didSelectCellBlock = ^(NSIndexPath *indexPath, id item) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if ([item isKindOfClass:[HomeRecommendSkit class]]) { // 短劇 cell
                SkitPlayerVC *vc = [SkitPlayerVC new];
                vc.skitArray = @[item];
                vc.skitIndex = 0;
                [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:[strongSelf.tableView cellForItemAtIndexPath:indexPath]];
                
            } else if ([item isKindOfClass:[ShortVideoModel class]] && ((ShortVideoModel*)item).isSearchResultMovies) { // 長視頻 cell
                LongVideoSearchResultCell *cell = [strongSelf.tableView cellForItemAtIndexPath:indexPath];
                LongVideoDetailMainVC *vc = [LongVideoDetailMainVC new];
                vc.videoId = ((ShortVideoModel*)item).video_id;
                vc.originalModel = item;
                [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:cell.videoImgView];

            } else if ([item isKindOfClass:[ShortVideoModel class]]) {  // 短視頻 cell
                ShortVideoListViewController *vc = [[ShortVideoListViewController alloc] initWithHost:@""];
                if (strongSelf.type == 0) { // 全部
                    [vc updateData:@[strongSelf.tableView.dataItems[indexPath.row]] selectIndex:0 fetchMore:NO];
                } else {
                    [vc updateData:[strongSelf.tableView.dataItems copy] selectIndex:indexPath.row fetchMore:YES];
                }
                vc.fetchMoreBlock = ^{
                    [strongSelf.tableView.mj_footer executeRefreshingCallback];
                };
                vc.currentIndexBlock = ^(NSString *videoId) {
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }

                    NSArray<ShortVideoModel*> *videos = nil;
                    if (strongSelf.type == 0) { // 全部
                        videos = @[strongSelf.tableView.dataItems[indexPath.row]];
                    } else {
                        videos = strongSelf.tableView.dataItems;
                    }
                    
                    NSInteger currentIndex = -1;
                    for (int i = 0; i < videos.count; i++) {
                        ShortVideoModel *model = videos[i];
                        if (![model isKindOfClass:[ShortVideoModel class]]) {
                            continue;
                        }
                        if ([model.video_id isEqualToString:videoId]) {
                            currentIndex = i;
                            break;
                        }
                    }

                    if (currentIndex < 0) {
                        return;
                    }
                    NSInteger section = indexPath.section;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:section];
                    if (strongSelf.type != 0 && [strongSelf.tableView numberOfItemsInSection:0] > currentIndex) {
                        [strongSelf.tableView scrollToItemAtIndexPath:indexPath
                                                     atScrollPosition:UICollectionViewScrollPositionNone
                                                             animated:NO];
                    }
                };
                vc.getViewCurrentIndexBlock = ^UIView * _Nonnull(NSString *videoId) {
                    STRONGSELF
                    if (strongSelf == nil) {
                        return nil;
                    }

                    NSArray<ShortVideoModel*> *videos = nil;
                    if (strongSelf.type == 0) { // 全部
                        return [strongSelf.tableView cellForItemAtIndexPath:indexPath].contentView;;
                    } else {
                        videos = strongSelf.tableView.dataItems;
                    }

                    NSInteger currentIndex = -1;
                    for (int i = 0; i < videos.count; i++) {
                        ShortVideoModel *model = videos[i];
                        if (![model isKindOfClass:[ShortVideoModel class]]) {
                            continue;
                        }
                        if ([model.video_id isEqualToString:videoId]) {
                            currentIndex = i;
                            break;
                        }
                    }

                    if (currentIndex < 0) {
                        return nil;
                    }

                    NSInteger section = indexPath.section;
                    return [strongSelf.tableView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:section]].contentView;
                };
                strongSelf.shortVideoViewController = vc;
//                [strongSelf.navigationController pushViewController:vc animated:YES];
                [[MXBADelegate sharedAppDelegate] pushViewController:vc cell:[strongSelf.tableView cellForItemAtIndexPath:indexPath]];

            } else if ([item isKindOfClass:[HomeSearchResultAnchorList class]]) { // 主播 cell
                HomeSearchResultAnchorList *anchor = strongSelf.tableView.dataItems[indexPath.row];
                otherUserMsgVC *person = [[otherUserMsgVC alloc]init];
                person.userID = anchor.identifier;
                [strongSelf.navigationController pushViewController:person animated:YES];
            } else if ([item isKindOfClass:[hotModel class]]) { // 直播 cell
                LivePlayTableVC *livePlayTableVC = [[LivePlayTableVC alloc]init];
                livePlayTableVC.index = strongSelf.type == 0 ? 0 : indexPath.row;
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:strongSelf.type == 0 ? @[item] : strongSelf.tableView.dataItems];
                livePlayTableVC.datas = tempArray;
                [[MXBADelegate sharedAppDelegate] pushViewController:livePlayTableVC cell:[strongSelf.tableView cellForItemAtIndexPath:indexPath]];
            }
        };
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateRemoveMode:) name:LivePlayTableVCUpdateRemoveModelNotifcation object:nil];
    self.hasMore = YES;
    [self setupView];
    [self.tableView vk_headerBeginRefreshing];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)updateRemoveMode:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *roomId = userInfo[@"roomId"];

    BOOL isNeedReload = NO;
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.tableView.dataItems];
    for (hotModel *model in self.tableView.dataItems) {
        if (![model isKindOfClass:[hotModel class]]) {
            continue;;
        }
        if ([model.zhuboID isEqualToString:roomId]) {
            [tempArray removeObject:model];
            isNeedReload = YES;
            break;
        }
    }

    if (isNeedReload) {
        self.tableView.dataItems = tempArray;
        [self.tableView reloadData];
    }
}

- (void)setupView {
    noDataView = [[UIView alloc] initWithFrame:CGRectZero];
    [noDataView setHidden:YES];
    [self.view addSubview:noDataView];
    [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.74);
    }];
    
    UIImageView *noDataImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    noDataImageView.contentMode = UIViewContentModeScaleAspectFit;
    noDataImageView.image = [ImageBundle imagewithBundleName:@"home_search_nodata"];
    [noDataView addSubview:noDataImageView];
    [noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.mas_equalTo(noDataView);
        make.centerY.mas_equalTo(self.view.mas_centerY).multipliedBy(0.8);
        make.size.mas_equalTo(self.view.mas_width).multipliedBy(0.45);
    }];
    
    UILabel *nodataLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
    nodataLabel1.textColor = vkColorHex(0x707070);
    nodataLabel1.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    nodataLabel1.textAlignment = NSTextAlignmentCenter;
    nodataLabel1.text = YZMsg(@"home_search_noRelevantResultsFound");
    [noDataView addSubview:nodataLabel1];
    [nodataLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(noDataImageView.mas_bottom);
        make.centerX.mas_equalTo(noDataImageView);
        make.leading.trailing.mas_equalTo(noDataView);
    }];
    
    UILabel *nodataLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
    nodataLabel2.textColor = vkColorHex(0x9C9C9C);
    nodataLabel2.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    nodataLabel2.textAlignment = NSTextAlignmentCenter;
    nodataLabel2.text = YZMsg(@"home_search_modifySearchKeywordsAndTryAgain");
    [noDataView addSubview:nodataLabel2];
    [nodataLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nodataLabel1.mas_bottom).offset(3);
        make.centerX.mas_equalTo(noDataImageView);
        make.leading.trailing.mas_equalTo(noDataView);
        make.bottom.mas_equalTo(noDataView);
    }];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.tableView reloadData];
    if (self.type == 5) {
//        self.tableView.backgroundColor = UIColor.whiteColor;
        self.tableView.layer.cornerRadius = 20;
    }
}
- (void)claerAllData {
    [self.tableView.dataItems removeAllObjects];
    self.tableView.pageIndex = 1;
}

-(void)refreshFooter {
    self.tableView.isHeaderRefreshing = NO;
    self.tableView.pageIndex ++;
    [self loadListData];
}

- (void)loadListData {
    if (self.key) {
        if (self.hasMore == NO) {
            [self.tableView vk_headerEndRefreshing];
            [self.tableView vk_footerEndRefreshing];
            [self->noDataView setHidden: self.tableView.dataItems.count > 0];
            return;
        }
        /**
         if (self.isFromHashTag) {
            [MBProgressHUD showMessage:nil];
            [HomeSearchResultNetworkUtil getShortVideoTopicVideos:self.key page:1 block:^(NetworkData *networkData) {
                if (!networkData.status) {
                    [MBProgressHUD showError:networkData.msg];
                    return;
                }
                [MBProgressHUD hideHUD];
                NSArray *skits = @[];
                NSArray *short_videos = [ShortVideoModel arrayFromJson:networkData.info];
                NSArray *movies = @[];
                self->mergeArr = [self mergeArrays:skits array2:short_videos array3:movies];
                [self->noDataView setHidden: self->mergeArr.count > 0];
                [self.tableView vk_refreshFinish: self->mergeArr];
            }];
        } else
         */
        WeakSelf
        if (self.type == 5) { // 用户昵称
            [HomeSearchResultNetworkUtil getAnchorList:self.key page:self.tableView.pageIndex block:^(NetworkData *networkData) {
                STRONGSELF
                strongSelf.onceDelay = NO;
                if (!strongSelf) return;
                if (!networkData.status) {
                    [MBProgressHUD showError:networkData.msg];
                    [strongSelf.tableView vk_headerEndRefreshing];
                    [strongSelf.tableView vk_footerEndRefreshing];
                    return;
                }
                NSArray<HomeSearchResultAnchorList *> *anchorList = [HomeSearchResultAnchorList arrayFromJson:networkData.info];
                strongSelf.hasMore = anchorList.count > 0;
                [strongSelf.tableView vk_refreshFinish: anchorList];
                strongSelf.tableView.extraDelegate = strongSelf;
                [strongSelf->noDataView setHidden: strongSelf.tableView.dataItems.count > 0];
                strongSelf.tableView.backgroundColor = strongSelf.tableView.dataItems.count > 0 ? UIColor.clearColor : UIColor.clearColor;
            }];
        } else {
            [HomeSearchResultNetworkUtil getUserSearchMedia:self.key type:self.type page:self.tableView.pageIndex block:^(NetworkData *networkData) {
                STRONGSELF
                strongSelf.onceDelay = NO;
                if (!strongSelf) return;
                if (!networkData.status) {
                    [MBProgressHUD showError:networkData.msg];
                    [strongSelf.tableView vk_headerEndRefreshing];
                    [strongSelf.tableView vk_footerEndRefreshing];
                    return;
                }
                NSArray *skits = [HomeRecommendSkit arrayFromJson:networkData.data[@"skits"]];
                NSArray *short_videos = [ShortVideoModel arrayFromJson:networkData.data[@"short_videos"]];
                NSMutableArray *mutMovies = [NSMutableArray arrayWithArray: [ShortVideoModel arrayFromJson:networkData.data[@"movies"]]];
                NSMutableArray *mutLives = [NSMutableArray arrayWithArray: [hotModel arrayFromJson:networkData.data[@"lives"]]];
                [mutMovies enumerateObjectsUsingBlock:^(ShortVideoModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.isSearchResultMovies = YES;
                }];
                [mutMovies enumerateObjectsUsingBlock:^(hotModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.cover_meta.width = 180;
                    obj.cover_meta.height = 126;
                }];
                NSArray *movies = [mutMovies copy];
                
                [mutLives enumerateObjectsUsingBlock:^(hotModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.cover_meta.width = 100;
                    obj.cover_meta.height = 100;
                }];
                NSArray *lives = [mutLives copy];
                
                NSMutableArray *mergeArr = [strongSelf mergeArrays:skits array2:short_videos array3:movies array4:lives];
                strongSelf.hasMore = mergeArr.count > 0;
                [strongSelf.tableView vk_refreshFinish: [mergeArr copy]];
                if (strongSelf.shortVideoViewController != nil) {
                    [strongSelf.shortVideoViewController updateData:strongSelf.tableView.dataItems selectIndex:-1 fetchMore:NO];
                }
                [strongSelf->noDataView setHidden: strongSelf.tableView.dataItems.count > 0];
            }];
        }
    }
}

/**
 搜索传入0的时候代表全部。每个类型第一个，再每个第二个，以此类推，1,1,1 2,2,2 来合并数据
 */
- (NSMutableArray *)mergeArrays:(NSArray *)array1 array2:(NSArray *)array2 array3:(NSArray *)array3 array4:(NSArray *)array4 {
    NSMutableArray *resultArray = [NSMutableArray array];
    NSUInteger maxLength = MAX(MAX(MAX(array1.count, array2.count), array3.count), array4.count);
    
    for (NSUInteger i = 0; i < maxLength; i++) {
        if (i < array1.count) {
            [resultArray addObject:array1[i]];
        }
        if (i < array2.count) {
            [resultArray addObject:array2[i]];
        }
        if (i < array3.count) {
            [resultArray addObject:array3[i]];
        }
        if (i < array4.count) {
            [resultArray addObject:array4[i]];
        }
    }
    return resultArray;
}


- (BOOL)isTextWrappingByLineCount:(NSString *)text withFont:(UIFont *)font andWidth:(CGFloat)width {
    // 單行高度
    CGFloat singleLineHeight = [@"測試" sizeWithAttributes:@{NSFontAttributeName: font}].height;
    
    // 獲取文字的屬性
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    // 計算文字總高度
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGRect textRect = [text boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    
    // 計算行數
    NSInteger numberOfLines = ceil(textRect.size.height / singleLineHeight);
    
    // 如果行數大於 1，表示換行
    return numberOfLines > 1;
}


#pragma mark - <DJWaterfallsflowLayoutDelegate>
- (CGFloat)waterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth {
    id <CoverMetaProtocol> layoutModel = self.tableView.dataItems[index];
    CGFloat height = layoutModel.cover_meta.height;
    CGFloat width = layoutModel.cover_meta.width;
    
    if (self.type == 5) { // 主播
        return 62;
    }
    
    // 检查 height 和 width 是否为 NaN 或无效值
    if (!isfinite(height) || !isfinite(width) || width == 0) {
        NSLog(@"Invalid height or width for item at index: %lu, using default values", (unsigned long)index);
        return itemWidth; // 或者返回一个合理的默认值，比如固定的比例
    }
    
    return itemWidth * height / width;
}

- (CGFloat)waterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout heightForShortVideoItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth {
    if ([self.tableView.dataItems[index] isKindOfClass:[ShortVideoModel class]]) {
        ShortVideoModel *item = self.tableView.dataItems[index];
        UIFont *font = [UIFont systemFontOfSize:12];
        CGFloat width = itemWidth - 12; // 减去 lebel 左右间距12
        BOOL isWrapping = [self isTextWrappingByLineCount:item.title withFont:font andWidth:width];
        return isWrapping ? 64 : 48;
    } else {
        return 0;
    }
}

/** 返回边缘间距 */
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout {
    return self.type == 5 ? UIEdgeInsetsMake(10, 14, 10, 14) : UIEdgeInsetsMake(0, 4, 0, 4);
}

- (CGFloat)columnCountInWaterflowLayout:(RSWaterfallsflowLayout *)waterflowLayout {
    return self.type == 5 ? 1: 2;
}

#pragma mark - <主播关注 Delegate>
-(void)doGuanzhu:(NSString *)st button:(UIButton *)clickButton {
    NSDictionary *subdic = @{@"uid":[Config getOwnID],
                             @"touid":st,
                             @"is_follow":minnum(!clickButton.selected)
    };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSString *isattent = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"isattent"]];
            if ([isattent isEqualToString:@"1"]) {
                clickButton.selected = YES;
                clickButton.layer.borderColor = vkColorHex(0xc8c8c8).CGColor; // #ff5fed
            }else{
                clickButton.selected = NO;
                clickButton.layer.borderColor = vkColorHex(0xff5fed).CGColor; // #ff5fed
            }
            for (int i = 0; i<strongSelf->_tableView.dataItems.count; i++) {
                HomeSearchResultAnchorList *anchor = strongSelf->_tableView.dataItems[i];
                if ([anchor.identifier isEqualToString:st]) {
                    anchor.isattention = isattent;
                    [strongSelf->_tableView.dataItems replaceObjectAtIndex:i withObject:anchor];
                    break;
                }
            }
            NSArray<HomeSearchResultAnchorList *> *arr = [strongSelf->_tableView.dataItems copy];
            [strongSelf.tableView vk_refreshFinish: arr];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
    
}
@end
