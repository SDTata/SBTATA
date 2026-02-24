//
//  ExchangeRateViewController.m
//  phonelive2
//
//  Created by lucas on 2021/9/24.
//  Copyright © 2021 toby. All rights reserved.
//

#import "ExchangeRateViewController.h"
#import "HXSearchBar.h"
#import "ExchangeRateModel.h"
#import "ExchangeRateCell.h"
#import "UIImageView+WebCache.h"

@interface ExchangeRateViewController ()<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UISearchBarDelegate>
{
   
   //全局索引集合
   UILocalizedIndexedCollation *collation;
}
@property (nonatomic, strong) NSMutableArray *sectionArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArr;
@property (nonatomic, copy) NSMutableArray *searchArr;
@property (nonatomic,strong) HXSearchBar *searchBars;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) ExchangeRateModel *model;
@end


@implementation ExchangeRateViewController

-(void)navtion{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    navtion.backgroundColor =navigationBGColor;
    UILabel *label = [[UILabel alloc]init];
    label.text = YZMsg(@"exchangeVC_curreny_title");
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
    self.dataArr = [NSMutableArray array];
    self.searchArr = [NSMutableArray array];
    [self navtion];
    [self addSearchBar];
    [self loadData];
}

-(void)dealDataArr: (NSMutableArray *)personArr{
      
      //初始化UILocalizedIndexedCollation对象
      collation = [UILocalizedIndexedCollation currentCollation];
      //这个对象中包含26个大写字母A-Z 和 #
      NSArray *titles = collation.sectionTitles;
      
      //定义一个二维数组,数组中的共有27个元素，每个元素又是一个数组，分别对应字母A、B、C、D...#的数据
      NSMutableArray *secionArray = [NSMutableArray arrayWithCapacity:titles.count];
      //向二维数组中添加小数组
      for (int i = 0; i < titles.count; i++) {
          NSMutableArray *subArr = [NSMutableArray array];
          [secionArray addObject:subArr];
      }
      
      for (ExchangeRateModel *model in personArr) {
          //这个方法会根据@selector中的方法返回的字符串的拼音首字母,找到这个首字母对应的下标index
          NSInteger section = [collation sectionForObject:model collationStringSelector:@selector(region_name)];
          //根据index取出二维数组中的一维数组数组元素
          NSMutableArray *subArr = secionArray[section];
          //将这个对象加入到一维数组数组中  也就是以字母A开头的对象如阿福会被加入到A字母所对应数组，其他字母同理
          [subArr addObject:model];
      }
      
      //遍历二维数组，取出每一个一维数组，在对数组中的对象按照字母进行下排序。
      for (NSMutableArray *arr in secionArray) {
          
          NSArray *sortArr = [collation sortedArrayFromArray:arr collationStringSelector:@selector(region_name)];
          
          [arr removeAllObjects];
          [arr addObjectsFromArray:sortArr];
      }
      
      _sectionArr = secionArray;
     [self.tableView reloadData];

}


