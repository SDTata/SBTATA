//
//  RankVC.m
//  yunbaolive
//
//  Created by YunBao on 2018/2/1.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "RankVC.h"

#import "RankModel.h"
#import "RankCell.h"
#import "otherUserMsgVC.h"
#import "UIImageView+WebCache.h"
#import "LiveGifImage.h"
#import "EnterLivePlay.h"
@interface RankVC ()<UITableViewDelegate,UITableViewDataSource> {
    UISegmentedControl *segment1;    //收益榜、消费榜榜
    //UILabel *line1;                  //收益榜下划线
    //UILabel *line2;                  //消费榜榜下划线
    int paging;
    NSArray *oneArr;                  //收益-消费
    NSArray *twoArr;                  //日-周-月-总
    NSMutableArray *btnArray;        //日-周-月-总 按钮数组
    int selectTypeIndex;
    UIImageView  *tableHeaderView;
    YBNoWordView *noNetwork;
    MBProgressHUD *hud;
    UIImageView  *segmentBg;
    UIView  *line;

}
@property (nonatomic,strong) UITableView *tableView;
//@property (nonatomic,strong) NSArray *models;
@property (nonatomic,strong) NSMutableArray *dataArray;
// 投注区  今日注单
@property (nonatomic,strong) NSMutableArray *masonryFBtnArray;
//  选中按钮
@property (nonatomic,strong) UIButton *selectedButton;


@end

@implementation RankVC

-(void)pullData:(BOOL)show {
    if (paging == 1 && show) {
        hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        [hud hideAnimated:YES afterDelay:10];
    }
    NSString *postUrl =oneArr[self.selectedButton.tag -100];
    NSDictionary *postDic = @{@"uid":[Config getOwnID],
                              @"type":twoArr[selectTypeIndex],
                              @"p":@(paging)
                              };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:postUrl withBaseDomian:NO andParameter:postDic data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->hud hideAnimated:YES];
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        strongSelf->noNetwork.hidden = YES;
        strongSelf.tableView.hidden = NO;
        if (code == 0) {
            NSArray *infoA = info;
            if (strongSelf->paging == 1) {
                [strongSelf.dataArray removeAllObjects];
            }
            [strongSelf.dataArray addObjectsFromArray:infoA];
            if (infoA.count <=10) {
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [strongSelf.tableView reloadData];
            if (strongSelf->paging == 1) {
                [strongSelf resetTableHeaderView];
            }
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^(id fail) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf->hud hideAnimated:YES];
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        if (strongSelf.dataArray.count == 0) {
            strongSelf->noNetwork.hidden = NO;
            strongSelf.tableView.hidden = YES;
        }
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@1100",YZMsg(@"public_networkError")]];

    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height - 20;
//    CGFloat naviHeight = _window_width/75*21 > 105 ?  _window_width/75*21 + _window_width/75*52 + statusHeight :105 + _window_width/75*52 + statusHeight + 30;
//    UIImageView *  bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, naviHeight, _window_width, 80)];
//    bg.image = [ImageBundle imagewithBundleName:@""];
//    [self.view addSubview: bg];
//    
//    UIImageView *  tabBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, naviHeight, _window_width, 800)];
//    tabBg.backgroundColor = RGB(230, 230, 230);
//    tabBg.layer.masksToBounds = YES;
//    tabBg.layer.cornerRadius = 20;
//    [self.view addSubview: tabBg];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [NSMutableArray array];
    oneArr = @[@"Home.profitList",@"Home.consumeList"];
    twoArr = @[@"day",@"yesterday",@"week",@"month"];
    //[self creatNavi];
    
    paging = 1;
    [self.view addSubview:self.tableView];
    [self creatTableHeaderView];
    WeakSelf
    noNetwork = [[YBNoWordView alloc]initWithImageName:NULL andTitle:NULL withBlock:^(id  _Nullable msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf pullData:NO];
    } AddTo:self.view];
    [self pullData:YES];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - UISegmentedControl
