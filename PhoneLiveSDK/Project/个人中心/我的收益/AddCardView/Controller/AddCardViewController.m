//
//  AddCardViewController.m
//
//

#import "AddCardViewController.h"
#import "BRPickerView.h"
#import "BRInfoCell.h"
#import "BRInfoModel.h"
#import "UIImage+Color.h"
#import "UIColor+BRAdd.h"
#import "SearchBankViewController.h"
#import "ExchangeRateViewController.h"
//#import "Test2ViewController.h"

#define kThemeColor BR_RGB_HEX(0x2e70c2, 1.0f)

typedef NS_ENUM(NSUInteger, BRTimeType) {
    BRTimeTypeBeginTime = 0,
    BRTimeTypeEndTime
};
@interface AddCardViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
/// footerView
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UITextField *beginTimeTF;
@property (nonatomic, strong) UITextField *endTimeTF;
@property (nonatomic, strong) UIView *beginTimeLineView;
@property (nonatomic, strong) UIView *endTimeLineView;
@property (nonatomic, strong) BRDatePickerView *datePickerView;


@property (nonatomic, copy) NSArray *titleArr;

@property (nonatomic, strong) BRInfoModel *infoModel;

@property (nonatomic, assign) BRTimeType timeType;

@property (nonatomic, assign) NSInteger bankSelectIndex;
@property (nonatomic, assign) NSInteger genderSelectIndex;
@property (nonatomic, assign) NSInteger addressSelectIndex;
@property (nonatomic, strong) NSDate *birthdaySelectDate;
@property (nonatomic, strong) NSDate *birthtimeSelectDate;
@property (nonatomic, assign) NSInteger educationSelectIndex;
@property (nonatomic, copy) NSArray <NSNumber *> *otherSelectIndexs;
@property (nonatomic, strong) NSMutableArray  *addressArr;
@property (nonatomic, strong) NSMutableArray  *addressKeyArr;
@property (nonatomic, strong) NSMutableArray  *bankArr;

@end

@implementation AddCardViewController


-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"AddCard_title");
    [label setFont:navtionTitleFont];
    label.textColor = navtionTitleColor;
    label.frame = CGRectMake(0, statusbarHeight,_window_width,84);
    label.textAlignment = NSTextAlignmentCenter;
    [navtion addSubview:label];
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0, statusbarHeight, _window_width/2, 64)];
    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:bigBTN];
    returnBtn.frame = CGRectMake(8,24 + statusbarHeight,40,40);
    returnBtn.imageEdgeInsets = UIEdgeInsetsMake(12.5, 0, 12.5, 25);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    UIButton *btnttttt = [UIButton buttonWithType:UIButtonTypeCustom];
    btnttttt.backgroundColor = [UIColor clearColor];
    [btnttttt addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    btnttttt.frame = CGRectMake(0,0,100,64);
    [navtion addSubview:btnttttt];

    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, navtion.height-1, _window_width, 1) andColor:RGB(244, 245, 246) andView:navtion];
    [self.view addSubview:navtion];
}
-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self navtion];
    self.infoModel.region_id = [Config getRegionId];
    self.infoModel.region_curreny = [Config getRegionCurreny];
    [self loadData];
    [self initUI];
    // 设置开始时间默认选择的值及状态
    //NSString *beginTime = @"2018-10-01 00";
    NSString *beginTime = nil;
    if (beginTime && beginTime.length > 0) {
        self.beginTimeTF.text = beginTime;
        self.beginTimeTF.textColor = kThemeColor;
        self.beginTimeLineView.backgroundColor = kThemeColor;
        // 设置选择器滚动到指定的日期
        self.datePickerView.selectDate = [NSDate br_getDate:self.beginTimeTF.text format:@"yyyy-MM-dd HH"];
    }
//    获取地区数据
    [self getAddressDataSourceComplation:^(BOOL isSuccess, NSMutableArray *data) {
        
    }];
    
}

