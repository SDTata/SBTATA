//
//  SearchBankViewController.m
//  phonelive2
//
//  Created by lucas on 2021/9/16.
//  Copyright © 2021 toby. All rights reserved.
//

#import "SearchBankViewController.h"
#import "HXSearchBar.h"

@interface SearchBankViewController ()<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArr;
@property (nonatomic, copy) NSMutableArray *searchArr;
@property (nonatomic,strong) HXSearchBar *searchBars;
@property (nonatomic,strong) UITextField *textField;
@end

@implementation SearchBankViewController

-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"AddCard_CardBankName");
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.title = YZMsg(@"AddCard_title");
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithImage:[ImageBundle imagewithBundleName:@"icon_arrow_leftsssa.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    [self navtion];
//    [self addSearchBar];
    [self.view addSubview:self.textField];
    [self loadData];
    [self initUI];

}

- (void)loadData {
    NSLog(@"-----加载数据-----");
    NSMutableArray * dataSource = [NSMutableArray array];
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"region": self.key,
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getBankInfo" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSArray * bank_info = info[@"bank_info"];
            for (int i = 0; i < bank_info.count; i++) {
                NSMutableDictionary * dict =  [[NSMutableDictionary alloc] initWithDictionary:bank_info[i]];
                dict[@"pinyin"] = [self firstCharactor:dict[@"bank_name"]];
                [dataSource addObject:dict];
            }
            strongSelf.dataArr = dataSource;
            strongSelf.searchArr = dataSource;
            [strongSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {

    }];
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
//    NSString *pinYin = [str capitalizedString];
    //3.去除掉首尾的空白字符和换行字符
    NSString *  pinYinStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //4.去除掉其它位置的空白字符和换行字符
    pinYinStr = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pinYinStr = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pinYinStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    //获取并返回首字母
    return pinYinStr;
}

- (void)initUI {
    self.tableView.hidden = NO;
}

//添加搜索条
- (void)addSearchBar {
    //加上 搜索栏
    _searchBars = [[HXSearchBar alloc] initWithFrame:CGRectMake(10, 64 + statusbarHeight , self.view.frame.size.width -20,60)];
    _searchBars.backgroundColor = [UIColor clearColor];
    _searchBars.delegate = self;
    //输入框提示
    _searchBars.placeholder = YZMsg(@"SearchCard_BankName");
    //光标颜色
    _searchBars.cursorColor = [UIColor blackColor];
    //TextField
    _searchBars.searchBarTextField.layer.cornerRadius = 16;
    _searchBars.searchBarTextField.layer.masksToBounds = YES;
    _searchBars.searchBarTextField.backgroundColor = RGB(241, 241, 241);
    _searchBars.hideSearchBarBackgroundImage = YES;
    _searchBars.searchBarTextField.font = [UIFont systemFontOfSize:14];
    [_searchBars becomeFirstResponder];
    [self.view addSubview:self.searchBars];
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(10, 64 + statusbarHeight + 10 , self.view.frame.size.width -20,40)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.font = [UIFont systemFontOfSize:16.0f];
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.delegate = self;
        //输入框提示
        _textField.placeholder = YZMsg(@"SearchCard_BankName");
        if (@available(iOS 13.0, *)) {
            _textField.textColor = [UIColor blackColor];
        } else {
            _textField.textColor = [UIColor blackColor];
        }
    }
    return _textField;
}

-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64 + statusbarHeight + 60 , SCREEN_WIDTH, SCREEN_HEIGHT -64-statusbarHeight -60) style:UITableViewStyleGrouped];
        if (@available(iOS 13.0, *)) {
            _tableView.backgroundColor = [UIColor whiteColor];
        } else {
            _tableView.backgroundColor = [UIColor whiteColor];
        }
//        _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"bankNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary * dict = self.searchArr[indexPath.row];
    cell.textLabel.text = dict[@"bank_name"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dict = self.searchArr[indexPath.row];
    if (self.callBlock) {
        self.callBlock(indexPath.row, dict[@"bank_name"]);
    }
}

#pragma mark - UITextFieldDelegate 返回键
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [textField addTarget:self action:@selector(handlerTextFieldEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return YES; // 当前 textField 可以编辑
}

#pragma mark - 处理编辑事件
- (void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"结束编辑:%@", textField.text);
    NSString * searchText = textField.text;
    NSMutableArray * data = [NSMutableArray array];
    for (int i = 0; i < self.dataArr.count; i ++) {
        NSDictionary * dict = self.dataArr[i];
        if ([dict[@"bank_name"] containsString:searchText] || [dict[@"pinyin"] containsString:searchText]) {
            [data addObject:dict];
        }
    }
    if (searchText.length == 0) {
        self.searchArr = self.dataArr;
    }else{
        self.searchArr = data;
    }
    [self.tableView reloadData];
}
#pragma mark - 处理编辑事件
- (void)handlerTextFieldEndEdit:(UITextField *)textField {
    NSLog(@"结束编辑:%@", textField.text);
}

-(NSMutableArray *)searchArr{
    if (!_searchArr) {
        _searchArr = [NSMutableArray array];
    }
    return _searchArr;
}





//已经开始编辑时的回调
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}
//搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"点击了搜索");
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSMutableArray * data = [NSMutableArray array];
    for (int i = 0; i < self.dataArr.count; i ++) {
        NSDictionary * dict = self.dataArr[i];
        if ([dict[@"bank_name"] containsString:searchText] || [dict[@"pinyin"] containsString:searchText]) {
            [data addObject:dict];
        }
    }
    if (searchText.length == 0) {
        self.searchArr = self.dataArr;
    }else{
        self.searchArr = data;
    }
    [self.tableView reloadData];
}


@end