- (void)segmentChange:(UISegmentedControl *)seg{
    /*
    if (segment1.selectedSegmentIndex == 0) {
        line1.hidden = NO;
        line2.hidden = YES;
    }else if (segment1.selectedSegmentIndex == 1){
        line1.hidden = YES;
        line2.hidden = NO;
    }
     */
    paging = 1;
    [self pullData:YES];
}
-(UIImage *)drawBckgroundImage:(CGFloat)r :(CGFloat)g :(CGFloat)b {
    CGSize size = CGSizeMake(2, 35);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, r/255.0, g/255.0, b/255.0, 1);
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
#pragma mark -
#pragma mark - 点击事件
-(void)clickFollowBtn:(UIButton *)btn {
    
    btn.enabled = NO;
    RankModel *model = [[RankModel alloc] initWithDic:[_dataArray objectAtIndex:btn.tag - 10085]];
    if ([model.uidStr isEqual:[Config getOwnID]]) {
        [MBProgressHUD showError:YZMsg(@"RankVC_FollowMeError")];
        btn.enabled = YES;
        return;
    }
    NSString *postUrl = @"User.setAttent";
    NSDictionary *postDic = @{@"uid":[Config getOwnID],
                              @"touid":model.uidStr,
                              @"is_follow":minnum(!btn.selected)
                              };
    WeakSelf
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    [[YBNetworking sharedManager] postNetworkWithUrl:postUrl withBaseDomian:NO andParameter:postDic data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        [hud hideAnimated:YES];
        if (strongSelf == nil) {
            return;
        }
        btn.enabled = YES;
        if (code == 0) {
            NSString *isAtt = YBValue([info firstObject], @"isattent");
            NSMutableDictionary *needReloadDic = [NSMutableDictionary dictionaryWithDictionary:strongSelf.dataArray[btn.tag - 10085]];
            [needReloadDic setValue:isAtt forKey:@"isAttention"];
            
            if (strongSelf.dataArray) {
                NSMutableArray *m_arr = [NSMutableArray arrayWithArray:strongSelf.dataArray];
                [m_arr replaceObjectAtIndex:(btn.tag - 10085) withObject:needReloadDic];
                strongSelf.dataArray = m_arr;
            }
            if (btn.tag >= 10088) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:(btn.tag - 10088) inSection:0];
                [strongSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }else{
                btn.selected = !btn.selected;
                if ([isAtt isEqual:@"0"]) {
                    [btn setTitle:YZMsg(@"RankCell_FollowButton") forState:UIControlStateNormal];
                }else {
                    [btn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
                }
            }
        }else{
            [MBProgressHUD showError:msg];
        }
        
    } fail:^(id fail) {
        [hud hideAnimated:YES];
        btn.enabled = YES;
    }];
    
}
#pragma mark -
#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 ) {
        return 0.01;
    }
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [UIView new];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0) {
//        return (_window_width*2/3*296/626 + 50);
//    }
    return 75;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count <= 3) {
        return 0;
    }
    return self.dataArray.count-3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
  
    RankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
    if (!cell) {
        cell=[[[XBundle currentXibBundleWithResourceName:@"RankCell"] loadNibNamed:@"RankCell" owner:self options:nil] firstObject];
        cell.iconIV.layer.masksToBounds = YES;
        cell.iconIV.layer.cornerRadius = 20;
        cell.countryImg.layer.masksToBounds = YES;
        cell.countryImg.layer.cornerRadius = 8;
    }
    RankModel *model = [[RankModel alloc] initWithDic:[_dataArray objectAtIndex:indexPath.row+3]];
      
    //收益榜-0 消费榜-1
    if (self.selectedButton.tag ==100) {
        model.type = @"0";
    }else{
        model.type = @"1";
    }
    cell.otherMCL.text = [NSString stringWithFormat:@"%ld",indexPath.row+4];
    cell.model = model;
    cell.isRich = NO;
    cell.backgroundColor = RGB(245, 245, 245);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_dataArray.count>indexPath.row) {
        NSDictionary *subDic = [_dataArray objectAtIndex:indexPath.row+3];
        RankModel *model = [[RankModel alloc] initWithDic:subDic];
        [self pushUserMessageVC:model];
    }else{
        [MBProgressHUD showError:YZMsg(@"RankVC_Empty")];
    }
}

