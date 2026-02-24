//
//  LivePlayTableVC.m
//  phonelive
//
//  Created by 400 on 2020/9/3.
//  Copyright © 2020 toby. All rights reserved.
//

#import "LivePlayTableVC.h"
#import "LivePlayCell.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "LivePlay.h"
#import "EnterLivePlay.h"
#import "UIView+LBExtension.h"
#import <NodeMediaClient/NodeMediaClient.h>
#import "LivePlayNOScrollView.h"
#import <UMCommon/UMCommon.h>

@interface LivePlayTableVC ()
{
    BOOL isFirstShow;
    NSInteger currentRequesting;
    
    
    
//    moviePlay *playerVLast;
//    moviePlay *playerVNext;
//    moviePlay *playerVCurrent;
//
//    NodePlayer *nplayerCurrent;
//    NodePlayer *nplayerLast;
//    NodePlayer *nplayerNext;

    NSMutableArray *playerArray;
    NSMutableArray *playerViewArray;
    dispatch_block_t delayBlock;
    
}

@end

@implementation LivePlayTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentRequesting = -1;
    isFirstShow = YES;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.rowHeight = SCREEN_HEIGHT;
    self.tableView.pagingEnabled = YES;
    self.tableView.scrollsToTop = NO;
    self.tableView.shouldIgnoreScrollingAdjustment  =YES;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    playerArray = [NSMutableArray new];
    playerViewArray = [NSMutableArray new];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadDatas) name:LivePlayTableVCUpdateNotifcation object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(liveCanScrollNotice:) name:KLiveCanScrollNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lotteryShow:) name:KShowLotteryBetViewControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(releaseDatas) name:LivePlayTableVCReleaseDatasNotifcation object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateModels:) name:LivePlayTableVCUpdateModelsNotifcation object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveRemoveRoomId:) name:LivePlayTableVCRemoveRoomIdNotifcation object:nil];
}
-(void)reloadDatas
{
    [self.tableView reloadData];
}

-(void)releaseDatas {
    NSArray *visibleCells = [self.tableView visibleCells];
    if (visibleCells.count > 0 ) {
        LivePlayCell *cellCurrent = (LivePlayCell*)visibleCells.firstObject;
        if (cellCurrent.moviePlayView) {
            [cellCurrent.moviePlayView releaseDatas];
        }
    }
}

-(void)updateModels:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSArray<hotModel *> *value = userInfo[@"models"];
    [self setDatas:value];
}

- (void)saveRemoveRoomId:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *roomId = userInfo[@"roomId"];
    if (roomId.length > 0) {
        self.removeRoomId = roomId;
    }
}