- (void)loadData {
    NSLog(@"-----加载数据-----");
    self.infoModel.nameStr = @"";
    self.infoModel.genderStr = @"";
    self.infoModel.birthdayStr = @"";
    self.infoModel.birthtimeStr = @"";
    self.infoModel.phoneStr = @"";
    self.infoModel.addressStr = @"";
    self.infoModel.educationStr = @"";
    self.infoModel.otherStr = @"";
}

- (void)initUI {
    self.tableView.hidden = NO;
    
    UILabel *tip2Label = [[UILabel alloc]initWithFrame:CGRectMake(15,2, SCREEN_WIDTH-30, 35)];
    tip2Label.font = [UIFont systemFontOfSize:13];
    tip2Label.textColor =  RGB(235,187,114);
    [tip2Label setTextAlignment:NSTextAlignmentLeft];
    tip2Label.text = YZMsg(@"AddCard_Transfor_tip1");
    tip2Label.numberOfLines = 0;
    [tip2Label sizeToFit];
    
    UIView *backGroudV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tip2Label.height+4)];
    backGroudV.backgroundColor = RGB(249,246,223);
    [backGroudV addSubview:tip2Label];
    
    self.tableView.tableHeaderView = backGroudV;
    
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSaveBtn {
    NSLog(@"-----保存数据-----");
    NSLog(@"姓名：%@", self.infoModel.nameStr);
    NSLog(@"性别：%@", self.infoModel.genderStr);
    NSLog(@"出生日期：%@", self.infoModel.birthdayStr);
    NSLog(@"出生时刻：%@", self.infoModel.birthtimeStr);
    NSLog(@"联系方式：%@", self.infoModel.phoneStr);
    NSLog(@"地址：%@", self.infoModel.addressStr);
    NSLog(@"学历：%@", self.infoModel.educationStr);
    NSLog(@"其它：%@", self.infoModel.otherStr);
    
}

- (UITableView *)tableView {
    if (!_tableView) {
       
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64 + statusbarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-(64 + statusbarHeight)) style:UITableViewStyleGrouped];
        if (@available(iOS 13.0, *)) {
            _tableView.backgroundColor = [UIColor whiteColor];
        } else {
            _tableView.backgroundColor = [UIColor whiteColor];
        }
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.tableFooterView = self.footerView;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"testCell";
    BRInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[BRInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.titleLabel.text = self.titleArr[indexPath.row];
    cell.textField.adjustsFontSizeToFitWidth = YES;
    cell.textField.contentScaleFactor = 0.5;
    
    cell.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.titleLabel.minimumScaleFactor = 0.5;
    
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    switch (indexPath.row) {
        case 0:
        {
            cell.canEdit = YES;
            cell.textField.placeholder = YZMsg(@"AddCard_CurrencyType");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.region_curreny;
        }
            break;
        case 1:
        {
            cell.canEdit = NO;
            cell.textField.placeholder = YZMsg(@"AddCard_CardCity");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.bankCityStr;
        }
            break;
        case 2:
        {
            cell.canEdit = YES;
            cell.textField.placeholder = YZMsg(@"AddCard_CardUserName");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.nameStr;
        }
            break;
        case 3:
        {
            cell.canEdit = YES;
            cell.textField.placeholder = YZMsg(@"AddCard_CardNum");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.cardNumberStr;
        }
            break;
        case 4:
        {
            cell.canEdit = YES;
            cell.textField.placeholder = YZMsg(@"AddCard_CardAddress");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.bankNodeStr;
        }
            break;
        case 5:
        {
            cell.canEdit = NO;
            cell.textField.placeholder = YZMsg(@"AddCard_CardBankName");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.bankNameStr;
        }
            break;

        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

#pragma mark - 获取地区数据源
- (void)getAddressDataSourceComplation:(void(^)(BOOL isSuccess, NSMutableArray *data))handler{
    // 加载地区数据源（实际开发中这里可以写网络请求，从服务端请求数据。可以把 BRCity.json
    
    NSMutableArray * dataSource = [NSMutableArray array];
    NSMutableArray * keys = [NSMutableArray array];
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getBankRegions" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSDictionary * regionDict = info[@"regions"];
            NSString * curent_region = regionDict[info[@"current_region"]];
            [regionDict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
                [dataSource addObject:[NSString stringWithFormat:@"%@",obj]];
                [keys addObject:[NSString stringWithFormat:@"%@",key]];
            }];
            if ([keys containsObject:curent_region]) {
                [keys removeObject:curent_region];
                [keys insertObject:curent_region atIndex:0];
                [dataSource removeObject:[regionDict objectForKey:curent_region]];
                [dataSource insertObject:[regionDict objectForKey:curent_region] atIndex:0];
            }
            
            strongSelf.addressArr = dataSource;
            strongSelf.addressKeyArr = keys;
        }else{
            [MBProgressHUD showError:msg];
        }
        if (handler && dataSource.count) {
            handler(YES, dataSource);
        }else{
            handler(NO, dataSource);
        }
    } fail:^(NSError * _Nonnull error) {
        if (handler) {
            handler(NO, dataSource);
        }
    }];
}