#pragma mark -
#pragma mark - tableView
-(UITableView *)tableView {
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height+([UIApplication sharedApplication].statusBarFrame.size.height)) style:UITableViewStyleGrouped];
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor =  RGB(245, 245, 245);

        WeakSelf
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (strongSelf == nil) {
                return;
            }
            strongSelf->paging = 1;
            [strongSelf pullData:NO];
        }];
        ((MJRefreshNormalHeader*)_tableView.mj_header).stateLabel.textColor = [UIColor blackColor];
        ((MJRefreshNormalHeader*)_tableView.mj_header).arrowView.tintColor = [UIColor blackColor];
        ((MJRefreshNormalHeader*)_tableView.mj_header).activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        ((MJRefreshNormalHeader*)_tableView.mj_header).lastUpdatedTimeLabel.textColor = [UIColor blackColor];
    
        _tableView.mj_footer.hidden = false;
//        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//            STRONGSELF
//            if (strongSelf == nil) {
//                return;
//            }
//            strongSelf->paging +=1;
//            [strongSelf pullData:NO];
//        }];
        //[_tableView.mj_header setBackgroundColor:RGB_COLOR(@"#feca2e", 1)];
    }
    return _tableView;
}
- (void)resetTableHeaderView{
    /*
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0 - navi.height, _window_width, _window_width/75*52)];
    headerImgView.userInteractionEnabled = YES;
    headerImgView.image = [ImageBundle imagewithBundleName:@"syb_bj"];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    */
    if (_dataArray.count > 2) {
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:_dataArray[0] andNum:1]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:_dataArray[1] andNum:2]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:_dataArray[2] andNum:3]];
    }else if (_dataArray.count == 2) {
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:_dataArray[0] andNum:1]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:_dataArray[1] andNum:2]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    }else if (_dataArray.count == 1) {
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:_dataArray[0] andNum:1]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    }else{
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
        [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    }
    
    for (UIButton *button in btnArray) {
        [tableHeaderView bringSubviewToFront:button];
    }
    //_tableView.tableHeaderView = tableHeaderView;

}
#pragma mark - navi
-(void)creatTableHeaderView {
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height - 20;
    CGFloat naviHeight = _window_width/75*21 > 105 ?  _window_width/75*21 + _window_width/75*52 + statusHeight :105 + _window_width/75*52 + statusHeight + 40;
    tableHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, naviHeight)];
    tableHeaderView.userInteractionEnabled = YES;
    tableHeaderView.backgroundColor = RGB(245, 245, 245);
    tableHeaderView.image = [ImageBundle imagewithBundleName:@"phb_di"];
    
    UIImageView *  rankBg = [[UIImageView alloc]initWithFrame:CGRectMake(15, naviHeight - 110, _window_width -30, 90)];
    rankBg.userInteractionEnabled = YES;
    rankBg.image = [ImageBundle imagewithBundleName:@"phb_mc"];
    [tableHeaderView addSubview: rankBg];
    
    UIImageView *  tabBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, naviHeight -20, _window_width, 20)];
    tabBg.backgroundColor =  RGB(245, 245, 245);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:tabBg.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = tabBg.bounds;
    maskLayer.path = maskPath.CGPath;
    tabBg.layer.mask = maskLayer;
    [tableHeaderView addSubview: tabBg];
//
    //[self.view addSubview:navi];
