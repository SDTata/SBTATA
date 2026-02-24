//
//  OpenHistoryViewController.m
//
//

#import "OpenHistoryViewController.h"
#import "IssueCollectionViewCell.h"
#import "ChipSwitchViewController.h"
#import "BetConfirmViewController.h"
#import "LotteryNNModel.h"
#import "OpenNNHistoryCell.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kIssueCollectionViewCell @"IssueCollectionViewCell"
#define kMultilevelCollectionHeader   @"CollectionHeader"

@interface OpenHistoryViewController ()<UICollectionViewDataSource>{
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    
    NSInteger curLotteryType;
    
    BOOL bUICreated; // UI是否创建
    
    NSInteger page;
}
@property(nonatomic,strong)NSMutableArray *allData;
@property (weak, nonatomic) IBOutlet UILabel *openhistoryTitleLabel;

@end

@implementation OpenHistoryViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    page = 0;
    [self getInfo];
    
    self.contentView.left = _window_width;
    self.contentView.alpha = 0;
    self.contentView.hidden = NO;
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.contentView.left = 0;
        strongSelf.contentView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.openhistoryTitleLabel.text =YZMsg(@"OpenHistory_titleBetHistory");
    
    self.allData = [NSMutableArray array];
    self.view.height = SCREEN_HEIGHT;
    self.view.width = SCREEN_WIDTH;
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.historyCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.view.width = _window_width;
    
    // 菊花
    testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // testActivityIndicator.center = self.view.center;
    testActivityIndicator.center = self.contentView.center;
    [self.view addSubview:testActivityIndicator];
    testActivityIndicator.color = [UIColor whiteColor];
    [testActivityIndicator startAnimating]; // 开始旋转

    
}
-(void)exitView{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.contentView.left = _window_width;
        strongSelf.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.closeCallback) {
            strongSelf.closeCallback();
        }
        [strongSelf.view removeFromSuperview];
        [strongSelf removeFromParentViewController];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
}

- (void)getInfo{
    if(!bUICreated){
        self.historyCollection.hidden = YES;
    }
    NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getOpenHistory&uid=%@&token=%@&lottery_type=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", curLotteryType]];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES andParameter:@{@"page":minnum(page)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.historyCollection.mj_header endRefreshing];
        [strongSelf.historyCollection.mj_footer endRefreshing];
        
        NSLog(@"xxxxxxxxx%@",info);
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        if(code == 0)
        {
            NSLog(@"%@",info);
            
            NSArray *dataArrays = [lastResultModel mj_objectArrayWithKeyValuesArray:[info objectForKey:@"list"]];
            if ([dataArrays isKindOfClass:[NSArray class]]) {
                
               if (strongSelf->page == 0) {
                   if (strongSelf->curLotteryType == 11 || strongSelf->curLotteryType == 6) {
                       NSMutableArray *newArray = [NSMutableArray array];
                       [dataArrays enumerateObjectsUsingBlock:^(lastResultModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
                           NSArray *open_result = [model.open_result componentsSeparatedByString:@","];
                           if ([open_result.firstObject integerValue] > [open_result.lastObject integerValue]) {
                               [model.spare_2 addObject:YZMsg(@"OpenHistory_Dragon")];
                           } else if ([open_result.firstObject integerValue] == [open_result.lastObject integerValue]) {
                               [model.spare_2 addObject:YZMsg(@"OpenHistory_he")];
                           } else {
                               [model.spare_2 addObject:YZMsg(@"OpenHistory_Tiger")];
                           }
                           [newArray addObject:model];
                       }];
                       strongSelf.allData = newArray;
                   } else {
                       strongSelf.allData = [NSMutableArray arrayWithArray:dataArrays];
                   }
                }else{
                    if (dataArrays.count <= 0) {
                        [strongSelf.historyCollection.mj_footer endRefreshingWithNoMoreData];
                    }else{
                        for (lastResultModel *subModel in dataArrays) {
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issue CONTAINS[cd] %@" ,subModel.issue];
                            NSArray *arrays = [strongSelf.allData filteredArrayUsingPredicate:predicate];
                            if(arrays.count>0){
                                continue;
                            }
                            [strongSelf.allData addObject:subModel];
                        }
                        
                    }
                }
            }
            dispatch_main_async_safe(^{
                [strongSelf refreshUI];
            });
        }
        else{
            [MBProgressHUD showError:msg];
            [strongSelf exitView];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->testActivityIndicator stopAnimating]; // 结束旋转
        [strongSelf->testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
        [strongSelf exitView];
    }];
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    [self.historyCollection reloadData];
    self.historyCollection.hidden = NO;
}

-(void)initUI{
    bUICreated = true;
    
    // 初始化投注选项
    [self initCollection];
    
    // 监听阴影层点击事件
    UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitView)];
    [self.shadowView addGestureRecognizer:myTap];
    
}

