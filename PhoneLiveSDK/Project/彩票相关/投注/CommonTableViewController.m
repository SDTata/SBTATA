//
//  CommonTableViewController.m
//
//

#import "CommonTableViewController.h"
#import "CommonCollectionViewController2.h"
#import "BetOptionCollectionViewCell2.h"
#import "PayViewController.h"
#import "ChipSwitchViewController.h"
#import "BetConfirmViewController.h"
#import "OpenHistoryViewController.h"
#import "IssueCollectionViewCell.h"
#import "popWebH5.h"
#import "LotteryWayTableViewCell.h"
#import "XLPageViewController.h"
#import "CommonTableViewController.h"
#import "CommonPageViewController.h"
#import "LotteryTypeListCell.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kCellRightLineTag 100
#define kBetOptionCollectionViewCell2 @"BetOptionCollectionViewCell2"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"
#define kCollectionHeader   @"LotteryCollectionHeader"

@interface CommonTableViewController (){
    NSMutableArray *ways;   // 投注选项
    NSInteger waySelectIndex; // 当前选择的投注索引
    BOOL bUICreated; // UI是否创建
    BOOL isExit;
    NSInteger betLeftTime; // 投注剩余时间
    NSInteger sealingTime; // 封盘时间
    NSString *curIssue; // 当前期号
    NSMutableArray *waysBtn;   // 投注分类按钮
    
    NSInteger curLotteryType; // 当前投注界面对应的彩种类型
    NSString *last_open_result;
    
    // 当前选中way中的投注项
    NSArray *curOptions;
    CommonPageViewController *pageview;
}

@property (nonatomic, strong) XLPageViewController *pageViewController;
@end

@implementation CommonTableViewController

-(void)exitView
{
    
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [self refreshUI];
    //    self.contentView.bottom = _window_height + self.contentView.frame.origin.y;
    //self.contentView.hidden = NO;
    //    [UIView animateWithDuration:0.25 animations:^{
    //        //        self.view.frame = f;
    //        self.contentView.bottom = _window_height;
    //    } completion:^(BOOL finished) {
    //        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exitView)];
    //        [self.shadowView addGestureRecognizer:myTap];
    //    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.navigationItem.title = @"投注中心";
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        self.leftTablew.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.view.width = _window_width;
    self.view.height = _window_height;
    waySelectIndex = 0;
    
}

- (void)viewWillDisappear:(BOOL)animated{
}

- (void)setLotteryType:(NSInteger)lotteryType{
    curLotteryType = lotteryType;
    //[GameToolClass setCurOpenedLotteryType:lotteryType];
}

- (void)setLotteryWays:(NSArray *)_ways{
    if (_ways.count>waySelectIndex) {
        ways = [NSMutableArray arrayWithArray:_ways];
        curOptions = [ways objectAtIndex:waySelectIndex][@"options"];
    }
    
    
    
}

-(void)refreshUI{
    if(!ways){
        ways = [NSMutableArray array];
    }
    if(!bUICreated){
        [self initUI];
    }
    
}

-(void)initUI{
    bUICreated = true;
    waySelectIndex = 0;
    
    // 初始化投注选项
    [self initScrollView];
    self.contentView.backgroundColor = vkColorHexA(0x000000, 0.3);
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    self.rightView.backgroundColor = UIColor.clearColor;
}

- (void)initScrollView {
    
    // 配置左侧tableview
//    self.leftSelectColor=[UIColor blackColor];
//    self.leftSelectBgColor=[UIColor whiteColor];
//    self.leftBgColor=UIColorFromRGB(0xF3F4F6);
//    self.leftSeparatorColor=UIColorFromRGB(0xE5E5E5);
//    self.leftUnSelectBgColor=UIColorFromRGB(0xF3F4F6);
//    self.leftUnSelectColor=[UIColor blackColor];
    
    /**
     左边的tableview视图
     */
    //self.leftTablew=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kLeftWidth, frame.size.height)];
    self.leftTablew.dataSource=self;
    self.leftTablew.delegate=self;
    
    self.leftTablew.tableFooterView=[[UIView alloc] init];
    self.leftTablew.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.leftTablew.backgroundColor = UIColor.clearColor;
    self.leftTablew.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
    self.leftTablew.estimatedRowHeight = 44;
//    self.leftTablew.backgroundColor=self.leftBgColor;
//    if ([self.leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
//        self.leftTablew.layoutMargins=UIEdgeInsetsZero;
//    }
//    if ([self.leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
//        self.leftTablew.separatorInset=UIEdgeInsetsZero;
//    }
//    self.leftTablew.separatorColor=self.leftSeparatorColor;
    [self.leftTablew registerClass:[LotteryTypeListCell class] forCellReuseIdentifier:NSStringFromClass([LotteryTypeListCell class])];
    
    // 默认选中tableview第一个
    [self.leftTablew selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    pageview = [[CommonPageViewController alloc] init];
    XLPageViewControllerConfig *config = [XLPageViewControllerConfig defaultConfig];
    //config.titleViewAlignment = XLPageTitleViewAlignmentCenter;
    //config.titleViewHeight = 0;
    config.shadowLineAnimationType = XLPageShadowLineAnimationTypeZoom;
    pageview.config = config;
    [pageview setCurrentWay:ways[waySelectIndex]];
    pageview.curLotteryType = curLotteryType;
    pageview.view.backgroundColor = UIColor.clearColor;
    //pageview.titles = @[@"测试1", @"测试2", @"测试3", @"测试4", @"测试5"];
    [self addChildViewController:pageview];
    [self.contentView addSubview:pageview.view];
    [pageview.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.rightView.mas_bottom);
        make.top.mas_equalTo(self.rightView.mas_top);
        make.left.mas_equalTo(self.rightView.mas_left);
        make.right.mas_equalTo(self.rightView.mas_right);
    }];
}

