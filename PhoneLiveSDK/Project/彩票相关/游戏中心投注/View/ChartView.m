//
//  ChartView.m
//  phonelive2
//
//  Created by 400 on 2022/6/27.
//  Copyright © 2022 toby. All rights reserved.
//

#import "ChartView.h"
#import "ChartCollectionViewCell.h"
#import "LotteryNNModel.h"

@implementation ChartModel

@end

@interface ChartView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *chartSwicthButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *menueBgView;
@property (weak, nonatomic) IBOutlet UIView *menueSubView;
@property (weak, nonatomic) IBOutlet UILabel *menueTitleLabel;


@property (weak, nonatomic) IBOutlet UIButton *meueButton1;
@property (weak, nonatomic) IBOutlet UIButton *meueButton2;
@property (weak, nonatomic) IBOutlet UIButton *meueButton3;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UIView *line1;

@property(nonatomic,strong)NSMutableArray *dataArrays;

@property(nonatomic,strong)NSMutableArray *resultDatas;

@property(nonatomic,assign)NSInteger typeLottery;
@property(nonatomic,assign)int switchLotteryType;
@property(nonatomic,assign)int blinkCount;

@property(nonatomic,strong)UIButton *blinkButton;
@end


@implementation ChartView
- (IBAction)meuAction:(id)sender {
    self.menueSubView.hidden  = !self.menueSubView.hidden;
}