- (NSString *)formatDurationToHMS:(NSTimeInterval)duration {
    NSInteger hours = duration / 3600;                      // 小时
    NSInteger minutes = ((NSInteger)duration % 3600) / 60;  // 分钟
    NSInteger seconds = (NSInteger)duration % 60;           // 秒

    // 格式化为 "小时:分钟:秒"
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    
    if (isFirstShow) {
        if (self.index>0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        if (self.index == 0) {
            [self scrollViewDidScroll:self.tableView];
        }
       
        isFirstShow = NO;
       
    }
    NSArray *visibleCells = [self.tableView visibleCells];
    if(visibleCells.count>0){
        LivePlayCell *cellCurrent = (LivePlayCell*)visibleCells.firstObject;
        if(cellCurrent.moviePlayView && !cellCurrent.moviePlayView.isChckedLive){
          
            [cellCurrent.moviePlayView changeRoom:cellCurrent.moviePlayView.playDocModel];
            
            [cellCurrent.moviePlayView setAudioEnable:1];
            [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = true;
            [cellCurrent.moviePlayView.nplayer start:cellCurrent.moviePlayView.playDocModel.pull];
            [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = false;
           
            
        }
    }
}

- (void)lotteryShow:(NSNotification *)noti{
    NSNumber *obj = noti.object;
    if (obj.integerValue == 0) {
//        self.tableView.scrollEnabled = NO;
    }else if(obj.integerValue == 2){
        self.tableView.scrollEnabled = YES;
    }else{
        self.tableView.scrollEnabled = YES;
    }
}


- (void)liveCanScrollNotice:(NSNotification *)notification {
    NSNumber *obj = notification.object;
    if (obj.integerValue == 0) {
        /// 禁止滑动
        self.tableView.scrollEnabled = NO;
    }else{
        /// 可以滑动
        self.tableView.scrollEnabled = YES;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.datas.count;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull LivePlayCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row < self.datas.count) {
          hotModel *model = self.datas[indexPath.row];
          if (model.startTime) {
              NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:model.startTime];
              model.stayDuration += duration; // 累加停留时长
              model.startTime = nil; // 清空开始时间
              
              if (((NSInteger)model.stayDuration % 60) > 0) {
                  NSString *formattedDuration = [self formatDurationToHMS:model.stayDuration];
                  NSDictionary *dict = @{ @"eventType": @(0),
                                          @"duration": formattedDuration};
                  int type = [model.type intValue];
                  if (type == 1) { // 密码房
                      [MobClick event:@"live_room_pwd_duration_click" attributes:dict];
                  } else if (type == 2 || type == 3) { // 2:付费房 3:计时房
                      [MobClick event:@"live_room_stay_duration_click" attributes:dict];
                  }
              }
          }
      }
    
    if (indexPath.row == currentRequesting) {
        return;
    }
//    if (cell.moviePlayView) {
//        [cell.moviePlayView releaseall];
//        [cell.moviePlayView.view removeFromSuperview];
//        [cell.moviePlayView removeFromParentViewController];
//        cell.moviePlayView = nil;
//    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 获取对应的模型
      hotModel *model = self.datas[indexPath.row];
      model.startTime = [NSDate date]; // 记录当前时间
}

-(void)setDatas:(NSArray<hotModel *> *)datas
{
    _datas = [NSMutableArray arrayWithArray:datas];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = (scrollView.contentOffset.y + scrollView.height/2.0) /scrollView.height;
    LivePlayCell *cellCurrent = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    for (UIProgressView *view in cellCurrent.moviePlayView.view.subviews) {
        if ([view isKindOfClass:[LivePlayNOScrollView class]]) {
            if (view.superview != nil &&
                view.isHidden == NO &&
                view.y <= cellCurrent.moviePlayView.view.mj_h) {
                [scrollView setContentOffset:CGPointMake(0, scrollView.height * index)];
                return;
            }
        }
    }

    CGFloat pageHeight = scrollView.frame.size.height;
    int currentPage = floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;

    // 判断是否接近当前页的底部或顶部
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat nextPageBeginning = currentPage * pageHeight;  // 当前页的开始位置（也是下一页的开始位置）
    CGFloat triggerDistanceForNextPage = 20;  // 滑动到下一页后20点触发

    
    if ((currentOffset - nextPageBeginning) >= triggerDistanceForNextPage && playerViewArray.count < 3 && currentPage<self.datas.count-1 && currentPage>1) {
        if (!self.shouldTriggerDecelerating) {
            self.shouldTriggerDecelerating = YES;
            // currentRequesting = currentPage;
            if(!isFirstShow){
                [self scrollViewDidEndDecelerating:scrollView];
            }else{
                WeakSelf
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONGSELF
                    if(strongSelf == nil){
                        return;
                    }
                    [strongSelf scrollViewDidEndDecelerating:scrollView];
                });
            }
           
        }
    } else if (fabs(currentOffset - currentPage * pageHeight) < 5) {
        if (!self.shouldTriggerDecelerating) {
            self.shouldTriggerDecelerating = YES;
            // currentRequesting = currentPage;
            if(!isFirstShow){
//                [self scrollViewDidEndDecelerating:scrollView];
            }else{
                WeakSelf
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    STRONGSELF
                    if(strongSelf == nil){
                        return;
                    }
                    [strongSelf scrollViewDidEndDecelerating:scrollView];
                });
            }
        }
    } else {
        self.shouldTriggerDecelerating = NO;
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.datas==nil || self.datas.count == 0) {
        [MBProgressHUD showError:@"1001 error"];
        return;
    }
    NSInteger index = (scrollView.contentOffset.y + scrollView.height/2.0) /scrollView.height;
    if (index < 0 || index >= self.datas.count) {
        return;
    }
    if (currentRequesting == index) {
        return;
    }
    @autoreleasepool {
        
        @synchronized(self) {
            hotModel *enterModel = self.datas[index];
            
            // 确保获取到正确的当前cell
            [self.tableView layoutIfNeeded];
            LivePlayCell *cellCurrent = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            if (!cellCurrent) {
                NSLog(@"当前cell获取失败，index: %ld", (long)index);
                return;
            }
            
            // 初始化为nil，避免使用未初始化的变量
            LivePlayCell *cellLast = nil;
            LivePlayCell *cellNext = nil;
            
            // 安全获取上一个cell
            if(index > 0){
                cellLast = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0]];
            }
            
            // 安全获取下一个cell，确保索引不越界
            if(index + 1 < self.datas.count){
                cellNext = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:0]];
            }
            
            self.index = index;
            currentRequesting = index;
            
            if(cellCurrent.moviePlayView == nil||(cellCurrent.moviePlayView!= nil && (![cellCurrent.moviePlayView.playDocModel.zhuboID isEqualToString:enterModel.zhuboID]||cellCurrent.moviePlayView.nplayer == nil))){
                BOOL isFromCachePlayer = false;
                // 优化播放器资源管理，避免完全清空
                if(playerArray.count>=(self.datas.count>2?3:2)){
                    isFromCachePlayer = true;
                   
                }
                
                moviePlay *playerVCurrent = [[moviePlay alloc]init];
                cellCurrent.moviePlayView = playerVCurrent;
                //    player.scrollarray = _infoArray;
                cellCurrent.moviePlayView.scrollindex = 0;
                cellCurrent.moviePlayView.playDocModel = enterModel;
                [cellCurrent.contentView addSubview:playerVCurrent.view];
                // 安全获取播放器，避免数组越界
                if(isFromCachePlayer && playerArray.count > 1){
                    NodePlayer *nplayerCurrent = playerArray[1];
                    [playerVCurrent onPlayNodeVideoPlayer:nplayerCurrent audioEnable:true];
                }else{
                    // 创建新播放器
                    NodePlayer *nplayerCurrent = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
                    [playerVCurrent onPlayNodeVideoPlayer:nplayerCurrent audioEnable:true];
                    [playerArray addObject:nplayerCurrent];
                }
              
                [cellCurrent.parentController addChildViewController:playerVCurrent];
                [cellCurrent.moviePlayView changeRoom:enterModel];
                [playerViewArray addObject:playerVCurrent];
                
                // 特殊处理：只有两个cell时的逻辑
                if(self.datas.count == 2){
                    // 只有两个cell的特殊处理
                    hotModel *otherModel = nil;
                    LivePlayCell *otherCell = nil;
                    int otherIndex = (index == 0) ? 1 : 0;
                    
                    otherModel = self.datas[otherIndex];
                    otherCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:otherIndex inSection:0]];
                    
                    if(otherCell && (otherCell.moviePlayView == nil || ![otherCell.moviePlayView.playDocModel.zhuboID isEqualToString:otherModel.zhuboID])){
                        // 预加载另一个cell
                        if(otherCell.moviePlayView){
                            [otherCell.moviePlayView releaseAll];
                            [otherCell.moviePlayView removeFromParentViewController];
                        }
                        
                        moviePlay *playerV = [[moviePlay alloc] init];
                        otherCell.moviePlayView = playerV;
                        otherCell.moviePlayView.scrollindex = 0;
                        otherCell.moviePlayView.playDocModel = otherModel;
                        [otherCell.contentView addSubview:playerV.view];
                        
                        NodePlayer *nplayer = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
                        [playerV onPlayNodeVideoPlayer:nplayer audioEnable:false];
                        [playerArray addObject:nplayer];
                        [playerViewArray addObject:playerV];
                        
                        [otherCell.parentController addChildViewController:playerV];
                    }
                }
                // 正常处理：三个及以上cell的逻辑
                else if(cellLast != nil && cellNext != nil){
                    hotModel *subModelLast = nil;
                    hotModel *subModelNext = nil;
                    if (index-1>=0) {
                        subModelLast = self.datas[index-1];
                    }
                    if (index+1<self.datas.count) {
                        subModelNext = self.datas[index+1];
                    }
                    
                    int isCreateLast = -1;  //-1没有 1 创建上一个 2 超过滑动跳页面 删掉重新加载前后或者第一次进来
                    if(playerViewArray.count>1){
                        for (int i= 0; i<playerViewArray.count; i++) {
                            moviePlay *playerView = playerViewArray[i];
                            if([playerView.playDocModel.zhuboID isEqualToString:subModelLast.zhuboID]){
                                isCreateLast = 0;
                                [playerView releaseDatas];
                                [playerView setAudioEnable:0];
                                [playerView removeFromParentViewController];
                                break;
                            }else if([playerView.playDocModel.zhuboID isEqualToString:subModelNext.zhuboID]){
                                isCreateLast = 1;
                                [playerView releaseDatas];
                                [playerView setAudioEnable:0];
                                [playerView removeFromParentViewController];
                                break;
                            }else{
                                if(isFromCachePlayer){
                                    isCreateLast = 2;
                                }
                                
                            }
                        }
                        
                    }else{
                        isCreateLast = 2;
                    }
                    
                    if(isCreateLast == 1){
                        
                        [cellNext.moviePlayView setAudioEnable:0];
                               
                        [cellNext.moviePlayView removeFromParentViewController];
                        
                        if (index-1>0) {
                            moviePlay *playerVLast = [[moviePlay alloc]init];
                            cellLast.moviePlayView = playerVLast;
                            cellLast.moviePlayView.scrollindex = 0;
                            cellLast.moviePlayView.playDocModel = self.datas[index-1];
                          
                            [cellLast.contentView addSubview:playerVLast.view];
                            NodePlayer *nplayerLast  = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
                            [playerVLast onPlayNodeVideoPlayer:nplayerLast audioEnable:false];
                            [playerArray addObject:nplayerLast];
                            [playerViewArray addObject:playerVLast];
                        }
                       
                    }else if(isCreateLast == 0 ){
                        [cellLast.moviePlayView setAudioEnable:0];
                        [cellLast.moviePlayView removeFromParentViewController];
                        
                        if (index+1<self.datas.count) {
                            moviePlay *playerVNext = [[moviePlay alloc]init];
                            cellNext.moviePlayView = playerVNext;
                            cellNext.moviePlayView.scrollindex = 0;
                            cellNext.moviePlayView.playDocModel = self.datas[index+1];
                          
                            cellLast.moviePlayView.isPreviewSecond = 0;
                            [cellNext.contentView addSubview:playerVNext.view];
                            NodePlayer *nplayerNext  = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
                            [playerVNext onPlayNodeVideoPlayer:nplayerNext audioEnable:false];

                            
                            [playerArray addObject:nplayerNext];
                            [playerViewArray addObject:playerVNext];
                        }
                       
                    }else if(isCreateLast == 2 ){
                        if ((index-1)>=0) {
                            moviePlay *playerVLast = [[moviePlay alloc]init];
                            cellLast.moviePlayView = playerVLast;
                            cellLast.moviePlayView.scrollindex = 0;
                            cellLast.moviePlayView.playDocModel = self.datas[index-1];
                           
                            [cellLast.contentView addSubview:playerVLast.view];
                            NodePlayer *nplayerLast;
                            if(playerArray.count<(self.datas.count>2?3:2)){
                                nplayerLast  = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
                            }else{
                                nplayerLast  = [playerArray objectAtIndex:0];
                            }
                            [playerVLast onPlayNodeVideoPlayer:nplayerLast audioEnable:false];

                            
                           
                            [playerArray addObject:nplayerLast];
                            [playerViewArray addObject:playerVLast];
                            
                        }
                        
                        if ((index+1)<self.datas.count) {
                            moviePlay *playerVNext = [[moviePlay alloc]init];
                            cellNext.moviePlayView = playerVNext;
                            cellNext.moviePlayView.scrollindex = 0;
                            cellNext.moviePlayView.playDocModel = self.datas[index+1];
                            [cellNext.contentView addSubview:playerVNext.view];
                            NodePlayer *nplayerNext;
                            if(playerArray.count<(self.datas.count>2?3:2)){
                                nplayerNext  = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
                            }else{
                                nplayerNext  = [playerArray objectAtIndex:(self.datas.count>2?2:1)];
                            }
                            
                            [playerVNext onPlayNodeVideoPlayer:nplayerNext audioEnable:false];
                            [playerArray addObject:nplayerNext];
                            [playerViewArray addObject:playerVNext];
                        }
                        
                       
                    }
                }else{
                    hotModel *subModelLast;
                    hotModel *subModelNext;
                    if((index-1)>=0){
                        subModelLast = self.datas[index-1];
                    }
                    if((index+1)<self.datas.count){
                        subModelNext = self.datas[index+1];
                    }
                    
                    for (int i= 0; i<playerViewArray.count; i++) {
                        moviePlay *playerView = playerViewArray[i];
                        if(subModelLast!= nil && [playerView.playDocModel.zhuboID isEqualToString:subModelLast.zhuboID]){
                            [playerView releaseDatas];
                            [playerView setAudioEnable:0];
                            [playerView removeFromParentViewController];
                        }else if(subModelNext!= nil &&  [playerView.playDocModel.zhuboID isEqualToString:subModelNext.zhuboID]){
                            [playerView releaseDatas];
                            [playerView setAudioEnable:0];
                            [playerView removeFromParentViewController];
                        }
                    }
                    
                }
                
            }else{
                
                
                moviePlay *relaceV;
                
                BOOL isNext =false;
                BOOL isLast =false;
                int indexA = 0;
                for (int i= 0; i<playerViewArray.count; i++) {
                    moviePlay *playerView = playerViewArray[i];
                    if(![playerView.playDocModel.zhuboID isEqualToString:cellCurrent.moviePlayView.playDocModel.zhuboID]){
                        [playerView releaseDatas];
                        [playerView setAudioEnable:0];
                        [playerView removeFromParentViewController];
                    }
                    
                    if(![cellCurrent.moviePlayView.playDocModel.zhuboID isEqualToString:playerView.playDocModel.zhuboID]&& ( ![cellLast.moviePlayView.playDocModel.zhuboID isEqualToString:playerView.playDocModel.zhuboID] && ![cellNext.moviePlayView.playDocModel.zhuboID isEqualToString:playerView.playDocModel.zhuboID])){
                        [playerView setAudioEnable:0];
                        relaceV = playerView;
                        indexA = i;
                    }
                    
                    if([cellLast.moviePlayView.playDocModel.zhuboID isEqualToString:playerView.playDocModel.zhuboID]){
                        isNext = true;
                    }
                    if([cellNext.moviePlayView.playDocModel.zhuboID isEqualToString:playerView.playDocModel.zhuboID]){
                        isLast = true;
                    }
                    
                }
                if(isNext){
                  
                    if(cellNext!= nil ){
                        moviePlay *relaceV1 = [[moviePlay alloc]init];
                        [cellNext.moviePlayView releaseAll];
                        cellNext.moviePlayView = relaceV1;
                        cellNext.moviePlayView.scrollindex = 0;
                       
                        if ((index+1)<self.datas.count) {
                            cellNext.moviePlayView.playDocModel = self.datas[index+1];
                        }
                        [cellNext.contentView addSubview:relaceV1.view];
                        NodePlayer *nplayerNext  = playerArray[0];
                        [relaceV1 onPlayNodeVideoPlayer:nplayerNext audioEnable:false];
                        NSInteger numindex = [playerViewArray indexOfObject:relaceV];
                        if(numindex>=0){
                            if (playerViewArray.count>numindex) {
                                [playerViewArray replaceObjectAtIndex:numindex withObject:relaceV1];
                            }else{
                                [playerViewArray removeObjectAtIndex:0];
                                [playerViewArray addObject:relaceV1];
                            }
                           
                        }else{
                            if(indexA<playerViewArray.count){
                                [playerViewArray replaceObjectAtIndex:indexA withObject:relaceV1];
                            }else{
                                
                                NSLog(@"===============================越界了2");
                            }
                        }
                        [playerArray removeObjectAtIndex:0];
                        [playerArray addObject:nplayerNext];
                        
                    }
                    [relaceV releaseAll];
                    
                }
                if(isLast){
                  
                    if(cellLast!= nil ){
                        moviePlay *relaceV1 = [[moviePlay alloc]init];
                        [cellLast.moviePlayView releaseAll];
                        cellLast.moviePlayView = relaceV1;
                        cellLast.moviePlayView.scrollindex = 0;
                        if (index-1>=0) {
                            cellLast.moviePlayView.playDocModel = self.datas[index-1];
                        }
                        cellLast.moviePlayView.isPreviewSecond = 0;
                        [cellLast.contentView addSubview:relaceV1.view];
                        NodePlayer *nplayerLast  = playerArray[2];
                        [relaceV1 onPlayNodeVideoPlayer:nplayerLast audioEnable:false];

                        NSInteger numindex = [playerViewArray indexOfObject:relaceV];
                        if(numindex>=0){
                            if (playerViewArray.count>numindex) {
                                [playerViewArray replaceObjectAtIndex:numindex withObject:relaceV1];
                            }else{
                                [playerViewArray removeObjectAtIndex:2];
                                [playerViewArray addObject:relaceV1];
                            }
                        }else{
                            if(indexA<playerViewArray.count){
                                [playerViewArray replaceObjectAtIndex:indexA withObject:relaceV1];
                            }else{
                                
                                NSLog(@"===============================越界了2");
                            }
                        }
                        [playerArray removeObjectAtIndex:2];
                        [playerArray insertObject:nplayerLast atIndex:0];
                        
                    }
                    [relaceV releaseAll];
                }
                if(cellLast){
                    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = true;
                    [cellLast.moviePlayView.nplayer start:cellLast.moviePlayView.playDocModel.pull];
                    [cellLast.moviePlayView.nplayer setVolume:0];
                    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = false;
                }
                if(cellNext){
                    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = true;
                    [cellNext.moviePlayView.nplayer start:cellNext.moviePlayView.playDocModel.pull];
                    [cellNext.moviePlayView.nplayer setVolume:0];
                    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = false;
                }
                

                
               
                [cellCurrent.parentController addChildViewController:cellCurrent.moviePlayView];
                [cellCurrent.moviePlayView changeRoom:enterModel];
                [cellCurrent.moviePlayView setAudioEnable:1];
                [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = true;
                [cellCurrent.moviePlayView.nplayer start:cellCurrent.moviePlayView.playDocModel.pull];
                [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = false;
            }
            
            // 优化延迟释放机制
            if(delayBlock){
                dispatch_block_cancel(delayBlock);
            }
            WeakSelf
            delayBlock = dispatch_block_create(0, ^{
                // 你的延迟代码
                STRONGSELF
                if(strongSelf == nil){
                    return;
                }
                if(cellLast && cellLast.moviePlayView && cellLast.moviePlayView.nplayer){
                    [cellLast.moviePlayView.nplayer stop];
                }
                if(cellNext && cellNext.moviePlayView && cellNext.moviePlayView.nplayer){
                    [cellNext.moviePlayView.nplayer stop];
                }
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), delayBlock);


            // 本地移除房間
            if (self.removeRoomId!= nil && self.removeRoomId.length > 0) {
                NSString *removeRoomId = self.removeRoomId;
                self.removeRoomId = @"";
                int removeIndex = -1;
                for (int i = 0; i<self.datas.count; i++) {
                    hotModel *removeModel = self.datas[i];
                    if ([removeModel.zhuboID isEqualToString:removeRoomId]) {
                        removeIndex = i;
                        break;
                    }
                }

                if (removeIndex >= 0) {
                    [self.datas removeObjectAtIndex:removeIndex];
                    [playerViewArray removeAllObjects];
                    [self.tableView reloadData];
                    if (index > removeIndex) {
                        [scrollView setContentOffset:CGPointMake(0, scrollView.height * removeIndex)];
                    }
                    currentRequesting = -1;
                    [self scrollViewDidEndDecelerating:scrollView];
                    NSDictionary *userInfo = @{@"roomId": removeRoomId};
                    [[NSNotificationCenter defaultCenter] postNotificationName:LivePlayTableVCUpdateRemoveModelNotifcation object:nil userInfo:userInfo];
                }
            }
        }
    }
    hotModel *enterModel = self.datas[index];
    [[NSNotificationCenter defaultCenter]postNotificationName:LivePlayTableVCRequestDataNotifcation object:nil userInfo:@{@"zhubo_id":enterModel.zhuboID}];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     LivePlayCell* cell = nil;
    //使用重用机制，IDENTIFIER作为重用机制查找的标识，tableview查找可用cell时通过IDENTIFIER检索，如果有则cell不为nil
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[LivePlayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];//代码创建的cell需要使用该初始化方法
        
    }
   
    [cell loadImageView:self.datas[indexPath.row]];
    
    return cell;
}

-(void)dealloc
{
    if (self.removeRoomId.length > 0) {
        NSDictionary *userInfo = @{@"roomId": self.removeRoomId};
        [[NSNotificationCenter defaultCenter] postNotificationName:LivePlayTableVCUpdateRemoveModelNotifcation object:nil userInfo:userInfo];
    }
    NSLog(@"dealloc - %@", NSStringFromClass([self class]));
    [self clearAllLive];
    [IQKeyboardManager sharedManager].enable = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)clearAllLive
{
    
    for(moviePlay *subPl in  playerViewArray){
        [subPl releaseAll];
        [subPl.view removeFromSuperview];
      
    }
    [playerViewArray removeAllObjects];
    playerViewArray = nil;
    
    for(NodePlayer *subPl in  playerArray){
        subPl.volume = 0;
        [subPl stop];
        [subPl detachView];
        subPl.nodePlayerDelegate = nil;
        subPl.cryptoKey = @"";
      
      
    }
    [playerArray removeAllObjects];
    playerArray= nil;
    
}
@end