//    NSArray *sgArr1 = [NSArray arrayWithObjects:YZMsg(@"RankVC_profit_list"),YZMsg(@"RankVC_contribution_list"), nil];
//    segment1 = [[UISegmentedControl alloc]initWithItems:sgArr1];
//    segment1.apportionsSegmentWidthsByContent = YES;
//    segment1.frame = CGRectMake((_window_width-230)/2, 27 + statusHeight, 230, 30);
//    segment1.tintColor = [UIColor clearColor];
//    NSDictionary *nomalC = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium],NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName, nil];
//    [segment1 setTitleTextAttributes:nomalC forState:UIControlStateNormal];
//
//    NSDictionary *selC = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium],NSFontAttributeName,RGB(0, 126,221), NSForegroundColorAttributeName, nil];
//    [segment1 setTitleTextAttributes:selC forState:UIControlStateSelected];
//    segment1.selectedSegmentIndex = 0;
//    [segment1 addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
//    [tableHeaderView addSubview:segment1];
    
    UIImageView * segmentBg = [[UIImageView alloc] initWithFrame:CGRectMake((_window_width-230)/2, 27 + statusHeight, 230, 30)];
    segmentBg.image = [ImageBundle imagewithBundleName:@"phb_bt1bg"];
    segmentBg.userInteractionEnabled = YES;
    [tableHeaderView addSubview:segmentBg];

    _masonryFBtnArray = [NSMutableArray array];
    NSArray *sgArr1 = [NSArray arrayWithObjects:YZMsg(@"RankVC_profit_list"),YZMsg(@"RankVC_contribution_list"), nil];
    for (int i = 0; i < sgArr1.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:sgArr1[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor]  forState:UIControlStateDisabled];
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [button addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake( 115*i, 0, 115, 30);
        button.tag = i + 100;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 15;
        [segmentBg addSubview:button];
        [_masonryFBtnArray addObject:button];
        if (i == 0) {
            self.selectedButton = button;
            self.selectedButton.backgroundColor = [UIColor whiteColor];
            self.selectedButton.enabled = NO;
        }
    }
    /*
    line1 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-80+25, segment1.bottom, 30, 3)];
    line1.backgroundColor = [UIColor whiteColor];
    line1.hidden = NO;
    line1.layer.cornerRadius = 1.5;
    line1.layer.masksToBounds  =YES;
    [tableHeaderView addSubview:line1];
    line2 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-80+25+80, segment1.bottom, 30, 3)];
    line2.backgroundColor = [UIColor whiteColor];
    line2.layer.cornerRadius = 1.5;
    line2.layer.masksToBounds  =YES;
    line2.hidden = YES;
    [tableHeaderView addSubview:line2];
     */
    btnArray = [NSMutableArray array];
    NSArray *sgArr2 = [NSArray arrayWithObjects:YZMsg(@"RankVC_List_of_day"),YZMsg(@"RankVC_Yesterday_the_list"),YZMsg(@"RankVC_List_of_Week"),YZMsg(@"RankVC_List_of_Month"), nil];
    CGFloat speace = (_window_width*0.84 - 60*4)/3;
    for (int i = 0; i < sgArr2.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(_window_width*0.08+i*(60+speace), segmentBg.bottom+15, 60, 24);
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumScaleFactor=0.6;
        [btn setTitle:sgArr2[i] forState:0];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.tag = 1000086+i;
        if (i == 0) {
            line = [[UILabel alloc]initWithFrame:CGRectMake(btn.left + 15, btn.bottom +3 , 30, 3)];
            line.backgroundColor = [UIColor whiteColor];
            line.layer.cornerRadius = 1.5;
            line.layer.masksToBounds  =YES;
            [tableHeaderView addSubview:line];
        }
        [btn addTarget:self action:@selector(changeRankType:) forControlEvents:UIControlEventTouchUpInside];
        [tableHeaderView addSubview:btn];
        [btnArray addObject:btn];
    }
    

    
    UIButton *returnBtn = [UIButton buttonWithType:0];
    returnBtn.frame = CGRectMake(0, 24 + statusHeight, 40, 40);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"person_back_white"] forState:0];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [tableHeaderView addSubview:returnBtn];
    [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
    [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
    [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    _tableView.tableHeaderView = tableHeaderView;
//    _tableView.tableHeaderView.backgroundColor = [UIColor blueColor];
//    _tableView.tableFooterView.backgroundColor = [UIColor orangeColor];

}
/*
- (void)creatTableHeaderView{
    UIImageView *headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0 - navi.height, _window_width, _window_width/75*52)];
    headerImgView.userInteractionEnabled = YES;
    headerImgView.image = [ImageBundle imagewithBundleName:@"rank_bottom"];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
    [headerImgView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    _tableView.tableHeaderView = headerImgView;
}
 */
- (UIView *)creatTopCellWithUserMsg:(NSDictionary *)dic andNum:(int)num{
    CGFloat statusHeight = 0;
    UIView *view = [[UIView alloc]init];
    CGFloat width;
    UITapGestureRecognizer *tap;
    for (UIView *sub in tableHeaderView.subviews) {
        if (sub.tag == 1010 + num) {
            [sub removeFromSuperview];
        }
    }
    if (num == 1) {
        width = (_window_width - 14 -30)/3.0;
        view.frame = CGRectMake(_window_width/2-width/2, 105 + statusHeight, width,40+  tableHeaderView.height - _window_width/75*21);
        view.tag = 1011;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num1Click:)];
    }
    if (num == 2) {
        width = (_window_width - 14 -30)/3.0;
        view.frame = CGRectMake(15, 105+ statusHeight, width, 40+ tableHeaderView.height - _window_width/75*21);
        view.tag = 1012;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num2Click:)];
        
    }
    if (num == 3) {
        width = (_window_width - 14 -30)/3.0;
        view.frame = CGRectMake(_window_width-width-15, 105 + statusHeight, width,40+ tableHeaderView.height - _window_width/75*21);
        view.tag = 1013;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num3Click:)];
        
    }
    //view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5.0;
    view.layer.masksToBounds = YES;