- (void)initCollection {
    //    if (nil == _historyCollection) {
    
    FLLayout *layout = [[FLLayout alloc]init];
    layout.dataSource = self;
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing=0.f;//左右间隔
    flowLayout.minimumLineSpacing=0.f;
    //        float leftMargin =0;
    //        self.historyCollection=[[UICollectionView alloc] initWithFrame:CGRectMake(0,0,kScreenWidth,self.view.height) collectionViewLayout:flowLayout];
    
    self.historyCollection.delegate = self;
    self.historyCollection.dataSource = self;
    self.historyCollection.collectionViewLayout = flowLayout;
    self.historyCollection.allowsMultipleSelection = YES;
    
    if (curLotteryType == 10) {
        UINib *nib =[UINib nibWithNibName:@"OpenNNHistoryCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        [self.historyCollection registerNib: nib forCellWithReuseIdentifier:@"OpenNNHistoryCell"];
    }else{
        UINib *nib=[UINib nibWithNibName:kIssueCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        [self.historyCollection registerNib: nib forCellWithReuseIdentifier:kIssueCollectionViewCell];
        UINib *header=[UINib nibWithNibName:kMultilevelCollectionHeader bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
        [self.historyCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMultilevelCollectionHeader];
    }
    self.historyCollection.backgroundColor=[UIColor clearColor];
    
    WeakSelf
    self.historyCollection.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->page = 0;
        [strongSelf getInfo];
        
    }];
    self.historyCollection.mj_footer  = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->page ++;
        [strongSelf getInfo];
    }];
    
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (curLotteryType == 10) {
        return 1;
    }
    return self.allData.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (curLotteryType == 10) {
        return self.allData.count;
    }
    lastResultModel *model = [self.allData objectAtIndex:section];
    
    if(!self.allData || !model || !model.open_result){
        return 0;
    }
    NSArray *open_result = [model.open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        result_count = result_count + 1;
    }else if (curLotteryType == 10){
        lastResultModel *model = [lastResultModel mj_objectWithKeyValues:[self.allData objectAtIndex:section]];
        return model.vs.blue.pai.count + model.vs.red.pai.count ;
    } else if ((curLotteryType == 11 || curLotteryType == 6 || curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27) && model.spare_2 != nil) {
        result_count = result_count + model.spare_2.count;
    }
    return result_count;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//called when the user taps on an already-selected item in multi-select mode
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (curLotteryType == 10){
        OpenNNHistoryCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"OpenNNHistoryCell" forIndexPath:indexPath];
        lastResultModel *model = [self.allData objectAtIndex:indexPath.row];
        cell.model = model;
        return cell;
    }
    IssueCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kIssueCollectionViewCell forIndexPath:indexPath];
    cell.isSpareType = NO;
    //    NSDictionary *dict = [allData objectAtIndex:indexPath.section];
    lastResultModel *model = [self.allData objectAtIndex:indexPath.section];
    NSArray *open_result = [model.open_result componentsSeparatedByString:@","];
    NSString *resultStr = @"";
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        if(indexPath.row == 6){
            resultStr = @"+";
        }else if (indexPath.row == 7){
            resultStr = [open_result objectAtIndex:6];
        }else{
            resultStr = [open_result objectAtIndex:indexPath.row];
        }
    } else if (curLotteryType == 11 || curLotteryType == 6) { // 时时彩
        if (indexPath.row <= 4) {
            resultStr = [open_result objectAtIndex:indexPath.row];
        } else {
            resultStr = [model.spare_2 objectAtIndex:indexPath.row - 5];
            [cell setIsSpareType: YES];
        }
    } else if (curLotteryType == 13 || curLotteryType == 22 || curLotteryType == 23 || curLotteryType == 26 || curLotteryType == 27) {  // 快三
        if (indexPath.row <= 2) {
            resultStr = [open_result objectAtIndex:indexPath.row];
        } else {
            resultStr = [model.spare_2 objectAtIndex:indexPath.row - 3];
            [cell setIsSpareType: YES];
        }
    }else{
        resultStr = [open_result objectAtIndex:indexPath.row];
    }
    
    [cell setNumber:resultStr lotteryType:curLotteryType];
    
    return cell;
}
// 标题
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (curLotteryType == 10){
        return nil;
    }
    NSString *reuseIdentifier;
    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
        reuseIdentifier = @"footer";
    }else{
        reuseIdentifier = kMultilevelCollectionHeader;
    }
    
    lastResultModel *model = self.allData[indexPath.section];
    
    UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[view viewWithTag:1];
    label.font=[UIFont systemFontOfSize:15];
    label.textColor=UIColorFromRGB(0x686868);
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        label.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        view.backgroundColor = [UIColor lightGrayColor];
        label.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    }
    
    return view;
}
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if (curLotteryType == 10){
        return CGSizeMake(SCREEN_WIDTH, 88);
    }
    return CGSizeMake(35, 35);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (curLotteryType == 10){
        return CGSizeMake(SCREEN_WIDTH, 88);
    }
    return CGSizeMake(35, 35);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (curLotteryType == 10){
        return UIEdgeInsetsMake(0, 0, 5, 0);
    }else if (curLotteryType == 28){
        return UIEdgeInsetsMake(0, 30, 0, 0);
    }
    return UIEdgeInsetsMake(0, 10, 5, 10);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (curLotteryType == 10){
        CGSize size={0,0};
        return size;
    }
    CGSize size={kScreenWidth,30};
    return size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
