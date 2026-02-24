//
//  LobbyHistoryAlertController.m
//  phonelive2
//
//  Created by test on 2021/6/25.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LobbyHistoryAlertController.h"
#import "LobbyHistoryCell.h"
#import "LobbyHistoryBottomView.h"
#import "LobbyHistoryStateView.h"
#import "LobbyHistoryTypeView.h"
#import "LobbyHistoryTimeView.h"
#import "BRDatePickerView.h"
@interface LobbyHistoryAlertController ()<UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate>
{
    NSInteger _currentState;
    NSInteger _currentPage;
    NSInteger _currentType;//当前彩种选择类型状态
    NSTimeInterval _currentStartTime;
    NSTimeInterval _currentEndTime;
    BOOL _netFlag; //网络锁
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constainBottom;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UITableView *tb_record;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_topMargin;
@property (weak, nonatomic) IBOutlet UIButton *btn_alltypes;
@property (weak, nonatomic) IBOutlet UIButton *btn_allstates;
@property (weak, nonatomic) IBOutlet UIButton *btn_timeselect;
@property (weak, nonatomic) IBOutlet UILabel *lb_close;
@property (weak, nonatomic) IBOutlet UIButton *btn_close;
@property (weak, nonatomic) IBOutlet UILabel *lb_resultTime;
@property (weak, nonatomic) IBOutlet UIView *v_alert;
@property (weak, nonatomic) IBOutlet UIView *backMaskView;
@property (weak, nonatomic) IBOutlet UIStackView *sk_btns;
@property (weak, nonatomic) IBOutlet UIView *navBackView;
@property (strong, nonatomic) UILabel *lb_alltypes;
@property (strong, nonatomic) UILabel *lb_allstates;
@property (strong, nonatomic) UILabel *lb_timeselect;
@property (strong, nonatomic) LobbyHistoryBottomView *bottomView;
@property (strong, nonatomic) BetListModel *dataModel;
@property (strong, nonatomic) NSArray <BetListDataModel *> *listModel;
@end

@implementation LobbyHistoryAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.lb_close setText:YZMsg(@"public_close")];
    self.lb_title.text = YZMsg(@"LobbyLotteryVC_BetRecord");
    CGFloat lbWidth = _window_width / 3.0 - 26;
    self.lb_alltypes = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, lbWidth, 40)];
    self.lb_alltypes.font = [UIFont systemFontOfSize:14];
    self.lb_alltypes.textColor = [UIColor blackColor];
    self.lb_alltypes.numberOfLines = 2;
    self.lb_alltypes.textAlignment = NSTextAlignmentCenter;
    self.lb_allstates = [[UILabel alloc] initWithFrame:CGRectMake(_window_width / 3.0 + 6, 0, lbWidth, 40)];
    self.lb_allstates.font = [UIFont systemFontOfSize:14];
    self.lb_allstates.numberOfLines = 2;
    self.lb_allstates.textAlignment = NSTextAlignmentCenter;
    self.lb_allstates.textColor = [UIColor blackColor];
    self.lb_timeselect = [[UILabel alloc] initWithFrame:CGRectMake(2 *(_window_width / 3.0) + 6, 0, lbWidth, 40)];
    self.lb_timeselect.font = [UIFont systemFontOfSize:14];
    self.lb_timeselect.numberOfLines = 2;
    self.lb_timeselect.textAlignment = NSTextAlignmentCenter;
    self.lb_timeselect.textColor = [UIColor blackColor];
    self.lb_alltypes.adjustsFontSizeToFitWidth = YES;
    self.lb_alltypes.minimumScaleFactor = 0.5;
    self.lb_allstates.adjustsFontSizeToFitWidth = YES;
    self.lb_allstates.minimumScaleFactor = 0.5;
    self.lb_timeselect.adjustsFontSizeToFitWidth = YES;
    self.lb_timeselect.minimumScaleFactor = 0.5;
    [self.sk_btns addSubview:self.lb_alltypes];
    [self.sk_btns addSubview:self.lb_allstates];
    [self.sk_btns addSubview:self.lb_timeselect];
    self.tb_record.delegate = self;
    self.tb_record.dataSource = self;
    self.bottomView = [[[XBundle currentXibBundleWithResourceName:@"LobbyHistoryBottomView"] loadNibNamed:@"LobbyHistoryBottomView" owner:nil options:nil] lastObject];
    self.constainBottom.constant = 66+ShowDiff;
    self.bottomView.frame = CGRectMake(0, 0, _window_width, 66-ShowDiff);
    _netFlag = YES;
    _currentPage = 1;
    _currentState = -1;
    _currentType = 0;
    NSDate *now = [NSDate date];
    NSDate *zero = [self getZeroTimeWithDate:now];
    NSDate *end = [self getEndTimeWithDate:now];
    _currentStartTime = [zero timeIntervalSince1970];
    _currentEndTime = [end timeIntervalSince1970];
    NSString *formatNow = [NSDate br_getDateString:now format:@"yyyy-MM-dd"];
    self.lb_resultTime.text = [NSString stringWithFormat:@"%@ %@ %@",formatNow,YZMsg(@"lb_resultTime"),formatNow];
    self.listModel = @[];
    [self.tb_record registerNib:[UINib nibWithNibName:@"LobbyHistoryCell" bundle:[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]] forCellReuseIdentifier:@"LobbyHistoryCell"];
    [self requestPageData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickClose:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 判断触摸点是否在特定子视图内
    if (touch.view != self.view) {
        return NO; // 不响应手势
    }
    return YES; // 响应手势
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.navBackView.verticalColors = @[vkColorHex(0xF8C9FE), vkColorHex(0xFDEBFF)];
    self.navBackView.layer.cornerRadius = 10;
    self.navBackView.layer.maskedCorners = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner;
}