//    UIImageView *numImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 15, 24)];
//    numImgView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"rank_num%d",num]];
//    numImgView.contentMode = UIViewContentModeScaleAspectFit;
//    [view addSubview:numImgView];
    //[view addGestureRecognizer:tap];
    if (dic) {
        //头像边框
//        UIImageView *headerImgView = [[UIImageView alloc]init];
//        headerImgView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"rank_header%d",num]];
        //头像
        UIImageView *iconImgView = [[UIImageView alloc]init];
        iconImgView.userInteractionEnabled = YES;
        [iconImgView addGestureRecognizer:tap];
        //名字
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = RGB(254, 254, 254);
        NSString * region = minstr([dic valueForKey:@"region_icon"]);
        if ([region isKindOfClass:[NSNull class]] || [region isEqual:[NSNull null]] || region == nil || [region isEqualToString:@"<null>"]) {
            nameLabel.text = minstr([dic valueForKey:@"user_nicename"]);
        }else{
            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:minstr([dic valueForKey:@"user_nicename"]) attributes:nil];
            NSTextAttachment *regionAttchment = [[NSTextAttachment alloc]init];
            regionAttchment.bounds = CGRectMake(0, -2, 16, 16);//设置frame
            regionAttchment.image = [ImageBundle imagewithBundleName:@""];
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:[dic valueForKey:@"region_icon"]] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL)
            {} completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL)
            {
                    UIImage * newimage = [self createImageWithImage:image rect:CGRectMake(0, 0, 16, 16) radius:8];
                    regionAttchment.image = newimage;
                    NSAttributedString *regionString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(regionAttchment)];
                    [noteStr insertAttributedString:regionString atIndex:0];
                    nameLabel.attributedText = noteStr;
            }];
        }