#pragma mark - 获取银行数据源
- (void)getBankDataSource:(NSString *)region  Complation:(void(^)(BOOL isSuccess, NSMutableArray *data))handler{
    
    NSMutableArray * dataSource = [NSMutableArray array];
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"region": region,
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getBankInfo" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSMutableArray * bank_info = info[@"bank_info"];
            for (int i = 0; i < bank_info.count; i++) {
                NSDictionary * dict = bank_info[i];
                [dataSource addObject:dict[@"bank_name"]];
            }
            strongSelf.bankArr = dataSource;
        }else{
            [MBProgressHUD showError:msg];
        }
        if (handler && dataSource.count) {
            handler(YES, dataSource);
        }else{
            handler(NO, dataSource);
        }
    } fail:^(NSError * _Nonnull error) {
        if (handler) {
            handler(NO, dataSource);
        }
    }];
}


#pragma mark - UITextFieldDelegate 返回键
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0 || textField.tag == 1 || textField.tag == 4) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 2 || textField.tag == 3 || textField.tag == 5) {
        [textField addTarget:self action:@selector(handlerTextFieldEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        return YES; // 当前 textField 可以编辑
    } else {
        [self.view endEditing:YES];
        [self handlerTextFieldSelect:textField];
        return NO; // 当前 textField 不可编辑，可以响应点击事件
    }
}

#pragma mark - 处理编辑事件
- (void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"结束编辑:%@", textField.text);
    switch (textField.tag) {
        case 2:
        {
            self.infoModel.nameStr = textField.text;
        }
            break;
        case 3:
        {
            self.infoModel.cardNumberStr = textField.text;
        }
            break;
        case 5:
        {
            self.infoModel.bankNodeStr = textField.text;
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 处理编辑事件
- (void)handlerTextFieldEndEdit:(UITextField *)textField {
    NSLog(@"结束编辑:%@", textField.text);
    switch (textField.tag) {
        case 2:
        {
            self.infoModel.nameStr = textField.text;
        }
            break;
        case 3:
        {
            self.infoModel.cardNumberStr = textField.text;
        }
            break;
        case 5:
        {
            self.infoModel.bankNodeStr = textField.text;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 处理点击事件
- (void)handlerTextFieldSelect:(UITextField *)textField {
    switch (textField.tag) {
        case 0:
        {
            ExchangeRateViewController * vc = [[ExchangeRateViewController alloc] init];
            vc.type = @"1";
            WeakSelf
            vc.callBlock = ^(ExchangeRateModel *model) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.infoModel.region_id = model.ID;
                textField.text = model.region_curreny;
             };
            [[MXBADelegate sharedAppDelegate]pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            // 城市
            BRStringPickerView *cityPickerView = [[BRStringPickerView alloc]init];
            cityPickerView.pickerMode = BRStringPickerComponentSingle;
            cityPickerView.title = YZMsg(@"AddCard_ChoiseBankCity");

            cityPickerView.selectIndex = self.addressSelectIndex;

            WeakSelf
            cityPickerView.resultModelBlock = ^(BRResultModel *resultModel) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.addressSelectIndex = resultModel.index;
                strongSelf.infoModel.bankCityStr = resultModel.value;
                textField.text = weakSelf.infoModel.bankCityStr;
                [strongSelf getBankDataSource:strongSelf.addressKeyArr[resultModel.index] Complation:^(BOOL isSuccess, NSMutableArray *data) {
                }];
            };
            cityPickerView.pickerStyle.pickerHeight = 350;//_window_height / 4 * 3;
            if (self.addressArr.count==0) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self getAddressDataSourceComplation:^(BOOL isSuccess, NSMutableArray *data) {
                    STRONGSELF
                    if (strongSelf == nil) {
                        return;
                    }
                    if (data.count) {
                        cityPickerView.dataSourceArr = data;
                        [cityPickerView show];
                    }
                    [hud hideAnimated:YES];
                    [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
                }];
            }else{
                cityPickerView.dataSourceArr = self.addressArr;
                [cityPickerView show];
            }
        }
            break;
        case 4:
        {            // 开户银行
            if (self.infoModel.bankCityStr.length ==0) {
                [MBProgressHUD showError:YZMsg(@"AddCard_ChoiseBankCity")];
                return;
            }
            SearchBankViewController * vc = [[SearchBankViewController alloc] init];
            vc.key = self.addressKeyArr[self.addressSelectIndex];
            WeakSelf
            vc.callBlock = ^(NSInteger index, NSString * _Nullable bankName) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.bankSelectIndex = index;
                strongSelf.infoModel.bankNameStr = bankName;
                textField.text = weakSelf.infoModel.bankNameStr;
                [strongSelf.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - footerView
- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 400)];
        _footerView.backgroundColor = [UIColor clearColor];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
       
        
        UIButton *BindCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        BindCardBtn.frame = CGRectMake( 20, 20+15, _footerView.width  - 40, 40);
        [BindCardBtn setTitle:YZMsg(@"AddCard_title") forState:0];
        BindCardBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        BindCardBtn.titleLabel.minimumScaleFactor = 0.5;
        [BindCardBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [BindCardBtn addTarget:self action:@selector(bindCardClick:) forControlEvents:UIControlEventTouchUpInside];
        BindCardBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //    BindCardBtn.titleLabel.textColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:153/255.f alpha:1.f];
        [BindCardBtn.titleLabel setTextColor:[UIColor whiteColor]];
        [BindCardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [BindCardBtn setBackgroundColor:[UIColor whiteColor]];
        //    [BindCardBtn setImage:[ImageBundle imagewithBundleName:@"icon_refresh.png"] forState:UIControlStateNormal];
        BindCardBtn.userInteractionEnabled = YES;
      

        [BindCardBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"btn_anniu"] forState:UIControlStateNormal];
        [_footerView addSubview:BindCardBtn];
        
    }
    return _footerView;
}

-(void) bindCardClick:(UIButton *)sender{
    NSLog(@"-----保存数据-----");
    NSLog(@"持卡人姓名：%@", self.infoModel.nameStr);
    NSLog(@"卡号：%@", self.infoModel.cardNumberStr);
    NSLog(@"开户银行：%@", self.infoModel.bankNameStr);
    NSLog(@"开户省市：%@", self.infoModel.bankCityStr);
    NSLog(@"开户网点：%@", self.infoModel.bankNodeStr);
    
    if (self.infoModel.nameStr == nil || self.infoModel.nameStr == NULL || self.infoModel.nameStr.length == 0) {
        [MBProgressHUD showError:YZMsg(@"AddCard_CardUserName")];
        return;
    }
    if (self.infoModel.cardNumberStr == nil || self.infoModel.cardNumberStr == NULL || self.infoModel.cardNumberStr.length == 0) {
        [MBProgressHUD showError:YZMsg(@"AddCard_CardNum")];
        return;
    }
    if (self.infoModel.bankNameStr == nil || self.infoModel.bankNameStr == NULL || self.infoModel.bankNameStr.length == 0) {
        [MBProgressHUD showError:YZMsg(@"AddCard_CardBankName")];
        return;
    }
    if (self.infoModel.bankCityStr == nil || self.infoModel.bankCityStr == NULL || self.infoModel.bankCityStr.length == 0) {
        [MBProgressHUD showError:YZMsg(@"AddCard_ChoiseBankCity")];
        return;
    }
//    if (self.infoModel.bankNodeStr == nil || self.infoModel.bankNodeStr == NULL || self.infoModel.bankNodeStr.length == 0) {
//        [MBProgressHUD showError:YZMsg(@"AddCard_CardAddress")];
//        return;
//    }
    if (self.infoModel.region_id == nil || self.infoModel.region_id == NULL || self.infoModel.region_id.length == 0) {
        [MBProgressHUD showError:YZMsg(@"AddCard_CurrencyType")];
        return;
    }
    NSDictionary *subdic = @{@"type":@(3),
              @"account":self.infoModel.cardNumberStr,
              @"name":self.infoModel.nameStr,
              @"account_bank":[NSString stringWithFormat:@"%@",self.infoModel.bankNameStr],
              @"account_address":[NSString stringWithFormat:@"%@",self.infoModel.bankCityStr],
              @"account_gate":[NSString stringWithFormat:@"%@",self.infoModel.bankNodeStr],
              @"region_id":[NSString stringWithFormat:@"%@",self.infoModel.region_id]
              };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.SetUserAccount" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [MBProgressHUD showError:msg];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                strongSelf.block();
            });
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {

    }];
}

#pragma mark - 切换日期显示模式
- (void)pickerModeSegmentedControlAction:(UISegmentedControl *)sender {
    NSInteger selecIndex = sender.selectedSegmentIndex;
    if (selecIndex == 0) {
        NSLog(@"年月日时");
        self.datePickerView.pickerMode = BRDatePickerModeYMDH;
    } else if (selecIndex == 1) {
        NSLog(@"年月日");
        self.datePickerView.pickerMode = BRDatePickerModeYMD;
    } else if (selecIndex == 2) {
        NSLog(@"年月");
        self.datePickerView.pickerMode = BRDatePickerModeYM;
    }
    
    self.datePickerView.selectDate = nil;
    self.beginTimeTF.text = nil;
    self.endTimeTF.text = nil;
    self.beginTimeLineView.backgroundColor = [UIColor lightGrayColor];
    self.endTimeLineView.backgroundColor = [UIColor lightGrayColor];
}

- (UITextField *)getTextField:(CGRect)frame placeholder:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    textField.backgroundColor = [UIColor br_systemBackgroundColor];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.textColor = [UIColor br_labelColor];
    textField.font = [UIFont systemFontOfSize:16.0f];
    textField.placeholder = placeholder;
    textField.delegate = self;
    
    return textField;
}

- (NSArray *)titleArr {
    if (!_titleArr) {
        _titleArr=@[YZMsg(@"AddCard_CurrencyType_title"),YZMsg(@"AddCard_ChoiseBankCity_title"),YZMsg(@"AddCard_CardUserName_title"),YZMsg(@"AddCard_BankNum_title"), YZMsg(@"AddCard_CardBankName_title"), YZMsg(@"AddCard_CardAddress_title")];
    }
    return _titleArr;
}

- (BRInfoModel *)infoModel {
    if (!_infoModel) {
        _infoModel = [[BRInfoModel alloc]init];
    }
    return _infoModel;
}


- (NSArray<NSNumber *> *)otherSelectIndexs {
    if (!_otherSelectIndexs) {
        _otherSelectIndexs = [NSArray array];
    }
    return _otherSelectIndexs;
}


@end