- (NSDate *)getZeroTimeWithDate:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond;
    NSDateComponents*zerocompents = [cal components:unitFlags fromDate:date];
    NSLog(@"%@",zerocompents);
    // 转化成0晨0点时间
    zerocompents.hour=0;
    zerocompents.minute=0;
    zerocompents.second=0;
    NSLog(@"%@",zerocompents);
    // NSdatecomponents转NSdate类型
    NSDate*newdate= [cal dateFromComponents:zerocompents];
    return newdate;
}
- (NSDate *)getEndTimeWithDate:(NSDate *)date{
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond;
    NSDateComponents*zerocompents = [cal components:unitFlags fromDate:date];
    NSLog(@"%@",zerocompents);
    // 转化成当天23点59分时间
    zerocompents.hour=23;
    zerocompents.minute=59;
    zerocompents.second=59;
    NSLog(@"%@",zerocompents);
    // NSdatecomponents转NSdate类型
    NSDate*newdate= [cal dateFromComponents:zerocompents];
    return newdate;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.layout_topMargin.constant = _window_height;
    [self.view layoutIfNeeded];
    [self.lb_alltypes setText:YZMsg(@"all_type")];
    [self.lb_allstates setText:YZMsg(@"all_state")];
    [self.lb_timeselect setText:YZMsg(@"time_sel")];

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.layout_topMargin.constant = VK_SCREEN_H - 500;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (@available(iOS 11.0, *)) {
            UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 66-ShowDiff, _window_width, 66+ShowDiff)];
            cover.tag = 1000;
            cover.backgroundColor = [UIColor whiteColor];
            [cover addSubview:strongSelf.bottomView];
            [strongSelf.view addSubview:cover];
        } else {
            // Fallback on earlier versions
        }
    });
    
}
- (void)extracted:(NSString *)postUrl weakSelf:(LobbyHistoryAlertController *const __weak)weakSelf {
    [[YBNetworking sharedManager] postNetworkWithUrl:postUrl withBaseDomian:YES andParameter:@{@"page":@(_currentPage),@"lottery_type":@(_currentType),@"status":@(_currentState),@"start_time":@(_currentStartTime),@"end_time":@(_currentEndTime)} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(code == 0)
        {
            NSLog(@"%@",info);
            strongSelf.dataModel = [BetListModel mj_objectWithKeyValues:info];
            if (strongSelf->_currentPage == 1) {
                strongSelf.listModel = strongSelf.dataModel.list;
            }else{
                NSMutableArray *new_list = strongSelf.listModel.mutableCopy;
                [new_list addObjectsFromArray:strongSelf.dataModel.list];
                strongSelf.listModel = new_list.copy;
            }
            if (strongSelf.dataModel.list.count == 10 && strongSelf.dataModel.page.current.integerValue < strongSelf.dataModel.page.max.integerValue) {
                strongSelf->_currentPage = strongSelf.dataModel.page.current.integerValue + 1;
                strongSelf->_netFlag = YES;
            }else{
                strongSelf->_netFlag = NO;
            }
            strongSelf.bottomView.model = strongSelf.dataModel.total;
            [strongSelf.tb_record reloadData];
        }else{
            
        }
        
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        NSLog(@"%@",error);
    }];
}
//清理重置页面参数
- (void)clearParam{
    _currentPage = 1;
    _netFlag = YES;
    self.listModel = @[];
}
- (void)requestPageData{
    NSString *postUrl = [NSString stringWithFormat:@"Lottery.betList2"];
    if (!_netFlag) {
        return;
    }
    _netFlag = NO;
    WeakSelf
    [self extracted:postUrl weakSelf:weakSelf];
}
- (IBAction)didClickAllType:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        self.btn_allstates.selected = NO;
        self.btn_timeselect.selected = NO;
        //选择类型
        LobbyHistoryTypeView *alert = [LobbyHistoryTypeView instanceStateAlertWithSate:_currentType andInfoData:self.dataModel.lotterysInfo];
        __weak LobbyHistoryAlertController *weakSelf = self;
        alert.completeHandler = ^(UIButton *btn) {
            __strong LobbyHistoryAlertController *strongSelf = weakSelf;
            strongSelf->_currentType = btn.tag - 1000;
            [strongSelf.lb_alltypes setText:btn.titleLabel.text];
            [strongSelf clearParam];
            [strongSelf requestPageData];
        };
        alert.cancelHandler = ^{
            sender.selected = NO;
        };
        [alert alertShowAnimationWithSuperView:self.view];
    }
}