//        nameLabel.text = minstr([dic valueForKey:@"user_nicename"]);
        [view addSubview:nameLabel];
        CGFloat iconWidth;
        if (num == 1) {
            iconWidth = view.width*18/25;
            UIImageView *iconBgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width/2-iconWidth/2 -3, 34, iconWidth + 6, iconWidth + 6)];
            iconBgImgView.image = [ImageBundle imagewithBundleName:@"phb_txk_1"];
            [view addSubview:iconBgImgView];
            
            UIImageView *iconTImgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width/2- 10, 10, 25, 20)];
            iconTImgView.image = [ImageBundle imagewithBundleName:@"phb_hg1"];
            [view addSubview:iconTImgView];
            
            iconImgView.frame = CGRectMake((view.width/2-iconWidth/2), 37, iconWidth, iconWidth);
            NSLog(@"xxddddd = %@",dic);
            NSString *stringt = [dic valueForKey:@"avatar_thumb"];
            if ([stringt isKindOfClass:[NSNull class]] || [stringt isEqual:[NSNull null]] || stringt == nil) {
                
            }else{
                [iconImgView sd_setImageWithURL:[NSURL URLWithString:[dic valueForKey:@"avatar_thumb"]] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
                [view addSubview:iconImgView];
//                headerImgView.frame =CGRectMake(view.width/2-view.width*195/250/2, 10, view.width*195/250, view.width*195/250);
                nameLabel.frame = CGRectMake(0, iconImgView.bottom, view.width, view.width/25*5);
            }
           
        }else{
            iconWidth = view.width*15/25;
            NSString *stringt = [dic valueForKey:@"avatar_thumb"];
            if ([stringt isKindOfClass:[NSNull class]] || [stringt isEqual:[NSNull null]] || stringt == nil) {
                
            }else{
                iconImgView.frame = CGRectMake(view.width/2-iconWidth/2, 37+view.width/200*60, iconWidth, iconWidth);
                [iconImgView sd_setImageWithURL:[NSURL URLWithString:[dic valueForKey:@"avatar_thumb"]] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
                [view addSubview:iconImgView];
//                headerImgView.frame =CGRectMake(view.width/2-view.width*14/20/2, 10, view.width*14/20, view.width*14/20);
                nameLabel.frame = CGRectMake(0, iconImgView.bottom, view.width, view.width/200*55);
                UIImageView *iconBgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width/2-iconWidth/2 -3, 34+view.width/200*60, iconWidth + 6, iconWidth + 6)];
                [view addSubview:iconBgImgView];
                UIImageView *iconTImgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width/2- 10, 10+view.width/200*60, 25, 20)];
                [view addSubview:iconTImgView];
                
                if (num == 2){
                    iconBgImgView.image = [ImageBundle imagewithBundleName:@"phb_txk_2"];
                    iconTImgView.image = [ImageBundle imagewithBundleName:@"phb_hg2"];
                }else{
                    iconBgImgView.image = [ImageBundle imagewithBundleName:@"phb_txk_3"];
                    iconTImgView.image = [ImageBundle imagewithBundleName:@"phb_hg3"];
                }
            }
           
        }
        iconImgView.layer.cornerRadius = iconImgView.width/2;
        iconImgView.layer.masksToBounds = YES;
        //[view addSubview:headerImgView];

       
        //等级
        UIImageView *levelImgView = [[UIImageView alloc]init];
        levelImgView.frame = CGRectMake(view.width/2, nameLabel.bottom, _window_width*0.08, _window_width*0.04);
