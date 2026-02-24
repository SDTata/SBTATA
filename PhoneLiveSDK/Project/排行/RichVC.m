//
//  RankVC.m
//  yunbaolive
//
//  Created by YunBao on 2018/2/1.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "RichVC.h"

#import "RankModel.h"
#import "RankCell.h"
#import "UIImageView+WebCache.h"
@interface RichVC ()<UITableViewDelegate,UITableViewDataSource> {
    UISegmentedControl *segment1;    //收益榜、消费榜榜
    //UILabel *line1;                  //收益榜下划线
    //UILabel *line2;                  //消费榜榜下划线
    int paging;
    int selectTypeIndex;
    UIImageView  *tableHeaderView;
    YBNoWordView *noNetwork;
//    MBProgressHUD *hud;

}
@property (nonatomic,strong) UITableView *tableView;
//@property (nonatomic,strong) NSArray *models;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation RichVC

-(void)pullData:(BOOL)show {
//    if (paging == 1 && show) {
//        hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//        [hud hideAnimated:YES afterDelay:10];
//    }
    NSString *postUrl = @"Home.lotteryProfitRankList";
    NSDictionary *postDic = @{@"uid":[Config getOwnID],
                              @"p":@(paging)
                              };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:postUrl withBaseDomian:NO andParameter:postDic data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        [strongSelf->hud hideAnimated:YES];
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
//        [strongSelf->hud hideAnimated:YES];
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        if (strongSelf.dataArray.count == 0) {
            strongSelf->noNetwork.hidden = NO;
            strongSelf.tableView.hidden = YES;
        }
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@1081",YZMsg(@"public_networkError")]];

    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [NSMutableArray array];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RankModel *model = [[RankModel alloc] initWithDic:[_dataArray objectAtIndex:indexPath.row+3]];
    RankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
    if (!cell) {
        cell=[[[XBundle currentXibBundleWithResourceName:@"RankCell"] loadNibNamed:@"RankCell" owner:self options:nil] lastObject];
    }
    cell.iconIV.layer.masksToBounds = YES;
    cell.iconIV.layer.cornerRadius = 20;
    cell.countryImg.layer.masksToBounds = YES;
    cell.countryImg.layer.cornerRadius = 8;
    
    cell.isRich = YES;
    //收益榜-0 消费榜-1
    if (segment1.selectedSegmentIndex==0) {
        model.type = @"0";
    }else{
        model.type = @"1";
    }
    cell.otherMCL.text = [NSString stringWithFormat:@"%ld",indexPath.row+4];
    cell.model = model;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
}

#pragma mark -
#pragma mark - tableView
-(UITableView *)tableView {
    if (!_tableView) {
        CGFloat naviHeight = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
        if (@available(iOS 11.0, *)) {
            _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, naviHeight, _window_width, _window_height - naviHeight - [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom) style:UITableViewStylePlain];
        } else {
            _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, naviHeight, _window_width, _window_height - naviHeight) style:UITableViewStylePlain];
        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
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

        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf->paging +=1;
            [strongSelf pullData:NO];
        }];
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
    
    //_tableView.tableHeaderView = tableHeaderView;

}
#pragma mark - navi
-(void)creatTableHeaderView {
    CGFloat naviHeight = _window_width/75*52;
    tableHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, naviHeight)];
    tableHeaderView.userInteractionEnabled = YES;
    tableHeaderView.backgroundColor = RGB(245, 245, 245);
    tableHeaderView.image = [ImageBundle imagewithBundleName:@"syb_bj"];
    [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:1]];
    [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:2]];
    [tableHeaderView addSubview:[self creatTopCellWithUserMsg:nil andNum:3]];
    _tableView.tableHeaderView = tableHeaderView;
}

