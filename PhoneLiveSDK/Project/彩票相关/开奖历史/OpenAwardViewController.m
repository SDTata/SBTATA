//
//  OpenAwardViewController.m
//
//

#import "OpenAwardViewController.h"
#import "IssueCollectionViewCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kIssueCollectionViewCell @"IssueCollectionViewCell"

#import "LotteryOpenViewCell_BJL.h"
#import "LotteryOpenViewCell_ZJH.h"
#import "LotteryOpenViewCell_LH.h"


@interface OpenAwardViewController (){
    UIActivityIndicatorView *testActivityIndicator;//菊花
    
    NSDictionary *allData;
    BOOL bUICreated; // UI是否创建
    BOOL isExit;
    NSInteger curLotteryType;
    
    NSDictionary *vsDic;
    NSString *last_open_result;
    NSString *last_open_resultZH;
    CAGradientLayer *grandentlLayer;
}

@property (weak, nonatomic) IBOutlet UIImageView *nnRedWinImgV;

@property (weak, nonatomic) IBOutlet UIImageView *nnBlueWinImgV;
@property (weak, nonatomic) IBOutlet UIView *grandentView;
@end

@implementation OpenAwardViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
//    [self getInfo];
    [self refreshUI];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat space = self.view.height / 3.0;
    [self.grandentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view).inset(-space);
    }];
    self.grandentView.layer.cornerRadius = self.view.height / 2.0;
    self.grandentView.layer.masksToBounds = YES;
//    CGRect rect = self.grandentView.bounds;
//    rect.size.width = rect.size.width + rect.size.height / 2.0;
//    rect.origin.x = rect.origin.x - rect.size.height / 2.0;
    grandentlLayer.frame = self.grandentView.bounds;;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.openResultCollection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf exitView];
    });
    self.nnRedWinImgV.image = [ImageBundle imagewithBundleName:YZMsg(@"OpenAwardVC_RightWin")];
    self.nnBlueWinImgV.image = [ImageBundle imagewithBundleName:YZMsg(@"OpenAwardVC_LeftWin")];

    grandentlLayer = [CAGradientLayer layer];
    grandentlLayer.colors = @[(__bridge id)RGB_COLOR(@"#F83600", 1).CGColor,(__bridge id)RGB_COLOR(@"#FACC22", 1).CGColor, (__bridge id)RGB_COLOR(@"#000000", 0).CGColor];
    grandentlLayer.startPoint = CGPointMake(0, 0);
    grandentlLayer.endPoint = CGPointMake(1.0, 0);
    grandentlLayer.locations = @[@0.0, @0.5, @1.0];
    grandentlLayer.zPosition = -100;
    self.grandentView.backgroundColor = [UIColor clearColor];
    [self.grandentView.layer insertSublayer:grandentlLayer atIndex:0];

    self.view.clipsToBounds = NO;
    self.grandentView.clipsToBounds = NO;
    self.contentView.clipsToBounds = NO;

}
-(void)exitView{
    if(isExit) return;
    isExit = true;
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.contentView.right = 0;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.view removeFromSuperview];
        [strongSelf removeFromParentViewController];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
}

