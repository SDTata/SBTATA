//
//  AddUSDTController.m
//  phonelive2
//
//  Created by test on 2022/1/12.
//  Copyright © 2022 toby. All rights reserved.
//

#import "AddUSDTController.h"
#import "BRPickerView.h"
#import "AddUSDTInfoCell.h"
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
@interface AddUSDTController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UITextViewDelegate,AddUSDTInfoCell>
{
    float heightCellUSDTAddress;
}
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

@end

@implementation AddUSDTController


-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"AddUSDT_title");
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
    heightCellUSDTAddress = 80.0f;
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
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
//    Test2ViewController *test2VC = [[Test2ViewController alloc]init];
//    [self.navigationController pushViewController:test2VC animated:YES];
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
    AddUSDTInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[AddUSDTInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.delegate = self;
    cell.titleLabel.text = self.titleArr[indexPath.row];
    cell.textField.adjustsFontSizeToFitWidth = YES;
    cell.textField.contentScaleFactor = 0.5;
    
    cell.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.titleLabel.minimumScaleFactor = 0.5;
    
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    
    cell.textView.delegate = self;
    cell.textView.tag = indexPath.row;
    
    switch (indexPath.row) {
        case 0:
        {
            cell.placeHolder.hidden = YES;
            cell.canEdit = NO;
            cell.textField.placeholder = YZMsg(@"AddUSDT_Type_title");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.nameStr;
        }
            break;
        case 1:
        {
            cell.placeHolder.hidden = NO;
            cell.canEdit = YES;
            cell.textField.placeholder = YZMsg(@"AddUSDT_Address_title");
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.text = self.infoModel.cardNumberStr;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 50.0f;
    }else{
        return heightCellUSDTAddress + 10.0f;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

#pragma mark - UITextFieldDelegate 返回键
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0 || textField.tag == 1 || textField.tag == 4) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textViewChange:(UITextView *)textView{
    self.infoModel.cardNumberStr = textView.text;
    static CGFloat maxHeight =180.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;  // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动
    }
    if (size.height<30.0f) {
        size.height = 30.0;
    }
    heightCellUSDTAddress = frame.origin.y + size.height;
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    AddUSDTInfoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (textView.text.length > 0) {
        cell.placeHolder.hidden = YES;
    }else{
        cell.placeHolder.hidden = NO;
    }
    UIView *lineView = cell.lineView;
    lineView.frame = CGRectMake(frame.origin.x, frame.origin.y + size.height, frame.size.width, 1);
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        [textField addTarget:self action:@selector(handlerTextFieldEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        return YES; // 当前 textField 可以编辑
    } else {
        [self.view endEditing:YES];
        [self handlerTextFieldSelect:textField];
        return NO; // 当前 textField 不可编辑，可以响应点击事件
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    [self textViewChange:textView];
}
#pragma mark - AddUSDTInfoCell
- (void)doPasteCall:(AddUSDTInfoCell *)cell{
    [self textViewChange:cell.textView];
}

#pragma mark - 处理编辑事件
- (void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"结束编辑:%@", textField.text);
    switch (textField.tag) {
        case 0:
        {
            self.infoModel.nameStr = textField.text;
        }
            break;
        case 1:
        {
            self.infoModel.cardNumberStr = textField.text;
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
        case 0:
        {
            self.infoModel.nameStr = textField.text;
        }
            break;
        case 1:
        {
            self.infoModel.cardNumberStr = textField.text;
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
            // 城市
            BRStringPickerView *cityPickerView = [[BRStringPickerView alloc]init];
            cityPickerView.pickerMode = BRStringPickerComponentSingle;
            cityPickerView.title = YZMsg(@"AddUSDT_ChoiseType_title");
            cityPickerView.selectIndex = self.addressSelectIndex;
            cityPickerView.dataSourceArr = @[@"ERC20",@"TRC20"];
            WeakSelf
            cityPickerView.resultModelBlock = ^(BRResultModel *resultModel) {
                STRONGSELF
                if (strongSelf == nil) {
                    return;
                }
                strongSelf.addressSelectIndex = resultModel.index;
                strongSelf.infoModel.nameStr = resultModel.value;
                textField.text = weakSelf.infoModel.nameStr;
            };
            cityPickerView.pickerStyle.pickerHeight = 350;//_window_height / 4 * 3;
            [cityPickerView show];
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
        
        UILabel *tip2Label = [[UILabel alloc]initWithFrame:CGRectMake(10, 4, _footerView.width-20, 20)];
        tip2Label.font = [UIFont systemFontOfSize:11];
        tip2Label.textColor = RGB_COLOR(@"#c03b33", 1);
        [tip2Label setTextAlignment:NSTextAlignmentCenter];
        tip2Label.text = YZMsg(@"AddUSDT_Transfor_tip");
        tip2Label.numberOfLines = 0;
        [_footerView addSubview:tip2Label];
        [tip2Label sizeToFit];
        
        UIButton *BindCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        BindCardBtn.frame = CGRectMake( _footerView.width / 2 - 80, tip2Label.bottom+15, 160, 35);
        [BindCardBtn setTitle:YZMsg(@"AddUSDT_title") forState:0];
        BindCardBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        BindCardBtn.titleLabel.minimumScaleFactor = 0.5;
        [BindCardBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [BindCardBtn addTarget:self action:@selector(bindCardClick:) forControlEvents:UIControlEventTouchUpInside];
        BindCardBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        //    BindCardBtn.titleLabel.textColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:153/255.f alpha:1.f];
        [BindCardBtn.titleLabel setTextColor:RGB_COLOR(@"#FF3399", 1)];
        [BindCardBtn setTitleColor:RGB_COLOR(@"#FF3399", 1) forState:UIControlStateNormal];
        [BindCardBtn setBackgroundColor:[UIColor whiteColor]];
        //    [BindCardBtn setImage:[ImageBundle imagewithBundleName:@"icon_refresh.png"] forState:UIControlStateNormal];
        BindCardBtn.userInteractionEnabled = YES;
        BindCardBtn.layer.cornerRadius = 15;                           //圆角弧度
        BindCardBtn.layer.shadowOffset = CGSizeMake(1, 1);             //阴影的偏移量
        BindCardBtn.layer.shadowOpacity = 0.25;                         //阴影的不透明度
        BindCardBtn.layer.shadowColor = [UIColor blackColor].CGColor;  //阴影的颜色
        [_footerView addSubview:BindCardBtn];
        
    }
    return _footerView;
}

-(void) bindCardClick:(UIButton *)sender{
    NSLog(@"-----保存数据-----");
    NSLog(@"主网类型：%@", self.infoModel.nameStr);
    NSLog(@"卡号：%@", self.infoModel.cardNumberStr);
    
    if (self.infoModel.nameStr == nil || self.infoModel.nameStr == NULL || self.infoModel.nameStr.length == 0) {
        [MBProgressHUD showError:YZMsg(@"AddUSDT_Type_Tips")];
        return;
    }
    if (self.infoModel.cardNumberStr == nil || self.infoModel.cardNumberStr == NULL || self.infoModel.cardNumberStr.length == 0) {
        [MBProgressHUD showError:YZMsg(@"AddUSDT_Address_Tips")];
        return;
    }
  
    NSDictionary *subdic = @{@"type":@(6),
              @"account":self.infoModel.cardNumberStr,//usdt地址
              @"name":self.infoModel.nameStr,//主网类型 ERC20  TRC20
              @"account_bank":@"USDT",
              //@"account_address":[NSString stringWithFormat:@"%@",self.infoModel.bankCityStr],
              //@"account_gate":[NSString stringWithFormat:@"%@",self.infoModel.bankNodeStr],
              //@"region_id":[NSString stringWithFormat:@"%@",self.infoModel.region_id]
              };
    WeakSelf
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.SetUserAccount" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if (code == 0) {
            [MBProgressHUD showError:msg];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                strongSelf.block();
            });
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.description];
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
        _titleArr=@[YZMsg(@"AddUSDT_Type_title"),YZMsg(@"AddUSDT_Address_title")];
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