- (UIView *)creatTopCellWithUserMsg:(NSDictionary *)dic andNum:(int)num{
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
        view.frame = CGRectMake(_window_width/2-width/2, 10 , width, tableHeaderView.height );
        view.tag = 1011;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num1Click:)];
    }
    if (num == 2) {
        width = (_window_width - 14 -30)/3.0;
        view.frame = CGRectMake(15, 10, width, tableHeaderView.height);
        view.tag = 1012;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num2Click:)];
        
    }
    if (num == 3) {
        width = (_window_width - 14 -30)/3.0;
        view.frame = CGRectMake(_window_width-width-15,10, width, tableHeaderView.height);
        view.tag = 1013;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(num3Click:)];
        
    }
   
    view.layer.cornerRadius = 5.0;
    view.layer.masksToBounds = YES;

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
        nameLabel.text = minstr([dic valueForKey:@"user_nicename"]);
        [view addSubview:nameLabel];
        CGFloat iconWidth;
        if (num == 1) {
            iconWidth = view.width*18/25;
            iconImgView.frame = CGRectMake(view.width/2-iconWidth/2, 10, iconWidth, iconWidth);
            NSLog(@"xxddddd = %@",dic);
            NSString *stringt = [dic valueForKey:@"avatar_thumb"];
            if ([stringt isKindOfClass:[NSNull class]] || [stringt isEqual:[NSNull null]] || stringt == nil) {
                
            }else{
                [iconImgView sd_setImageWithURL:[NSURL URLWithString:[dic valueForKey:@"avatar_thumb"]] placeholderImage:nil options:1];
                [view addSubview:iconImgView];
//                headerImgView.frame =CGRectMake(view.width/2-view.width*195/250/2, 10, view.width*195/250, view.width*195/250);
                nameLabel.frame = CGRectMake(0, iconImgView.bottom, view.width, view.width/25*5);
            }
           
        }else{
            iconWidth = view.width*15/25;
            NSString *stringt = [dic valueForKey:@"avatar_thumb"];
            if ([stringt isKindOfClass:[NSNull class]] || [stringt isEqual:[NSNull null]] || stringt == nil) {
                
            }else{
                iconImgView.frame = CGRectMake(view.width/2-iconWidth/2, 10+view.width/200*60, iconWidth, iconWidth);
                [iconImgView sd_setImageWithURL:[NSURL URLWithString:[dic valueForKey:@"avatar_thumb"]] placeholderImage:nil options:1];
                [view addSubview:iconImgView];
//                headerImgView.frame =CGRectMake(view.width/2-view.width*14/20/2, 10, view.width*14/20, view.width*14/20);
                nameLabel.frame = CGRectMake(0, iconImgView.bottom, view.width, view.width/200*55);
            }
           
        }
        iconImgView.layer.cornerRadius = iconImgView.width/2;
        iconImgView.layer.masksToBounds = YES;
        //[view addSubview:headerImgView];
        
        //等级
        UIImageView *levelImgView = [[UIImageView alloc]init];
        levelImgView.frame = CGRectMake(view.width/2, nameLabel.bottom, _window_width*0.08, _window_width*0.04);
//      levelImgView.image = [ImageBundle imagewithBundleName:@"leve1"];
        NSDictionary *levelDic = [common getUserLevelMessage:minstr([dic valueForKey:@"level"])];
        [levelImgView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])] placeholderImage:nil options:1];
        
        [view addSubview:levelImgView];
        //性别
        UIImageView *sexImgView = [[UIImageView alloc]init];
        sexImgView.frame = CGRectMake(levelImgView.left-_window_width*0.04-3, nameLabel.bottom, _window_width*0.04, _window_width*0.04);
        if ([minstr([dic valueForKey:@"sex"]) isEqual:@"1"]) {
            sexImgView.image = [ImageBundle imagewithBundleName:@"sex_man"];
        }else{
            sexImgView.image = [ImageBundle imagewithBundleName:@"sex_woman"];
        }
        [view addSubview:sexImgView];
        //月牙数
        UILabel *votesLabel = [[UILabel alloc]init];
        if (num == 1) {
            votesLabel.frame = CGRectMake(0, sexImgView.bottom + _window_width / 15.0,view.width,levelImgView.height*2);
        }else if (num == 2){
            votesLabel.frame = CGRectMake(0, sexImgView.bottom + _window_width / 22.0,view.width,levelImgView.height*2);
        }else{
            votesLabel.frame = CGRectMake(0, sexImgView.bottom + _window_width / 12.0 ,view.width,levelImgView.height*2);
        }
        votesLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
        votesLabel.textAlignment = NSTextAlignmentCenter;
        votesLabel.textColor = [UIColor whiteColor];
        votesLabel.text = [self setText:minfloat([[dic valueForKey:@"totalcoin"] floatValue])];
        [view addSubview:votesLabel];
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
- (NSString *)setText:(NSString *)votes{
    NSString *currencyCoin = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%@", votes] showUnit:YES];
    NSString *str = [NSString stringWithFormat:@"%@",currencyCoin];
    //NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@",votes,name]];
    //[att addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#c7c8c9", 1) range:NSMakeRange(votes.length+1, name.length)];
    return str;
}
- (void)num1Click:(id)tap{
}

- (void)num2Click:(id)tap{
}

- (void)num3Click:(id)tap{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