-(void)reloadData{
    [self.leftTablew reloadData];
}

-(void)setLeftTablewCellSelected:(BOOL)selected withCell:(LotteryWayTableViewCell*)cell
{
//    UILabel * line=(UILabel*)[cell viewWithTag:kCellRightLineTag];
//    if (selected) {
//        line.backgroundColor=cell.backgroundColor;
//        cell.titile.textColor=self.leftSelectColor;
//        cell.backgroundColor=self.leftSelectBgColor;
//    }else{
//        cell.titile.textColor=self.leftUnSelectColor;
//        cell.backgroundColor=self.leftUnSelectBgColor;
//        line.backgroundColor=_leftTablew.separatorColor;
//    }
    //cell.selectedImageView.hidden = !selected;
    //cell.selected = selected;
}

#pragma mark---左边的tablew 代理
#pragma mark--deleagte
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 左侧投注大类数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ways.count;
}

// 初始化左侧Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * Identifier=@"LotteryTypeListCell";
    LotteryTypeListCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[LotteryTypeListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }

    NSDictionary *curWayDict = [ways objectAtIndex:indexPath.row];
    cell.leftLab.text = minstr(curWayDict[@"st"]);

    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * Identifier=@"LotteryWayTableViewCell";
    LotteryWayTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell=[[[XBundle currentXibBundleWithResourceName:@"LotteryWayTableViewCell"] loadNibNamed:@"LotteryWayTableViewCell" owner:self options:nil] lastObject];
    }
    
    //    MultilevelTableViewCell * BeforeCell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:_selectIndex]];
    //
    //    [self setLeftTablewCellSelected:NO withCell:BeforeCell];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelMachineSelection" object:nil];
    waySelectIndex = indexPath.row;
    curOptions = ways[waySelectIndex][@"options"];
    
    [self setLeftTablewCellSelected:YES withCell:cell];
    
    //rightMeun * title=self.allData[indexPath.row];
    if(indexPath.row < self.allData.count) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    
    
    //////////////////////////////////////////////////
    //self.isReturnLastOffset=NO;
    
    
    //    [self.rightCollection.collectionViewLayout invalidateLayout];
    //[self.rightCollection reloadData];
    [pageview setCurrentWay:ways[waySelectIndex]];
    [pageview reloadData];
    
    //    NSIndexSet *reloadSet = [NSIndexSet indexSetWithIndex:indexPath];
    //    [self.rightCollection reloadSections:reloadSet];
    
    if (self.isRecordLastScroll) {
        //        [self.rightCollection scrollRectToVisible:CGRectMake(0, title.offsetScorller - 34, self.rightCollection.frame.size.width, self.rightCollection.frame.size.height) animated:self.isRecordLastScrollAnimated];
        
        //[self.rightCollection setContentOffset:CGPointMake(0, title.offsetScorller) animated:self.isRecordLastScrollAnimated];
    }
    else{
        //[self.rightCollection setContentOffset:CGPointMake(0, 0) animated:self.isRecordLastScrollAnimated];
        //        [self.rightCollection scrollRectToVisible:CGRectMake(0, 0, self.rightCollection.frame.size.width, self.rightCollection.frame.size.height) animated:self.isRecordLastScrollAnimated];
    }
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    LotteryWayTableViewCell * cell=(LotteryWayTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//    cell.titile.textColor=self.leftUnSelectColor;
//    UILabel * line=(UILabel*)[cell viewWithTag:100];
//    line.backgroundColor=tableView.separatorColor;
    
    [self setLeftTablewCellSelected:NO withCell:cell];
    
//    cell.backgroundColor=self.leftUnSelectBgColor;
}


-(void) setBottomSpace:(CGFloat) height{
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.tableBottomSpace.constant = height;
        strongSelf.collectionBottomSpace.constant = height;
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.tableBottomSpace.constant = height;
        strongSelf.collectionBottomSpace.constant = height;
    }];
}

- (NSMutableArray *)getSelectedOptions{
    return [pageview getSelectedOptions];
}

- (void)clearSelectedStatus{
    return [pageview clearSelectedStatus];
}

- (void)randomSelected{
    return [pageview randomSelected];
}

- (NSInteger)getMinZhu{
    return [pageview getMinZhu];
}

- (NSInteger)getMaxZhu{
    return [pageview getMaxZhu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString*)getOptionName {
    if (ways!= nil && ways.count>0 && waySelectIndex<ways.count) {
        NSDictionary *wayCurrent = ways[waySelectIndex];
        if (wayCurrent) {
            NSString *curentOption = wayCurrent[@"name"];
            return curentOption;
        }
    }
    return @"";
}

-(NSString*)getOptionNameSt {
    if (ways!= nil && ways.count>0 && waySelectIndex<ways.count) {
        NSDictionary *wayCurrent = ways[waySelectIndex];
        if (wayCurrent) {
            NSString *curentOption = wayCurrent[@"st"];
            return curentOption;
        }
    }
    return @"";
}
@end