+ (instancetype)instanceChatViewWithType:(NSInteger)type
{
    ChartView *instance = [[[XBundle currentXibBundleWithResourceName:@""] loadNibNamed:@"ChartView" owner:nil options:nil] lastObject];
    instance.backgroundColor = [UIColor clearColor];
    instance.typeLottery = type;
    instance.switchLotteryType = 0;
    instance.dataArrays = [NSMutableArray array];
    instance.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    [instance.collectionView registerNib:[UINib nibWithNibName:@"ChartCollectionViewCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellWithReuseIdentifier:@"ChartCollectionViewCell"];
    instance.collectionView.backgroundColor = [UIColor clearColor];

    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing      = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
    [instance resetMenu];
    [instance.collectionView setCollectionViewLayout:layout];
    instance.collectionView.delegate = instance;
    instance.collectionView.dataSource = instance;
    instance.collectionView.showsHorizontalScrollIndicator = false;
    instance.collectionView.alwaysBounceHorizontal = true;
    [instance loadData];
    switch (type) {
        case 26:
        case 8:
        case 14:
        case 11:
        case 6:
        case 27:
            [instance updateMenueStr1:YZMsg(@"Chart_Area_big_small") Str2:YZMsg(@"Chart_Area_single_double")];
            break;
        case 30:
            [instance updateMenueStr1:YZMsg(@"Chart_Area_big_small") Str2:YZMsg(@"Chart_Area_red_black")];
            break;
        default:
            break;
    }
    return instance;
}



-(void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshTableV];
}

-(void)refreshTableV{
    self.width = SCREEN_WIDTH;
    self.collectionView.width = SCREEN_WIDTH-self.menuLayoutConstraint.constant;
}

-(void)resetMenu
{
    self.blinkCount = 0;
    self.menueTitleLabel.text  = YZMsg(@"trend");
    self.menueSubView.hidden = YES;
    self.blinkCount = 0;
    self.menueTitleLabel.text  = YZMsg(@"trend");
    self.menueSubView.hidden = YES;
    if (self.typeLottery == 26||self.typeLottery == 27||self.typeLottery == 14||self.typeLottery == 11||self.typeLottery == 6) {
        self.meueButton3.hidden = YES;
        self.line1.hidden = YES;
        self.line2.hidden = YES;
        [self.meueButton1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.meueButton1 setTitle:@"" forState:UIControlStateNormal];
        [self.meueButton2 setTitle:@"" forState:UIControlStateNormal];
        [self.meueButton1 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
        [self.meueButton2 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
    }else if (self.typeLottery == 30||self.typeLottery == 8 ||self.typeLottery == 7||self.typeLottery == 32) {
        [self.meueButton1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.meueButton1 setTitle:@"" forState:UIControlStateNormal];
        [self.meueButton2 setTitle:@"" forState:UIControlStateNormal];
        
        [self.meueButton3 setTitle:self.typeLottery==8?YZMsg(@"Chart_Area_Color"):YZMsg(@"Chart_Area") forState:UIControlStateNormal];
        [self.meueButton1 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
        [self.meueButton2 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
        [self.meueButton3 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.menueBgView.hidden = YES;
        self.menuLayoutConstraint.constant = 0;
    }
    
    [self refreshTableV];
}

-(void)updateMenueStr1:(NSString*)str1 Str2:(NSString*)str2
{
    self.blinkCount = 0;
    self.menueTitleLabel.text  = YZMsg(@"trend");
    self.menueSubView.hidden = YES;
    if (self.typeLottery == 26||self.typeLottery == 27||self.typeLottery == 14||self.typeLottery == 11||self.typeLottery == 6) {
        self.meueButton3.hidden = YES;
        self.line1.hidden = YES;
        self.line2.hidden = YES;
        [self.meueButton1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.meueButton1 setTitle:str1 forState:UIControlStateNormal];
        [self.meueButton2 setTitle:str2 forState:UIControlStateNormal];
        [self.meueButton1 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
        [self.meueButton2 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
    }else if (self.typeLottery == 30||self.typeLottery == 8 || self.typeLottery == 7||self.typeLottery == 32) {
        [self.meueButton1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.meueButton1 setTitle:str1 forState:UIControlStateNormal];
        [self.meueButton2 setTitle:str2 forState:UIControlStateNormal];
        
        [self.meueButton3 setTitle:self.typeLottery==8?YZMsg(@"Chart_Area_Color"):YZMsg(@"Chart_Area") forState:UIControlStateNormal];
        [self.meueButton1 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
        [self.meueButton2 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
        [self.meueButton3 addTarget:self action:@selector(buttonActionMenueSwich:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.menueBgView.hidden = YES;
        self.menuLayoutConstraint.constant = 0;
    }
    [self refreshTableV];
}

-(void)buttonActionMenueSwich:(UIButton*)button{
    [self.meueButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.meueButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.meueButton3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if ([button isEqual:self.meueButton1]) {
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _switchLotteryType = 0;
        
    }else if([button isEqual:self.meueButton2]){
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _switchLotteryType = 1;
    }else if([button isEqual:self.meueButton3]){
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _switchLotteryType = 2;
    }
    

    [self sortDatas:self.resultDatas];
    self.menueSubView.hidden  = YES;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath{
    
    return CGSizeMake(100/6, 100);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(100/6, 100);
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataArrays.count<23) {
        return 28;
    }else{
        return self.dataArrays.count+5;
    }
   
}

// 右侧子集属性设置
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ChartCollectionViewCell *cell = (ChartCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ChartCollectionViewCell" forIndexPath:indexPath];
    NSArray *subA = @[cell.contentView1,cell.contentView2,cell.contentView3,cell.contentView4,cell.contentView5,cell.contentView6];
    for (int i = 0; i<subA.count; i++) {
        UIView *subV = subA[i];
        UIButton *subImgButton = [subV viewWithTag:1000];
        subImgButton.userInteractionEnabled = false;
        if (subImgButton == nil) {
            subImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
            subImgButton.frame = CGRectMake(0, 0, 100/6, 100/6);
            subImgButton.tag = 1000;
            [subV addSubview:subImgButton];
        }
        [subImgButton setBackgroundImage:nil forState:UIControlStateNormal];
        [subImgButton setImage:nil forState:UIControlStateNormal];
        [subImgButton setTitle:@"" forState:UIControlStateNormal];
        BOOL isClear = true;
        if (self.dataArrays.count>indexPath.row) {
            NSArray *subArr = self.dataArrays[indexPath.row];
            for (ChartModel *subModel in subArr) {
                if (subModel.yIndex == i) {
                    if (subModel.displayType == 0) {
                        isClear = true;
                    }else if (subModel.displayType == 1) {
                        [subImgButton setBackgroundImage:[ImageBundle imagewithBundleName:@"zs_04"] forState:UIControlStateNormal];
//                        if (self.typeLottery == 29) {
//                            UIImage *image = [[ImageBundle imagewithBundleName:@"zs_04"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//                            [subImgButton setBackgroundImage:image forState:UIControlStateNormal];
                            [subImgButton setTitle:subModel.showTitle forState:UIControlStateNormal];
                            subImgButton.titleLabel.font = [UIFont systemFontOfSize:12];
//                        }
                        isClear = false;
                    }else if (subModel.displayType == 2) {
                        [subImgButton setBackgroundImage:[ImageBundle imagewithBundleName:@"zs_08"] forState:UIControlStateNormal];
//                        if (self.typeLottery == 29) {
//                            UIImage *image = [[ImageBundle imagewithBundleName:@"zs_08"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//                            [subImgButton setBackgroundImage:image forState:UIControlStateNormal];
                            [subImgButton setTitle:subModel.showTitle forState:UIControlStateNormal];
                            subImgButton.titleLabel.font = [UIFont systemFontOfSize:12];
//                        }
                        isClear = false;
                    }else if (subModel.displayType == 3) {
                        [subImgButton setBackgroundImage:[ImageBundle imagewithBundleName:@"zs_06"] forState:UIControlStateNormal];
//                        if (self.typeLottery == 29) {
//                            UIImage *image = [[ImageBundle imagewithBundleName:@"zs_06"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//                            [subImgButton setBackgroundImage:image forState:UIControlStateNormal];
                            [subImgButton setTitle:subModel.showTitle forState:UIControlStateNormal];
                            subImgButton.titleLabel.font = [UIFont systemFontOfSize:12];
//                        }
                        isClear = false;
                    }
                    if (subModel.displayTitle!= nil && [subModel.displayTitle isEqualToString:@"0"]) {
                        [subImgButton setImage:[ImageBundle imagewithBundleName:@"zs_xg"] forState:UIControlStateNormal];
                        [subImgButton setTitle:@"" forState:UIControlStateNormal];
                        isClear = false;
                    }else if (subModel.displayTitle!= nil && ![subModel.displayTitle isEqualToString:@"0"]){
                        [subImgButton setImage:nil forState:UIControlStateNormal];
                        [subImgButton setTitle:subModel.displayTitle forState:UIControlStateNormal];
                        [subImgButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
                        subImgButton.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
                        isClear = false;
                    }
                    if (indexPath.row == self.dataArrays.count-1 && subModel.yIndex == subArr.count-1) {
                        if (self.blinkCount>0) {
                            self.blinkButton = subImgButton;
                            [self isblinkAction];
                        }
                    }
                    
                    break;
                }
            }
        }
//        if (isClear) {
//            [subImgButton setBackgroundImage:nil forState:UIControlStateNormal];
//            [subImgButton setImage:nil forState:UIControlStateNormal];
//            [subImgButton setTitle:@"" forState:UIControlStateNormal];
//        }
//
    }
    

   
    return cell;
}

-(void)isblinkAction{
    if (self.blinkButton) {
        self.blinkButton.hidden=!self.blinkButton.hidden;
        if (self.blinkCount>0) {
            [self performSelector:@selector(isblinkAction) withObject:nil afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
            self.blinkCount--;
        }else{
            self.blinkButton.hidden = NO;
        }
    }
    
    
}

-(void)loadData
{
    if (self.typeLottery == 26||self.typeLottery == 27) {
        NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getOpenAwardList&lottery_type=%ld&type=4",self.typeLottery];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES andParameter:@{@"page":minnum(0)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSLog(@"xxxxxxxxx%@",info);
            if(code == 0)
            {
               
               NSArray *datas = [info objectForKey:@"list"];
               if ([datas isKindOfClass:[NSArray class]]) {
                   strongSelf.resultDatas = [lastResultModel mj_objectArrayWithKeyValuesArray:[info objectForKey:@"list"]];
                   if ([strongSelf.resultDatas isKindOfClass:[NSArray class]]) {
                       strongSelf.resultDatas = [NSMutableArray arrayWithArray:[[strongSelf.resultDatas reverseObjectEnumerator] allObjects]];
                       [strongSelf sortDatas:strongSelf.resultDatas];
                   }
               }
               
            }
        } fail:^(NSError * _Nonnull error) {
            [MBProgressHUD showError:YZMsg(@"public_networkError")];
        }];
    }else{
        NSString *getOpenHistoryUrl = [NSString stringWithFormat:@"Lottery.getOpenHistory&uid=%@&token=%@&lottery_type=%@",[Config getOwnID],[Config getOwnToken], [NSString stringWithFormat:@"%ld", (long)self.typeLottery]];
        WeakSelf
        [[YBNetworking sharedManager] postNetworkWithUrl:getOpenHistoryUrl withBaseDomian:YES andParameter:@{@"page":minnum(0)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if(code == 0 && [info isKindOfClass:[NSDictionary class]])
            {
                NSLog(@"%@",info);
                
                strongSelf.resultDatas = [lastResultModel mj_objectArrayWithKeyValuesArray:[info objectForKey:@"list"]];
                if ([strongSelf.resultDatas isKindOfClass:[NSArray class]]) {
                    strongSelf.resultDatas = [NSMutableArray arrayWithArray:[[strongSelf.resultDatas reverseObjectEnumerator] allObjects]];
                    [strongSelf sortDatas:strongSelf.resultDatas];
                }
            }
        } fail:^(NSError * _Nonnull error) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            
        }];
        
    }
    
    
}

//0 不显示 1红色 2 蓝色 3绿色 displayType
//豹1 豹6 0斜杠显示 displayTitle
//xIndex yIndex
-(void)sortDatas:(NSMutableArray*)arrayssss
{
    NSMutableArray *contentIndexA = [NSMutableArray array];
    [self.dataArrays removeAllObjects];
    ChartModel *lastModel = nil;
    
    for (int i = 0; i<arrayssss.count; i++) {
        lastResultModel *subMo = arrayssss[i];
        ChartModel *model = [ChartModel new];
        [self updateModelData:model resultmodel:subMo lastModel:lastModel index:i];
        
        if (model == nil) {
            continue;
        }
        if(lastModel == nil){
            model.rootIndex = 0;
            model.xIndex = 0;
            model.yIndex = 0;
            
        }else if (model.displayType == lastModel.displayType) {
            model.rootIndex = lastModel.rootIndex;
            if (model.displayType!= 0 && lastModel.xIndex==lastModel.rootIndex) {
                if (lastModel.yIndex<5) {
                    model.xIndex=  lastModel.xIndex;
                    model.yIndex = lastModel.yIndex+1;
                    NSString *xySt = [NSString stringWithFormat:@"%d,%d",model.xIndex,model.yIndex];
                    if ([contentIndexA containsObject:xySt]) {
                        model.xIndex=  lastModel.xIndex+1;
                        model.yIndex = lastModel.yIndex;
                    }
                }else{
                    model.xIndex = lastModel.xIndex+1;
                    model.yIndex = lastModel.yIndex;
                }
            }else{
                model.xIndex = lastModel.xIndex+1;
                model.yIndex = lastModel.yIndex;
            }
            
        }else if(model.displayType!= 0 &&  model.displayType!= lastModel.displayType){
            model.rootIndex = lastModel.rootIndex+1;
            model.xIndex = model.rootIndex;
            model.yIndex = 0;
        }
        
        NSMutableArray *lastArray = nil;
        if (self.dataArrays.count>model.xIndex) {
            lastArray = self.dataArrays[model.xIndex];
        }else{
            lastArray = [NSMutableArray arrayWithCapacity:6];
            [self.dataArrays addObject:lastArray];
        }
        if (model.displayTitle != nil) {
            
        }else{
            if (model.displayTitle == nil && model.displayType == 0) {
                continue;
            }
            [lastArray addObject:model];
            [contentIndexA addObject:[NSString stringWithFormat:@"%d,%d", model.xIndex,model.yIndex]];
            lastModel = model;
        }
        
    }
    
    
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    NSInteger countsn = [self.collectionView numberOfItemsInSection:0];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:countsn-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}


-(void)scrollToRight{
    if (self.collectionView) {
        NSInteger countsn = [self.collectionView numberOfItemsInSection:0];
        if (countsn>0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:countsn-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
            });
           
        }
    }
}

-(void)updateModelData:(ChartModel*)model resultmodel:(lastResultModel*)subMod lastModel:(ChartModel*)lastModel index:(int)i
{
    if (self.typeLottery == 30) {
        NSString *openresult11 = subMod.open_result;
        NSInteger openResu = [openresult11 integerValue];
        if (self.switchLotteryType == 0) { // 大小
            if (openResu>0 && openResu<19) {
                model.displayType = 2; //小
                model.showTitle = YZMsg(@"lottery_trend_xiao");
            }else if(openResu>18){
                model.displayType = 1; //大
                model.showTitle = YZMsg(@"lottery_trend_da");
            }else if(openResu == 0){
                if (lastModel) {
                    lastModel.displayTitle = @"0";
                }else {
                    if (i==0) {
                        model = nil;
                    }
                }
            }
        }else if (self.switchLotteryType == 1) {
            if (openResu==1 ||openResu== 3 ||openResu==4 ||openResu==5  ||openResu== 7||openResu== 9||openResu== 12||openResu== 14||openResu== 16||openResu== 18||openResu== 21||openResu== 23||openResu== 25||openResu== 27||openResu== 30||openResu== 32||openResu== 34||openResu== 36) {
                model.displayType = 1; //红
                model.showTitle = YZMsg(@"lottery_trend_hong");
            }else if(openResu == 0){
                if (lastModel) {
                    lastModel.displayTitle = @"0";
                }else{
                    if (i==0) {
                        model = nil;
                    }
                }
            }else{
                model.displayType = 2; //黑
                model.showTitle = YZMsg(@"lottery_trend_hei");
               
            }
        }else if (self.switchLotteryType == 2) {
            if (openResu>=1 && openResu<=12) {
                model.displayType = 2; //区间
                model.showTitle = YZMsg(@"lottery_trend_lan");
            }else if (openResu>=13 && openResu<=24) {
                model.displayType = 3; //区间
                model.showTitle = YZMsg(@"lottery_trend_lv");
            }else if(openResu>=25 && openResu<=36){
                model.displayType = 1; //区间
                model.showTitle = YZMsg(@"lottery_trend_hong");
            }else if(openResu == 0){
                if (lastModel) {
                    lastModel.displayTitle = @"0";
                }else{
                    if (i==0) {
                        model = nil;
                    }
                }
            }
        }
    }else if(self.typeLottery == 26||self.typeLottery == 27){
        
        if (self.switchLotteryType == 0) { // 大小
            NSArray *result_data = subMod.results_data_zh;
            if (result_data.count>2) {
                NSString *restStr = result_data[2];
                
                if ([restStr isEqualToString:@"大"]) {
                    model.displayType = 1; //大
                    model.showTitle = YZMsg(@"lottery_trend_da");
                }else if([restStr isEqualToString:@"小"]){
                    model.displayType = 2; //大
                    model.showTitle = YZMsg(@"lottery_trend_xiao");
                }
                if ([subMod.open_result isEqualToString:@"1,1,1"]) {
                    if (lastModel) {
                        lastModel.displayTitle = @"1";
                        model.displayType = 0; //不显示
                    }else{
                        if (i==0) {
                            model = nil;
                        }
                    }
                  
                }else if([subMod.open_result isEqualToString:@"6,6,6"]){
                    if (lastModel) {
                        lastModel.displayTitle = @"6";
                        model.displayType = 0; //不显示
                    }else{
                        if (i==0) {
                            model = nil;
                        }
                    }
                  
                }
            }else{
                if ([subMod.open_result isEqualToString:@"1,1,1"]) {
                    if (lastModel) {
                        lastModel.displayTitle = @"1";
                        model.displayType = 0; //不显示
                    }else{
                        if (i==0) {
                            model = nil;
                        }
                    }
                 
                }else if([subMod.open_result isEqualToString:@"6,6,6"]){
                    if (lastModel) {
                        lastModel.displayTitle = @"6";
                        model.displayType = 0; //不显示
                    }else{
                        if (i==0) {
                            model = nil;
                        }
                    }
                   
                }
            }
            
        }else if (self.switchLotteryType == 1) {
            NSArray *result_data = subMod.results_data_zh;
            if (result_data.count>2) {
                NSString *restStr = result_data[1];
                
                if ([restStr isEqualToString:@"单"]) {
                    model.displayType = 1; //大
                    model.showTitle = YZMsg(@"lottery_trend_dan");
                }else if([restStr isEqualToString:@"双"]){
                    model.displayType = 2; //大
                    model.showTitle = YZMsg(@"lottery_trend_shuang");
                }
                if ([subMod.open_result isEqualToString:@"1,1,1"]) {
                    if (lastModel) {
                        lastModel.displayTitle = @"1";
                        model.displayType = 0; //不显示
                    }else {
                        if (i==0) {
                            model = nil;
                        }
                    }
                   
                }else if([subMod.open_result isEqualToString:@"6,6,6"]){
                    if (lastModel) {
                        lastModel.displayTitle = @"6";
                        model.displayType = 0; //不显示
                    }else {
                        if (i==0) {
                            model = nil;
                        }
                    }
                    
                }
            }else{
                if ([subMod.open_result isEqualToString:@"1,1,1"]) {
                    if (lastModel) {
                        lastModel.displayTitle = @"1";
                        model.displayType = 0; //不显示
                    }else {
                        if (i==0) {
                            model = nil;
                        }
                    }
                }else if([subMod.open_result isEqualToString:@"6,6,6"]){
                    if (lastModel) {
                        lastModel.displayTitle = @"6";
                        model.displayType = 0; //不显示
                    }else {
                        if (i==0) {
                            model = nil;
                        }
                    }
                }
            }
        }
    }else if(self.typeLottery == 28){
        NSString *openresult = subMod.open_result_zh;
        if ([openresult rangeOfString:@"闲胜"].location!=NSNotFound) {
            model.displayType = 2; //小
            model.showTitle = YZMsg(@"lottery_trend_xian");
        }else if ([openresult rangeOfString:@"庄胜"].location!=NSNotFound) {
            model.displayType = 1; //大
            model.showTitle = YZMsg(@"lottery_trend_zhuang");
        }else if([openresult rangeOfString:@"和"].location!=NSNotFound){
            if (lastModel) {
                lastModel.displayTitle = @"0";
            }else {
                if (i==0) {
                    model = nil;
                }
            }
        }
    }else if(self.typeLottery == 31){
        NSString *openresult = subMod.open_result_zh;
        if ([openresult rangeOfString:@"龙"].location!=NSNotFound) {
            model.displayType = 2; //小
            model.showTitle = YZMsg(@"lottery_trend_long");
        }else if ([openresult rangeOfString:@"虎"].location!=NSNotFound) {
            model.displayType = 1; //大
            model.showTitle = YZMsg(@"lottery_trend_hu");
        }else if([openresult rangeOfString:@"和"].location!=NSNotFound){
            if (lastModel) {
                lastModel.displayTitle = @"0";
            }else {
                if (i==0) {
                    model = nil;
                }
            }
        }
    }else if(self.typeLottery == 29){
        NSString *openresult = subMod.open_result;
        if ([openresult rangeOfString:@"玩家一"].location!=NSNotFound) {
            model.displayType = 2; //区间
            model.showTitle = YZMsg(@"lottery_trend_lan");
        }else if ([openresult rangeOfString:@"玩家二"].location!=NSNotFound) {
            model.displayType = 3; //区间
            model.showTitle = YZMsg(@"lottery_trend_ning");
        }else if([openresult rangeOfString:@"玩家三"].location!=NSNotFound){
            model.displayType = 1; //区间
            model.showTitle = YZMsg(@"lottery_trend_ying");
        }
    }else if(self.typeLottery == 10){
        NSString *openresult = subMod.open_result_another;
        if ([openresult rangeOfString:@"蓝方"].location!=NSNotFound) {
            model.displayType = 2; //区间
            model.showTitle = YZMsg(@"lottery_trend_lan");
        }else if ([openresult rangeOfString:@"红方"].location!=NSNotFound) {
            model.displayType = 1; //区间
            model.showTitle = YZMsg(@"lottery_trend_hong");
        }else{
            model.displayType = 0; //区间
        }
    }else if(self.typeLottery == 8 ||self.typeLottery == 7 || self.typeLottery == 32){
        NSArray *resultArray = [subMod.open_result componentsSeparatedByString:@","];
        NSInteger numberLast = [resultArray.lastObject integerValue];
       
        if (self.switchLotteryType == 0) {//大小
            if (numberLast<=24) {
                model.displayType = 2; //小
                model.showTitle = YZMsg(@"lottery_trend_xiao");
            }else if(numberLast>=25)
            {
                model.displayType = 1; //大
                model.showTitle = YZMsg(@"lottery_trend_da");
            }
        }else if(self.switchLotteryType == 1){//单双
            if (numberLast%2 == 0) {//双
                model.displayType = 2;
                model.showTitle = YZMsg(@"lottery_trend_shuang");
            }else{//单
                model.displayType = 1;
                model.showTitle = YZMsg(@"lottery_trend_dan");
            }
        }else if(self.switchLotteryType == 2){//色
            NSInteger iNumber = numberLast;
            // 红波：01-02-07-08-12-13-18-19-23-24-29-30-34-35-40-45-46
            if(iNumber == 1 || iNumber == 2 || iNumber == 7 || iNumber == 8 || iNumber == 12 || iNumber == 13 || iNumber == 18 || iNumber == 19 || iNumber == 23 || iNumber == 24 || iNumber == 29 || iNumber == 30 || iNumber == 34 || iNumber == 35 || iNumber == 40 || iNumber == 45 || iNumber == 46){
                model.displayType = 1;
                model.showTitle = YZMsg(@"lottery_trend_hong");
            }
            // 蓝波：03-04-09-10-14-15-20-25-26-31-36-37-41-42-47-48
            else if(iNumber == 3 || iNumber == 4 || iNumber == 9 || iNumber == 10 || iNumber == 14 || iNumber == 15 || iNumber == 20 || iNumber == 25 || iNumber == 25 || iNumber == 26 || iNumber == 31 || iNumber == 36 || iNumber == 37 || iNumber == 41 || iNumber == 42 || iNumber == 47 || iNumber == 48){
                model.displayType = 2;
                model.showTitle = YZMsg(@"lottery_trend_lan");
            }
            // 绿波：05-06-11-16-17-21-22-27-28-32-33-38-39-43-44-49
            else if(iNumber == 5 || iNumber == 6 || iNumber == 11 || iNumber == 16 || iNumber == 17 || iNumber == 21 || iNumber == 22 || iNumber == 27 || iNumber == 28 || iNumber == 32 || iNumber == 33 || iNumber == 38 || iNumber == 39 || iNumber == 43 || iNumber == 44 || iNumber == 49){
                model.displayType = 3;
                model.showTitle = YZMsg(@"lottery_trend_lv");
            }
        }
    }else if (self.typeLottery == 14){
        NSArray *resultArray = [subMod.open_result componentsSeparatedByString:@","];
        NSInteger numberLast = [resultArray.firstObject integerValue];
       
        if (self.switchLotteryType == 0) {//大小
            if (numberLast<=5) {
                model.displayType = 2; //小
                model.showTitle = YZMsg(@"lottery_trend_xiao");
            }else
            {
                model.displayType = 1; //大
                model.showTitle = YZMsg(@"lottery_trend_da");
            }
        }else if(self.switchLotteryType == 1){//单双
            if (numberLast%2 == 0) {//双
                model.displayType = 2;
                model.showTitle = YZMsg(@"lottery_trend_shuang");
            }else{//单
                model.displayType = 1;
                model.showTitle = YZMsg(@"lottery_trend_dan");
            }
        }
        
    }else if (self.typeLottery == 11||self.typeLottery == 6){
        NSArray *resultArray = [subMod.open_result componentsSeparatedByString:@","];
        NSInteger numberAll = 0;
        for (NSString *strNum in resultArray) {
            NSInteger numberLast = [strNum integerValue];
            numberAll=numberAll+numberLast;
        }
        if (self.switchLotteryType == 0) {//大小
            if (numberAll<=22) {
                model.displayType = 2; //小
                model.showTitle = YZMsg(@"lottery_trend_xiao");
            }else
            {
                model.displayType = 1; //大
                model.showTitle = YZMsg(@"lottery_trend_da");
            }
        }else if(self.switchLotteryType == 1){//单双
            if (numberAll%2 == 0) {//双
                model.displayType = 2;
                model.showTitle = YZMsg(@"lottery_trend_shuang");
            }else{//单
                model.displayType = 1;
                model.showTitle = YZMsg(@"lottery_trend_dan");
            }
        }
        
    }
    
}

-(void)updateChartData:(NSString*)result
{

    if (self.resultDatas!= nil && self.resultDatas.count>0) {
        self.blinkCount = 8;
        if (self.typeLottery == 30) {
            lastResultModel *latRest = [lastResultModel new];
            latRest.open_result = result;
            [self.resultDatas addObject:latRest];
            [self sortDatas:self.resultDatas];
        }else if(self.typeLottery == 26||self.typeLottery == 27){
            lastResultModel *latRest = [lastResultModel new];
//            4-10 小 11-17 大
//            累加单双
            NSArray *arrayNum = [result componentsSeparatedByString:@","];
            NSMutableArray *resultOpen = [NSMutableArray array];
            if (arrayNum.count>2) {
                int amount = [arrayNum[0] intValue]+[arrayNum[1] intValue]+[arrayNum[2] intValue];
                [resultOpen addObject:@(amount)];
                
                
                if (amount%2 == 0) {
                    [resultOpen addObject:@"双"];
                }else{
                    [resultOpen addObject:@"单"];
                }
                
                if (amount>=4&& amount<=10) {
                    [resultOpen addObject:@"小"];
                }else if(amount>=11 && amount<=17){
                    [resultOpen addObject:@"大"];
                }else{
                    [resultOpen addObject:@"豹子"];
                }
                latRest.open_result = result;
                latRest.results_data_zh = resultOpen;
                [self.resultDatas addObject:latRest];
                [self sortDatas:self.resultDatas];
            }
            
        }else if(self.typeLottery == 28){
            lastResultModel *latRest = [lastResultModel new];
            latRest.open_result_zh = result;
            [self.resultDatas addObject:latRest];
            [self sortDatas:self.resultDatas];
        }else if(self.typeLottery == 29){
            lastResultModel *latRest = [lastResultModel new];
            latRest.open_result = result;
            [self.resultDatas addObject:latRest];
            [self sortDatas:self.resultDatas];
        }else if(self.typeLottery == 31){
            lastResultModel *latRest = [lastResultModel new];
            latRest.open_result_zh = [result stringByReplacingOccurrencesOfString:@"龙虎_" withString:@""];
            [self.resultDatas addObject:latRest];
            [self sortDatas:self.resultDatas];
        }else if(self.typeLottery == 10){
            lastResultModel *latRest = [lastResultModel new];
            latRest.open_result_another = result;
            [self.resultDatas addObject:latRest];
            [self sortDatas:self.resultDatas];
        }else if(self.typeLottery == 14){
            lastResultModel *latRest = [lastResultModel new];
            latRest.open_result = result;
            [self.resultDatas addObject:latRest];
            [self sortDatas:self.resultDatas];
        }else if(self.typeLottery == 11||self.typeLottery == 6||self.typeLottery == 8 ||self.typeLottery == 7 ||self.typeLottery == 32){
            lastResultModel *latRest = [lastResultModel new];
            latRest.open_result = result;
            [self.resultDatas addObject:latRest];
            [self sortDatas:self.resultDatas];
        }
    }
    
}

@end