//      levelImgView.image = [ImageBundle imagewithBundleName:@"leve1"];
        if (self.selectedButton.tag==100) {
            NSDictionary *levelDic = [common getAnchorLevelMessage:minstr([dic valueForKey:@"levelAnchor"])];
            [levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
            
        }else {

            NSDictionary *levelDic = [common getUserLevelMessage:minstr([dic valueForKey:@"level"])];
            [levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
        }

        [view addSubview:levelImgView];
        
        
        BOOL isLive = [[dic objectForKey:@"isLive"] boolValue];
        if (isLive) {
            // 设置灰色半透明背景
            UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(levelImgView.right+2, levelImgView.top-1, 20, 20)];
            backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1]; // 灰色半透明
            backgroundView.layer.cornerRadius = 10; // 圆角半径
            backgroundView.layer.masksToBounds = YES; // 裁剪超出圆角部分
            
            [view addSubview:backgroundView];
            
            
            NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
            YYAnimatedImageView *gifImg = [[YYAnimatedImageView alloc]initWithFrame:CGRectMake(3, 5, 14, 10)];
            LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
            [imgAnima setAnimatedImageLoopCount:0];
//            imgAnima.loopCount = 0;
            gifImg.image = imgAnima;
            gifImg.runloopMode = NSRunLoopCommonModes;
            gifImg.animationRepeatCount = 0;
            [gifImg startAnimating];
            [backgroundView addSubview:gifImg];
        }
        
        //性别
        UIImageView *sexImgView = [[UIImageView alloc]init];
        sexImgView.frame = CGRectMake(levelImgView.left-_window_width*0.04-3, nameLabel.bottom, _window_width*0.04, _window_width*0.04);
        if ([minstr([dic valueForKey:@"sex"]) isEqual:@"1"]) {
            sexImgView.image = [ImageBundle imagewithBundleName:@"sex_man"];
        }else{
            sexImgView.image = [ImageBundle imagewithBundleName:@"sex_woman"];
        }
        [view addSubview:sexImgView];
        
//        UIImageView *regcionImgView = [[UIImageView alloc]init];
//        regcionImgView.backgroundColor = [UIColor redColor];
//        regcionImgView.frame = CGRectMake(sexImgView.left- 3 -_window_width*0.04 , nameLabel.bottom, _window_width*0.04, _window_width*0.04);
//        [view addSubview:regcionImgView];
//        regcionImgView.layer.masksToBounds = YES;
//        regcionImgView.layer.cornerRadius = _window_width*0.02;
        
        //关注按钮
        UIButton *attionBtn = [UIButton buttonWithType:0];
        attionBtn.frame = CGRectMake(view.width/2-_window_width*0.06, sexImgView.bottom + 5,  _window_width*0.12, _window_width*0.12*4/9);
//        [attionBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"public_fans_follow_Icon")] forState:UIControlStateNormal];
//        [attionBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"public_fans_followed_Icon")] forState:UIControlStateSelected];
        attionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [attionBtn setTitleColor:RGB(232, 96, 212) forState:UIControlStateNormal];
        [attionBtn setTitle:YZMsg(@"RankCell_FollowButton") forState:UIControlStateNormal];
        attionBtn.layer.cornerRadius = _window_width*0.12*4/18;
        attionBtn.layer.masksToBounds = YES;
        attionBtn.layer.borderColor = RGB(232, 96, 212).CGColor;
        attionBtn.layer.borderWidth = 0.5;

        //月牙数
        UILabel *votesLabel = [[UILabel alloc]init];
        if (num == 1) {
            votesLabel.frame = CGRectMake(0, attionBtn.bottom - 10 + _window_width / 15.0,view.width,levelImgView.height*2);
            votesLabel.hidden = YES;
        }else if (num == 2){
            votesLabel.frame = CGRectMake(10, attionBtn.bottom - 10 + _window_width / 22.0,view.width-20,levelImgView.height*2);
        }else{
            votesLabel.frame = CGRectMake(10, attionBtn.bottom - 10 + _window_width / 22.0 ,view.width-20,levelImgView.height*2);
        }
        votesLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
        votesLabel.textAlignment = NSTextAlignmentCenter;
        votesLabel.adjustsFontSizeToFitWidth = YES;
        votesLabel.minimumScaleFactor = 0.2;
        votesLabel.textColor = [UIColor whiteColor];
        votesLabel.text = [self setText:[dic valueForKey:@"totalcoin"] number:num];
        [view addSubview:votesLabel];
        if ([minstr([dic valueForKey:@"isAttention"]) isEqual:@"1"]) {
            attionBtn.selected = YES;
        }else{
            attionBtn.selected = NO;
        }
        attionBtn.tag = 10084+num;
        [attionBtn addTarget:self action:@selector(clickFollowBtn:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:attionBtn];
    }else{
        UIImageView *nothingImgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width*0.3, 50, view.width*0.4, view.width*0.4)];
        nothingImgView.image = [ImageBundle imagewithBundleName:@"rank_nothing"];
        [view addSubview:nothingImgView];
        
        UILabel *nothingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingImgView.bottom+10, view.width, 20)];
        nothingLabel.text = YZMsg(@"RankVC_Empty");
        nothingLabel.textAlignment = NSTextAlignmentCenter;
        nothingLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
        nothingLabel.font = [UIFont systemFontOfSize:13];
        [view addSubview:nothingLabel];
    }
    return view;
}