//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstCharactor:(NSString *)aString
{
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //去除掉首尾的空白字符和换行字符
    NSString *pinYinStr = [pinYin stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //去除掉其它位置的空白字符和换行字符
    pinYinStr = [pinYinStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pinYinStr = [pinYinStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pinYinStr = [pinYinStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return pinYinStr;
}

//获取拼音首字母
- (NSString *)getFirstLetter:(NSString *)aString
{
    if (aString.length == 0) {
        return @"";
    }
    NSString *pinyin = [self firstCharactor:aString];
    if (pinyin.length > 0) {
        return [pinyin substringToIndex:1];
    }
    return @"";
}

- (void)loadData {
    NSLog(@"-----加载数据-----");
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.getRegionsExchangeRate" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf.dataArr = [ExchangeRateModel mj_objectArrayWithKeyValuesArray:info];
            
            // 为每个模型添加拼音属性
            for (ExchangeRateModel *model in strongSelf.dataArr) {
                model.pinyin = [strongSelf firstCharactor:model.region_name];
                model.firstLetter = [strongSelf getFirstLetter:model.region_name];
            }
            
            strongSelf.searchArr = strongSelf.dataArr;
            [strongSelf dealDataArr:strongSelf.searchArr];
        }else{
            [MBProgressHUD showError:msg];
        }

    } fail:^(NSError * _Nonnull error) {

    }];
}

- (void)ExchangeRateData {
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"exchange_id": self.model.ID,
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.changeExchangeRateRegion" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if (strongSelf.callBlock) {
                strongSelf.callBlock(strongSelf.model);
            }
            
            LiveUser *user = [Config myProfile];
            user.region_id = strongSelf.model.ID;
            user.region = strongSelf.model.region;
            user.region_curreny = strongSelf.model.region_curreny;
            user.region_curreny_char = strongSelf.model.region_curreny_char;
            user.exchange_rate = strongSelf.model.exchange_rate;
            [Config updateProfile:user];
            [strongSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {

    }];
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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[ExchangeRateCell class] forCellReuseIdentifier:@"ExchangeRateCell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        self.tableView.estimatedSectionHeaderHeight = 0.01;
        self.tableView.estimatedSectionFooterHeight = 0.01;
        //定义tableview右侧section的外观
        //文字颜色
        _tableView.sectionIndexColor = [UIColor blackColor];
       //触摸section区域时候的背景颜色
        _tableView.sectionIndexTrackingBackgroundColor = [UIColor greenColor];
//        _tableView.sectionIndexMinimumDisplayRowCount = 13;
        //索引条背景的颜色（清空颜色就不会感觉索引条将tableview往左边挤
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.model = [[_sectionArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([self.type isEqualToString:@"1"]){
        if (self.callBlock) {
            self.callBlock(self.model);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else if (![self.model.region_curreny isEqualToString:[Config getRegionCurreny]]) {
        [self ExchangeRateData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [collation sectionTitles].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sectionArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ExchangeRateCell";
    ExchangeRateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[ExchangeRateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ExchangeRateModel *model = [[_sectionArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.nameLab.text = model.region_name;
    cell.currencyLab.text = [NSString stringWithFormat:@"(%@)",model.region_curreny];
    [cell.iconImgV sd_setImageWithURL:[NSURL URLWithString:minstr(model.region_icon)] placeholderImage:[ImageBundle imagewithBundleName:@"left_item_loading"]];
    if ([model.ID isEqualToString:[Config getRegionId]]) {
        self.model = model;
        cell.selectedBtn.selected = YES;
    }else{
        cell.selectedBtn.selected = NO;
    }
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
////    NSMutableArray * arr = _sectionArr[section];
////    return [_sectionArr[section] count] == 0 ? 0 : 15;
//    return  0.0f;
//}

/**返回右侧索引所包含的内容*/
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *sections = [collation.sectionTitles mutableCopy];
    //往索引数组的开始处添加一个放大镜🔍 放大镜是系统定义好的一个常量字符串表示UITableViewIndexSearch 当然除了放大镜外也可以添加其他文字
    return sections;

}

//返回每个section的title
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString * str = [[collation sectionTitles] objectAtIndex:section];
//    return [[collation sectionTitles] objectAtIndex:section];
//}

//点击右侧索引后跳转到的section
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    if ([[_sectionArr objectAtIndex:index] count]) {
        // 让table滚动到对应的indexPath位置
        [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    return index;
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
        ExchangeRateModel * model = self.dataArr[i];
        // 检查区域货币、区域名称、区域代码是否包含搜索文本（忽略大小写）
        if ([model.region_curreny rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound || 
            [model.region rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound || 
            [model.region_name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
            // 检查拼音全拼是否包含搜索文本
            [model.pinyin rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
            // 检查拼音首字母是否匹配搜索文本的开头部分
            (searchText.length > 0 && model.firstLetter.length > 0 && 
             [[model.firstLetter lowercaseString] hasPrefix:[searchText lowercaseString]])) {
            [data addObject:model];
        }
    }
    if (searchText.length == 0) {
        self.searchArr = self.dataArr;
    }else{
        self.searchArr = data;
    }
    [self dealDataArr:self.searchArr];
}

@end
