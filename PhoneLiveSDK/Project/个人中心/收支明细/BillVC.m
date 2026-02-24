//
//  BillVC.m
//  phonelive2
//
//  Created by 400 on 2021/6/25.
//  Copyright © 2021 toby. All rights reserved.
//

#import "BillVC.h"
#import "BRPickerView.h"
#import "BillTableViewCell.h"

@interface BillVC ()<UITableViewDelegate,UITableViewDataSource>

{
    NSInteger pageNum;
}
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subTitleLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)BOOL isIncome;

@property (nonatomic, strong) NSDate *selectDate;

@property(nonatomic,strong)NSMutableArray *dataArrays;
@end

@implementation BillVC

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNum =1;
    self.dataArrays = [NSMutableArray array];
    self.selectDate = [NSDate date];
    [self initView];
    [self requestData];
    // Do any additional setup after loading the view from its nib.
}

-(void)initView{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,0, _window_width, (ShowDiff>0?ShowDiff:20) + 44)];
    navtion.backgroundColor = [UIColor whiteColor];
   
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(8, ShowDiff>0?ShowDiff:20,40,44);
    [returnBtn setHighlighted:YES];
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn setBackgroundImage:[UIImage sd_imageWithColor:[UIColor whiteColor] size:CGSizeMake(40, 44)]];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-80)/2.0, ShowDiff>0?ShowDiff:20, 80, 44)];
    self.titleLabel.userInteractionEnabled = YES;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.3;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.text = YZMsg(@"BillVC_consumeDetail");
    [navtion addSubview:self.titleLabel];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake((SCREEN_WIDTH-self.titleLabel.width)/2.0, ShowDiff>0?ShowDiff:20, self.titleLabel.width, 44);
    
    UITapGestureRecognizer *typeChangeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showChoiseType)];
    [self.titleLabel addGestureRecognizer:typeChangeTap];
    
    
    UIImage *imgiCon = [ImageBundle imagewithBundleName:@"down_arrow"];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(self.titleLabel.right, self.titleLabel.top+18,10, 10)];
    imgView.image = imgiCon;
    [navtion addSubview:imgView];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
    
    UIView *bottomMenuView = [[UIView alloc]initWithFrame:CGRectMake(0, navtion.bottom, SCREEN_WIDTH, 34)];
    bottomMenuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomMenuView];
    
    self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-250)/2.0, 0, 250, 34)];
    self.subTitleLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.subTitleLabel.font = [UIFont systemFontOfSize:14];
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.text = [NSString stringWithFormat:YZMsg(@"BillVC_consumeToday_%@%@"),@"0",[common name_coin]];
    [bottomMenuView addSubview:self.subTitleLabel];
    
    UIImageView *imgView1 = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-20, 13,10, 10)];
    imgView1.image = imgiCon;
    [bottomMenuView addSubview:imgView1];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    NSString *datestr = [NSDate br_getDateString:[NSDate date] format:YZMsg(@"BillVC_DateFormat")];
    self.timeLabel.text = datestr;
    self.timeLabel.userInteractionEnabled = YES;
    self.timeLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    [bottomMenuView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(imgView1.mas_left);
        make.centerY.mas_equalTo(self.subTitleLabel.mas_centerY);
    }];
    
    UITapGestureRecognizer *changeTimeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showtimeChoise)];
    [self.timeLabel addGestureRecognizer:changeTimeTap];
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -ShowDiff, 0);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(bottomMenuView.bottom);
    }];
    pageNum = 1;
    WeakSelf
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        strongSelf->pageNum = 1;
        [strongSelf requestData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        [strongSelf requestData];
    }];
    
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showChoiseType{
    
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        WeakSelf
    UIAlertAction *showAllInfoAction = [UIAlertAction actionWithTitle:self.isIncome?YZMsg(@"BillVC_consumeDetail"):YZMsg(@"BillVC_inComeDetail") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.isIncome = !strongSelf.isIncome;
        strongSelf.titleLabel.text = strongSelf.isIncome?YZMsg(@"BillVC_inComeDetail"):YZMsg(@"BillVC_consumeDetail");
        strongSelf->pageNum = 1;
        [strongSelf requestData];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [actionSheetController addAction:cancelAction];
    [actionSheetController addAction:showAllInfoAction];
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}
- (NSDate*)getZeroDay:(NSDate*)dateCurrent{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dateCurrent];
    NSDate *startDate = [calendar dateFromComponents:components];
    return startDate;
}
-(void)requestData{
    NSLog(@"请求数据");
    NSString *requestURLStr = @"User.getCoinRecord";
    NSTimeInterval end_time = [self.selectDate timeIntervalSince1970]+24*60*60;
    
    NSDictionary *paramDic = @{@"type":self.isIncome?@"income":@"expend",@"start_time":minnum([[ self getZeroDay:self.selectDate] timeIntervalSince1970]),@"end_time":minnum(end_time),@"page":minnum(pageNum)};
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:requestURLStr withBaseDomian:YES andParameter:paramDic data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        
        if (code == 0) {
            NSDictionary *subDicInfo = (NSDictionary*)info;
            NSString *income_total = [NSString stringWithFormat:@"%.2f",[subDicInfo[@"income_total"] doubleValue]];
            NSString *expend_total = [NSString stringWithFormat:@"%.2f",[subDicInfo[@"expend_total"] doubleValue]];
            NSDictionary *pageDic = subDicInfo[@"page"];
            int maxPage = [pageDic[@"max"] intValue];
            int current = [pageDic[@"current"] intValue];
            if (!strongSelf.isIncome) {
                strongSelf.subTitleLabel.text = [NSString stringWithFormat:YZMsg(@"BillVC_consumeToday_%@%@"),[YBToolClass getRateCurrency:expend_total showUnit:YES],@""];
            }else{
                strongSelf.subTitleLabel.text = [NSString stringWithFormat:YZMsg(@"BillVC_incomeToday_%@%@"),[YBToolClass getRateCurrency:income_total showUnit:YES],@""];
            }
            NSArray *list = subDicInfo[@"list"];
            if (strongSelf->pageNum == 1) {
                [strongSelf.dataArrays removeAllObjects];
                [strongSelf.tableView.mj_footer resetNoMoreData];
            }
            if (list.count>0) {
                [PublicView hiddenTextNoData:strongSelf.tableView];
                [strongSelf.dataArrays addObjectsFromArray:list];
            }else{
                if (strongSelf->pageNum>1) {
                    [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [PublicView showTextNoData:strongSelf.tableView text1:@"" text2:YZMsg(@"public_noEmpty")];
                }
            }
            if (strongSelf->pageNum>1 && maxPage == current && current!= 0) {
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            strongSelf->pageNum++;
        }else{
            [MBProgressHUD showError:msg];

        }
        [strongSelf.tableView reloadData];
        
        
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD showError:error.localizedDescription];
        [strongSelf.tableView.mj_header endRefreshing];
        [strongSelf.tableView.mj_footer endRefreshing];
        
    }];
    
}
-(void)showtimeChoise
{
    BRDatePickerView *datePickerView = [[BRDatePickerView alloc]init];
    datePickerView.pickerMode = BRDatePickerModeYMD;
    datePickerView.title = YZMsg(@"BillVC_DateChoiseTitle");
    datePickerView.selectDate = self.selectDate;
    datePickerView.minDate = [NSDate br_getNewDate:[NSDate date] addDays:-7];
    datePickerView.maxDate = [NSDate date];
    datePickerView.isAutoSelect = YES;
    //datePickerView.addToNow = YES;
    //datePickerView.showToday = YES;
    //datePickerView.showWeek = YES;
    datePickerView.showUnitType = BRShowUnitTypeNone;
    WeakSelf
    datePickerView.resultBlock = ^(NSDate *selectDate, NSString *selectValue) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSString *datestr = [NSDate br_getDateString:selectDate format:YZMsg(@"BillVC_DateFormat")];
        strongSelf.selectDate  = selectDate;
        strongSelf.timeLabel.text = datestr;
        strongSelf->pageNum = 1;
        [strongSelf requestData];
    };
    
    // 添加头视图
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    headerView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1f];
    NSArray *unitArr = @[YZMsg(@"BillVC_Month"), YZMsg(@"BillVC_Days")];
    for (NSInteger i = 0; i < unitArr.count; i++) {
        CGFloat width = SCREEN_WIDTH / unitArr.count;
        CGFloat orginX = i * (SCREEN_WIDTH / unitArr.count);
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(orginX, 0, width, 36)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16.0f];
        label.textColor = [UIColor darkGrayColor];
        label.text = unitArr[i];
        [headerView addSubview:label];
    }
    datePickerView.pickerHeaderView = headerView;
    
    // 添加尾视图
    //UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    //footerView.backgroundColor = [UIColor blueColor];
    //datePickerView.pickerFooterView = footerView;
    
    // 模板样式
    //datePickerView.pickerStyle = [BRPickerStyle pickerStyleWithThemeColor:[UIColor blueColor]];
    //datePickerView.pickerStyle = [BRPickerStyle pickerStyleWithDoneTextColor:[UIColor blueColor]];
    //datePickerView.pickerStyle = [BRPickerStyle pickerStyleWithDoneBtnImage:[ImageBundle imagewithBundleName:@"icon_close"]];
    
    [datePickerView show];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"BillTableViewCell";
    BillTableViewCell *cell;
    cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell=[[[XBundle currentXibBundleWithResourceName:@"BillTableViewCell"] loadNibNamed:@"BillTableViewCell" owner:self options:nil] lastObject];
    }
    NSDictionary *subDic = self.dataArrays[indexPath.row];
    cell.dicContent = subDic;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArrays.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

@end