- (IBAction)didClickAllStatus:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        self.btn_alltypes.selected = NO;
        self.btn_timeselect.selected = NO;
        //选择状态
        LobbyHistoryStateView *alert = [LobbyHistoryStateView instanceStateAlertWithSate:_currentState andInfoData:self.dataModel.statusInfo];
        __weak LobbyHistoryAlertController *weakSelf = self;
        alert.completeHandler = ^(UIButton *btn) {
            __strong LobbyHistoryAlertController *strongSelf = weakSelf;
            strongSelf->_currentState = btn.tag - 100;
            [strongSelf.lb_allstates setText:btn.titleLabel.text];
            [strongSelf clearParam];
            [strongSelf requestPageData];
        };
        alert.cancelHandler = ^{
            sender.selected = NO;
        };
        [alert alertShowAnimationWithSuperView:self.view];
    }
}
- (IBAction)didClickTimeSelect:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        self.btn_alltypes.selected = NO;
        self.btn_allstates.selected = NO;
        //选择时间
        NSDate *start = [NSDate date];
        if ( _currentStartTime) {
            start = [NSDate dateWithTimeIntervalSince1970: _currentStartTime];
        }
        NSDate *end = [NSDate date];
        if ( _currentEndTime) {
            end = [NSDate dateWithTimeIntervalSince1970: _currentEndTime];
        }
        WeakSelf
        LobbyHistoryTimeView *alert = [LobbyHistoryTimeView instanceStateAlertWithStartTime:start andEndTime:end];
        alert.completeHandler = ^(NSDate * _Nonnull startDate, NSString * _Nonnull startValue, NSDate * _Nonnull endDate, NSString * _Nonnull endValue) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            NSDate *start = [strongSelf getZeroTimeWithDate:startDate];
            NSDate *end = [strongSelf getEndTimeWithDate:endDate];
            NSTimeInterval begin = [start timeIntervalSince1970];
            NSTimeInterval finish = [end timeIntervalSince1970];
            if (begin > finish) {
                [MBProgressHUD showError:YZMsg(@"TimeSelect_tipError")];
                return;
            }
            strongSelf->_currentStartTime = begin;
            strongSelf->_currentEndTime = finish;
            strongSelf.lb_resultTime.text = [NSString stringWithFormat:@"%@ %@ %@",startValue,YZMsg(@"lb_resultTime"),endValue];
            [strongSelf clearParam];
            [strongSelf requestPageData];
        };
        alert.cancelHandler = ^{
            sender.selected = NO;
        };
        [alert alertShowAnimationWithSuperView:self.view];
    }
}
- (IBAction)didClickRefresh:(UIButton *)sender {
    
}
- (IBAction)didClickClose:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        self.layout_topMargin.constant = _window_height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (strongSelf.closeCallback) {
            strongSelf.closeCallback();
        }
        if (@available(iOS 11.0, *)) {
            UIView *cover = [strongSelf.view viewWithTag:1000];
            if (cover) {
                [cover removeFromSuperview];
            }
        } else {
            // Fallback on earlier versions
        }
    });
}

#pragma mark - UITableView delegate datasource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listModel.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LobbyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LobbyHistoryCell"];
    if (self.listModel.count > indexPath.row) {
        cell.model = self.listModel[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.listModel.count - 2) {
        if (_netFlag) {
            [self requestPageData];
        }
    }
}
@end