- (UIImage *)createImageWithImage:(UIImage *)image rect:(CGRect)rect radius:(float)radius{
    CGFloat side = MIN(rect.size.width, rect.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(side, side), false, [UIScreen mainScreen].scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                    [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, side, side)].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    CGFloat X = -(rect.size.width - side) / 2.f;
    CGFloat Y = -(rect.size.height - side) / 2.f;
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:radius] addClip];
    [image drawInRect:CGRectMake(X, Y, rect.size.width, rect.size.height)];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

- (NSString *)setText:(NSString *)votes number:(int)number{
    NSString *str = @"";
    NSString *currencyCoin = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%@", votes] showUnit:YES];
    if (number>1) {
        str =  [NSString stringWithFormat:YZMsg(@"RankCell_Title_scroe%@"),[NSString stringWithFormat:@"%@",currencyCoin]];
    }else{
        str = [NSString stringWithFormat:@"%@",currencyCoin];
    }
   
    //NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",votes,name]];
    //[att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#c7c8c9", 1) range:NSMakeRange(votes.length+1, name.length)];
    return str;
}
#pragma mark -
-(void)doReturn
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)changeRankType:(UIButton *)sender{
    paging = 1;
    selectTypeIndex = (int)sender.tag - 1000086;
    for (UIButton *btn in btnArray) {
        if (btn == sender) {
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            line.frame = CGRectMake(btn.left + 15, btn.bottom + 3, 30, 3);
        }
    }
    [self pullData:YES];
}
- (void)num1Click:(id)tap{
    if (_dataArray.count>0) {
        RankModel *model = [[RankModel alloc] initWithDic:[_dataArray objectAtIndex:0]];
        [self pushUserMessageVC:model];
    }else{
        [MBProgressHUD showError:YZMsg(@"RankVC_Empty")];
    }
}

- (void)num2Click:(id)tap{
    if (_dataArray.count>1) {
        RankModel *model = [[RankModel alloc] initWithDic:[_dataArray objectAtIndex:1]];
        [self pushUserMessageVC:model];
    }else{
        [MBProgressHUD showError:YZMsg(@"RankVC_Empty")];
    }
    
}

- (void)num3Click:(id)tap{
    if (_dataArray.count>2) {
        RankModel *model = [[RankModel alloc] initWithDic:[_dataArray objectAtIndex:2]];
        [self pushUserMessageVC:model];
    }else{
        [MBProgressHUD showError:YZMsg(@"RankVC_Empty")];
    }
    
}
- (void)pushUserMessageVC:(RankModel *)model{
    
    if (model.isLive) {
        [[EnterLivePlay sharedInstance]showLivePlayFromLiveID:[model.uidStr integerValue] fromInfoPage:YES];
    }else{
        otherUserMsgVC *person = [[otherUserMsgVC alloc]init];
        person.userID = model.uidStr;
        [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark
- (void)titleClick:(UIButton *)button
{
    self.selectedButton.enabled = YES;
    self.selectedButton.backgroundColor = [UIColor clearColor];
    button.enabled = NO;
    self.selectedButton = button;
    button.backgroundColor = [UIColor whiteColor];
    paging = 1;
    [self pullData:YES];
}


@end