- (void)setOpenAwardInfo:(NSDictionary *)dict{
    /*
     name
     logo
     lastResult = {open_result=open_result}
     */
    allData = dict;
    NSString * result = dict[@"result"];
    curLotteryType = [minstr(allData[@"lotteryType"]) integerValue];
    _issueStr = allData[@"issue"];
    
    
    if (curLotteryType == 29) {
        NSArray *arrayResult = dict[@"winWays"];
        if (arrayResult && [arrayResult isKindOfClass:[NSArray class]] && arrayResult.count>0) {
            last_open_result = arrayResult.firstObject;
        }else{
            last_open_result = result;
        }
        
        NSDictionary *zjhDic = dict[@"zjh"];
        NSArray *pai_type_strs = zjhDic[@"pai_type_str"];
        NSString *pairesultStr = dict[@"result"];
        
        NSString *whowWinStr = [NSString stringWithFormat:@"%@",zjhDic[@"whoWin"]];
        NSString *open_result = @"";
        if ([whowWinStr isEqualToString:@"0"]) {
            open_result = @"玩家一";
        }else if ([whowWinStr isEqualToString:@"1"]) {
            open_result = @"玩家二";
        }else if ([whowWinStr isEqualToString:@"2"]) {
            open_result = @"玩家三";
        }
        
        NSArray *paiA = [pairesultStr componentsSeparatedByString:@"|"];
        if(paiA.count>2 && pai_type_strs.count>2){
            NSString *paiS_1 = paiA[0];
            NSString *paiS_2 = paiA[1];
            NSString *paiS_3 = paiA[2];
            if(paiS_1 && paiS_1.length>0 && paiS_2 && paiS_2.length>0 && paiS_3 && paiS_3.length>0){
                NSString *pai_1 = [[paiS_1 stringByReplacingOccurrencesOfString:@"玩家1:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                NSString *pai_2 = [[paiS_2 stringByReplacingOccurrencesOfString:@"玩家2:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                NSString *pai_3 = [[paiS_3 stringByReplacingOccurrencesOfString:@"玩家3:" withString:@""] componentsSeparatedByString:@"("].firstObject;
                
                vsDic = @{@"open_result":open_result,@"who_win":zjhDic[@"whoWin"],@"vs":@{@"player1":@{@"pai":[pai_1 componentsSeparatedByString:@","],@"pai_type_str":pai_type_strs[0]},
                                                 @"player2":@{@"pai":[pai_2 componentsSeparatedByString:@","],@"pai_type_str":pai_type_strs[1]},
                                                 @"player3":@{@"pai":[pai_3 componentsSeparatedByString:@","],@"pai_type_str":pai_type_strs[2]}}
                };
            }
        }
       
    }else if(curLotteryType == 28){
        NSInteger whoWin =[[(dict[@"bjl"]) objectForKey:@"whoWin"] integerValue];
        NSString *whoWinStr = @"";
        if (whoWin == 0) {
            whoWinStr = @"百家乐_庄胜";
        }else if (whoWin == 1){
            whoWinStr = @"百家乐_闲胜";
        }else if (whoWin == 2){
            whoWinStr = @"百家乐_和";
        }
        NSString *winStr = dict[@"sum_result_str"];
        if (winStr) {
            last_open_result =[winStr componentsSeparatedByString:@","].firstObject;
        }
        NSDictionary *lhDic = dict[@"bjl"];
        NSString *xian_dian = lhDic[@"xian_dian"];
        NSString *zhuang_dian = lhDic[@"zhuang_dian"];
        NSString *pairesultStr = dict[@"result"];
        NSArray *paiA = [pairesultStr componentsSeparatedByString:@"|"];
        if(paiA.count>1){
            NSString *xian_paiS =paiA[0];
            NSString *zhuang_paiS = paiA[1];
            if(xian_paiS && xian_paiS.length>0 && [xian_paiS containsString:@"闲:"] && zhuang_paiS && zhuang_paiS.length>0 && [zhuang_paiS containsString:@"庄:"] ){
                NSString *xian_p = [xian_paiS stringByReplacingOccurrencesOfString:@"闲:" withString:@""];
                NSString *zhuang_p = [zhuang_paiS stringByReplacingOccurrencesOfString:@"庄:" withString:@""];
                
                vsDic = @{@"blue":@{@"pai":[xian_p componentsSeparatedByString:@","],@"dian":xian_dian},@"red":@{@"pai":[zhuang_p componentsSeparatedByString:@","],@"dian":zhuang_dian}};
            }
        }
       
        
    } else if(curLotteryType == 31){
        NSInteger whoWin =[[(dict[@"lh"]) objectForKey:@"whoWin"] integerValue];
        NSString *whoWinStr = @"";
        if (whoWin == 0) {
            whoWinStr = @"龙虎_龙";
        }else if (whoWin == 1){
            whoWinStr = @"龙虎_虎";
        }else if (whoWin == 2){
            whoWinStr = @"龙虎_和";
        }
        
        NSString *winStr = dict[@"sum_result_str"];
        if (winStr) {
            last_open_result =[winStr componentsSeparatedByString:@","].firstObject;
        }
        
        NSDictionary *lhDic = dict[@"lh"];
        NSString *dragon_dian = lhDic[@"dragon_dian"];
        NSString *tiger_dian = lhDic[@"tiger_dian"];
        NSString *pairesultStr = dict[@"result"];
        NSArray *paiA = [pairesultStr componentsSeparatedByString:@"|"];
        if(paiA.count>1){
            NSString *dragon_paiS =paiA[0];
            NSString *tiger_paiS = paiA[1];
            if(dragon_paiS && dragon_paiS.length>0 && [dragon_paiS containsString:@"龙:"] && tiger_paiS && tiger_paiS.length>0 && [tiger_paiS containsString:@"虎:"] ){
                NSString *dragon_p = [dragon_paiS stringByReplacingOccurrencesOfString:@"龙:" withString:@""];
                NSString *tiger_p = [tiger_paiS stringByReplacingOccurrencesOfString:@"虎:" withString:@""];
                
                vsDic = @{@"dragon":@{@"pai":dragon_p,@"pai_type":dragon_dian},@"tiger":@{@"pai":tiger_p,@"pai_type":tiger_dian}};
            }
        }
        
    }
    
}





-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    self.openResultCollection.hidden = NO;
    // 刷新彩种名字
    self.lotteryName.text = allData[@"name"];
    self.lotteryIssue.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), allData[@"issue"]];
    if (curLotteryType == 10) {
        self.leftBlueLabel.text = YZMsg(@"OpenAward_NiuNiu_Blue");
        self.rightRedLabel.text = YZMsg(@"OpenAward_NiuNiu_Red");
        NSString *result_sum = allData[@"sum_result_str"];
        if (result_sum && result_sum.length>0 && [result_sum rangeOfString:YZMsg(@"OpenAward_NiuNiu_BlueWin")].location !=NSNotFound) {
            self.blueWinImgView.hidden = NO;
            self.redWinImgView.hidden = YES;
        }else if(result_sum && result_sum.length>0 && [result_sum rangeOfString:YZMsg(@"OpenAward_NiuNiu_RedWin")].location !=NSNotFound){
            self.blueWinImgView.hidden = YES;
            self.redWinImgView.hidden = NO;
        }
        NSDictionary *niuDic = allData[@"niu"];
        if ([niuDic isKindOfClass:[NSDictionary class]]) {
            NSString *blue_niu = niuDic[@"blue_niu"];
            NSString *red_niu = niuDic[@"red_niu"];
            self.leftNiuLabel.text = blue_niu;
            self.rightNiuLabel.text = red_niu;
        }
    }
    [self.openResultCollection reloadData];
    
//    // 刷新彩种logo
//    self.logo.contentMode = UIViewContentModeScaleAspectFit;
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:minstr(allData[@"logo"])] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        if (image) {
//            [self.logo setImage:image];
//        }
//    }];
}

-(void)initUI{
    bUICreated = true;
    
    // 初始化投注选项
    [self initCollection];
    // 监听关闭按钮
    [self.closeBtn addTarget:self action:@selector(exitView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initCollection {
    // 最后一期开奖
    UICollectionViewFlowLayout *flowLayout;
    
    if (curLotteryType==28||curLotteryType==29||curLotteryType==31) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.openResultCollection.collectionViewLayout = layout;
    }else if (curLotteryType == 10) {
        flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 1.1f;
        self.openResultCollection.collectionViewLayout = flowLayout;
    }else{
        flowLayout = [[EqualSpaceFlowLayoutEvolve alloc]    initWthType:AlignWithLeft];
        ((EqualSpaceFlowLayoutEvolve*)flowLayout).betweenOfCell = 1;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
        self.openResultCollection.collectionViewLayout = flowLayout;
    }
    self.openResultCollection.delegate = self;
    self.openResultCollection.dataSource = self;
   
    self.openResultCollection.allowsMultipleSelection = self;
    UINib *nib2=[UINib nibWithNibName:kIssueCollectionViewCell bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    UINib *copennibLH=[UINib nibWithNibName:kLotteryOpenViewCell_LH bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    UINib *copennibBJL=[UINib nibWithNibName:kLotteryOpenViewCell_BJL bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    UINib *copennibZJH=[UINib nibWithNibName:kLotteryOpenViewCell_ZJH bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]];
    
    
    [self.openResultCollection registerNib: copennibBJL forCellWithReuseIdentifier:kLotteryOpenViewCell_BJL];
    [self.openResultCollection registerNib: copennibZJH forCellWithReuseIdentifier:kLotteryOpenViewCell_ZJH];
    [self.openResultCollection registerNib: copennibLH forCellWithReuseIdentifier:kLotteryOpenViewCell_LH];
    [self.openResultCollection registerNib: nib2 forCellWithReuseIdentifier:kIssueCollectionViewCell];
    
    self.openResultCollection.backgroundColor=[UIColor clearColor];
}

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (curLotteryType == 29||curLotteryType == 28||curLotteryType == 31) {
        return 1;
    }
    NSDictionary *dict = allData[@"lastResult"];
    if(!dict) return 0;
    NSArray *open_result = [dict[@"open_result"] componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        result_count = result_count + 1;
    }else if (curLotteryType == 10){
        result_count = [PublicObj getPokersNamesBy:dict[@"open_result"]].count;
    }
    
    return result_count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section{
    NSDictionary *dict = allData[@"lastResult"];
    if(!dict) return 0;
    NSArray *open_result = [dict[@"open_result"] componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        result_count = result_count + 1;
    }else if (curLotteryType == 10){
        result_count = [PublicObj getPokersNamesBy:dict[@"open_result"]].count;
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
    // 根据彩票类型返回不同的cell
    if(curLotteryType == 28){
        LotteryOpenViewCell_BJL *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_BJL forIndexPath:indexPath];
        cell.isShowJustLast = YES;
        lastResultModel * model = [lastResultModel new];
        model.open_result = last_open_result;
        model.vs = [ResultVSModel mj_objectWithKeyValues:vsDic];
        cell.model = model;
        return cell;
    } else if(curLotteryType == 29){
        LotteryOpenViewCell_ZJH *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_ZJH forIndexPath:indexPath];
        cell.isShowJustLast = YES;
        cell.model = vsDic;
        return cell;
    } else if(curLotteryType == 31){
        LotteryOpenViewCell_LH *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLotteryOpenViewCell_LH forIndexPath:indexPath];
        cell.isShowJustLast = YES;
        cell.model = @{@"open_result":last_open_result?:@"",@"vs":vsDic};
        return cell;
    }
    
    // 处理其他类型
    IssueCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIssueCollectionViewCell forIndexPath:indexPath];
    NSDictionary *dict = allData[@"lastResult"];
    if (!dict) {
        return cell;
    }
    
    NSArray *open_result = [dict[@"open_result"] componentsSeparatedByString:@","];
    NSString *resultStr = @"";
    
    if(curLotteryType == 8 || curLotteryType == 7 || curLotteryType == 32){
        if(indexPath.row == 6){
            resultStr = @"+";
        }else if (indexPath.row == 7 && open_result.count > 6){
            resultStr = open_result[6];
        }else if (indexPath.row < open_result.count){
            resultStr = open_result[indexPath.row];
        }
    }else if (curLotteryType == 10) {
        NSArray *pokerNames = [PublicObj getPokersNamesBy:dict[@"open_result"]];
        if (indexPath.row < pokerNames.count) {
            resultStr = pokerNames[indexPath.row];
        }
    }else if (indexPath.row < open_result.count){
        resultStr = open_result[indexPath.row];
    }
    
    [cell setNumber:resultStr lotteryType:curLotteryType];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    if (curLotteryType==28||curLotteryType==29||curLotteryType==31) {
        return CGSizeMake(self.openResultCollection.width,50);
    }
    NSDictionary *dict = allData[@"lastResult"];
    NSArray *open_result = [dict[@"open_result"] componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        result_count = result_count + 1;
        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float cHeight = self.openResultCollection.height;
        float scaleRate = MAX(MIN(matchW, cHeight), cHeight/2) / 80;
        return CGSizeMake(80*scaleRate, 80*scaleRate);
    }else if (curLotteryType == 10) {
        result_count = [PublicObj getPokersNamesBy:dict[@"open_result"]].count;
        float w = (self.openResultCollection.width - 0 - 20) / result_count;
        return CGSizeMake(w, 35);
        
    }else{
        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float cHeight = self.openResultCollection.height;
        float scaleRate = MAX(MIN(matchW, cHeight), cHeight/2) / 80;
        
        if (result_count == 1) {
            return CGSizeMake(self.openResultCollection.width/3, 60*scaleRate);
        }else{
            return CGSizeMake(60*scaleRate, 60*scaleRate);
        }
        
    }
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (curLotteryType==28||curLotteryType==29||curLotteryType==31) {
        return CGSizeMake(self.openResultCollection.width,50);
    }
    
    NSDictionary *dict = allData[@"lastResult"];
    NSArray *open_result = [dict[@"open_result"] componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if(curLotteryType == 8||curLotteryType == 7||curLotteryType == 32){
        result_count = result_count + 1;
        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float cHeight = self.openResultCollection.height;
        float scaleRate = MAX(MIN(matchW, cHeight), cHeight/2) / 80;
        return CGSizeMake(80*scaleRate, 80*scaleRate);
    }else if (curLotteryType == 10) {
        result_count = [PublicObj getPokersNamesBy:dict[@"open_result"]].count;
        float w = (self.openResultCollection.width - 0 - 20) / result_count;
        return CGSizeMake(w, 35);
    }else{
        float matchW = (self.openResultCollection.width - 15) / result_count - 1;
        float cHeight = self.openResultCollection.height;
        float scaleRate = MAX(MIN(matchW, cHeight), cHeight/2) / 80;
        
        if (result_count == 1) {
            return CGSizeMake(self.openResultCollection.width/3, 60*scaleRate);
        }else{
            return CGSizeMake(60*scaleRate, 60*scaleRate);
        }
        
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (curLotteryType == 10) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth,0};
    return size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
